#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

python -m pip install --upgrade pip
pip install -r requirements-dev.txt
flake8 lambda tests --max-line-length=100 --exclude=__pycache__
pytest tests/ -v

echo ""
echo "Local checks passed. Next: push to GitHub or run 'terraform plan' in infra/terraform."
