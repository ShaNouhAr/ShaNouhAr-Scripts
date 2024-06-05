$folderPath = Read-Host -Prompt "Entrez le chemin complet du dossier"
$oldExtension = Read-Host -Prompt "Entrez l’extension actuelle des fichiers (par exemple, .txt)"
$newExtension = Read-Host -Prompt "Entrez la nouvelle extension pour les fichiers (par exemple, .docx)"

Get-ChildItem -Path $folderPath -Filter *$oldExtension | ForEach-Object {
    $newFileName = [IO.Path]::ChangeExtension($_.Name, $newExtension)
    $newFilePath = Join-Path -Path $_.Directory -ChildPath $newFileName
    Rename-Item -Path $_.FullName -NewName $newFilePath
}
