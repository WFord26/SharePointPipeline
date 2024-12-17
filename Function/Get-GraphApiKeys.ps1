function Get-GraphApiKeys {
    $spRootSite = Read-Host "Enter the SharePoint Root Site (e.g. contoso.sharepoint.com)"
    $tenantId = Read-Host "Enter the Tenant ID"
    $clientId = Read-Host "Enter the Client ID"
    $clientSecret = Read-Host "Enter the Client Secret" -AsSecureString
    # Confirm that all variables have been set
    if ($tenantId -and $clientId -and $clientSecret -and $spRootSite) {
        # Convert the secure string to plain text
        $plainClientSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret))
        # Display the values to the user
        Write-Host "SP_ROOT_SITE: $spRootSite"
        Write-Host "TENANT_ID: $tenantId"
        Write-Host "CLIENT_ID: $clientId"
        Write-Host "CLIENT_SECRET: $plainClientSecret"
        $plainClientSecret = $null
        # Check if Values are correct only allow Y/N
        $correct = Read-Host "Are these values correct? (Y/N)"
        if ($correct -eq "Y") {
            $saveKey = @{}
            $saveKey.Add("SP_ROOT_SITE", $spRootSite)
            $saveKey.Add("TENANT_ID", $tenantId)
            $saveKey.Add("CLIENT_ID", $clientId)
            $saveKey.Add("CLIENT_SECRET", $clientSecret)
            Save-GraphApiKeys -keys $saveKey
        } else {
            # Call the function again
            Write-Host "Please enter the correct values" -ForegroundColor Red
            Get-GraphApiKeys
        }
    } else {
        Write-Host "Please enter all required values" -ForegroundColor Red
        # Check if the user wants to try again
        $tryAgain = Read-Host "Would you like to try again? (Y/N)"
        if ($tryAgain -eq "Y") {
            # Call the function again
            Get-GraphApiKeys
        } else {
            # Exit the script
            exit
    }
}
}