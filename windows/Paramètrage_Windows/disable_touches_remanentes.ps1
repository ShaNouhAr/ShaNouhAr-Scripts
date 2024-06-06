# Désactiver les touches rémanentes pour l'utilisateur actuel
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name "Flags" -Value 506
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response' -Name "Flags" -Value 122
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys' -Name "Flags" -Value 58
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\SoundSentry' -Name "Flags" -Value 58

# Désactiver les touches rémanentes pour le profil utilisateur par défaut
Set-ItemProperty -Path 'HKU:S-1-5-19\Control Panel\Accessibility\StickyKeys' -Name "Flags" -Value 506
Set-ItemProperty -Path 'HKU:S-1-5-19\Control Panel\Accessibility\Keyboard Response' -Name "Flags" -Value 122
Set-ItemProperty -Path 'HKU:S-1-5-19\Control Panel\Accessibility\ToggleKeys' -Name "Flags" -Value 58
Set-ItemProperty -Path 'HKU:S-1-5-19\Control Panel\Accessibility\SoundSentry' -Name "Flags" -Value 58

Set-ItemProperty -Path 'HKU:S-1-5-20\Control Panel\Accessibility\StickyKeys' -Name "Flags" -Value 506
Set-ItemProperty -Path 'HKU:S-1-5-20\Control Panel\Accessibility\Keyboard Response' -Name "Flags" -Value 122
Set-ItemProperty -Path 'HKU:S-1-5-20\Control Panel\Accessibility\ToggleKeys' -Name "Flags" -Value 58
Set-ItemProperty -Path 'HKU:S-1-5-20\Control Panel\Accessibility\SoundSentry' -Name "Flags" -Value 58

# Informer l'utilisateur que l'opération est terminée
Write-Output "Les touches rémanentes ont été désactivées avec succès."
