@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'SharePointPipeline.psm1'

    # Version number of this module.
    ModuleVersion = '0.0.1'

    # ID used to uniquely identify this module
    GUID = '20291dd5-5046-4d7e-b156-4e3d78dc3a50'

    # Author of this module
    Author = 'William Ford'

    # Company or vendor of this module
    CompanyName = 'Managed Solution'

    # Description of the functionality provided by this module
    Description = 'Module for SharePoint Pipeline operations including authentication to Microsoft Graph API, file management in SharePoint, and app registration in Azure AD'

    # Functions to export from this module
    FunctionsToExport = @(
        'New-SppAppRegistration',
        'Request-GraphApiToken',
        'Clear-GraphApiEnvironment',
        'Upload-ToSharePoint',
        'Test-GraphApiKeys',
        'Save-GraphApiKeys',
        'Read-GraphApiKeys',
        'New-GraphApiKeys',
        'Get-SharePointSiteId',
        'Get-SharePointDriveId',
        'Copy-SharePointFile'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{

    }
}