#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required. Install Docker Desktop and retry."
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE=(docker-compose)
else
  echo "Docker Compose is required."
  exit 1
fi

echo "Starting local Hadoop cluster..."
echo "Pulling image (first run may take a few minutes)..."
docker pull neshkeev/hadoop:3.3.6-jdk-11
"${COMPOSE[@]}" up -d

echo
echo "Waiting for NameNode UI..."
for _ in $(seq 1 30); do
  if curl -sf http://localhost:9870 >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

echo
echo "Cluster started."
echo "  HDFS NameNode UI : http://localhost:9870"
echo "  HDFS RPC         : localhost:9900"
echo "  YARN ResourceMgr : http://localhost:8088"
echo "  Job History      : http://localhost:19888"
echo
echo "Wait for healthy status: docker compose ps"
echo "Run smoke test: ./scripts/smoke-test.sh"
