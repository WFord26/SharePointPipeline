function Upload-ToSharePoint {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$sitePath,
        [Parameter(Mandatory = $true)]
        [string]$spRootSite = $env:SP_ROOT_SITE,
        [Parameter(Mandatory = $true)]
        [string]$clientId = $env:CLIENT_ID,
        [Parameter(Mandatory = $true)]
        [string]$clientSecret = $env:CLIENT_SECRET,
        [Parameter(Mandatory = $true)]
        [string]$tenantId = $env:TENANT_ID,
        [Parameter(Mandatory = $true)]
        [string]$sharepointFileName,
        [Parameter(Mandatory = $true)]
        [string]$localPath
    )
    # Get the Drive ID
    Get-SharePointDriveId -sitePath $sitePath -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId -spRootSite $spRootSite
    # Construct the URL to upload the file
    $Url  = "https://graph.microsoft.com/v1.0/drives/$script:driveId/items/root:/$($sharepointFileName):/content"
    try{    # Upload the file
    $fileUpload = Invoke-RestMethod -Uri $Url -Headers $script:header -Method Put -InFile $localPath -ContentType 'application/json'
    Write-Host "File Uploaded to $sitePath" -ForegroundColor Green
    }
    catch{
        Write-Host "Error uploading file to $sitePath" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}