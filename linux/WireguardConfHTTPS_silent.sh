#!/bin/bash
apt-get install jq -y > /dev/null 2>&1
apt-get install sshpass -y > /dev/null 2>&1
API_KEY=$1
NBCONF=$2

# Vérifier si la variable API_KEY est vide
if [ -z "$API_KEY" ]; then
    echo "Entrez votre API KEY :" && read API_KEY
else
    echo "API KEY pris en compte"
fi

# Configuration des couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Pas de couleur

echo -e "${GREEN}Debut de la configuration du serveur Linode...${NC}"

# Générer un suffixe aléatoire pour le label du serveur
RANDOM_SUFFIX=$(date +%s | sha256sum | base64 | head -c 8)

# Génération d'un mot de passe aléatoire sécurisé (12 caractères minimum)
SERVER_PASSWORD=$(openssl rand -base64 18 | tr -d /=+ | cut -c -18)

# Configuration de base avec suffixe aléatoire ajouté au label
LABEL="debian-server-$RANDOM_SUFFIX"
REGION="fr-par"
PLAN="g6-nanode-1"
IMAGE="linode/debian11"

echo -e "Label du serveur : ${GREEN}$LABEL${NC}"

# Création du serveur Linode
create_linode() {
  response=$(curl -s -H "Content-Type: application/json" \
       -H "Authorization: Bearer $API_KEY" \
       -X POST -d '{
         "label": "'$LABEL'",
         "region": "'$REGION'",
         "type": "'$PLAN'",
         "image": "'$IMAGE'",
         "root_pass": "'$SERVER_PASSWORD'"
       }' \
       https://api.linode.com/v4/linode/instances)
  echo "$response"
}

# Exécution de la création du serveur et récupération de son ID
response=$(create_linode)
SERVER_ID=$(echo "$response" | jq -r '.id')
SERVER_IP=$(echo "$response" | jq -r '.ipv4[0]')

# Vérification si l'ID du serveur est récupéré
if [ -z "$SERVER_ID" ] || [ "$SERVER_ID" == "null" ]; then
    echo -e "${RED}Erreur : L'ID du serveur n'a pas été récupéré correctement. Réponse : $response${NC}"
    exit 1
fi
echo -e "ID du serveur créé : ${GREEN}$SERVER_ID${NC}"

# Attente pour l'attribution de l'adresse IP
echo "Attente pour l'attribution de l'adresse IP..."
for i in {1..10}; do
    if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" == "null" ]; then
        sleep 10
        SERVER_IP=$(curl -s -H "Authorization: Bearer $API_KEY" "https://api.linode.com/v4/linode/instances/$SERVER_ID" | jq -r '.ipv4[0]')
    else
        break
    fi
    echo -n "."
done

if [ -z "$SERVER_IP" ] || [ "$SERVER_IP" == "null" ]; then
    echo -e "${RED}Erreur : Impossible de récupérer l'adresse IP du serveur.${NC}"
    exit 1
fi

echo -e "Adresse IPv4 du serveur : ${GREEN}$SERVER_IP${NC}"

# Vérification de la disponibilité du serveur via ping
echo "Vérification de la disponibilité du serveur (cela peut prendre quelques minutes)..."
while true; do
    ping -c 1 $SERVER_IP > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Le serveur est en ligne !${NC}"
        break
    else
        echo -n "."
        sleep 5
    fi
done
sleep 5

# Connexion SSH et installation de WireGuard
sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP 'bash -s' << 'EOF'
apt-get update > /dev/null 2>&1
apt-get install wireguard qrencode -y > /dev/null 2>&1
wget -O wireguard.sh https://get.vpnsetup.net/wg > /dev/null 2>&1
chmod +x wireguard.sh
./wireguard.sh --auto > /dev/null 2>&1

for (( i=1; i<=$NBCONF; i++ )); do
    echo "Ajout de la configuration client $i"
    ./wireguard.sh add-client client$i > /dev/null 2>&1
done

apt-get install apache2 -y > /dev/null 2>&1
apt-get install php -y > /dev/null 2>&1
apt-get install git -y > /dev/null 2>&1

# Configuration SSL pour Apache
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj "/C=US/ST=YourState/L=YourCity/O=YourOrganization/OU=YourDepartment/CN=$SERVER_IP" > /dev/null 2>&1

# Configuration Apache pour servir WireGuard
cat > /etc/apache2/sites-available/wireguard.conf << 'APACHE_CONF'
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

    <Directory "/var/www/html">
        Options +Indexes +FollowSymLinks +MultiViews
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
APACHE_CONF

a2enmod ssl > /dev/null 2>&1
a2ensite wireguard.conf > /dev/null 2>&1
systemctl reload apache2 > /dev/null 2>&1

# Nettoyage et configuration finale
rm /var/www/html/index.html
git clone https://github.com/zgabi10103710/GUI-Directory.git /var/www/html/ > /dev/null 2>&1
cp client*.conf /var/www/html/Script/ > /dev/null 2>&1
chmod 777 /var/www/html/Script /var/www/html/Script/client*.conf

echo "${GREEN}Installation et configuration terminées.${NC}"
EOF

echo -e "${GREEN}Informations de connexion :${NC}"
echo -e "Adresse IP : ${GREEN}$SERVER_IP${NC}"
echo -e "Mot de passe : ${GREEN}$SERVER_PASSWORD${NC}"



# Demander à l utilisateur s'il souhaite se reconnecter au serveur
echo -e "${GREEN}Voulez-vous vous reconnecter au serveur ? (y/n)${NC}"
read -t 5 -p "Appuyez sur 'y' pour se connecter, ou attendez 5 secondes pour quitter. " user_choice

if [[ "$user_choice" == "y" ]]; then
    echo "Connexion au serveur..."
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP
else
    echo "Fin du script."
fi
