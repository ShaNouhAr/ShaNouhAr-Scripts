# V�rifier si l'ex�cution du script se fait en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Ce script doit �tre ex�cut� en tant qu'administrateur."
    exit
}

# Activer la fonctionnalit� WSL
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

# Activer la fonctionnalit� de plateforme de machine virtuelle
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

bcdedit /set hypervisorlaunchtype auto

# Red�marrer l'ordinateur
Write-Host "Les fonctionnalit�s n�cessaires ont �t� activ�es. L'ordinateur va maintenant red�marrer."
Restart-Computer -Confirm