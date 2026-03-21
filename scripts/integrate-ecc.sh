#!/bin/bash
#
# integrate-ecc.sh - Integrate ECC skills with OpenCode configuration
#
# This script updates opencode.json and AGENTS.md to reference ECC skills
# while maintaining compatibility with context-mode and superpowers.

set -e

# Configuration
OPENCODE_DIR="$HOME/.config/opencode"
OPENCODE_JSON="$OPENCODE_DIR/opencode.json"
AGENTS_MD="${PWD}/AGENTS.md"
ECC_SKILLS_DIR="$OPENCODE_DIR/ecc-skills"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Backup file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}${BACKUP_SUFFIX}"
        log_info "Backed up: $file"
    fi
}

# Update opencode.json
update_opencode_json() {
    log_info "Updating opencode.json..."
    
    if [ ! -f "$OPENCODE_JSON" ]; then
        log_error "opencode.json not found at: $OPENCODE_JSON"
        return 1
    fi
    
    backup_file "$OPENCODE_JSON"
    
    # Create temporary file with updated configuration
    local temp_file=$(mktemp)
    
    # Check if instructions array already exists
    if grep -q '"instructions"' "$OPENCODE_JSON"; then
        log_warn "Instructions array already exists in opencode.json"
        log_info "Please manually add ECC skills to the instructions array"
        echo ""
        echo "Add these lines to your instructions array:"
        echo '"~/.config/opencode/ecc-skills/golang-patterns/SKILL.md",'
        echo '"~/.config/opencode/ecc-skills/golang-testing/SKILL.md",'
        echo '"~/.config/opencode/ecc-skills/frontend-patterns/SKILL.md",'
        echo '"~/.config/opencode/ecc-skills/python-patterns/SKILL.md",'
        echo '"~/.config/opencode/ecc-skills/python-testing/SKILL.md",'
        echo '"~/.config/opencode/ecc-skills/rust-patterns/SKILL.md",'
        echo '"~/.config/opencode/ecc-skills/security-review/SKILL.md",'
        echo '"~/.config/opencode/ecc-skills/documentation-lookup/SKILL.md",'
    else
        # Add instructions array before the closing brace
        python3 << 'EOF' - "$OPENCODE_JSON" "$temp_file"
import json
import sys

with open(sys.argv[1], 'r') as f:
    config = json.load(f)

# Add instructions array with ECC skills
config['instructions'] = [
    "~/.config/opencode/ecc-skills/golang-patterns/SKILL.md",
    "~/.config/opencode/ecc-skills/golang-testing/SKILL.md",
    "~/.config/opencode/ecc-skills/frontend-patterns/SKILL.md",
    "~/.config/opencode/ecc-skills/backend-patterns/SKILL.md",
    "~/.config/opencode/ecc-skills/api-design/SKILL.md",
    "~/.config/opencode/ecc-skills/python-patterns/SKILL.md",
    "~/.config/opencode/ecc-skills/python-testing/SKILL.md",
    "~/.config/opencode/ecc-skills/rust-patterns/SKILL.md",
    "~/.config/opencode/ecc-skills/security-review/SKILL.md",
    "~/.config/opencode/ecc-skills/documentation-lookup/SKILL.md",
    "~/.config/opencode/ecc-skills/search-first/SKILL.md"
]

with open(sys.argv[2], 'w') as f:
    json.dump(config, f, indent=2)

print("Added instructions array with ECC skills")
EOF
        
        mv "$temp_file" "$OPENCODE_JSON"
        log_success "Updated opencode.json with ECC skills"
    fi
}

