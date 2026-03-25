#!/bin/bash
#
# upgrade-ecc.sh - Check for and install ECC updates
#
# Usage:
#   ./scripts/upgrade-ecc.sh              # Check and optionally upgrade
#   ./scripts/upgrade-ecc.sh --check-only # Just check, don't upgrade
#   ./scripts/upgrade-ecc.sh --auto       # Upgrade without prompting

set -euo pipefail

# Configuration
ECC_REPO="affaan-m/everything-claude-code"
VERSION_FILE="$HOME/.config/opencode/ecc-skills/version.txt"
INSTALL_SCRIPT="./install-ecc-skills.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_highlight() { echo -e "${CYAN}$1${NC}"; }

# Get installed version
get_installed_version() {
    if [ -f "$VERSION_FILE" ]; then
        head -1 "$VERSION_FILE"
    else
        echo "not-installed"
    fi
}

# Get latest version from GitHub
get_latest_version() {
    local api_url="https://api.github.com/repos/${ECC_REPO}/releases/latest"
    local version=""
    
    # Try to get version from GitHub API with timeout
    if command -v curl &> /dev/null; then
        version=$(curl -s --max-time 10 "$api_url" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    elif command -v wget &> /dev/null; then
        version=$(wget -qO- --timeout=10 "$api_url" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    fi
    
    if [ -z "$version" ] || [ "$version" = "null" ]; then
        # Fallback: try to get from git ls-remote
        version=$(git ls-remote --tags "https://github.com/${ECC_REPO}.git" 2>/dev/null | \
            grep -o 'refs/tags/v[0-9.]*$' | sort -V | tail -1 | sed 's/refs\/tags\///')
    fi
    
    echo "$version"
}

# Compare versions
# Returns: 0 if equal, 1 if v1 > v2, 2 if v1 < v2
compare_versions() {
    local v1="${1#v}"  # Remove 'v' prefix if present
    local v2="${2#v}"
    
    if [ "$v1" = "$v2" ]; then
        return 0
    fi
    
    # Use sort -V if available, otherwise use simple string comparison
    if printf '%s\n' "$v1" "$v2" | sort -V > /dev/null 2>&1; then
        local lowest
        lowest=$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | head -n1)
        if [ "$lowest" = "$v1" ]; then
            return 2  # v1 < v2
        else
            return 1  # v1 > v2
        fi
    else
        # Fallback: simple string comparison (works for most cases)
        if [[ "$v1" < "$v2" ]]; then
            return 2
        else
            return 1
        fi
    fi
}

# Check for updates
check_updates() {
    log_info "Checking for ECC updates..."
    
    local installed
    local latest
    installed=$(get_installed_version)
    latest=$(get_latest_version)
    
    echo ""
    log_highlight "Current version: ${installed}"
    log_highlight "Latest version:  ${latest}"
    echo ""
    
    if [ "$installed" = "not-installed" ]; then
        log_warn "ECC is not installed"
        echo "Run: ./install-ecc-skills.sh"
        return 1
    fi
    
    if [ -z "$latest" ]; then
        log_error "Could not determine latest version"
        log_info "Check your internet connection or try again later"
        return 1
    fi
    
    compare_versions "$installed" "$latest"
    local result=$?
    
    if [ $result -eq 0 ]; then
        log_success "You are running the latest version!"
        return 0
    elif [ $result -eq 2 ]; then
        log_warn "Update available: $latest"
        return 2
    else
        log_info "Installed version is newer than latest release"
        log_info "You may be running a development or pre-release version"
        return 0
    fi
}

# Show changelog preview
show_changelog() {
    local version="$1"
    log_info "Fetching changelog for $version..."
    
    local changelog_url="https://github.com/${ECC_REPO}/releases/tag/${version}"
    echo ""
    echo "View full changelog at:"
    echo "  $changelog_url"
    echo ""
}

# Perform upgrade
do_upgrade() {
    local version="$1"
    
    log_info "Upgrading to $version..."
    
    if [ ! -f "$INSTALL_SCRIPT" ]; then
        log_error "Install script not found: $INSTALL_SCRIPT"
        exit 1
    fi
    
    # Run install script with new version
    "$INSTALL_SCRIPT" "$version"
    
    log_success "Upgrade complete!"
}

# Interactive upgrade prompt
prompt_upgrade() {
    local version="$1"
    
    show_changelog "$version"
    
    echo -n "Would you like to upgrade to $version? [Y/n]: "
    read -r response
    
    case "$response" in
        [Nn]*)
            log_info "Upgrade cancelled"
            return 0
            ;;
        *)
            do_upgrade "$version"
            ;;
    esac
}

# Main
main() {
    local check_only=false
    local auto_upgrade=false
    
    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --check-only)
                check_only=true
                ;;
            --auto)
                auto_upgrade=true
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --check-only    Check for updates only, don't upgrade"
                echo "  --auto          Upgrade automatically without prompting"
                echo "  --help, -h      Show this help message"
                echo ""
                exit 0
                ;;
        esac
    done
    
    echo "========================================="
    echo "ECC Version Checker & Upgrader"
    echo "========================================="
    echo ""
    
    check_updates
    local result=$?
    
    if [ $result -eq 2 ] && [ "$check_only" = false ]; then
        local latest
    latest=$(get_latest_version)
        
        if [ "$auto_upgrade" = true ]; then
            do_upgrade "$latest"
        else
            prompt_upgrade "$latest"
        fi
    fi
}

main "$@"
