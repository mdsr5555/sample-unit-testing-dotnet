#!/usr/bin/env bash

set -euo pipefail

# Simple script to:
# 1. Fetch latest commit SHA from terraform-templates repo
# 2. Update all terraform-templates module refs in terraform/main.tf

REPO_API="https://api.github.com/repos/mdsr5555/terraform-templates/commits/main"
TARGET_FILE="terraform/main.tf"

echo "Fetching latest commit SHA from terraform-templates..."
SHA=$(curl -s "$REPO_API" | python3 -c 'import sys, json; print(json.load(sys.stdin)["sha"])')

if [ -z "$SHA" ]; then
  echo "Failed to fetch latest commit SHA."
  exit 1
fi

echo "Latest SHA: $SHA"
echo "Updating module refs in $TARGET_FILE ..."

python3 <<PY
import re
from pathlib import Path

target = Path("$TARGET_FILE")
sha = "$SHA"

text = target.read_text()

pattern = re.compile(
    r'git::https://github\.com/mdsr5555/terraform-templates\.git//modules/([^"?]+)\?ref=[^"]+'
)

updated = pattern.sub(
    lambda m: f'git::https://github.com/mdsr5555/terraform-templates.git//modules/{m.group(1)}?ref={sha}',
    text
)

target.write_text(updated)
PY

echo "Done."
echo "All terraform-templates module refs updated to:"
echo "$SHA"