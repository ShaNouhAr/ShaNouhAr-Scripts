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
read -p "Veuillez entrer le numéro de saison (laissez vide si aucun): " seasonNumber
read -p "Veuillez entrer l'extension du fichier (e.g., 'mkv'): " fileExtension
read -p "Veuillez entrer le préfixe de modèle (e.g., 'BreakingBad-'): " prefixPattern
read -p "Est-ce une série 'dis longue' où le numéro de l'épisode doit recommencer à 1 pour chaque saison? (o/n): " isLongSeries

# Si c'est une série "dis longue", trouvez le numéro d'épisode le plus petit
offset=0
if [[ $isLongSeries == "o" ]]; then
  for file in *.$fileExtension; do
    regexPattern="$prefixPattern([0-9]+)"
    if [[ $file =~ $regexPattern ]]; then
      episodeNumber="${BASH_REMATCH[1]}"
      # Conversion explicite en décimal
      episodeNumber=$((10#$episodeNumber))
      # Mettez à jour l'offset si le numéro de l'épisode est plus petit que l'offset actuel
      if [[ $offset -eq 0 || $episodeNumber -lt $offset ]]; then
        offset=$episodeNumber
      fi
    fi
  done
  # Soustrayez 1 de l'offset pour faire recommencer à 1
  offset=$((offset - 1))
fi

echo "Renommage des fichiers..."

for file in *.$fileExtension; do
  # Utiliser une expression régulière pour extraire le numéro de l'épisode
  regexPattern="$prefixPattern([0-9]+)"
  if [[ $file =~ $regexPattern ]]; then
    episodeNumber="${BASH_REMATCH[1]}"
    # Conversion explicite en décimal
    episodeNumber=$((10#$episodeNumber - offset))
    # Formatage du nouveau nom
    if [[ -z $seasonNumber ]]; then
      newName="$seriesName - E$(printf "%02d" $episodeNumber).$fileExtension"
    else
      newName="$seriesName - S$(printf "%02d" $seasonNumber)E$(printf "%02d" $episodeNumber).$fileExtension"
    fi
    # Renommer le fichier
    echo "Renommer l'épisode $file en $newName"
    mv "$file" "$newName"
  else
    echo "Le fichier $file ne correspond pas au modèle donné."
  fi
done
