# Chemin vers le fichier CSV
$csvPath = "utilisateurs_AD.csv"

# V�rifier si le fichier CSV existe
if (-not (Test-Path $csvPath)) {
    Write-Host "Fichier CSV non trouv� � l'emplacement : $csvPath"
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

    # Cr�er l'utilisateur dans AD
    try {
        New-ADUser @userProps
        Write-Host "Utilisateur cr�� : $($userProps.Name)"
    } catch {
        Write-Host "Erreur lors de la cr�ation de l'utilisateur : $_"
    }
}

Write-Host "Importation des utilisateurs termin�e."
