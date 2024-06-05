# Vérifier si le pare-feu Windows est activé
$firewallEnabled = Get-NetFirewallProfile | Where-Object { $_.Name -eq 'Public' }
if ($firewallEnabled.Enabled) {
    Write-Host "Le pare-feu Windows est déjà activé."
} else {
    Write-Host "Activation du pare-feu Windows..."
    Set-NetFirewallProfile -Profile 'Public' -Enabled True
    Write-Host "Le pare-feu Windows est maintenant activé."
}

# Vérifier si une règle Minecraft existe déjà
$existingRule = Get-NetFirewallRule | Where-Object { $_.DisplayName -eq 'Minecraft' }
if ($existingRule) {
    Write-Host "Une règle Minecraft existe déjà dans le pare-feu."
} else {
    # Créer une nouvelle règle pour Minecraft
    Write-Host "Création d'une nouvelle règle Minecraft dans le pare-feu..."
    $rule = New-NetFirewallRule -DisplayName 'Minecraft' -Direction Inbound -Protocol TCP -LocalPort 25565 -Action Allow
    $rule | Set-NetFirewallRule -Profile 'Public'
    Write-Host "La règle Minecraft a été ajoutée au pare-feu."
}

Write-Host "Le pare-feu a été configuré pour autoriser Minecraft."