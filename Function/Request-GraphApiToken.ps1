function Request-GraphApiToken {
    # Set the scope for the request
    $Scope = "https://graph.microsoft.com/.default"
    # Construct the body of the request
    $Body = @{
        client_id = $env:CLIENT_ID
        client_secret = $env:CLIENT_SECRET
        scope = $Scope
        grant_type = 'client_credentials'
    }
    # Construct the URL for the request
    $GraphUrl = "https://login.microsoftonline.com/$env:TENANT_ID/oauth2/v2.0/token"
    # Make the request
    $AuthorizationRequest = Invoke-RestMethod -Uri $GraphUrl -Method "Post" -Body $Body
    # Set the headers
    $script:header = @{
        Authorization = $AuthorizationRequest.access_token
        "Content-Type"= "application/json"
    }
    # Return the headers
    write-host "Token Acquired" -ForegroundColor Green
    return $script:header
}