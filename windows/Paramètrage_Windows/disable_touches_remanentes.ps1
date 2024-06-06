# Désactiver les touches rémanentes
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name "Flags" -Value 506
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response' -Name "Flags" -Value 122
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys' -Name "Flags" -Value 58
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\SoundSentry' -Name "Flags" -Value 58

# Désactiver les touches rémanentes au niveau du système
Set-ItemProperty -Path 'HKU\.DEFAULT\Control Panel\Accessibility\StickyKeys' -Name "Flags" -Value 506
Set-ItemProperty -Path 'HKU\.DEFAULT\Control Panel\Accessibility\Keyboard Response' -Name "Flags" -Value 122
Set-ItemProperty -Path 'HKU\.DEFAULT\Control Panel\Accessibility\ToggleKeys' -Name "Flags" -Value 58
Set-ItemProperty -Path 'HKU\.DEFAULT\Control Panel\Accessibility\SoundSentry' -Name "Flags" -Value 58

# Informer l'utilisateur que l'opération est terminée
Write-Output "Les touches rémanentes ont été désactivées avec succès."
