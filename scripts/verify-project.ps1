$root = Split-Path -Parent $PSScriptRoot
Write-Host "NebulaOS project structure:" -ForegroundColor Cyan
Get-ChildItem $root | Select-Object Name, Mode
Write-Host ""
Write-Host "Project files:" -ForegroundColor Cyan
Get-ChildItem $root -Recurse -File | Select-Object FullName | ForEach-Object { $_.FullName.Replace($root + '\', '') }
