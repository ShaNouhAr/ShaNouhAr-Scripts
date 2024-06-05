#!/bin/bash

# Définir les variables
REPO_OWNER="ShaNouhAr"
REPO_NAME="ShaNouhAr-Scripts"
BASE_API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents"
CURRENT_URL="$BASE_API_URL/linux"
PARENT_URLS=()
EXIT=false

# Couleurs
COLOR_RESET="\e[0m"
COLOR_GREEN="\e[32m"
COLOR_YELLOW="\e[33m"
COLOR_CYAN="\e[36m"
COLOR_RED="\e[31m"

# Fonction pour obtenir le contenu d'un dossier depuis l'API GitHub
get_github_content() {
    curl -s -H "User-Agent: shell-script" "$1"
}

# Fonction pour afficher la liste des scripts disponibles
show_directory_content() {
    ITEMS=$(get_github_content "$1")
    COUNTER=1
    echo -e "${COLOR_YELLOW}0. .. (Revenir en arrière)${COLOR_RESET}"
    echo "$ITEMS" | jq -r '.[] | "\(.type) \(.name)"' | while read -r TYPE NAME; do
        if [ "$TYPE" == "dir" ]; then
            echo -e "${COLOR_CYAN}$COUNTER. $NAME (Dossier)${COLOR_RESET}"
        else
            echo -e "${COLOR_GREEN}$COUNTER. $NAME (Fichier)${COLOR_RESET}"
        fi
        COUNTER=$((COUNTER + 1))
    done
}

# Fonction pour exécuter un script
execute_script() {
    SCRIPT_URL="$1"
    FILE_NAME=$(basename "$2")
    TEMP_SCRIPT_PATH="/tmp/$FILE_NAME"
    curl -s -L -o "$TEMP_SCRIPT_PATH" "$SCRIPT_URL"
    chmod +x "$TEMP_SCRIPT_PATH"
    bash "$TEMP_SCRIPT_PATH"
}

# Boucle principale de navigation
while [ "$EXIT" = false ]; do
    clear
    echo -e "${COLOR_RED}=============================================="
    echo -e "                 ShaNouhAr-Scripts             "
    echo -e "==============================================${COLOR_RESET}"
    CONTENT=$(get_github_content "$CURRENT_URL")
    show_directory_content "$CURRENT_URL"
    read -p "Entrez le numéro du script à exécuter ou 'exit' pour quitter: " INPUT
    if [ "$INPUT" == "exit" ]; then
        EXIT=true
    elif [ "$INPUT" -eq 0 ]; then
        if [ ${#PARENT_URLS[@]} -gt 0 ]; then
            CURRENT_URL=${PARENT_URLS[-1]}
            PARENT_URLS=("${PARENT_URLS[@]:0:${#PARENT_URLS[@]}-1}")
        else
            echo -e "${COLOR_RED}Vous êtes déjà à la racine.${COLOR_RESET}"
            sleep 2
        fi
    else
        SELECTED_ITEM=$(echo "$CONTENT" | jq -r ".[$((INPUT-1))]")
        SELECTED_TYPE=$(echo "$SELECTED_ITEM" | jq -r '.type')
        SELECTED_NAME=$(echo "$SELECTED_ITEM" | jq -r '.name')
        SELECTED_URL=$(echo "$SELECTED_ITEM" | jq -r '.url')
        if [ "$SELECTED_TYPE" == "dir" ]; then
            PARENT_URLS+=("$CURRENT_URL")
            CURRENT_URL="$SELECTED_URL"
        elif [ "$SELECTED_TYPE" == "file" ]; then
            RAW_URL=$(echo "$SELECTED_URL" | sed 's|https://api.github.com/repos/|https://raw.githubusercontent.com/|; s|/contents/|/master/|')
            execute_script "$RAW_URL" "$SELECTED_NAME"
        else
            echo -e "${COLOR_RED}Veuillez sélectionner un numéro valide.${COLOR_RESET}"
            sleep 2
        fi
    fi
done
