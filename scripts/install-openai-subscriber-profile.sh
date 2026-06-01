#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_CONFIG="$REPO_ROOT/opencode/oh-my-openagent.openai-subscriber.jsonc"
TARGET_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
TARGET_CONFIG="$TARGET_DIR/oh-my-openagent.jsonc"
OPENCODE_JSON="$TARGET_DIR/opencode.json"

mkdir -p "$TARGET_DIR"

if [[ ! -f "$SOURCE_CONFIG" ]]; then
  echo "Missing source config: $SOURCE_CONFIG" >&2
  exit 1
fi

backup_if_present() {
  local file="$1"

  if [[ -f "$file" ]]; then
    local backup="$file.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    echo "Backed up existing config: $backup"
  fi
}

backup_if_present "$TARGET_CONFIG"
backup_if_present "$TARGET_DIR/oh-my-openagent.json"
backup_if_present "$TARGET_DIR/oh-my-opencode.jsonc"
backup_if_present "$TARGET_DIR/oh-my-opencode.json"

cp "$SOURCE_CONFIG" "$TARGET_CONFIG"

if [[ -f "$OPENCODE_JSON" ]]; then
  if ! python3 - "$OPENCODE_JSON" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text())
except json.JSONDecodeError as exc:
    raise SystemExit(f"Could not parse opencode.json as JSON: {exc}")

plugins = data.setdefault("plugin", [])
if not isinstance(plugins, list):
    raise SystemExit("opencode.json plugin field exists but is not an array")
if "oh-my-openagent" not in plugins and "oh-my-opencode" not in plugins:
    plugins.append("oh-my-openagent")
    path.write_text(json.dumps(data, indent=2) + "\n")
    print("Registered oh-my-openagent in opencode.json plugin array")
else:
    print("oh-my-openagent/oh-my-opencode already registered in opencode.json")
PY
  then
    echo "Warning: install the plugin manually by adding \"oh-my-openagent\" to $OPENCODE_JSON plugin array." >&2
  fi
else
  cat > "$OPENCODE_JSON" <<'JSON'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["oh-my-openagent"]
}
JSON
  echo "Created opencode.json with oh-my-openagent plugin registration"
fi

echo "Installed OpenAI subscriber OMO profile:"
echo "  $TARGET_CONFIG"
echo ""
echo "Next steps:"
echo "  1. Run: opencode auth login"
echo "  2. Choose OpenAI browser/OAuth subscriber login."
echo "  3. Run: opencode models --refresh"
echo "  4. Run: oh-my-openagent doctor --verbose"
