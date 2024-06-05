#!/bin/bash

# Mise à jour des paquets
echo "Mise à jour des paquets..."
sudo apt update -y

# Installation d'Apache2
echo "Installation d'Apache2..."
sudo apt install apache2 -y

# Activation et démarrage du service Apache2
echo "Activation et démarrage du service Apache2..."
sudo systemctl enable apache2
sudo systemctl start apache2

echo "Installation terminée. Apache2 est installé et en cours d'exécution."
