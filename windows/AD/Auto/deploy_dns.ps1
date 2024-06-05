# Obtenir les d�tails de l'interface r�seau en mode bridge
$interface = Get-NetAdapter | Where-Object {$_.Name -eq "Nom de l'interface r�seau en mode bridge"} | Select-Object -First 1

# V�rifier si le service DNS est d�j� install�
$dnsFeature = Get-WindowsFeature -Name DNS
if ($dnsFeature.InstallState -eq "Installed") {
    Write-Host "Le service DNS est d�j� install� sur ce serveur. Le script va se terminer."
    exit
}

# Valeurs par d�faut pour la configuration IP
$newIpAddress = "192.168.1.10"  # Nouvelle adresse IP
$subnetMask = "255.255.255.0"  # Masque de sous-r�seau
$gateway = "192.168.1.1"       # Adresse de la passerelle

# Convertir le masque de sous-r�seau en longueur de pr�fixe CIDR
function Convert-SubnetToCidr {
    param ([string]$subnetMask)
    $subnetBinaryString = $subnetMask -split "\." | ForEach-Object { [Convert]::ToString([int]$_, 2).PadLeft(8, '0') }
    return ($subnetBinaryString -join "").TrimEnd("0").Length
}
$prefixLength = Convert-SubnetToCidr -subnetMask $subnetMask

# Appliquer la nouvelle configuration IP
New-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -IPAddress $newIpAddress -PrefixLength $prefixLength -DefaultGateway $gateway
Write-Host "Adresse IP mise � jour avec succ�s."

# Installer le r�le DNS
Install-WindowsFeature -Name DNS -IncludeManagementTools

# Valeurs par d�faut pour la zone DNS
$zoneName = "mondomaine.local"  # Nom de la zone DNS

# Cr�er une zone primaire
Add-DnsServerPrimaryZone -Name $zoneName -ZoneFile "$zoneName.dns"

# Valeurs par d�faut pour l'enregistrement A
$hostName = "serveur"            # Nom d'h�te pour l'enregistrement A
$ipAddress = "192.168.1.10"      # Adresse IP pour l'enregistrement A

# Ajouter un enregistrement A � la zone
Add-DnsServerResourceRecordA -Name $hostName -ZoneName $zoneName -IPv4Address $ipAddress

# V�rification de la zone
Get-DnsServerZone -Name $zoneName

# Confirmation de l'ajout de l'enregistrement
Get-DnsServerResourceRecord -ZoneName $zoneName -Name $hostName
