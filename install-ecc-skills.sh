#!/bin/bash
#
# install-ecc-skills.sh - Install ECC skills for OpenCode (memory/hook-free)
#
# This script installs selected skills from everything-claude-code repository
# while avoiding conflicts with context-mode and superpowers.
#
# Usage:
#   ./install-ecc-skills.sh                    # Install default skills
#   ./install-ecc-skills.sh v1.9.0             # Install specific version
#   ./install-ecc-skills.sh v1.9.0 my-skills.txt  # Custom skills list

set -euo pipefail

# Configuration
ECC_VERSION="${1:-v1.9.0}"
SKILLS_FILE="${2:-ecc-config/skills-list.txt}"
ECC_REPO="https://github.com/affaan-m/everything-claude-code.git"
TEMP_DIR=$(mktemp -d)
INSTALL_DIR="$HOME/.config/opencode/ecc-skills"
VERSION_FILE="$INSTALL_DIR/version.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v git &> /dev/null; then
        log_error "git is required but not installed"
        exit 1
    fi
    
    # Check if we can write to install directory
    if [ ! -d "$HOME/.config/opencode" ]; then
        log_info "Creating ~/.config/opencode directory..."
        mkdir -p "$HOME/.config/opencode" || {
            log_error "Cannot create ~/.config/opencode - check permissions"
            exit 1
        }
    fi
    
    if [ ! -w "$HOME/.config/opencode" ]; then
        log_error "Cannot write to ~/.config/opencode - check permissions"
        exit 1
    fi
    
    if [ ! -f "$SKILLS_FILE" ]; then
        log_error "Skills file not found: $SKILLS_FILE"
        log_info "Creating default skills file..."
        mkdir -p "$(dirname "$SKILLS_FILE")"
        create_default_skills_file
    fi
    
    log_success "Prerequisites check passed"
}

# Create default skills list
create_default_skills_file() {
    cat > "$SKILLS_FILE" << 'EOF'
# ECC Skills for OpenCode
#
# These skills fill gaps in superpowers by providing:
# - Language-specific patterns (Go, TypeScript, Python, Rust, Shell)
# - Security auditing (missing from superpowers)
# - Documentation lookup (missing from superpowers)
#
# NOTE: We intentionally skip skills that overlap with superpowers:
# - tdd-workflow (use superpowers test-driven-development instead)
# - verification-loop (use superpowers verification-before-completion)
# - code-review (use superpowers requesting-code-review)

# Language-Specific Patterns
# Go
golang-patterns
golang-testing

# TypeScript/JavaScript
frontend-patterns
backend-patterns
bun-runtime
nextjs-turbopack
api-design
e2e-testing

# Python
python-patterns
python-testing

# Rust
rust-patterns
rust-testing

# Shell
shell-patterns

# Security & Documentation (fills superpowers gaps)
security-review
documentation-lookup

# DevOps & Deployment
docker-patterns
deployment-patterns

# Research Workflow
search-first

# Code Review Agents (from ECC repo)
go-reviewer
typescript-reviewer
python-reviewer
rust-reviewer
security-reviewer
docs-lookup
EOF
    log_success "Created default skills file: $SKILLS_FILE"
}

# Clone ECC repository
clone_ecc_repo() {
    log_info "Cloning ECC repository (version: $ECC_VERSION)..."
    
    if ! git clone --depth 1 --branch "$ECC_VERSION" "$ECC_REPO" "$TEMP_DIR/ecc" 2>/dev/null; then
        log_error "Failed to clone ECC repository"
        log_info "Trying to fetch latest version..."
        git clone --depth 1 "$ECC_REPO" "$TEMP_DIR/ecc"
    fi
    
    log_success "Cloned ECC repository"
}

