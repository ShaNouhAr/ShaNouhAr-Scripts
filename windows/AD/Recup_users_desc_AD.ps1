# Importer le module Active Directory
Import-Module ActiveDirectory

# Récupérer tous les utilisateurs de l'Active Directory
$utilisateurs = Get-ADUser -Filter * -Properties Description

# Créer un tableau pour stocker les données des utilisateurs
$tableauUtilisateurs = @()

# Parcourir tous les utilisateurs et ajouter les descriptions non vides au tableau
foreach ($utilisateur in $utilisateurs) {
    if ($utilisateur.Description -ne $null -and $utilisateur.Description -ne '') {
        $ligneUtilisateur = [PSCustomObject]@{
            Nom = $utilisateur.Name
            Description = $utilisateur.Description
        }
        $tableauUtilisateurs += $ligneUtilisateur
    }
}

# Exporter le tableau des utilisateurs dans un fichier CSV
$tableauUtilisateurs | Export-Csv -Path ".\aduserdesc.csv" -NoTypeInformation