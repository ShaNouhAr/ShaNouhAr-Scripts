#!/bin/bash

# Détecter si le système d'exploitation est Debian ou Ubuntu
OS_NAME=$(. /etc/os-release && echo "$ID")

# Ajouter la clé GPG officielle de Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/${OS_NAME}/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Ajouter le dépôt Docker aux sources APT
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${OS_NAME} \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Mettre à jour la liste des paquets après l'ajout du dépôt Docker
sudo apt-get update

# Installer Docker Engine, Docker CLI, et des plugins additionnels
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Installation de Docker terminée sur ${OS_NAME}."
