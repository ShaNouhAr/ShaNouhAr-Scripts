import subprocess

# Commande PowerShell pour changer la langue sans interaction manuelle
ps_command = """
$LangList = Get-WinUserLanguageList
$LangList[0] = 'fr-FR'
Set-WinUserLanguageList $LangList -Force
"""

# Exécuter la commande PowerShell depuis Python
try:
    subprocess.run(['powershell', '-Command', ps_command], check=True)
    print("La langue du système a été modifiée sans confirmation.")
except subprocess.CalledProcessError as e:
    print(f"Erreur lors du changement de langue : {e}")
