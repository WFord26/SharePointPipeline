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
        Import-Module -Name "AzureAD" -Force
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
    if (-not $?) {
        Write-Host "Failed to connect to Azure AD" -ForegroundColor Red
        exit
    }
    # Check if the user is a global admin
    $user = Get-AzureADUser -ObjectId (Get-AzureADSignedInUser).ObjectId
    if (-not $user) {
        Write-Host "Failed to get signed-in user" -ForegroundColor Red
        exit
    }
    if ($user.UserType -ne "Member") {
        Write-Host "You are not a global admin, you need to be a global admin to create an app registration" -ForegroundColor Red
        exit
    }
    # Check if the App registration already exists
    $appRegistration = Get-AzureADApplication -Filter "displayName eq 'SPP-Graph-App'"  -ErrorAction SilentlyContinue
    if ($appRegistration) {
        Write-Host "App registration already exists" -ForegroundColor Yellow
        Write-Host "Checking the apps permissions" -ForegroundColor Yellow
        $graphServicePrincipal = Get-AzureADServicePrincipal -Filter "displayName eq 'Microsoft Graph'"
        $requiredResourceAccess = $appRegistration.RequiredResourceAccess | Where-Object { $_.ResourceAppId -eq $graphServicePrincipal.AppId }
        $resourceAccesses = $requiredResourceAccess.ResourceAccess
        $graphPermissions = @(
            "Sites.Read.All",
            "Sites.ReadWrite.All"
        )
        $missingPermissions = @()
        foreach ($permission in $graphPermissions) {
            $appRole = $graphServicePrincipal.AppRoles | Where-Object { $_.Value -eq $permission -and $_.AllowedMemberTypes -contains "Application" }
            $resourceAccess = $resourceAccesses | Where-Object { $_.Id -eq $appRole.Id }
            if (-not $resourceAccess) {
                $missingPermissions += $permission
            }
        }
        if ($missingPermissions.Count -gt 0) {
            Write-Host "The app is missing the following permissions: $($missingPermissions -join ",")" -ForegroundColor Yellow
            Write-Host "Would you like to add the missing permissions?" -ForegroundColor Yellow
            $response = Read-Host "Y/N"
            if ($response -eq "Y") {
                $requiredResourceAccess.ResourceAccess = $resourceAccesses
                Set-AzureADApplication -ObjectId $appRegistration.ObjectId -RequiredResourceAccess @($requiredResourceAccess)
                Write-Host "Permissions have been added" -ForegroundColor Green
                # Grant admin consent for the permissions https://login.microsoftonline.com/{organization}/adminconsent?client_id={client-id}
                $tenantId = (Get-AzureADTenantDetail).ObjectId
                if (-not $tenantId) {
                    Write-Host "Failed to get tenant ID" -ForegroundColor Red
                    exit
                }
                $adminConsentUrl = "https://login.microsoftonline.com/$tenantId/adminconsent?client_id=$($appRegistration.AppId)"
                Start-Process -FilePath $adminConsentUrl
                # check if consent was granted
                
            } else {
                Write-Host "Fine, but don't blame me when things don't work!" -ForegroundColor Yellow
                exit
            }
        } else {
            Write-Host "The app has the required permissions" -ForegroundColor Green
            exit
        }
        # Check if user wants to create a key file for the app
        Write-Host "Do you want to create a key file?" -ForegroundColor Yellow
        $response = Read-Host "Y/N"
        if ($response -eq "Y") {
            $spRootSite = Read-Host "Enter the root site of the SharePoint site(eg. contoso.sharepoint.com)"
            $key = @{
                TENANT_ID     = $tenantId
                CLIENT_ID     = $appRegistration.AppId
                CLIENT_SECRET = (Get-AzureADApplicationPasswordCredential -ObjectId $appRegistration.ObjectId).Value
            }
            if (-not $key["CLIENT_SECRET"]) {
                Write-Host "Failed to get client secret" -ForegroundColor Red
                exit
            }
            $key["CLIENT_SECRET"] = $key["CLIENT_SECRET"] | ConvertTo-SecureString -AsPlainText -Force
            Save-GraphApiKeys -keys $key
            if (-not $?) {
                Write-Host "Failed to save keys" -ForegroundColor Red
                exit
            }
            exit
        } else {
            Write-Host "Fine, but don't blame when these scripts don't work!" -ForegroundColor Yellow
            exit
        }
    } else {
        Write-Host "Creating app registration" -ForegroundColor Green
        # Create the app registration
        $appRegistration = New-AzureADApplication -DisplayName "SPP-Graph-App"
        # Create a description for the app
        $appRegistration.Description = "App registration for SharePointPipeline Graph API"
        # Create the secret
        $secret = New-AzureADApplicationPasswordCredential -ObjectId $appRegistration.ObjectId
        if (-not $secret) {
            Write-Host "Failed to create application password credential" -ForegroundColor Red
            exit
        }
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
        # Set Reply URL to return to PowerShell
        $replyUrl = "http://localhost"
        Set-AzureADApplication -ObjectId $appRegistration.ObjectId -ReplyUrls @($replyUrl)
        # Grant admin consent for the permissions https://login.microsoftonline.com/{organization}/adminconsent?client_id={client-id}
        $tenantId = (Get-AzureADTenantDetail).ObjectId
        if (-not $tenantId) {
            Write-Host "Failed to get tenant ID" -ForegroundColor Red
            exit
        }
        $adminConsentUrl = "https://login.microsoftonline.com/$tenantId/adminconsent?client_id=$($appRegistration.AppId)"
        Start-Process -FilePath $adminConsentUrl

        # Create Key file
        $key = @{
            TENANT_ID     = $tenantId
            CLIENT_ID     = $appRegistration.AppId
            CLIENT_SECRET = $secret.Value
        }
        Write-Host "Keys have been generated, please save them in a secure location" -ForegroundColor Green
        Write-Host "Do you want to create a key file?" -ForegroundColor Yellow
        $response = Read-Host "Y/N"
        if ($response -eq "Y") {
            $spRootSite = Read-Host "Enter the root site of the SharePoint site(eg. contoso.sharepoint.com)"
            $key.Add("SP_ROOT_SITE", $spRootSite)
            $key["CLIENT_SECRET"] = $key["CLIENT_SECRET"] | ConvertTo-SecureString -AsPlainText -Force
            Save-GraphApiKeys -keys $key
            if (-not $?) {
                Write-Host "Failed to save keys" -ForegroundColor Red
                exit
            }
            exit
        } else {
            Write-Host "Fine, but don't blame me when you forget them!" -ForegroundColor Yellow
            exit
        }
    }
}
    