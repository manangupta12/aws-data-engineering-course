function Resolve-ComposeCommand {
    docker compose version 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        return @("docker", "compose")
    }

    if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
        return @("docker-compose")
    }

    throw "Docker Compose is required. Install Docker Desktop or the compose plugin."
}

function Require-Docker {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Docker is required. Install Docker Desktop (Windows/Mac) or Docker Engine (Linux)."
    }
}

function Get-ClusterContainers {
    return @(
        "namenode",
        "resourcemanager",
        "historyserver",
        "proxyserver",
        "worker-1",
        "worker-2",
        "worker-3"
    )
}

function Wait-ForCluster {
    param(
        [int]$TimeoutSeconds = 300,
        [int]$IntervalSeconds = 5
    )

    Write-Host "Waiting for all cluster containers to become healthy..."
    $elapsed = 0

    while ($elapsed -lt $TimeoutSeconds) {
        $allHealthy = $true
        foreach ($container in Get-ClusterContainers) {
            $status = docker inspect --format='{{.State.Health.Status}}' $container 2>$null
            if ($LASTEXITCODE -ne 0 -or $status -ne "healthy") {
                $allHealthy = $false
                break
            }
        }

        if ($allHealthy) {
            Write-Host "All containers are healthy."
            return
        }

        Start-Sleep -Seconds $IntervalSeconds
        $elapsed += $IntervalSeconds
    }

    throw "Cluster did not become healthy within ${TimeoutSeconds}s. Run: docker compose ps"
}

function Show-ClusterUrls {
    Write-Host "  HDFS NameNode UI : http://localhost:9870"
    Write-Host "  HDFS RPC         : localhost:9900"
    Write-Host "  YARN ResourceMgr : http://localhost:8088"
    Write-Host "  Job History      : http://localhost:19888"
}
