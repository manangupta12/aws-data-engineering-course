$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot "lib.ps1")

Require-Docker
$compose = Resolve-ComposeCommand

Write-Host "Starting local Hadoop cluster..."
Write-Host "Pulling image (first run may take a few minutes)..."
docker pull neshkeev/hadoop:3.3.6-jdk-11
& $compose[0] @($compose[1..($compose.Length - 1)] + @("up", "-d"))

Wait-ForCluster -TimeoutSeconds 360

Write-Host ""
Write-Host "Cluster started."
Show-ClusterUrls
Write-Host ""
Write-Host "Verify anytime: .\scripts\verify.ps1"
Write-Host "Run smoke test: .\scripts\smoke-test.ps1"
