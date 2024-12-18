function Read-GraphApiKeys {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$spRootSite
    )
    # Seach for xml credentials file
    if ($env:OS -eq "Windows_NT") {
        $xmlFile = "$env:USERPROFILE\.graphAPI\$spRootSite-Keys.xml"
    } else {
        $xmlFile = "$env:HOME/.graphAPI/$spRootSite-Keys.xml"
    }
    if (Test-Path $xmlFile) {
        $keys = Import-Clixml -Path $xmlFile
        Write-Host "Keys found for $spRootSite" -ForegroundColor Green
        Write-Host "Importing Keys." -ForegroundColor Yellow -NoNewline
        $env:TENANT_ID = $keys.TENANT_ID
        Start-Sleep -Seconds 0.5
        Write-Host "." -NoNewline -ForegroundColor Yellow
        $env:CLIENT_ID = $keys.CLIENT_ID
        Start-Sleep -Seconds 0.5
        Write-Host "." -NoNewline -ForegroundColor Yellow
        $env:CLIENT_SECRET = $(ConvertFrom-SecureString -SecureString $keys.CLIENT_SECRET -AsPlainText)
        Start-Sleep -Seconds 0.5
        Write-Host "." -NoNewline -ForegroundColor Yellow
        $env:SP_ROOT_SITE = $keys.SP_ROOT_SITE
        Start-Sleep -Seconds 0.5
        Write-Host "." -ForegroundColor Yellow
        Write-Host "Keys imported successfully" -ForegroundColor Green
        Write-Host "Testing Keys" -ForegroundColor Yellow
        Test-GraphApiKeys
    } else {
        Write-Host "No keys found for $spRootSite" -ForegroundColor Red
        # CHeck if the user wants to create new keys?
        $createNew = Read-Host "Would you like to create new keys? (Y/N)"
        if ($createNew -eq "Y") {
            New-GraphApiKeys
        } else {
            # Check if the user wants to try again
            $tryAgain = Read-Host "Would you like to try again? (Y/N)"
            if ($tryAgain -eq "Y") {
                # Call the function again
                Get-GraphApiKeys
            } else {
                Write-Host "Well I can't help you if you don't want to help yourself" -ForegroundColor Red
                # Exit the script
                Clear-GraphApiEnvironment
            }
        }
    }
}