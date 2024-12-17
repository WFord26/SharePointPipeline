function Test-GraphApiKeys {
    # Check if keys work against tenant
    $body = @{
        grant_type    = "client_credentials"
        client_id     = $env:CLIENT_ID
        client_secret = $env:CLIENT_SECRET
        scope         = "https://graph.microsoft.com/.default"
    }

    $response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$env:TENANT_ID/oauth2/v2.0/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body

    if ($response.access_token) {
        Write-Output "API keys are valid." -ForegroundColor Green
    } else {
        Write-Output "API keys are invalid." -ForegroundColor Red
        # Ask user if they want to create new keys
        $response = Read-Host "Would you like to create new keys? (y/n)"
        if ($response -eq "y") {
            # Create new keys
            New-GraphApiKeys
        } else {
            Write-Output "Alright, suit yourself. Don't come crying to me when things break!" -ForegroundColor Yellow
            # Clear environment variables
            Clear-GraphApiEnvironment
        }
    }

}