#!/bin/bash

echo "Attention : tous les espaces dans les noms des fichiers seront supprimés dans le répertoire actuel."
read -p "Appuyez sur Enter pour continuer ou Ctrl+C pour quitter..."

# Supprimer les espaces des noms de fichiers
for file in *\ *; do
  mv "$file" "${file// /}"
done

echo "Liste des fichiers dans le répertoire actuel (sans espaces):"
ls
echo

read -p "Veuillez entrer le nom de la série (e.g., 'Breaking Bad'): " seriesName
read -p "Veuillez entrer le numéro de saison (e.g., 1): " seasonNumber
read -p "Veuillez entrer l'extension du fichier (e.g., 'mkv'): " fileExtension
read -p "Veuillez entrer le préfixe de modèle (e.g., 'BreakingBad-'): " prefixPattern

echo "Renommage des fichiers..."

for file in *.$fileExtension; do
  # Utiliser une expression régulière pour extraire le numéro de l'épisode
  regexPattern="$prefixPattern([0-9]+)"
  if [[ $file =~ $regexPattern ]]; then
    episodeNumber="${BASH_REMATCH[1]}"
    # Conversion explicite en décimal
    episodeNumber=$((10#$episodeNumber))
    # Formatage du nouveau nom
    newName="$seriesName - S$(printf "%02d" $seasonNumber)E$(printf "%02d" $episodeNumber).$fileExtension"
    # Renommer le fichier
    echo "Renommer l'épisode $file en $newName"
    mv "$file" "$newName"
  else
    echo "Le fichier $file ne correspond pas au modèle donné."
  fi
done

echo "Renommage terminé."
echo "Liste des fichiers après renommage:"
ls *.$fileExtension
