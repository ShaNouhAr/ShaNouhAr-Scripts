import os
import getpass
import http.client
import json
import platform
import logging
from cryptography.fernet import Fernet
from datetime import datetime
import time

# Chemins des fichiers de configuration
key_path = 'key.key'
config_path = 'config.enc'
log_dir = 'logs'

# Créer le dossier de logs s'il n'existe pas
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

# Configurer le logger pour enregistrer les messages de journalisation dans un fichier
log_filename = datetime.now().strftime("%Y-%m-%d_%H-%M-%S") + '_log.txt'
log_file = os.path.join(log_dir, log_filename)
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s',
                    handlers=[logging.FileHandler(log_file), logging.StreamHandler()])

def generate_key():
    """Générer et sauvegarder une clé de chiffrement."""
    key = Fernet.generate_key()
    with open(key_path, 'wb') as key_file:
        key_file.write(key)
    return key

def load_or_create_key():
    """Charger ou créer une nouvelle clé de chiffrement."""
    if os.path.exists(key_path):
        with open(key_path, 'rb') as key_file:
            key = key_file.read()
    else:
        key = generate_key()
    return key

def encrypt_data(data, cipher_suite):
    """Chiffrer des données avec la suite de chiffrement fournie."""
    return cipher_suite.encrypt(data.encode())

def decrypt_data(encrypted_data, cipher_suite):
    """Déchiffrer des données avec la suite de chiffrement fournie."""
    return cipher_suite.decrypt(encrypted_data).decode()

def save_credentials(email, password, cipher_suite):
    """Chiffrer et sauvegarder les identifiants."""
    encrypted_email = encrypt_data(email, cipher_suite)
    encrypted_password = encrypt_data(password, cipher_suite)
    with open(config_path, 'wb') as f:
        f.write(encrypted_email + b'\n' + encrypted_password)

def load_credentials(cipher_suite):
    """Charger et déchiffrer les identifiants."""
    with open(config_path, 'rb') as f:
        encrypted_email, encrypted_password = [line.strip() for line in f.readlines()]
    email = decrypt_data(encrypted_email, cipher_suite)
    password = decrypt_data(encrypted_password, cipher_suite)
    return email, password

def request_user_credentials():
    """Demander à l'utilisateur ses identifiants."""
    email = input("Enter your email: ")
    password = getpass.getpass("Enter your password: ")
    return email, password
    
def clean_old_logs(directory, keep=7):
    """Supprimer les fichiers de log les plus anciens, ne garder que les 'keep' derniers."""
    # Obtenir tous les fichiers de log dans le répertoire
    files = [os.path.join(directory, f) for f in os.listdir(directory)]
    # Filtrer les fichiers et obtenir leurs chemins complets
    files = [f for f in files if os.path.isfile(f) and f.endswith('.txt')]
    # Trier les fichiers par date de modification (du plus récent au plus ancien)
    files.sort(key=lambda x: os.path.getmtime(x), reverse=True)
    # Supprimer les fichiers excédentaires
    for f in files[keep:]:
        os.remove(f)
        logging.info(f"Supprimé fichier de log ancien : {f}")

def main():
    # Charger ou créer la clé de chiffrement
    key = load_or_create_key()
    cipher_suite = Fernet(key)

    # Charger les identifiants ou demander à l'utilisateur
    if os.path.exists(config_path):
        email, password = load_credentials(cipher_suite)
    else:
        email, password = request_user_credentials()
        save_credentials(email, password, cipher_suite)

    host = "cp.ultra.cc"
    user_agent = f"insomnia/8.6.1"
    conn = http.client.HTTPSConnection(host)

    def extract_cookies(headers):
        csrf_token = ''
        session_id = ''
        cookies = headers.get_all('Set-Cookie')
        if cookies:
            for cookie in cookies:
                if 'csrftoken' in cookie:
                    csrf_token = cookie.split('csrftoken=')[1].split(';')[0]
                if 'sessionid' in cookie:
                    session_id = cookie.split('sessionid=')[1].split(';')[0]
        return csrf_token, session_id

    def send_request(method, url, headers, payload=""):
        conn.request(method, url, body=payload, headers=headers)
        response = conn.getresponse()
        data = response.read()
        return response, data.decode("utf-8")

    # Login request
    login_payload = json.dumps({"username": email, "password": password})
    login_headers = {'Content-Type': "application/json", 'User-Agent': user_agent}
    logging.info("Sending login request...")
    response, response_data = send_request("POST", "/api/rest-auth/login/?=", login_headers, login_payload)

    csrf_token, session_id = extract_cookies(response.headers)
    logging.info("Extracted CSRF Token: %s", csrf_token)
    logging.info("Extracted Session ID: %s", session_id)

    if not csrf_token or not session_id:
        logging.error("Failed to extract CSRF token or Session ID.")
        conn.close()
        exit()

    cookie_header = f"csrftoken={csrf_token}; sessionid={session_id}"
    with open('services.conf', 'r') as file:
        services = [line.strip() for line in file if line.strip() and not line.startswith('#')]


    # GET request for "/api/user-service/"
    get_headers = {
        'cookie': cookie_header,
        'User-Agent': user_agent,
        'x-csrftoken': csrf_token,
        'Referer': f"https://{host}/"
    }

    response, get_data = send_request("GET", "/api/user-service/", get_headers)
    get_response = json.loads(get_data)

    # Extract IDs from the response
    ids = []
    for service in get_response.get('results', []):
        ids.append(service.get('id'))

    logging.info("GET request for /api/user-service/ returned the following IDs: %s", ids)



    for service in services:
        upgrade_payload = json.dumps({"action": "upgrade", "application": service, "data": {}})
        upgrade_headers = {
            'cookie': cookie_header,
            'Content-Type': "application/json",
            'User-Agent': user_agent,
            'x-csrftoken': csrf_token,
            'Referer': f"https://{host}/"
        }
        logging.info("Sending application upgrade request for %s...", service)


        for service_id in ids:
            response, response_data = send_request("POST", f"/api/service/{service_id}/apps/", upgrade_headers, upgrade_payload)
            response_data = json.loads(response_data)  # Convert to dictionary

            if response_data.get('status') == 'success':
                logging.info("%s has been successfully updated!", service)
            else:
                logging.error("Failed to update %s: %s", service, response_data.get('message'))

    conn.close()

if __name__ == "__main__":
# Nettoyer les logs après les opérations de journalisation
    clean_old_logs(log_dir, 7)
    main()
    




# Created by: Zgabi && ShaNouhAr