function Clear-GraphApiEnvironment {
    # Clear environment variables
    $env:TENANT_ID = $null
    $env:CLIENT_ID = $null
    $env:CLIENT_SECRET = $null
    Write-Output "Environment variables cleared." -ForegroundColor Yellow
    Exit
}