#!/usr/bin/env bash
set -euo pipefail

GITLEAKS_IMAGE="${GITLEAKS_IMAGE:-ghcr.io/gitleaks/gitleaks:v8.24.3}"
REPO_DIR="${REPO_DIR:-$PWD}"

docker run --rm \
  -e GIT_CONFIG_COUNT=1 \
  -e GIT_CONFIG_KEY_0=safe.directory \
  -e GIT_CONFIG_VALUE_0=/repo \
  -v "${REPO_DIR}:/repo" \
  "${GITLEAKS_IMAGE}" \
  detect \
  --source /repo \
  --config /repo/.gitleaks.toml \
  --redact \
  --verbose \
  --exit-code 1
