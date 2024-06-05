#!/bin/bash

# Demander le chemin du script à exécuter
echo "Veuillez entrer le chemin complet vers le script que vous souhaitez exécuter :"
read scriptPath

# Vérifier que le script existe et est exécutable
if [ ! -f "$scriptPath" ] || [ ! -x "$scriptPath" ]; then
  echo "Erreur : Le fichier $scriptPath n'existe pas, n'est pas un fichier régulier, ou n'est pas exécutable."
  exit 1
fi

# Déclarer un tableau pour stocker les chemins des répertoires
directories=()

# Boucle pour demander les répertoires
while true; do
  echo "Veuillez entrer le chemin complet vers un répertoire où vous souhaitez exécuter le script (ou 'q' pour quitter) :"
  read directory

  # Sortir de la boucle si l'utilisateur entre 'q'
  if [ "$directory" == "q" ]; then
    break
  fi

  # Vérifier que le répertoire existe
  if [ -d "$directory" ]; then
    directories+=("$directory") # Ajouter le chemin du répertoire au tableau
  else
    echo "Erreur : Répertoire $directory non trouvé."
  fi
done

# Exécuter le script dans chaque répertoire
for directory in "${directories[@]}"; do
  echo "Exécution du script $scriptPath dans $directory..."
  (cd "$directory" && "$scriptPath")
  echo "Le script a été exécuté dans $directory."
done

echo "Fin de l'exécution du script."
