#!/usr/bin/env bash
set -euo pipefail

# Ensures INFRACOST_API_KEY is present or guides user
if [[ -z "${INFRACOST_API_KEY:-}" ]]; then
  echo "INFRACOST_API_KEY not set. Export it or create ~/.config/infracost/credentials.yml" >&2
  exit 1
fi

infracost breakdown --path . --format table "$@"
