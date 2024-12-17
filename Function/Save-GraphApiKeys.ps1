function Save-GraphApiKeys {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$keys
    )
    # Check the operating system
    if ($env:OS -eq "Windows_NT") {
        $outPath = "$env:USERPROFILE\.graphAPI"
        # Create the directory if it doesn't exist $env:USERPROFILE\.graphAPI
        if (-Not (Test-Path "$outPath")) {
            New-Item -ItemType Directory -Path "$env:USERPROFILE\.graphAPI"
            Write-Host "Directory created at $outPath" -ForegroundColor Green
        }
    } else {
        $outPath = "$env:HOME/.graphAPI"
        # Create the directory if it doesn't exist $env:HOME/.graphAPI
        if (-Not (Test-Path "$outPath")) {
            New-Item -ItemType Directory -Path "$env:HOME/.graphAPI"
            Write-Host "Directory created" -ForegroundColor Green
        }
    }
    Write-Host "Saving keys." -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "." -NoNewline -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    Write-Host "." -NoNewline -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    Write-Host "." -ForegroundColor Yellow
    $spRootSite = $keys.SP_ROOT_SITE
    if ($env:OS -eq "Windows_NT") {
        $keys | Export-Clixml -Path "$env:USERPROFILE\.graphAPI\$spRootSite-Keys.xml"
    } else {
        $keys | Export-Clixml -Path "$env:HOME/.graphAPI/$spRootSite-Keys.xml"
    }
    Write-Host "Keys saved successfully" -ForegroundColor Green
    Read-GraphApiKeys -spRootSite $spRootSite
}