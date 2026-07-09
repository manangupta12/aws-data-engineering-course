#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT_DIR/scripts/lib.sh"

cd "$ROOT_DIR"
require_docker

echo "Container status:"
"${COMPOSE[@]}" ps

echo
for container in $(cluster_containers); do
  status="$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "missing")"
  printf "  %-18s %s\n" "$container" "$status"
done

echo
if curl -sf http://localhost:9870 >/dev/null 2>&1; then
  echo "NameNode UI reachable: http://localhost:9870"
else
  echo "NameNode UI not reachable yet: http://localhost:9870"
fi

if curl -sf http://localhost:8088 >/dev/null 2>&1; then
  echo "YARN UI reachable: http://localhost:8088"
else
  echo "YARN UI not reachable yet: http://localhost:8088"
fi
