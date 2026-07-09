$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

docker compose down
Write-Host "Hadoop cluster stopped."
