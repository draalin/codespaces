#!/usr/bin/env bash
set -euo pipefail

# Simple health check to ensure critical tools are present
for bin in terraform aws unzip jq git tflint terraform-docs terragrunt infracost; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "missing:$bin" >&2
    exit 1
  fi
done

# Terraform version sanity
terraform -version | head -n1
aws --version

exit 0
