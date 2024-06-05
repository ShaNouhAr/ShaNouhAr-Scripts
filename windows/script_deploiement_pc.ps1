function PromptForConfirmation($message) {
    $choice = $null
    while ($choice -ne 'y' -and $choice -ne 'n') {
        $choice = Read-Host -Prompt "$message (y/n)"
    }
    return $choice -eq 'y'
}

clear
Write-Host "####################################################"
Write-Host "#                                                  #"
Write-Host "#             SCRIPT DE DEPLOIEMENT DE PC          #"
Write-Host "#                                                  #"
Write-Host "#                                                  #"
Write-Host "####################################################"

# Recueillir toutes les confirmations
$actions = @{
    "InstallChocolatey" = $false;
    "InstallSoftwares" = @();
    "InstallElectorrent" = $false;
    "OpenGenshinWebsite" = $false;
    "OpenHonkaiWebsite" = $false;
    "ModifyRegistry" = $false;
    "RunExternalScript" = $false;
    "ConfigurePowerSettings" = $false;
    "SwitchToDarkTheme" = $false;
    "DisableStickyKeys" = $false;
    "ScanDrivers" = $false;
    "RunWindowsUpdate" = $false;
}

# Vérifier si choco.exe est présent
$chocoInstalled = $false
$chocoPath = Get-Command choco -ErrorAction SilentlyContinue
if ($chocoPath) {
    $chocoInstalled = $true
    Write-Host ""
    Write-Host "Chocolatey est déjà installé."
}

# Si Chocolatey n'est pas installé, proposer son installation
if (-not $chocoInstalled) {
    $actions["InstallChocolatey"] = PromptForConfirmation("Chocolatey n'a pas été trouvé. Il sera nécessaire pour la suite du script. Voulez-vous l'installer ?")
}

# Liste des logiciels à installer avec leur nom d'affichage
$logiciels =  [ordered] @{
    "googlechrome"           = "Google Chrome";
    "brave"                  = "Brave";
    "discord"                = "Discord";
    "teamviewer"             = "TeamViewer";
    "whatsapp"               = "WhatsApp";
    "notepadplusplus"        = "Notepad++";
    "obsidian"               = "Obsidian";
    "spotify"                = "Spotify";
    "7zip"                   = "7-Zip";
    "filezilla"              = "FileZilla";
    "rdm"                    = "Remote Desktop Manager";
    "wireguard"              = "WireGuard";
    "bitwarden"              = "Bitwarden";
    "virtualbox"             = "VirtualBox";
    "python"                 = "Python";
    "javaruntime"            = "Java";
    "powershell-core"        = "PowerShell 7";
    "steam"                  = "Steam";
    "epicgameslauncher"      = "Epic Games Launcher";
    "icue"                   = "ICUE";
    "geforce-experience"     = "NVIDIA GeForce Experience";
    "geforce-game-ready-driver" = "Pilote graphique NVIDIA";
    "vlc"                    = "VLC";
    "plexmediaplayer"        = "Plex Media Player for Windows";
}
Write-Host ""
Write-Host "LOGICIELS :"
Write-Host ""
foreach ($logiciel in $logiciels.GetEnumerator()) {
    if (PromptForConfirmation("Voulez-vous installer $($logiciel.Value) ?")) {
        $actions["InstallSoftwares"] += $logiciel.Key
    }
}

$actions["InstallElectorrent"] = PromptForConfirmation("Voulez-vous télécharger et installer Electorrent ?")
$actions["OpenGenshinWebsite"] = PromptForConfirmation("Voulez-vous vous rendre sur le site de téléchargement de Genshin Impact ?")
$actions["OpenHonkaiWebsite"] = PromptForConfirmation("Voulez-vous vous rendre sur le site de téléchargement de Honkai Star Rail ?")
$actions["ModifyRegistry"] = PromptForConfirmation("Voulez-vous enlever le message 'Afficher plus d'options'? (Uniquement sur Win11 et effectif au prochain redémarrage)")
$actions["RunExternalScript"] = PromptForConfirmation("Voulez-vous exécuter le script depuis https://massgrave.dev/get (Activation Windows/Office) ?")
$actions["ConfigurePowerSettings"] = PromptForConfirmation("Voulez-vous désactiver la mise en veille et l'extinction de l'écran ?")
$actions["SwitchToDarkTheme"] = PromptForConfirmation("Voulez-vous passer en Dark Theme ?")
$actions["DisableStickyKeys"] = PromptForConfirmation("Voulez-vous désactiver les touches rémanentes (activation lorsque la touche Maj est appuyée cinq fois de suite) ?")
$actions["ScanDrivers"] = PromptForConfirmation("Voulez vous faire un scan des drivers à installés ?")
$actions["RunWindowsUpdate"] = PromptForConfirmation("Voulez-vous rechercher et installer les mises à jour Windows ?")

# Exécution des actions
if ($actions["InstallChocolatey"]) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((Invoke-WebRequest -UseBasicParsing -Uri https://chocolatey.org/install.ps1).Content)
}

foreach ($software in $actions["InstallSoftwares"]) {
    choco install $software -y
}

if ($actions["InstallElectorrent"]) {
    $electorrentUrl = "https://electorrent.vercel.app/download/win32"
    $downloadPath = "$env:TEMP\ElectorrentSetup.exe"
    Invoke-WebRequest -Uri $electorrentUrl -OutFile $downloadPath
    Start-Process -Wait -FilePath $downloadPath
}

if ($actions["OpenGenshinWebsite"]) {
    Start-Process "https://genshin.hoyoverse.com/fr/"
}

if ($actions["OpenHonkaiWebsite"]) {
    Start-Process "https://hsr.hoyoverse.com/fr-fr/"
}

if ($actions["ModifyRegistry"]) {
    Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name '(Default)' -Value ""
}

if ($actions["RunExternalScript"]) {
    powershell -command "irm https://massgrave.dev/get | iex"
}

if ($actions["ConfigurePowerSettings"]) {
    # Définir le plan d'alimentation actif sur "Hautes performances"
    powercfg -s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    # Désactiver la mise en veille
    powercfg -change -standby-timeout-ac 0
    # Désactiver l'extinction de l'écran
    powercfg -change -monitor-timeout-ac 0
}

if ($actions["SwitchToDarkTheme"]) {
    # Activer le Dark Theme pour les applications
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
    # Activer le Dark Theme pour l'explorateur Windows
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0
    # Redémarrer explorer.exe
    Stop-Process -Name "explorer" -Force
    Start-Process "explorer"
}

if ($actions["DisableStickyKeys"]) {
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506"
}

if ($actions["ScanDrivers"]) {
    $url = "https://fichiers2.touslesdrivers.com/Mes_Drivers_3.0.4.exe"
    $downloadPath = "$env:TEMP\Mes_Drivers_3.0.4.exe"
    Invoke-WebRequest -Uri $url -OutFile $downloadPath
    Start-Process -Wait -FilePath $downloadPath
}

if ($actions["RunWindowsUpdate"]) {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-PackageProvider -Name NuGet -Force
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Install-Module -Name PSWindowsUpdate -Force
    }
    # Rechercher et installer les mises à jour
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot
}

Write-Host "Script terminé."
Write-Host "Au revoir."
PAUSE
clear
