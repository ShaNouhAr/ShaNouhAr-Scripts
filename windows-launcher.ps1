# Script PowerShell pour lister et naviguer dans un repository GitHub public
# Titre : ShaNouhAr-Scripts

# URL du repository GitHub
$repoOwner = "ShaNouhAr"
$repoName = "ShaNouhAr-Scripts"
$baseApiUrl = "https://api.github.com/repos/$repoOwner/$repoName/contents"

# Fonction pour obtenir le contenu d'un dossier depuis l'API GitHub
function Get-GitHubContent {
    param (
        [string]$url
    )

    $response = Invoke-RestMethod -Uri $url -Method Get -Headers @{ "User-Agent" = "PowerShell" }
    return $response
}

# Fonction pour afficher le contenu d'un dossier
function Show-DirectoryContent {
    param (
        [string]$url
    )

    $items = Get-GitHubContent -url $url
    $items | ForEach-Object { 
        [PSCustomObject]@{
            Number = $global:counter++
            Name   = $_.name
            Path   = $_.path
            Type   = if ($_.type -eq "dir") { "Dossier" } else { "Fichier" }
            Url    = $_.url
        }
    }
}

# Fonction pour exécuter un script localement dans une nouvelle fenêtre PowerShell en mode administrateur
function Execute-Script {
    param (
        [string]$scriptUrl,
        [string]$filePath
    )

    $scriptContent = Invoke-RestMethod -Uri $scriptUrl -Method Get -Headers @{ "User-Agent" = "PowerShell" }
    $tempScriptPath = "$env:TEMP\$filePath"
    $scriptContent | Out-File -FilePath $tempScriptPath -Encoding UTF8

    $extension = [System.IO.Path]::GetExtension($tempScriptPath)

    switch ($extension) {
        ".ps1" {
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempScriptPath`"" -Verb RunAs
        }
        ".py" {
            Start-Process python -ArgumentList "`"$tempScriptPath`"" -NoNewWindow
        }
        ".reg" {
            Start-Process regedit.exe -ArgumentList "/s `"$tempScriptPath`"" -Verb RunAs
        }
        ".bat" {
            Start-Process cmd.exe -ArgumentList "/c `"$tempScriptPath`"" -Verb RunAs
        }
        default {
            Write-Output "Type de fichier non supporté: $extension" -ForegroundColor Red
        }
    }
}

# Fonction pour afficher une interface utilisateur agréable
function Show-Interface {
    param (
        [array]$content
    )

    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "                 ShaNouhAr-Scripts             " -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan

    Write-Host "0. .. (Revenir en arrière)" -ForegroundColor White
    $content | ForEach-Object {
        if ($_.Type -eq "Dossier") {
            Write-Host ("{0}. {1}" -f $_.Number, $_.Name) -ForegroundColor Green
        } else {
            Write-Host ("{0}. {1}" -f $_.Number, $_.Name) -ForegroundColor Yellow
        }
    }

    Write-Host "`nEntrez un numéro pour naviguer ou exécuter un script, ou 'exit' pour quitter:" -ForegroundColor Yellow
}

# Initialisation de la navigation
$currentUrl = "$baseApiUrl/windows"
$parentUrls = @()
$exit = $false

while (-not $exit) {
    $global:counter = 1
    $content = Show-DirectoryContent -url $currentUrl
    Show-Interface -content $content

    $input = Read-Host

    if ($input -eq 'exit') {
        $exit = $true
    } elseif ($input -eq '0') {
        if ($parentUrls.Count -gt 0) {
            $currentUrl = $parentUrls[-1]
            $parentUrls = $parentUrls[0..($parentUrls.Count - 2)]
        } else {
            Write-Output "Vous êtes déjà à la racine." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    } elseif ($input -match '^\d+$') {
        $number = [int]$input
        $item = $content | Where-Object { $_.Number -eq $number }
        if ($item) {
            if ($item.Type -eq 'Dossier') {
                $parentUrls += $currentUrl
                $currentUrl = $item.Url
            } elseif ($item.Type -eq 'Fichier') {
                $fileUrl = $item.Url -replace 'https://api.github.com/repos/', 'https://raw.githubusercontent.com/'
                $fileUrl = $fileUrl -replace '/contents/', '/master/'
                Execute-Script -scriptUrl $fileUrl -filePath $item.Name
            }
        } else {
            Write-Output "Veuillez sélectionner un numéro valide." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    } else {
        Write-Output "Commande invalide. Essayez à nouveau." -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}
