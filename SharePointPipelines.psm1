# Dot-source each function script
Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 | ForEach-Object { . $_.FullName }