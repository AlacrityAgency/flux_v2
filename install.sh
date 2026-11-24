#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.gemini/config/skills/flux_v2"

mkdir -p "${TARGET_DIR}/references"
cp -f "${SOURCE_DIR}/SKILL.md" "${TARGET_DIR}/SKILL.md"
cp -f "${SOURCE_DIR}/references/prompt-templates.md" "${TARGET_DIR}/references/prompt-templates.md"

echo "Installed flux_v2 skill to: ${TARGET_DIR}"
