#!/usr/bin/env bash
# Install Galaxy collections from requirements.yml (same pattern as ansible-pihole CI).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

COL="${ANSIBLE_COLLECTIONS_INSTALL_PATH:-$ROOT/.ansible/collections}"
mkdir -p "$COL"

if [[ -f "$ROOT/requirements.yml" ]]; then
  ansible-galaxy collection install -r "$ROOT/requirements.yml" -p "$COL" --force
fi
