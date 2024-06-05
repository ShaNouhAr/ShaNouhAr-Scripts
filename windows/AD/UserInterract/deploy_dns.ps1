# V�rifier si le service DNS est d�j� install�
$dnsFeature = Get-WindowsFeature -Name DNS
if ($dnsFeature.InstallState -eq "Installed") {
    Write-Host "Le service DNS est d�j� install� sur ce serveur. Le script va se terminer."
    exit
}
# Obtenir les d�tails de l'interface r�seau principale
$interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
$ipConfig = Get-NetIPAddress -InterfaceIndex $interface.InterfaceIndex -AddressFamily IPv4

# V�rifier si une adresse IP statique est d�j� configur�e
if ($ipConfig.PrefixOrigin -ne "Manual") {
    Write-Host "Votre adresse IP actuelle est : $($ipConfig.IPAddress)"
    $changeIp = Read-Host "Voulez-vous configurer une adresse IP fixe ? (oui/non)"

    if ($changeIp.ToLower() -eq "oui") {
        # Demander la nouvelle adresse IP et le masque de sous-r�seau
        $newIpAddress = Read-Host "Entrez la nouvelle adresse IP"
        $subnetMask = Read-Host "Entrez le masque de sous-r�seau (par exemple, 255.255.255.0)"
        $gateway = Read-Host "Entrez l'adresse de la passerelle (laissez vide si aucune)"

        # Convertir le masque de sous-r�seau en longueur de pr�fixe CIDR
        function Convert-SubnetToCidr {
            param ([string]$subnetMask)
            $subnetBinaryString = $subnetMask -split "\." | ForEach-Object { [Convert]::ToString([int]$_, 2).PadLeft(8, '0') }
            return ($subnetBinaryString -join "").TrimEnd("0").Length
        }
        $prefixLength = Convert-SubnetToCidr -subnetMask $subnetMask

        # Appliquer la nouvelle configuration IP
        $newIpConfig = @{
            InterfaceIndex = $interface.InterfaceIndex
            IPAddress = $newIpAddress
            PrefixLength = $prefixLength
        }
        if ($gateway -ne "") {
            $newIpConfig.DefaultGateway = $gateway
        }
        New-NetIPAddress @newIpConfig
        Write-Host "Adresse IP mise � jour avec succ�s."
    } else {
        Write-Host "Aucun changement d'adresse IP n'a �t� effectu�."
    }
} else {
    Write-Host "Une adresse IP fixe est d�j� configur�e. Configuration de l'adresse IP ignor�e."
}

# Installer le r�le DNS
Install-WindowsFeature -Name DNS -IncludeManagementTools
# Demander � l'utilisateur d'entrer le nom de la zone DNS
$zoneName = Read-Host "Entrez le nom de la zone DNS (par exemple, mondomaine.local)"

# Cr�er une zone primaire
Add-DnsServerPrimaryZone -Name $zoneName -ZoneFile "$zoneName.dns"

# Demander � l'utilisateur d'entrer les d�tails de l'enregistrement A
$hostName = Read-Host "Entrez le nom d'h�te pour l'enregistrement A (par exemple, serveur)"
$ipAddress = Read-Host "Entrez l'adresse IP pour l'enregistrement A (par exemple, 192.168.1.10)"

# Ajouter un enregistrement A � la zone
Add-DnsServerResourceRecordA -Name $hostName -ZoneName $zoneName -IPv4Address $ipAddress

# V�rification de la zone
Get-DnsServerZone -Name $zoneName

# Confirmation de l'ajout de l'enregistrement
Get-DnsServerResourceRecord -ZoneName $zoneName -Name $hostName
