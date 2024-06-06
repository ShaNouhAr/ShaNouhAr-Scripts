# Disable Sticky Keys for the current user
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name "Flags" -Value 506
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\Keyboard Response' -Name "Flags" -Value 122
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\ToggleKeys' -Name "Flags" -Value 58

# Load the default user hive
reg load HKU\DefaultUser C:\Users\Default\NTUSER.DAT

# Disable Sticky Keys for the default user
Set-ItemProperty -Path 'HKU\DefaultUser\Control Panel\Accessibility\StickyKeys' -Name "Flags" -Value 506
Set-ItemProperty -Path 'HKU\DefaultUser\Control Panel\Accessibility\Keyboard Response' -Name "Flags" -Value 122
Set-ItemProperty -Path 'HKU\DefaultUser\Control Panel\Accessibility\ToggleKeys' -Name "Flags" -Value 58

# Unload the default user hive
reg unload HKU\DefaultUser

# Inform the user that the operation is complete
Write-Output "Les touches rémanentes ont été désactivées avec succès."
