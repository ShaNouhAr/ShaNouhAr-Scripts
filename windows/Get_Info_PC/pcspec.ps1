# Charger les assemblies pour Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Créer le formulaire principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "Monitoring PC"
$form.Width = 400
$form.Height = 400
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)  # Couleur d'arrière-plan sombre

# Ajouter un label pour afficher les informations
$label = New-Object System.Windows.Forms.Label
$label.Width = 350
$label.Height = 250
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.ForeColor = [System.Drawing.Color]::White  # Couleur du texte blanc
$form.Controls.Add($label)

# Fonction pour récupérer les informations système
function Get-SystemInfo {
    $cpu = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
    $ram = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory
    $ramInGB = [math]::Round(($ram / 1GB), 2)

    # Récupérer le nom du GPU
    $gpu = Get-WmiObject -Class Win32_VideoController | Select-Object -ExpandProperty Name

    # Récupérer l'édition de Windows
    $osEdition = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption

    return "CPU: $cpu`nRAM: $ramInGB GB`nGPU: $gpu`nOS: $osEdition"
}

# Créer un Timer pour rafraîchir les informations toutes les 10 secondes
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 10000  # 10 secondes
$timer.Add_Tick({
    $label.Text = Get-SystemInfo
})
$timer.Start()

# Rafraîchir les informations au lancement
$label.Text = Get-SystemInfo

# Afficher le formulaire
$form.ShowDialog()
