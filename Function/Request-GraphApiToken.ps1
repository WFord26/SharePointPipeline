function Request-GraphApiToken {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$tenantId,
        [Parameter(Mandatory = $true)]
        [string]$clientId,
        [Parameter(Mandatory = $true)]
        [string]$clientSecret
    )
    # Set the scope for the request
    $Scope = "https://graph.microsoft.com/.default"
    # Construct the body of the request
    $Body = @{
        client_id = $clientId
        client_secret = $clientSecret
        scope = $Scope
        grant_type = 'client_credentials'
    }
    # Construct the URL for the request
    $GraphUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    # Make the request
    $AuthorizationRequest = Invoke-RestMethod -Uri $GraphUrl -Method "Post" -Body $Body
    # Isolate the access token
    $Access_token = $AuthorizationRequest.Access_token
    # Set the headers
    $script:header = @{
        Authorization = $AuthorizationRequest.access_token
        "Content-Type"= "application/json"
    }
    # Return the headers
    write-host "Token Acquired" -ForegroundColor Green
    return $script:header
}