# Update AGENTS.md
update_agents_md() {
    log_info "Updating AGENTS.md..."
    
    if [ ! -f "$AGENTS_MD" ]; then
        log_warn "AGENTS.md not found at: $AGENTS_MD"
        log_info "Creating new AGENTS.md..."
        create_agents_md
        return
    fi
    
    backup_file "$AGENTS_MD"
    
    # Check if ECC section already exists
    if grep -q "## ECC Skills Reference" "$AGENTS_MD"; then
        log_warn "ECC Skills section already exists in AGENTS.md"
        log_info "Skipping AGENTS.md update"
        return
    fi
    
    # Append ECC section to AGENTS.md
    cat >> "$AGENTS_MD" << 'EOF'

## ECC Skills Reference

The following ECC skills are available for language-specific patterns and domain knowledge.
Use these to complement superpowers' process skills.

### Language-Specific Patterns

**Go**
- **golang-patterns** - Idiomatic Go patterns, concurrency, error handling
- **golang-testing** - Go testing patterns, TDD, benchmarks
- **go-reviewer** agent - Go code review specialist

**TypeScript/JavaScript**
- **frontend-patterns** - React, Next.js patterns
- **backend-patterns** - API, database, caching patterns
- **api-design** - REST API design, pagination, error responses
- **e2e-testing** - Playwright E2E patterns
- **typescript-reviewer** agent - TypeScript code review

**Python**
- **python-patterns** - Pythonic idioms, PEP 8, type hints
- **python-testing** - Python testing with pytest
- **python-reviewer** agent - Python code review

**Rust**
- **rust-patterns** - Idiomatic Rust patterns, ownership, error handling
- **rust-testing** - Rust testing patterns
- **rust-reviewer** agent - Rust code review

### Security & Documentation

- **security-review** - Security audit checklist and patterns
- **security-reviewer** agent - Security-focused code review
- **documentation-lookup** - API reference research
- **docs-lookup** agent - Documentation lookup specialist
- **search-first** - Research-before-coding methodology

### Skill Selection Guide

**When to use Superpowers vs ECC:**

| Task Type | Use This | Not That |
|-----------|----------|----------|
| TDD workflow | Superpowers `test-driven-development` | ECC `tdd-workflow` |
| Verification | Superpowers `verification-before-completion` | ECC `verification-loop` |
| Code review process | Superpowers `requesting-code-review` | ECC general code-review |
| Go idioms & patterns | ECC `golang-patterns` | - |
| Security audit | ECC `security-review` | - |
| API design | ECC `api-design` | - |

**Usage Examples:**
- "Use golang-patterns to refactor this handler"
- "Apply security-review to the authentication module"
- "Use api-design principles for this endpoint"
EOF

    log_success "Updated AGENTS.md with ECC skills reference"
}

# Create new AGENTS.md
create_agents_md() {
    log_info "Creating AGENTS.md..."
    
    cat > "$AGENTS_MD" << 'EOF'
# AGENTS.md - Agentic Coding Guidelines

## Context-Mode Routing Rules

You have context-mode MCP tools available. These rules protect your context window.

### BLOCKED Commands
- **curl / wget**: Use `ctx_fetch_and_index(url, source)` instead
- **Inline HTTP**: Use `ctx_execute(language, code)` instead

### REDIRECTED Tools
- **Shell (>20 lines)**: Use `ctx_batch_execute` or `ctx_execute`
- **File analysis**: Use `ctx_execute_file(path, language, code)`

### Tool Selection Hierarchy
1. **GATHER**: `ctx_batch_execute(commands, queries)`
2. **FOLLOW-UP**: `ctx_search(queries)`
3. **PROCESSING**: `ctx_execute` or `ctx_execute_file`
4. **WEB**: `ctx_fetch_and_index` then `ctx_search`

## Superpowers Skills Reference

These skills trigger automatically and enforce development discipline:

- **brainstorming** - Socratic design refinement (auto-triggers before coding)
- **test-driven-development** - RED-GREEN-REFACTOR cycle
- **systematic-debugging** - 4-phase root cause analysis
- **verification-before-completion** - Ensure it's actually fixed
- **requesting-code-review** - Pre-review quality checks
- **receiving-code-review** - Process feedback rigorously
- **writing-plans** - Detailed implementation planning
- **executing-plans** - Batch execution with checkpoints
- **using-git-worktrees** - Parallel development branches

## ECC Skills Reference

[Content will be added by update_agents_md function]
EOF

    # Now add the ECC section
    update_agents_md
}

# Print summary
print_summary() {
    echo ""
    echo "========================================="
    log_success "Integration Complete!"
    echo "========================================="
    echo ""
    echo "Updated files:"
    echo "  - ~/.config/opencode/opencode.json"
    echo "  - AGENTS.md"
    echo ""
    echo "Backups created with suffix: $BACKUP_SUFFIX"
    echo ""
    echo "Next steps:"
    echo "  1. Review the updated files"
    echo "  2. Restart OpenCode"
    echo "  3. Test skills: 'Use golang-patterns to review this code'"
    echo ""
}

# Main
main() {
    echo "========================================="
    echo "ECC Integration Script"
    echo "========================================="
    echo ""
    
    update_opencode_json
    update_agents_md
    print_summary
}

main "$@"
