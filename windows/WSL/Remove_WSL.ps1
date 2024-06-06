# V�rifier si l'ex�cution du script se fait en tant qu'administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Ce script doit �tre ex�cut� en tant qu'administrateur."
    exit
}

# D�sactiver WSL
Write-Host "D�sactivation de WSL en cours..."
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /quiet /norestart

# D�sactiver la plateforme de machine virtuelle
Write-Host "D�sactivation de la plateforme de machine virtuelle en cours..."
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /quiet /norestart

# Supprimer l'enregistrement de la distribution Linux
Write-Host "Suppression de l'enregistrement de la distribution Linux..."
wsl --unregister kali-linux

# Red�marrer l'ordinateur
Write-Host "Les fonctionnalit�s ont �t� d�sactiv�es et l'enregistrement de la distribution Linux a �t� supprim�. L'ordinateur va maintenant red�marrer."
Restart-Computer -Confirm