# Create installation directory
setup_install_dir() {
    log_info "Setting up installation directory..."
    
    mkdir -p "$INSTALL_DIR"
    
    # Backup existing installation if present
    if [ -d "$INSTALL_DIR/skills" ] || [ -d "$INSTALL_DIR/agents" ]; then
        BACKUP_DIR="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
        log_warn "Existing installation found, backing up to: $BACKUP_DIR"
        mv "$INSTALL_DIR" "$BACKUP_DIR"
        mkdir -p "$INSTALL_DIR"
    fi
    
    log_success "Installation directory ready"
}

# Install skills
install_skills() {
    log_info "Installing skills..."
    
    local skills_dir="$TEMP_DIR/ecc/skills"
    local install_count=0
    local skip_count=0
    
    while IFS= read -r skill || [[ -n "$skill" ]]; do
        # Skip comments and empty lines
        [[ "$skill" =~ ^#.*$ ]] && continue
        [[ -z "$skill" ]] && continue
        
        local skill_path="$skills_dir/$skill"
        
        if [ -d "$skill_path" ]; then
            log_info "Installing skill: $skill"
            cp -r "$skill_path" "$INSTALL_DIR/"
            ((install_count++))
        else
            log_warn "Skill not found: $skill"
            ((skip_count++))
        fi
    done < "$SKILLS_FILE"
    
    log_success "Installed $install_count skills"
    if [ $skip_count -gt 0 ]; then
        log_warn "Skipped $skip_count skills (not found)"
    fi
}

# Install agents
install_agents() {
    log_info "Installing agents..."
    
    local agents_dir="$TEMP_DIR/ecc/agents"
    local target_agents=(
        "go-reviewer.md"
        "typescript-reviewer.md"
        "python-reviewer.md"
        "rust-reviewer.md"
        "security-reviewer.md"
        "docs-lookup.md"
    )
    
    local install_count=0
    
    for agent in "${target_agents[@]}"; do
        local agent_path="$agents_dir/$agent"
        if [ -f "$agent_path" ]; then
            log_info "Installing agent: $agent"
            cp "$agent_path" "$INSTALL_DIR/"
            ((install_count++))
        else
            log_warn "Agent not found: $agent"
        fi
    done
    
    log_success "Installed $install_count agents"
}

# Save version info
save_version() {
    echo "$ECC_VERSION" > "$VERSION_FILE"
    date -Iseconds >> "$VERSION_FILE"
    log_info "Saved version info: $ECC_VERSION"
}

# Run integration script
run_integration() {
    log_info "Running integration script..."
    
    if [ -f "./scripts/integrate-ecc.sh" ]; then
        ./scripts/integrate-ecc.sh
    else
        log_warn "Integration script not found. Manual integration required."
        log_info "Please run: ./scripts/integrate-ecc.sh"
    fi
}

# Install code review agent and pr-gate skill
install_code_review_agent() {
    echo ""
    echo "=== Installing Code Review Agent ==="
    if [ -f "$(dirname "$0")/install-agents.sh" ]; then
        bash "$(dirname "$0")/install-agents.sh" || true
    else
        echo "Warning: install-agents.sh not found. Code review agent not installed."
    fi
}

# Print summary
print_summary() {
    echo ""
    echo "========================================="
    log_success "ECC Skills Installation Complete!"
    echo "========================================="
    echo ""
    echo "Version: $ECC_VERSION"
    echo "Location: $INSTALL_DIR"
    echo ""
    echo "Next steps:"
    echo "  1. Review updated ~/.config/opencode/opencode.json"
    echo "  2. Review updated AGENTS.md"
    echo "  3. Restart OpenCode"
    echo "  4. Test with: 'Use golang-patterns to review this code'"
    echo ""
    echo "To check for upgrades:"
    echo "  ./scripts/upgrade-ecc.sh"
    echo ""
}

# Main execution
main() {
    echo "========================================="
    echo "ECC Skills Installer for OpenCode"
    echo "========================================="
    echo ""
    
    check_prerequisites
    clone_ecc_repo
    setup_install_dir
    install_skills
    install_agents
    install_code_review_agent
    save_version
    run_integration
    print_summary
}

main "$@"
