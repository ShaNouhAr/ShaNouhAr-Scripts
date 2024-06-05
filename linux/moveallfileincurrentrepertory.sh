#!/bin/bash

read -p "Cela déplacera tous les fichiers de tous les sous-dossiers dans le répertoire courant. Continuer? (o/n): " confirm

if [[ $confirm == "o" ]]; then
  find . -type f -exec mv -t . {} \;
  echo "Tous les fichiers ont été déplacés dans le répertoire courant."
else
  echo "Opération annulée."
  exit 1
fi

read -p "Voulez-vous supprimer tous les fichiers .nfo? (o/n): " delete_nfo

if [[ $delete_nfo == "o" ]]; then
  find . -type f -name "*.nfo" -exec rm -f {} \;
  echo "Tous les fichiers .nfo ont été supprimés."
else
  echo "Les fichiers .nfo n'ont pas été supprimés."
fi
