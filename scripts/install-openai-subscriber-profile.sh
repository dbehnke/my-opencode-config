#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_CONFIG="$REPO_ROOT/opencode/oh-my-openagent.openai-subscriber.jsonc"
TARGET_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
TARGET_CONFIG="$TARGET_DIR/oh-my-openagent.jsonc"

mkdir -p "$TARGET_DIR"

if [[ ! -f "$SOURCE_CONFIG" ]]; then
  echo "Missing source config: $SOURCE_CONFIG" >&2
  exit 1
fi

if [[ -f "$TARGET_CONFIG" ]]; then
  BACKUP="$TARGET_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$TARGET_CONFIG" "$BACKUP"
  echo "Backed up existing config: $BACKUP"
fi

cp "$SOURCE_CONFIG" "$TARGET_CONFIG"

echo "Installed OpenAI subscriber OMO profile:"
echo "  $TARGET_CONFIG"
echo ""
echo "Next steps:"
echo "  1. Ensure oh-my-openagent is registered in ~/.config/opencode/opencode.json plugin array."
echo "  2. Run: opencode auth login"
echo "  3. Choose OpenAI browser/OAuth subscriber login."
echo "  4. Run: opencode models --refresh"
echo "  5. Run: bunx oh-my-openagent doctor --verbose"
