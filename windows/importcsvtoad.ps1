# Chemin vers le fichier CSV
$csvPath = "utilisateurs_AD.csv"

# Vérifier si le fichier CSV existe
if (-not (Test-Path $csvPath)) {
    Write-Host "Fichier CSV non trouvé à l'emplacement : $csvPath"
    exit
}

# Importer les utilisateurs depuis le fichier CSV
Import-Csv $csvPath | ForEach-Object {
    $userProps = @{
        SamAccountName = $_.SamAccountName
        UserPrincipalName = $_.UserPrincipalName
        Name = $_.Name
        GivenName = $_.GivenName
        Surname = $_.Surname
        Enabled = $true
        DisplayName = $_.DisplayName
        Path = $_.OUPath

        AccountPassword = ConvertTo-SecureString $_.Password -AsPlainText -Force
        ChangePasswordAtLogon = $true
    }

    # Créer l'utilisateur dans AD
    try {
        New-ADUser @userProps
        Write-Host "Utilisateur créé : $($userProps.Name)"
    } catch {
        Write-Host "Erreur lors de la création de l'utilisateur : $_"
    }
}

Write-Host "Importation des utilisateurs terminée."
