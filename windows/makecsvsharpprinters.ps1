# Initialiser le tableau qui va contenir les données
$data = @()

# Obtenir toutes les imprimantes
$printers = Get-Printer

# Boucler sur chaque imprimante
foreach ($printer in $printers) {

    # Vérifier si la marque de l'imprimante est Sharp
    if ($printer.DriverName -like "*Sharp*") {

        # Récupérer les détails de la configuration du port pour obtenir l'adresse IP
        $port = Get-PrinterPort -Name $printer.PortName

        # Ajouter les détails de l'imprimante au tableau
        $data += New-Object PSObject -Property @{
            'Nom d imprimante' = $printer.Name
            'Adresse IP' = $port.PrinterHostAddress
        }
    }
}

# Exporter les données au format CSV
$data | Export-Csv -Path "Chemin\Vers\Mon\Fichier.csv" -NoTypeInformation -Encoding UTF8

