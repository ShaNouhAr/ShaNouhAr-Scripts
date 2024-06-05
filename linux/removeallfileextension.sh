#!/bin/bash

# Demande à l'utilisateur de saisir le chemin du dossier
read -p "Veuillez saisir le chemin du dossier : " dossier

# Vérifie si le dossier existe
if [ ! -d "$dossier" ]; then
  echo "Le dossier spécifié n'existe pas."
  exit 1
fi

# Demande à lutilisateur de saisir l'extension des fichiers à supprimer
read -p "Veuillez saisir l'extension des fichiers à supprimer (sans le point) : " extension

# Se déplace dans le dossier spécifié
cd "$dossier" || exit

# Supprime les fichiers avec l'extension spécifiée
find . -type f -name "*.$extension" -delete

echo "Suppression terminée."
