#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/target" >&2
  exit 1
fi
TARGET=$1
shift || true

INCLUDE=(
  .devcontainer
  .pre-commit-config.yaml
  Makefile
  scripts
  .gitignore
  README.md
  .env.example
  .secrets.baseline
  .github/workflows/terraform-ci.yml
  infrastructure/modules
  infrastructure/env
)

mkdir -p "$TARGET"

for item in "${INCLUDE[@]}"; do
  if [[ -e "$item" ]]; then
    rsync -a --exclude '*/.terraform/' --exclude '*.tfstate*' "$item" "$TARGET"/
  fi
done

echo "Template exported to $TARGET"
echo "Next steps:"
echo "1. Edit infrastructure/env/dev/main.tf backend config (bucket, lock table)."
echo "2. Remove unwanted example modules."
echo "3. Update README badges (repo path)."
echo "4. Run: (cd $TARGET/infrastructure/env/dev && terraform init)"
