#!/usr/bin/env bash
set -euo pipefail

HOOK_SRC="scripts/pre-push"
HOOK_DST=".git/hooks/pre-push"

if [ ! -f "$HOOK_SRC" ]; then
  echo "Hook source introuvable: $HOOK_SRC" >&2
  exit 1
fi

mkdir -p .git/hooks
cp "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"

echo "Hook pre-push installé dans $HOOK_DST"

