#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$HOME/.config/opencode/agents"
SKILLS_DIR="$HOME/.config/opencode/skills"

echo ""
echo "=== Installing Code Review Agent ==="
echo ""

# Install code-reviewer agent
echo "→ Installing code-reviewer agent..."
mkdir -p "$AGENTS_DIR"
cp "$SCRIPT_DIR/agents/code-reviewer.md" "$AGENTS_DIR/code-reviewer.md"
echo "  ✓ Installed: $AGENTS_DIR/code-reviewer.md"

# Install pr-gate skill
echo "→ Installing pr-gate skill..."
mkdir -p "$SKILLS_DIR/pr-gate"
cp "$SCRIPT_DIR/skills/pr-gate/SKILL.md" "$SKILLS_DIR/pr-gate/SKILL.md"
echo "  ✓ Installed: $SKILLS_DIR/pr-gate/SKILL.md"

echo ""
echo "=== Code Review Agent Setup Complete ==="
echo ""
echo "Restart OpenCode for changes to take effect."
echo ""
echo "Usage:"
echo "  Before pushing:  'run pr-gate'"
echo "  Manual review:   '@code-reviewer review the current diff'"
echo ""