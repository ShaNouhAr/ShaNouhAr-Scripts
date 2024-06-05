# Vérifier si AD DS est déjà installé
$adFeature = Get-WindowsFeature -Name AD-Domain-Services
if ($adFeature.InstallState -eq "Installed") {
    Write-Host "AD DS est déjà installé sur ce serveur. Le script va se terminer."
    exit
}

# Installer AD DS (et DNS si nécessaire)
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Write-Host "AD DS installé avec succès."

# Installer le rôle DNS si ce n'est pas déjà fait
$dnsFeature = Get-WindowsFeature -Name DNS
if ($dnsFeature.InstallState -ne "Installed") {
    Install-WindowsFeature -Name DNS -IncludeManagementTools
    Write-Host "Serveur DNS installé avec succès."
}

# Configurer le nouveau domaine Active Directory
$domainName = Read-Host "Entrez le nom du nouveau domaine (par exemple, mondomaine.local)"
$safeModeAdminPassword = Read-Host "Entrez le mot de passe pour le mode sans échec d'AD DS" -AsSecureString

# Capturer des avertissements potentiels lors de la création du domaine
try {
    Import-Module ADDSDeployment
    Install-ADDSForest -DomainName $domainName -SafeModeAdministratorPassword $safeModeAdminPassword -Force
    Write-Host "Nouveau domaine Active Directory configuré avec succès."
} catch {
    Write-Host "Une erreur s'est produite lors de la création du domaine : $_"
    exit
}

Write-Host "L'installation et la configuration d'AD DS et DNS sont terminées."
