# V�rifier si AD DS est d�j� install�
$adFeature = Get-WindowsFeature -Name AD-Domain-Services
if ($adFeature.InstallState -eq "Installed") {
    Write-Host "AD DS est d�j� install� sur ce serveur. Le script va se terminer."
    exit
}

# Installer AD DS (et DNS si n�cessaire)
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Write-Host "AD DS install� avec succ�s."

# Installer le r�le DNS si ce n'est pas d�j� fait
$dnsFeature = Get-WindowsFeature -Name DNS
if ($dnsFeature.InstallState -ne "Installed") {
    Install-WindowsFeature -Name DNS -IncludeManagementTools
    Write-Host "Serveur DNS install� avec succ�s."
}

# Configurer le nouveau domaine Active Directory
$domainName = Read-Host "Entrez le nom du nouveau domaine (par exemple, mondomaine.local)"
$safeModeAdminPassword = Read-Host "Entrez le mot de passe pour le mode sans �chec d'AD DS" -AsSecureString

# Capturer des avertissements potentiels lors de la cr�ation du domaine
try {
    Import-Module ADDSDeployment
    Install-ADDSForest -DomainName $domainName -SafeModeAdministratorPassword $safeModeAdminPassword -Force
    Write-Host "Nouveau domaine Active Directory configur� avec succ�s."
} catch {
    Write-Host "Une erreur s'est produite lors de la cr�ation du domaine : $_"
    exit
}

Write-Host "L'installation et la configuration d'AD DS et DNS sont termin�es."
