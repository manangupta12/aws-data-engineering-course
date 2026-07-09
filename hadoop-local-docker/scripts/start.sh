#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT_DIR/scripts/lib.sh"

cd "$ROOT_DIR"
require_docker

echo "Starting local Hadoop cluster..."
echo "Pulling image (first run may take a few minutes)..."
docker pull neshkeev/hadoop:3.3.6-jdk-11
"${COMPOSE[@]}" up -d

wait_for_cluster 360

echo
echo "Cluster started."
print_cluster_urls
echo
echo "Verify anytime: ./scripts/verify.sh"
echo "Run smoke test: ./scripts/smoke-test.sh"
