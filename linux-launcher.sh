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

# Fonction pour afficher le contenu d'un dossier
show_directory_content() {
    ITEMS=$(get_github_content "$1")
    COUNTER=1
    echo -e "${COLOR_YELLOW}0. .. (Revenir en arrière)${COLOR_RESET}"
    echo "$ITEMS" | jq -r '.[] | "\(.type) \(.name) \(.path) \(.url)"' | while read -r TYPE NAME PATH URL; do
        if [ "$TYPE" == "dir" ]; then
            echo -e "${COLOR_CYAN}$COUNTER. $NAME (Dossier)${COLOR_RESET}"
        else
            echo -e "${COLOR_GREEN}$COUNTER. $NAME (Fichier)${COLOR_RESET}"
        fi
        COUNTER=$((COUNTER + 1))
    done
}

# Fonction pour exécuter un script localement
execute_script() {
    SCRIPT_URL=$1
    FILE_NAME=$2
    TEMP_SCRIPT_PATH="/tmp/$FILE_NAME"
    curl -s -L -o "$TEMP_SCRIPT_PATH" "$SCRIPT_URL"
    chmod +x "$TEMP_SCRIPT_PATH"

    EXTENSION="${FILE_NAME##*.}"

    case "$EXTENSION" in
        sh)
            bash "$TEMP_SCRIPT_PATH"
            ;;
        py)
            python3 "$TEMP_SCRIPT_PATH"
            ;;
        *)
            echo -e "${COLOR_RED}Type de fichier non supporté: $EXTENSION${COLOR_RESET}"
            ;;
    esac
}

# Boucle principale de navigation
while [ "$EXIT" = false ]; do
    clear
    echo -e "${COLOR_RED}=============================================="
    echo -e "                 ShaNouhAr-Scripts             "
    echo -e "==============================================${COLOR_RESET}"

    CONTENT=$(get_github_content "$CURRENT_URL")
    show_directory_content "$CURRENT_URL"

    read -p "Entrez un numéro pour naviguer ou exécuter un script, ou 'exit' pour quitter: " INPUT

    if [ "$INPUT" == "exit" ]; then
        EXIT=true
    elif [[ -n "$INPUT" && "$INPUT" =~ ^[0-9]+$ ]]; then
        if [ "$INPUT" -eq 0 ]; then
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
            SELECTED_PATH=$(echo "$SELECTED_ITEM" | jq -r '.path')
            SELECTED_URL=$(echo "$SELECTED_ITEM" | jq -r '.url')

            if [ "$SELECTED_TYPE" == "dir" ]; then
                PARENT_URLS+=("$CURRENT_URL")
                CURRENT_URL="$BASE_API_URL/$SELECTED_PATH"
            elif [ "$SELECTED_TYPE" == "file" ]; then
                RAW_URL=$(echo "$SELECTED_URL" | sed 's|https://api.github.com/repos/|https://raw.githubusercontent.com/|; s|/contents/|/master/|')
                execute_script "$RAW_URL" "$SELECTED_NAME"
            else
                echo -e "${COLOR_RED}Veuillez sélectionner un numéro valide.${COLOR_RESET}"
                sleep 2
            fi
        fi
    else
        echo -e "${COLOR_RED}Veuillez entrer un numéro valide.${COLOR_RESET}"
        sleep 2
    fi
done
