#!/usr/bin/env bash
#
# ICE-WEBAPP Codex Setup Script
# Specialized setup for ChatGPT Codex container environments
# Handles shell detection, Node.js version mismatches, and pnpm installation issues
#

set -Eeuo pipefail
IFS=$'\n\t'

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $*${NC}" >&2; }
warn() { echo -e "${YELLOW}[WARNING] $*${NC}" >&2; }
error() { echo -e "${RED}[ERROR] $*${NC}" >&2; exit 1; }
info() { echo -e "${BLUE}[INFO] $*${NC}" >&2; }
success() { echo -e "${GREEN}[SUCCESS] $*${NC}" >&2; }

# Configuration
readonly NODE_VERSION="22.12.0"
readonly WORKSPACE_DIR="$PWD"

# Codex environment setup
setup_codex_environment() {
    log "Setting up Codex container environment..."
    
    # Essential environment variables
    export SHELL="/bin/bash"
    export DEBIAN_FRONTEND=noninteractive
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    
    # Clear proxy settings that cause npm warnings
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
    
    # Create required directories
    mkdir -p "$PNPM_HOME" ~/.npm ~/.cache ~/.config
    
    # Configure apt for container environments
    if command -v apt-get >/dev/null 2>&1; then
        echo 'Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80-retries >/dev/null
        echo 'Acquire::http::Timeout "60";' | sudo tee /etc/apt/apt.conf.d/80-timeout >/dev/null
        sudo apt-get update -qq
    fi
    
    success "Codex environment configured"
}

# Fix Node.js version issues
fix_nodejs_version() {
    log "Fixing Node.js version for Codex..."
    
    local current_version
    current_version=$(node --version 2>/dev/null || echo "none")
    log "Current Node.js version: $current_version"
    
    if [[ ! "$current_version" =~ ^v22\. ]]; then
        warn "Node.js version needs update, installing v22.x..."
        
        # Remove any existing Node.js installations
        sudo apt-get remove -y nodejs npm 2>/dev/null || true
        sudo apt-get autoremove -y 2>/dev/null || true
        
        # Install Node.js 22.x with retry mechanism
        local retry=0
        while [ $retry -lt 3 ]; do
            if curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -; then
                sudo apt-get install -y nodejs
                break
            fi
            retry=$((retry + 1))
            warn "Retry $retry/3 for Node.js installation..."
            sleep 2
        done
        
        # Verify installation
        current_version=$(node --version)
        log "Updated Node.js version: $current_version"
        
        if [[ ! "$current_version" =~ ^v22\. ]]; then
            error "Failed to install Node.js v22.x. Current version: $current_version"
        fi
    fi
    
    success "Node.js v22.x verified"
}

# Install pnpm with Codex-specific handling
install_pnpm_codex() {
    log "Installing pnpm for Codex environment..."
    
    # Set explicit shell for pnpm installer
    export SHELL="/bin/bash"
    
    # Download and install with explicit shell
    if curl -fsSL https://get.pnpm.io/install.sh | SHELL=/bin/bash sh -; then
        success "pnpm installed successfully"
    else
        warn "Standard pnpm installation failed, trying manual installation..."
        
        # Manual installation for problematic environments
        local pnpm_version="9.15.0"
        local pnpm_url="https://github.com/pnpm/pnpm/releases/download/v${pnpm_version}/pnpm-linux-x64"
        
        mkdir -p "$PNPM_HOME"
        curl -fsSL "$pnpm_url" -o "$PNPM_HOME/pnpm"
        chmod +x "$PNPM_HOME/pnpm"
        
        success "pnpm installed manually"
    fi
    
    # Ensure pnpm is in PATH
    export PATH="$PNPM_HOME:$PATH"
    
    # Add to shell profile
    {
        echo 'export PNPM_HOME="$HOME/.local/share/pnpm"'
        echo 'export PATH="$PNPM_HOME:$PATH"'
    } >> ~/.bashrc
    
    # Verify installation
    if command -v pnpm >/dev/null 2>&1; then
        log "pnpm version: $(pnpm --version)"
    else
        error "pnpm installation verification failed"
    fi
    
    # Configure pnpm for containers
    pnpm config set registry https://registry.npmjs.org/
    pnpm config set store-dir ~/.pnpm-store
    pnpm config set network-timeout 300000
    pnpm config set fetch-retries 5
    pnpm config set fetch-retry-factor 2
    pnpm config set fetch-retry-mintimeout 10000
    
    success "pnpm configured for Codex environment"
}

# Configure npm to avoid warnings
configure_npm() {
    log "Configuring npm for clean operation..."
    
    # Remove problematic configurations
    npm config delete proxy --global 2>/dev/null || true
    npm config delete https-proxy --global 2>/dev/null || true
    npm config delete http-proxy --global 2>/dev/null || true
    
    # Set optimal configurations
    npm config set registry https://registry.npmjs.org/ --global
    npm config set fetch-retries 5 --global
    npm config set fetch-retry-factor 2 --global
    npm config set fetch-retry-mintimeout 10000 --global
    
    success "npm configured"
}

# Quick setup for existing projects
quick_codex_setup() {
    log "Running quick Codex setup..."
    
    setup_codex_environment
    fix_nodejs_version
    configure_npm
    install_pnpm_codex
    
    # If package.json exists, install dependencies
    if [[ -f "package.json" ]]; then
        log "Installing project dependencies..."
        pnpm install
        success "Dependencies installed"
    fi
    
    # Verify setup
    log "Verifying setup..."
    echo "  Node.js: $(node --version)"
    echo "  npm: $(npm --version)"
    echo "  pnpm: $(pnpm --version)"
    
    success "Codex setup completed successfully!"
}

# Main execution
main() {
    info "ICE-WEBAPP Codex Setup Starting..."
    info "This script fixes common Codex container issues:"
    info "  - Shell detection for pnpm"
    info "  - Node.js version mismatches" 
    info "  - npm proxy warnings"
    info "  - Container environment optimizations"
    echo
    
    quick_codex_setup
    
    info "Setup complete! You can now:"
    echo "  1. Run the main setup: bash setup.sh"
    echo "  2. Or start developing: pnpm run dev"
    echo "  3. Run quality checks: pnpm run lint && pnpm run type-check"
}

# Handle script arguments
case "${1:-}" in
    --quick) quick_codex_setup ;;
    --help) 
        echo "ICE-WEBAPP Codex Setup Script"
        echo "Usage: $0 [--quick|--help]"
        echo "  --quick: Run quick setup only"
        echo "  --help:  Show this help"
        ;;
    *) main "$@" ;;
esac 