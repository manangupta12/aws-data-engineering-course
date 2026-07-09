$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is required. Install Docker Desktop and retry."
}

Write-Host "Starting local Hadoop cluster..."
Write-Host "Pulling image (first run may take a few minutes)..."
docker pull neshkeev/hadoop:3.3.6-jdk-11
docker compose up -d

Write-Host ""
Write-Host "Waiting for NameNode UI..."
for ($i = 0; $i -lt 30; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:9870" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) { break }
    } catch {
        Start-Sleep -Seconds 5
    }
}

Write-Host ""
Write-Host "Cluster started."
Write-Host "  HDFS NameNode UI : http://localhost:9870"
Write-Host "  HDFS RPC         : localhost:9900"
Write-Host "  YARN ResourceMgr : http://localhost:8088"
Write-Host "  Job History      : http://localhost:19888"
Write-Host ""
Write-Host "Wait for healthy status: docker compose ps"
Write-Host "Run smoke test: .\scripts\smoke-test.ps1"
