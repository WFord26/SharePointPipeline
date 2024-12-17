function Save-GraphApiKeys {
    param (
        [hashtable]$keys
    )
    # Create the directory if it doesn't exist $env:USERPROFILE\.graphAPI
    if (-Not (Test-Path "$env:USERPROFILE\.graphAPI")) {
        New-Item -ItemType Directory -Path "$env:USERPROFILE\.graphAPI"
    }
    Write-Host "Saving keys." -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "." -NoNewline -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    Write-Host "." -NoNewline -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    Write-Host "." -ForegroundColor Yellow
    $spRootSite = $keys.SP_ROOT_SITE
    $keys | Export-Clixml -Path "$env:USERPROFILE\.graphAPI\$spRootSite-Keys.xml"
    Write-Host "Keys saved successfully" -ForegroundColor Green
}