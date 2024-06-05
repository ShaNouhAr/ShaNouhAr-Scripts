#!/bin/bash

# Script Bash pour lister et naviguer dans un repository GitHub public
# Titre : ShaNouhAr-Scripts

# URL du repository GitHub
repoOwner="ShaNouhAr"
repoName="ShaNouhAr-Scripts"
baseApiUrl="https://api.github.com/repos/$repoOwner/$repoName/contents/linux"

# Fonction pour obtenir le contenu d'un dossier depuis l'API GitHub
function get_github_content {
    url=$1
    curl -s -H "User-Agent: Bash" "$url"
}

# Fonction pour afficher le contenu d'un dossier
function show_directory_content {
    url=$1
    items=$(get_github_content "$url")
    echo "$items" | jq -r '.[] | "\(.type) \(.name) \(.path) \(.url)"' | nl -v 1
}

# Fonction pour exécuter un script localement
function execute_script {
    script_url=$1
    file_path=$2
    script_content=$(curl -s -H "User-Agent: Bash" "$script_url")
    temp_script_path="/tmp/$file_path"
    echo "$script_content" > "$temp_script_path"
    
    extension="${temp_script_path##*.}"
    
    case $extension in
        ps1)
            sudo pwsh "$temp_script_path"
            ;;
        py)
            python3 "$temp_script_path"
            ;;
        reg)
            echo "Regedit not supported on Linux"
            ;;
        bat)
            echo "Batch files not supported on Linux"
            ;;
        *)
            echo "Type de fichier non supporté: $extension"
            ;;
    esac
}

# Fonction pour afficher une interface utilisateur agréable
function show_interface {
    content=$1
    clear
    echo -e "\e[36m=============================================="
    echo -e "                 ShaNouhAr-Scripts             "
    echo -e "==============================================\e[0m"
    
    echo -e "\e[37m0. .. (Revenir en arrière)\e[0m"
    echo -e "$content" | while read -r line; do
        type=$(echo "$line" | awk '{print $2}')
        if [ "$type" = "dir" ]; then
            echo -e "\e[32m$line\e[0m"
        else
            echo -e "\e[33m$line\e[0m"
        fi
    done

    echo -e "\n\e[33mEntrez un numéro pour naviguer ou exécuter un script, ou 'exit' pour quitter:\e[0m"
}

# Initialisation de la navigation
current_url=$baseApiUrl
parent_urls=()
exit=false

while [ "$exit" = false ]; do
    content=$(show_directory_content "$current_url")
    show_interface "$content"
    
    read -p "> " input
    
    if [ "$input" = "exit" ]; then
        exit=true
    elif [ "$input" = "0" ]; then
        if [ ${#parent_urls[@]} -gt 0 ]; then
            current_url=${parent_urls[-1]}
            parent_urls=("${parent_urls[@]::${#parent_urls[@]}-1}")
        else
            echo -e "\e[31mVous êtes déjà à la racine.\e[0m"
            sleep 2
        fi
    elif [[ "$input" =~ ^[0-9]+$ ]]; then
        number=$(echo "$input" | awk '{print $1}')
        item=$(echo "$content" | awk 'NR=='$number'')
        if [ -n "$item" ]; then
            item_url=$(echo "$item" | awk '{print $5}')
            item_type=$(echo "$item" | awk '{print $2}')
            item_name=$(echo "$item" | awk '{print $3}')
            if [ "$item_type" = "dir" ]; then
                parent_urls+=("$current_url")
                current_url=$item_url
            elif [ "$item_type" = "file" ]; then
                file_url=${item_url/https:\/\/api.github.com\/repos\//https:\/\/raw.githubusercontent.com\/}
                file_url=${file_url/\/contents\//\/master\/}
                execute_script "$file_url" "$item_name"
            fi
        else
            echo -e "\e[31mVeuillez sélectionner un numéro valide.\e[0m"
            sleep 2
        fi
    else
        echo -e "\e[31mCommande invalide. Essayez à nouveau.\e[0m"
        sleep 2
    fi
done
