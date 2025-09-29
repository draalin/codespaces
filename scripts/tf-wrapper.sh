#!/usr/bin/env bash
set -euo pipefail

# Wrapper to automatically pick AWS profile from nearest .aws-profile file
# Falls back to existing AWS_PROFILE if present.

find_profile_file() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.aws-profile" ]]; then
      cat "$dir/.aws-profile"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

if PROFILE_FILE_CONTENT=$(find_profile_file); then
  export AWS_PROFILE="$PROFILE_FILE_CONTENT"
fi

exec terraform "$@"
