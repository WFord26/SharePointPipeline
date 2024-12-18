function Copy-SharePointFile {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$sitePath,
        [Parameter(Mandatory = $true)]
        [string]$spRootSite,
        [Parameter(Mandatory = $true)]
        [string]$sharepointFileName,
        [Parameter(Mandatory = $true)]
        [string]$localPath
    )
    # Read the Graph API Keys
    Read-GraphApiKeys -spRootSite $spRootSite
    # Get the Drive ID
    Get-SharePointDriveId -sitePath $sitePath -clientId $env:CLIENT_ID -clientSecret $env:CLIENT_SECRET -tenantId $env:TENANT_ID
    # Construct the URL to get the file metadata
    $Url  = "https://graph.microsoft.com/v1.0/drives/$script:driveId/items/root:/$($sharepointFileName)"
    # Get the file metadata
    $Response =  Invoke-RestMethod -Uri $Url -Headers $script:header -Method Get -ContentType 'multipart/form-data' 
    # Download the file
    Invoke-WebRequest -Uri $Response.'@microsoft.graph.downloadUrl' -OutFile $localPath
    Write-Host "File Downloaded to $localPath" -ForegroundColor Green
}