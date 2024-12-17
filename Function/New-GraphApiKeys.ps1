function New-GraphApiKeys {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Enter the root site of the SharePoint site(eg. contoso.sharepoint.com")]
        [string]$spRootSite
    )
    $tenantId = Read-Host "Enter the Tenant ID"
    $clientId = Read-Host "Enter the Client ID"
    $clientSecret = Read-Host "Enter the Client Secret" -AsSecureString
    # Confirm that all variables have been set
    if ($tenantId -and $clientId -and $clientSecret -and $spRootSite) {
        
        # Display the values to the user
        Write-Host "SP_ROOT_SITE: $spRootSite"
        Write-Host "TENANT_ID: $tenantId"
        Write-Host "CLIENT_ID: $clientId"
        Write-Host "CLIENT_SECRET: $(ConvertFrom-SecureString -SecureString $clientSecret -AsPlainText)"

        # Check if Values are correct only allow Y/N
        $correct = Read-Host "Are these values correct? (Y/N)"
        if ($correct -eq "Y") {
            $keyToSave = @{}
            $keyToSave.Add("SP_ROOT_SITE", $spRootSite)
            $keyToSave.Add("TENANT_ID", $tenantId)
            $keyToSave.Add("CLIENT_ID", $clientId)
            $keyToSave.Add("CLIENT_SECRET", $clientSecret)
            Save-GraphApiKeys -keys $keyToSave
        } else {
            # Call the function again
            Write-Host "Please enter the correct values" -ForegroundColor Red
            New-GraphApiKeys
        }
    } else {
        Write-Host "Please enter all required values" -ForegroundColor Red
        # Check if the user wants to try again
        $tryAgain = Read-Host "Would you like to try again? (Y/N)"
        if ($tryAgain -eq "Y") {
            # Call the function again
            Get-GraphApiKeys
        } else {
            Write-Host "Alright, giving up already? Maybe next time you'll get it right." -ForegroundColor Yellow
            # Exit the script
            Clear-GraphApiEnvironment
    }
}
}