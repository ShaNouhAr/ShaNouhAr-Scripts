#!/bin/bash

# Green color
echo -e "\033[0;32m"
echo "======================================="
echo "       SCRIPT DE CONNEXION SSH         "
echo "======================================="
# Reset color
echo -e "\033[0m"

# Récupération des adresses IP
declare -a ipAddresses
count=1
while true; do
    read -p "Entrez la ${count}ère adresse IP ou 'exit' pour finir: " ip
    if [ "$ip" = "exit" ]; then
        break
    fi
    ipAddresses+=("$ip")
    ((count++))
done

# Récupération des couples d'utilisateurs et de mots de passe
declare -a usernames
declare -a passwords
count=1
while true; do
    read -p "Entrez le ${count}ème nom d'utilisateur ou 'exit' pour finir: " username
    if [ "$username" = "exit" ]; then
        break
    fi
    usernames+=("$username")

    read -s -p "Entrez le ${count}ème mot de passe ou 'exit' pour finir: " password
    echo
    if [ "$password" = "exit" ]; then
        break
    fi
    passwords+=("$password")
    ((count++))
done

# Récupération des commandes
declare -a commands
count=1
while true; do
    read -p "Entrez la ${count}ème commande ou 'exit' pour finir: " cmd
    if [ "$cmd" = "exit" ]; then
        break
    fi
    commands+=("$cmd")
    ((count++))
done

# Connexion SSH et exécution des commandes
len=${#usernames[@]}
for (( i=0; i<$len; i++ )); do
    for ip in "${ipAddresses[@]}"; do
        for cmd in "${commands[@]}"; do
            echo "Trying to connect to $ip as ${usernames[$i]} to execute $cmd"
            sshpass -p ${passwords[$i]} ssh -o StrictHostKeyChecking=no -o ConnectTimeout=15 -oKexAlgorithms=+diffie-hellman-group1-sha1 -c aes256-cbc ${usernames[$i]}@$ip $cmd

            status=$?
            if [ $status -eq 0 ]; then
                echo "Command executed successfully."
            else
                echo "There was an error executing the command or the connection timed out."
            fi
            sleep 1
        done
    done
done
