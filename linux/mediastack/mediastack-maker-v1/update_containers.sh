#!/bin/bash
cd /srv/dockerdata
# Nom du fichier de log
LOG_FILE="update_containers.log"

# Vérifier si le fichier de log existe et sa taille
if [[ -f "$LOG_FILE" ]]; then
    FILE_SIZE=$(stat -c%s "$LOG_FILE")
    # Supprimer le fichier de log s'il dépasse 25 Mo
    if [[ $FILE_SIZE -gt 26214400 ]]; then
        rm -f "$LOG_FILE"
    fi
fi

# Parcourir chaque sous-dossier
for d in */ ; do
    # Vérifier si 'docker-compose.yml' existe dans le dossier
    if [[ -f "$d/docker-compose.yml" ]]; then
        # Ajouter un timestamp
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Mise à jour des conteneurs dans le dossier $d" | tee -a "$LOG_FILE"
        # Aller dans le dossier
        cd "$d"
        # Tirer les dernières images
        docker-compose pull 2>&1 | tee -a "../$LOG_FILE"
        # Arrêter et recréer les conteneurs
        docker-compose down 2>&1 | tee -a "../$LOG_FILE"
        docker-compose up -d 2>&1 | tee -a "../$LOG_FILE"
        # Revenir au dossier parent
        cd ..
    fi
done

# Ajouter un timestamp à la fin du script
echo "$(date '+%Y-%m-%d %H:%M:%S') - Mise à jour ou réparation terminée pour tous les dossiers compatibles." | tee -a "$LOG_FILE"
