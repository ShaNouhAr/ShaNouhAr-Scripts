#!/bin/bash

# Générer la liste des dossiers contenant docker-compose.yml
mapfile -t options < <(find . -maxdepth 2 -name 'docker-compose.yml' -exec dirname {} \; | sed 's|^\./||' | sort)

# Vérifier si des options sont disponibles
if [ ${#options[@]} -eq 0 ]; then
    echo "Aucun fichier docker-compose.yml trouvé dans le répertoire courant ou ses sous-dossiers."
    exit 1
fi

# Préparer les options pour whiptail
whiptail_options=()
for option in "${options[@]}"; do
    whiptail_options+=("$option" "" OFF)
done

# Afficher le menu de sélection
selected=$(whiptail --title "Sélectionnez les dossiers" --checklist \
"Choisissez les dossiers contenant les docker-compose.yml à exécuter:" 20 78 10 \
"${whiptail_options[@]}" 3>&1 1>&2 2>&3)

# Sortir si l'utilisateur annule
if [ $? -ne 0 ]; then
    exit 1
fi

# Exécuter docker-compose up dans chaque dossier sélectionné
for folder in $selected; do
    # Supprimer les guillemets ajoutés par whiptail
    folder="${folder%\"}"
    folder="${folder#\"}"
    
    echo "Exécution de docker-compose up -d dans le dossier : $folder"
    (cd "$folder" && docker-compose up -d)
done
