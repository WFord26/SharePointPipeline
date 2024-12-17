function Get-SharePointSiteId {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$sitePath,
        [Parameter(Mandatory = $true)]
        [string]$spRootSite,
        [Parameter(Mandatory = $true)]
        [string]$clientId,
        [Parameter(Mandatory = $true)]
        [string]$clientSecret,
        [Parameter(Mandatory = $true)]
        [string]$tenantId
    )
    # Craft the body of the request
    $body = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }
    # Construct the URL to get the site ID
    $tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    # Get the access token
    $tokenResponse = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
    # Isolate the access token
    $accessToken = $tokenResponse.access_token
    
    # Set Headers
    $siteIdHeader = @{
        "Authorization" = "Bearer $accessToken"
    }
    
    # Get Site ID
    $siteApiUrl = "https://graph.microsoft.com/v1.0/sites/$($spRootSite):$sitePath"
    $siteResponse = Invoke-RestMethod -Uri $siteApiUrl -Headers $siteIdHeader
    $siteId = $siteResponse.id
    return $siteId

}