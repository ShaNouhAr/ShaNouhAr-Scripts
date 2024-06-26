#!/bin/bash
apt install sshpass -y
# Votre clé API Linode
API_KEY="0302993f7272b075b49b2aed1ac900a622680d0da3983db9fcd7786b501e6a83"

#!/bin/bash

# Configuration des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Pas de couleur

echo -e "${GREEN}Début de la configuration du serveur Linode...${NC}"

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

# Attente pour que l'adresse IP soit attribuée
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

# Affichage des informations de connexion
echo -e "${GREEN}Informations de connexion :${NC}"
echo -e "Adresse IP : ${GREEN}$SERVER_IP${NC}"
echo -e "Mot de passe : ${GREEN}$SERVER_PASSWORD${NC}"

# Connexion SSH et installation de WireGuard
echo "Connexion au serveur pour installer WireGuard..."
sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP << 'EOF'
wget -O wireguard.sh https://get.vpnsetup.net/wg
chmod +x wireguard.sh
sudo bash wireguard.sh --auto
EOF
# Demander à l'utilisateur s'il souhaite se reconnecter au serveur
echo -e "${GREEN}Voulez-vous vous reconnecter au serveur ? (y/n)${NC}"
read -t 10 -p "Appuyez sur 'y' pour se connecter, autre touche pour quitter : " user_choice

if [[ "$user_choice" == "y" ]]; then
    echo "Connexion au serveur..."
    sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no root@$SERVER_IP
else
    echo "Fin du script."
fi
