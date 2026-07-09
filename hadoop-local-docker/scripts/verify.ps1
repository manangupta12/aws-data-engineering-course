$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot "lib.ps1")

Require-Docker
$compose = Resolve-ComposeCommand

Write-Host "Container status:"
& $compose[0] @($compose[1..($compose.Length - 1)] + @("ps"))

Write-Host ""
foreach ($container in Get-ClusterContainers) {
    $status = docker inspect --format='{{.State.Health.Status}}' $container 2>$null
    if ($LASTEXITCODE -ne 0) { $status = "missing" }
    Write-Host ("  {0,-18} {1}" -f $container, $status)
}

Write-Host ""
try {
    $nn = Invoke-WebRequest -Uri "http://localhost:9870" -UseBasicParsing -TimeoutSec 5
    if ($nn.StatusCode -eq 200) {
        Write-Host "NameNode UI reachable: http://localhost:9870"
    }
} catch {
    Write-Host "NameNode UI not reachable yet: http://localhost:9870"
}

try {
    $yarn = Invoke-WebRequest -Uri "http://localhost:8088" -UseBasicParsing -TimeoutSec 5
    if ($yarn.StatusCode -eq 200) {
        Write-Host "YARN UI reachable: http://localhost:8088"
    }
} catch {
    Write-Host "YARN UI not reachable yet: http://localhost:8088"
}
