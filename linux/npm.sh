#!/bin/bash

# Fonction pour installer Docker et Docker Compose pour Debian/Ubuntu
install_docker_debian_ubuntu() {
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/${1}/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${1} $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}

# Fonction pour installer Docker et Docker Compose pour Kali
install_docker_kali() {
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
}

# Installation de Docker Compose (commun pour toutes les distributions)
install_docker_compose() {
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version
}

# Installation de Nginx Proxy Manager
install_nginx_proxy_manager() {
    # Création d'un répertoire pour Nginx Proxy Manager
    mkdir -p $HOME/nginx-proxy-manager
    cd $HOME/nginx-proxy-manager
    # Création d'un fichier docker-compose.yml pour Nginx Proxy Manager
    cat >docker-compose.yml <<EOL
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    environment:
      DB_SQLITE_FILE: "/data/database.sqlite"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOL

    # Démarrage de Nginx Proxy Manager
    docker-compose up -d
}

# Vérification du groupe Docker et ajout de l'utilisateur
setup_docker_group() {
    if ! getent group docker > /dev/null; then
        sudo groupadd docker
    fi
    sudo usermod -aG docker $USER
}

# Détection de la distribution et exécution des commandes appropriées
OS_ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')

case $OS_ID in
    "ubuntu"|"debian")
        install_docker_debian_ubuntu $OS_ID
        ;;
    "kali")
        install_docker_kali
        ;;
    *)
        echo "Votre distribution ($OS_ID) n'est pas prise en charge par ce script."
        exit 1
        ;;
esac

install_docker_compose
setup_docker_group
install_nginx_proxy_manager

echo "Nginx Proxy Manager installé et en cours d'exécution."
echo "Accédez à l'interface de gestion via http://<votre-ip>:81"
echo "Utilisateur par défaut : admin@example.com Mot de passe : changeme"
