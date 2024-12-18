function Get-SharePointDriveId {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$sitePath
    )
    # Get the access token
    Request-GraphApiToken -tenantId $env:TENANT_ID -clientId $env:CLIENT_ID -clientSecret $env:CLIENT_SECRET
    # Get the site ID
    Get-SharePointSiteId -sitePath $sitePath -clientId $env:CLIENT_ID -clientSecret $env:CLIENT_SECRET -tenantId $env:TENANT_ID
    # Construct the URL to get the drive ID
    $GraphUrl = "https://graph.microsoft.com/v1.0/sites/$SiteID/drives"
    # Get the drive ID
    $Result = Invoke-RestMethod -Uri $GraphUrl -Method 'GET' -Headers $script:header -ContentType "application/json" 
    # Isolate the Drive ID
    $script:driveId = $Result.value.id
    # Return the Drive ID
    Write-Host "Drive ID:" -ForegroundColor Green
    return $script:driveId
}