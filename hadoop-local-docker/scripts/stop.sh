#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT_DIR/scripts/lib.sh"

cd "$ROOT_DIR"
require_docker

"${COMPOSE[@]}" down
echo "Hadoop cluster stopped."
