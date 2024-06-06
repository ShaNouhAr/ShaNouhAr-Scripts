#!/bin/bash

REPO_OWNER="ShaNouhAr"
REPO_NAME="ShaNouhAr-Scripts"
BASE_API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/contents"

function get_github_content() {
    local url=$1
    curl -s -H "User-Agent: Bash" $url
}

function show_directory_content() {
    local url=$1
    get_github_content $url | jq -r '.[] | "\(.type)\t\(.name)\t\(.path)\t\(.url)"'
}

function execute_script() {
    local script_url=$1
    local file_path=$2
    local temp_script_path="/tmp/$file_path"

    curl -s -H "User-Agent: Bash" $script_url -o $temp_script_path

    case "$temp_script_path" in
        *.sh)
            chmod +x $temp_script_path
            bash "$temp_script_path"
            ;;
        *.py)
            python3 "$temp_script_path"
            ;;
        *)
            echo "Unsupported file type."
            ;;
    esac
}

function show_interface() {
    local content=$1
    local counter=1

    echo "0. .. (Revenir en arrière)"
    echo "$content" | while IFS=$'\t' read -r type name path url; do
        if [[ $type == "dir" ]]; then
            echo "$counter. $name (Dossier)"
        else
            echo "$counter. $name (Fichier)"
        fi
        counter=$((counter + 1))
    done
    echo -e "\nEntrez un numéro pour naviguer ou exécuter un script, ou 'exit' pour quitter:"
}

current_url="$BASE_API_URL/linux"
parent_urls=()
exit=false

while [ "$exit" = false ]; do
    content=$(show_directory_content $current_url)
    show_interface "$content"

    if ! read -r input; then
        echo "Erreur de lecture de l'entrée"
        exit 1
    fi
    input=$(echo "$input" | tr -d '\r')

    if [[ $input == "exit" ]]; then
        exit=true
    elif [[ $input == "0" ]]; then
        if [ ${#parent_urls[@]} -gt 0 ]; then
            current_url=${parent_urls[-1]}
            unset parent_urls[-1]
        else
            echo "Vous êtes déjà à la racine."
            sleep 2
        fi
    elif [[ $input =~ ^[0-9]+$ ]]; then
        number=$input
        selected_item=$(echo "$content" | sed "${number}q;d")
        item_type=$(echo "$selected_item" | awk '{print $1}')
        item_url=$(echo "$selected_item" | awk '{print $4}')
        item_name=$(echo "$selected_item" | awk '{print $2}')

        if [[ $item_type == "dir" ]]; then
            parent_urls+=("$current_url")
            current_url=$item_url
        elif [[ $item_type == "file" ]]; then
            file_url=${item_url/https:\/\/api.github.com\/repos\//https:\/\/raw.githubusercontent.com\/}
            file_url=${file_url/\/contents\//\/master\/}
            execute_script "$file_url" "$item_name"
        else
            echo "Veuillez sélectionner un numéro valide."
            sleep 2
        fi
    else
        echo "Commande invalide. Essayez à nouveau."
        sleep 2
    fi
done
