# Vérifier si l'exécution du script se fait en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Ce script doit être exécuté en tant qu'administrateur."
    exit
}

# Activer la fonctionnalité WSL
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

# Activer la fonctionnalité de plateforme de machine virtuelle
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

bcdedit /set hypervisorlaunchtype auto

# Redémarrer l'ordinateur
Write-Host "Les fonctionnalités nécessaires ont été activées. L'ordinateur va maintenant redémarrer."
Restart-Computer -Confirm