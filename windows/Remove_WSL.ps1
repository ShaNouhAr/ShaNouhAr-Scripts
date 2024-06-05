# Vérifier si l'exécution du script se fait en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Ce script doit être exécuté en tant qu'administrateur."
    exit
}

# Désactiver WSL
Write-Host "Désactivation de WSL en cours..."
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /quiet /norestart

# Désactiver la plateforme de machine virtuelle
Write-Host "Désactivation de la plateforme de machine virtuelle en cours..."
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /quiet /norestart

# Supprimer l'enregistrement de la distribution Linux
Write-Host "Suppression de l'enregistrement de la distribution Linux..."
wsl --unregister kali-linux

# Redémarrer l'ordinateur
Write-Host "Les fonctionnalités ont été désactivées et l'enregistrement de la distribution Linux a été supprimé. L'ordinateur va maintenant redémarrer."
Restart-Computer -Confirm