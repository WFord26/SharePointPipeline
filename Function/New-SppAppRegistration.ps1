function New-SppAppRegistration {
    # Check if processor architecture is arm or amd64
    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64" -or $env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
        # Check if the AzureAD module is installed if it is not installed ask if they would like to install it
        if (-not (Get-Module -Name "AzureAD" -ListAvailable)) {
            Write-Host "AzureAD module not found. Would you like to install it?" -ForegroundColor Red
            $response = Read-Host "Y/N"
            if ($response -eq "Y") {
                Install-Module -Name "AzureAD" -Force
            } else {
                Write-Host "Fine, you can do it manually I guess." -ForegroundColor Yellow
                exit
            }
        }
        Import-Moudle -Name "AzureAD" -Force
    } else {
        # install azuread module for arm
        if (-not (Get-Module -Name "AzureAD.Standard.Preview" -ListAvailable)) {
            Write-Host "AzureAD.Standard.Preview module not found. Would you like to install it?" -ForegroundColor Red
            $response = Read-Host "Y/N"
            if ($response -eq "Y") {
                Install-Module -Name "AzureAD.Standard.Preview" -Force
            } else {
                Write-Host "Fine, you can do it manually I guess." -ForegroundColor Yellow
                exit   
            }
        }
        Import-Module -Name "AzureAD.Standard.Preview" -Force
    }
    # Connect to Azure AD
    Connect-AzureAD
    # Create the app registration
    $appRegistration = New-AzureADApplication -DisplayName "SPP-Graph-App"
    # Create the service principal
    $servicePrincipal = New-AzureADServicePrincipal -AppId $appRegistration.AppId
    # Creare a description for the app
    $appRegistration.Description = "App registration for SharePointPipeline Graph API"
    # Create the secret
    $secret = New-AzureADApplicationPasswordCredential -ObjectId $appRegistration.ObjectId
    # Add Graph API permissions Site.Read.All and Site.ReadWrite.All
    $graphPermissions = @(
        "Sites.Read.All",
        "Sites.ReadWrite.All"
    )

    $graphServicePrincipal = Get-AzureADServicePrincipal -Filter "displayName eq 'Microsoft Graph'"
    $requiredResourceAccess = New-Object -TypeName Microsoft.Open.AzureAD.Model.RequiredResourceAccess
    $requiredResourceAccess.ResourceAppId = $graphServicePrincipal.AppId

    $resourceAccesses = @()
    foreach ($permission in $graphPermissions) {
        $appRole = $graphServicePrincipal.AppRoles | Where-Object { $_.Value -eq $permission -and $_.AllowedMemberTypes -contains "Application" }
        $resourceAccess = New-Object -TypeName Microsoft.Open.AzureAD.Model.ResourceAccess
        $resourceAccess.Id = $appRole.Id
        $resourceAccess.Type = "Role"
        $resourceAccesses += $resourceAccess
    }

    $requiredResourceAccess.ResourceAccess = $resourceAccesses
    Set-AzureADApplication -ObjectId $appRegistration.ObjectId -RequiredResourceAccess @($requiredResourceAccess)
    # Set Reply URL to retunr to PowerShell
    $replyUrl = "http://localhost"
    Set-AzureADApplication -ObjectId $appRegistration.ObjectId -ReplyUrls @($replyUrl)
    # Grant admin consent for the permissions https://login.microsoftonline.com/{organization}/adminconsent?client_id={client-id}
    $tenantId = (Get-AzureADTenantDetail).ObjectId
    $adminConsentUrl = "https://login.microsoftonline.com/$tenantId/adminconsent?client_id=$($appRegistration.AppId)"
    Start-Process -FilePath $adminConsentUrl

    # Create Key file
    $key = @{
        TENANT_ID     = $tenantId
        CLIENT_ID     = $appRegistration.AppId
        CLIENT_SECRET = $secret.Value
    }
    $key
    Write-Host "Keys have been generated, please save them in a secure location" -ForegroundColor Green
    Write-Host "Do you want to create a key file?" -ForegroundColor Yellow
    $response = Read-Host "Y/N"
    if ($response -eq "Y") {
        $spRootSite = Read-Host "Enter the root site of the SharePoint site(eg. contoso.sharepoint.com)"
        $key.Add("SP_ROOT_SITE", $spRootSite)
        Save-GraphApiKeys -keys $key
        exit
    } else {
        Write-Host "Fine, but don't blame me when you forget them!" -ForegroundColor Yellow
        exit
}
}