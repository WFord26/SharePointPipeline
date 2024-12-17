function Get-SharePointDriveId {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$sitePath,
        [Parameter(Mandatory = $true)]
        [string]$clientId,
        [Parameter(Mandatory = $true)]
        [string]$clientSecret,
        [Parameter(Mandatory = $true)]
        [string]$tenantId
    )
    # Get the access token
    Request-GraphApiToken -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret
    # Get the site ID
    Get-SharePointSiteId -sitePath $sitePath -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId
    # Construct the URL to get the drive ID
    $GraphUrl = "https://graph.microsoft.com/v1.0/sites/$SiteID/drives"
    # Take $Body and convert it to JSON
    $spRootSite = $Body | ConvertTo-Json -Compress
    # Get the drive ID
    $Result = Invoke-RestMethod -Uri $GraphUrl -Method 'GET' -Headers $script:header -ContentType "application/json" 
    # Isolate the Drive ID
    $script:driveId = $Result.value.id
    # Return the Drive ID
    Write-Host "Drive ID:" -ForegroundColor Green
    return $script:driveId
}