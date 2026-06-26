#!/usr/bin/env bash
set -u

OPENCODE_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
OPENCODE_JSON="$OPENCODE_DIR/opencode.json"
TUI_JSON="$OPENCODE_DIR/tui.json"
OMO_PROFILE="$OPENCODE_DIR/oh-my-openagent.jsonc"
ECC_DIR="$OPENCODE_DIR/ecc-skills"
ECC_VERSION_FILE="$ECC_DIR/version.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

failures=0
warnings=0

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; warnings=$((warnings + 1)); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; failures=$((failures + 1)); }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

have() {
  command -v "$1" >/dev/null 2>&1
}

json_query() {
  local file="$1"
  local query="$2"

  jq -e "$query" "$file" >/dev/null 2>&1
}

echo "========================================="
echo "my-opencode-config doctor"
echo "========================================="
echo ""

if have node; then
  node_version="$(node --version)"
  case "$node_version" in
    v24.*) pass "Node LTS is active: $node_version" ;;
    *) fail "Expected Node 24 LTS, found $node_version" ;;
  esac
else
  fail "node is not on PATH"
fi

if have npm; then
  pass "npm is available: $(npm --version)"
else
  fail "npm is not on PATH"
fi

if have brew; then
  if brew list --pinned 2>/dev/null | grep -qx 'node@24'; then
    pass "Homebrew node@24 is pinned"
  else
    warn "Homebrew node@24 is not pinned"
  fi
fi

echo ""
info "OpenCode and OMO"

if have opencode; then
  pass "opencode is available: $(opencode --version)"
else
  fail "opencode is not on PATH"
fi

if have oh-my-openagent; then
  pass "oh-my-openagent is available"
  if oh-my-openagent doctor --verbose >/tmp/my-opencode-config-omo-doctor.log 2>&1; then
    pass "oh-my-openagent doctor passed"
  else
    warn "oh-my-openagent doctor reported issues; see /tmp/my-opencode-config-omo-doctor.log"
  fi
else
  fail "oh-my-openagent is not on PATH"
fi

if [ -f "$OMO_PROFILE" ]; then
  pass "OpenAI subscriber profile exists: $OMO_PROFILE"
else
  warn "OpenAI subscriber profile missing: $OMO_PROFILE"
fi

if [ -f "$TUI_JSON" ] && jq -e '((.plugin // []) | type == "array" and any(.[]?; type == "string" and (. == "oh-my-openagent" or . == "oh-my-opencode" or test("^oh-my-(openagent|opencode)/.+$"))))' "$TUI_JSON" >/dev/null 2>&1; then
  pass "OMO TUI plugin is registered"
else
  warn "OMO TUI plugin is not registered in $TUI_JSON"
fi

echo ""
info "OpenCode config boundaries"

if [ ! -f "$OPENCODE_JSON" ]; then
  fail "Missing OpenCode config: $OPENCODE_JSON"
else
  if jq empty "$OPENCODE_JSON" >/dev/null 2>&1; then
    pass "opencode.json is valid JSON"
  else
    fail "opencode.json is not valid JSON"
  fi

  if json_query "$OPENCODE_JSON" '.plugin | index("context-mode")'; then
    pass "context-mode is registered as an OpenCode plugin"
  else
    fail "context-mode missing from opencode.json plugin array"
  fi

  if json_query "$OPENCODE_JSON" '.plugin | index("oh-my-openagent") or index("oh-my-opencode")'; then
    pass "oh-my-openagent is registered as an OpenCode plugin"
  else
    fail "oh-my-openagent missing from opencode.json plugin array"
  fi

  if json_query "$OPENCODE_JSON" '.mcp["context-mode"]'; then
    fail "Remove legacy mcp.context-mode; context-mode should be plugin-only"
  else
    pass "No duplicate mcp.context-mode block"
  fi

  ecc_instruction_count="$(jq '[.instructions[]? | select(test("ecc-skills/.+/SKILL.md"))] | length' "$OPENCODE_JSON" 2>/dev/null || echo 0)"
  if [ "$ecc_instruction_count" -gt 0 ]; then
    pass "ECC instructions registered: $ecc_instruction_count"
  else
    warn "No ECC skill instructions registered in opencode.json"
  fi
fi

echo ""
info "context-mode"

if have context-mode; then
  pass "context-mode is available"
  if context-mode doctor >/tmp/my-opencode-config-context-mode-doctor.log 2>&1; then
    pass "context-mode doctor completed"
  else
    warn "context-mode doctor reported issues; see /tmp/my-opencode-config-context-mode-doctor.log"
  fi
else
  fail "context-mode is not on PATH"
fi

echo ""
info "ECC"

if [ -d "$ECC_DIR" ]; then
  skill_count="$(find "$ECC_DIR" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
  pass "ECC skills installed: $skill_count"
else
  warn "ECC skills directory missing: $ECC_DIR"
fi

if [ -f "$ECC_VERSION_FILE" ]; then
  ecc_version="$(head -n 1 "$ECC_VERSION_FILE")"
  case "$ecc_version" in
    *rc*|*alpha*|*beta*) warn "ECC version is prerelease: $ecc_version" ;;
    v1.10.0) pass "ECC stable version installed: $ecc_version" ;;
    *) warn "ECC version differs from curated default v1.10.0: $ecc_version" ;;
  esac
else
  warn "ECC version file missing: $ECC_VERSION_FILE"
fi

echo ""
echo "========================================="
if [ "$failures" -gt 0 ]; then
  echo -e "${RED}Doctor failed:${NC} $failures failure(s), $warnings warning(s)"
  exit 1
fi

echo -e "${GREEN}Doctor passed:${NC} 0 failures, $warnings warning(s)"
if [ "$warnings" -gt 0 ]; then
  exit 2
fi
