#!/usr/bin/env bash

resolve_compose() {
  if docker compose version >/dev/null 2>&1; then
    COMPOSE=(docker compose)
  elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE=(docker-compose)
  else
    echo "Docker Compose is required. Install Docker Desktop or the compose plugin."
    exit 1
  fi
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required. Install Docker Desktop (Mac/Windows) or Docker Engine (Linux)."
    exit 1
  fi
  resolve_compose
}

cluster_containers() {
  echo "namenode resourcemanager historyserver proxyserver worker-1 worker-2 worker-3"
}

wait_for_cluster() {
  local timeout="${1:-300}"
  local elapsed=0
  local interval=5

  echo "Waiting for all cluster containers to become healthy..."
  while [[ "$elapsed" -lt "$timeout" ]]; do
    local all_healthy=true
    for container in $(cluster_containers); do
      local status
      status="$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "missing")"
      if [[ "$status" != "healthy" ]]; then
        all_healthy=false
        break
      fi
    done

    if [[ "$all_healthy" == "true" ]]; then
      echo "All containers are healthy."
      return 0
    fi

    sleep "$interval"
    elapsed=$((elapsed + interval))
  done

  echo "Cluster did not become healthy within ${timeout}s."
  echo "Run: docker compose ps"
  echo "Logs: docker compose logs namenode worker-1 resourcemanager"
  exit 1
}

print_cluster_urls() {
  echo "  HDFS NameNode UI : http://localhost:9870"
  echo "  HDFS RPC         : localhost:9900"
  echo "  YARN ResourceMgr : http://localhost:8088"
  echo "  Job History      : http://localhost:19888"
}
