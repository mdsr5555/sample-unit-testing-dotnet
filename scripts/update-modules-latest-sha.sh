#!/usr/bin/env bash

set -euo pipefail

REPO_API="https://api.github.com/repos/mdsr5555/terraform-templates/commits/main"
TARGET_FILE="terraform/main.tf"

echo "Fetching latest commit SHA from terraform-templates..."

SHA=$(
  curl -fsSL "$REPO_API" |
    sed -n 's/^[[:space:]]*"sha":[[:space:]]*"\([0-9a-f]\{40\}\)".*/\1/p' |
    head -n 1
)

if [ -z "$SHA" ]; then
  echo "Failed to fetch latest commit SHA."
  exit 1
fi

echo "Latest SHA: $SHA"
echo "Updating module refs in $TARGET_FILE ..."

TMP_FILE="$(mktemp)"

sed -E \
  "s#git::https://github\.com/mdsr5555/terraform-templates\.git//modules/([^\"?]+)\?ref=[^\"]+#git::https://github.com/mdsr5555/terraform-templates.git//modules/\1?ref=${SHA}#g" \
  "$TARGET_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$TARGET_FILE"

echo "Done."
echo "All terraform-templates module refs updated to:"
echo "$SHA"
