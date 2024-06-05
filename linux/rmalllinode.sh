#!/bin/bash

# Votre Token d'Accès Personnel Linode
TOKEN="0302993f7272b075b49b2aed1ac900a622680d0da3983db9fcd7786b501e6a83"

# Obtenir la liste des Linodes
linodes=$(curl -H "Authorization: Bearer $TOKEN" \
               https://api.linode.com/v4/linode/instances | jq '.data[].id')

# Supprimer chaque Linode
for id in $linodes
do
    echo "Suppression du Linode avec l'ID: $id"
    curl -X DELETE -H "Authorization: Bearer $TOKEN" \
         https://api.linode.com/v4/linode/instances/$id
done

echo "Tous les Linodes ont été supprimés."

