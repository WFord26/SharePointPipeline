function Get-SharePointSiteId {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$sitePath
    )
    # Craft the body of the request
    $body = @{
        client_id     = $env:CLIENT_ID
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $env:CLIENT_SECRET
        grant_type    = "client_credentials"
    }
    # Construct the URL to get the site ID
    $tokenEndpoint = "https://login.microsoftonline.com/$env:TENANT_ID/oauth2/v2.0/token"
    # Get the access token
    $tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
    # Isolate the access token
    $accessToken = $tokenResponse.access_token
    
    # Set Headers
    $siteIdHeader = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    # Get Site ID
    $siteApiUrl = "https://graph.microsoft.com/v1.0/sites/$($env:SP_ROOT_SITE):$sitePath"
    $siteResponse = Invoke-RestMethod -Uri $siteApiUrl -Headers $siteIdHeader
    $siteId = $siteResponse.id
    return $siteId

}