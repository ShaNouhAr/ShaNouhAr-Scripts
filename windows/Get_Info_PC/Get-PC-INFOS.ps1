param (
    [switch]$forceFile
)

# R�cup�rer les informations
$ComputerName = $env:COMPUTERNAME
$OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property Caption, Version, BuildNumber
$Motherboard = Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property Product,Manufacturer
$RAMModules = Get-CimInstance -ClassName Win32_PhysicalMemory
$TotalRAM = ($RAMModules | Measure-Object -Property Capacity -Sum).Sum / 1GB
$GPUs = Get-CimInstance -ClassName Win32_VideoController
$Disks = Get-CimInstance -ClassName Win32_DiskDrive
$BIOS = Get-CimInstance -ClassName Win32_BIOS | Select-Object -Property Manufacturer, SMBIOSBIOSVersion

# Afficher et potentiellement enregistrer les informations
$InfoContent = @"
=================================================
            Informations du Syst�me
=================================================
Nom du PC: $ComputerName

Syst�me d'Exploitation:
- Nom: $($OSInfo.Caption)
- Version: $($OSInfo.Version)
- Build: $($OSInfo.BuildNumber)

Carte M�re:
- Fabricant: $($Motherboard.Manufacturer)
- Produit: $($Motherboard.Product)

RAM Totale: $TotalRAM GB
"@

# D�tails des modules RAM
$InfoContent += "D�tails des Modules RAM:`n"
$RAMModules | ForEach-Object {
    $capacityGB = $_.Capacity / 1GB
    $InfoContent += "- Fabricant: $($_.Manufacturer), Capacit�: $capacityGB GB, Vitesse: $($_.Speed) MHz`n"
}

# D�tails des cartes graphiques
$InfoContent += "Cartes Graphiques:`n"
$GPUs | ForEach-Object {
    $InfoContent += "- Nom: $($_.Name), Version du Pilote: $($_.DriverVersion)`n"
}

# D�tails des disques
$InfoContent += "Disques:`n"
$Disks | ForEach-Object {
    $capacityGB = [math]::round($_.Size / 1GB, 2)
    $InfoContent += "- Mod�le: $($_.Model), Capacit�: $capacityGB GB`n"
}

# D�tails du BIOS
$InfoContent += @"
BIOS:
- Fabricant: $($BIOS.Manufacturer)
- Version: $($BIOS.SMBIOSBIOSVersion)
"@

# Afficher les informations
Write-Host $InfoContent

# V�rifier si le script doit enregistrer les informations dans un fichier
if ($forceFile -or ($PSBoundParameters.ContainsKey('forceFile') -eq $false -and $Host.UI.PromptForChoice("Enregistrer les informations", "Voulez-vous enregistrer ces informations dans un fichier texte ?", @("&Oui", "&Non"), 0) -eq 0)) {
    $OutputFile = "$env:USERPROFILE\Desktop\System_Info.txt"
    $InfoContent | Out-File -FilePath $OutputFile
    Write-Host "Les informations ont �t� sauvegard�es dans $OutputFile"
}
