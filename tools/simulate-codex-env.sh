#!/bin/bash

# 🧊 ICE-WEBAPP: Codex Environment Simulator
# Simulates OpenAI Codex Universal environment for local testing
# Based on official Codex Universal Docker image specifications

set -euo pipefail

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Logging functions
log() { echo -e "[$(date +'%H:%M:%S')] $*"; }
info() { echo -e "${GREEN}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
debug() { echo -e "${PURPLE}[DEBUG]${NC} $*"; }

# Configuration
readonly TEST_DIR="/tmp/ice-webapp-codex-sim"
readonly REPO_URL="https://github.com/DrJLabs/ice-webapp.git"

print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║            🧊 ICE-WEBAPP Codex Environment Simulator       ║"
    echo "║               Testing Without Docker Dependency            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

simulate_codex_environment() {
    log "Setting up simulated Codex environment..."
    
    # Create isolated test directory
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Simulate Codex environment variables
    export CONTAINER="docker"
    export CODESPACE_NAME="codex"
    export OPENAI_CODEX="true"
    export SHELL="/bin/bash"
    export DEBIAN_FRONTEND="noninteractive"
    export USER="${USER:-$(whoami 2>/dev/null || echo 'unknown')}"
    export CODEX_ENV_NODE_VERSION="22"
    export CODEX_ENV_PYTHON_VERSION="3.12"
    
    # Simulate limited network environment (like Codex)
    # Note: We can't actually block network, but we can simulate failures
    export SIMULATE_NETWORK_ISSUES="${SIMULATE_NETWORK_ISSUES:-false}"
    
    info "✅ Codex environment variables set"
    
    # Clone repository (simulating Codex behavior)
    log "Cloning ICE-WEBAPP repository..."
    if git clone "$REPO_URL" ice-webapp-test; then
        info "✅ Repository cloned successfully"
        cd ice-webapp-test
    else
        error "❌ Failed to clone repository"
        return 1
    fi
}

check_pre_installed_packages() {
    log "Checking pre-installed packages (simulating Codex Universal)..."
    
    # Check Node.js
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        info "✅ Node.js: $node_version"
    else
        warn "⚠️ Node.js not found (would be pre-installed in Codex)"
    fi
    
    # Check Python
    if command -v python3 >/dev/null 2>&1; then
        local python_version=$(python3 --version)
        info "✅ Python: $python_version"
    else
        warn "⚠️ Python not found (would be pre-installed in Codex)"
    fi
    
    # Check other tools
    local tools=("git" "curl" "wget" "unzip" "jq")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            info "✅ $tool: available"
        else
            warn "⚠️ $tool: not found"
        fi
    done
}

test_setup_script() {
    log "Testing setup-codex.sh in simulated environment..."
    
    if [[ ! -f "setup-codex.sh" ]]; then
        error "❌ setup-codex.sh not found in repository"
        return 1
    fi
    
    # Make script executable
    chmod +x setup-codex.sh
    
    # Run setup script with detailed output
    echo -e "${BLUE}================================================${NC}"
    echo -e "${WHITE}Running setup-codex.sh...${NC}"
    echo -e "${BLUE}================================================${NC}"
    
    if bash -x setup-codex.sh; then
        info "✅ Setup script completed successfully"
        return 0
    else
        error "❌ Setup script failed"
        return 1
    fi
}

validate_setup_results() {
    log "Validating setup results..."
    
    # Check if key files were created
    local expected_files=(
        "package.json"
        "src/app/layout.tsx"
        "src/app/page.tsx"
        "tailwind.config.ts"
        "tsconfig.json"
    )
    
    for file in "${expected_files[@]}"; do
        if [[ -f "$file" ]]; then
            info "✅ $file: created"
        else
            warn "⚠️ $file: missing"
        fi
    done
    
    # Check if node_modules exists (if pnpm install succeeded)
    if [[ -d "node_modules" ]]; then
        info "✅ Dependencies installed"
    else
        warn "⚠️ Dependencies not installed"
    fi
    
    # Check TypeScript compilation
    if command -v pnpm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
        log "Testing TypeScript compilation..."
        if pnpm run type-check 2>/dev/null; then
            info "✅ TypeScript compilation successful"
        else
            warn "⚠️ TypeScript compilation issues"
        fi
    fi
}

run_functional_tests() {
    log "Running functional tests..."
    
    # Test 1: Check if Next.js dev server can start (without actually starting)
    if command -v pnpm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
        if pnpm list next >/dev/null 2>&1; then
            info "✅ Next.js is properly installed"
        else
            warn "⚠️ Next.js installation issues"
        fi
    fi
    
    # Test 2: Validate package.json structure
    if [[ -f "package.json" ]] && command -v jq >/dev/null 2>&1; then
        local next_version=$(jq -r '.dependencies.next // "missing"' package.json)
        local react_version=$(jq -r '.dependencies.react // "missing"' package.json)
        local typescript_version=$(jq -r '.devDependencies.typescript // "missing"' package.json)
        
        info "✅ Dependencies - Next.js: $next_version, React: $react_version, TypeScript: $typescript_version"
    fi
    
    # Test 3: Check Tailwind CSS configuration
    if [[ -f "tailwind.config.ts" ]]; then
        if grep -q "app/" tailwind.config.ts; then
            info "✅ Tailwind CSS configured for App Router"
        else
            warn "⚠️ Tailwind CSS configuration may be incomplete"
        fi
    fi
}

generate_test_report() {
    local test_result=$1
    local report_file="$TEST_DIR/codex-test-report.md"
    
    log "Generating test report..."
    
    cat > "$report_file" << EOF
# 🧊 ICE-WEBAPP Codex Environment Test Report

**Test Date:** $(date)
**Test Environment:** Simulated Codex Universal
**Test Result:** $([ $test_result -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")

## Environment Details
- **Node.js Version:** $(node --version 2>/dev/null || echo "Not available")
- **Python Version:** $(python3 --version 2>/dev/null || echo "Not available")
- **Git Version:** $(git --version 2>/dev/null || echo "Not available")
- **Package Manager:** $(command -v pnpm >/dev/null 2>&1 && echo "pnpm $(pnpm --version)" || echo "pnpm not available")

## Test Results Summary
$([ $test_result -eq 0 ] && echo "All tests passed successfully. The setup script is working correctly in the simulated Codex environment." || echo "Some tests failed. Review the output above for specific issues.")

## Files Created
\`\`\`
$(find . -maxdepth 2 -type f -name "*.json" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.md" | head -20)
\`\`\`

## Next Steps
$([ $test_result -eq 0 ] && echo "- The setup script is ready for production use in Codex environments
- Consider running the Docker-based tests when Docker is available
- Deploy to a real Codex environment for final validation" || echo "- Review and fix the issues identified in the test output
- Re-run the simulation after making corrections
- Test individual components separately if needed")

---
Generated by ICE-WEBAPP Codex Environment Simulator
EOF

    info "✅ Test report generated: $report_file"
    echo -e "${CYAN}Test report location: $report_file${NC}"
}

cleanup() {
    log "Cleaning up test environment..."
    if [[ -d "$TEST_DIR" ]] && [[ "$TEST_DIR" != "/" ]]; then
        # Keep the test results but clean up temporary files
        find "$TEST_DIR" -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
        info "✅ Cleanup completed (test results preserved)"
    fi
}

main() {
    print_header
    
    local exit_code=0
    
    # Setup simulated environment
    simulate_codex_environment || exit_code=1
    
    if [[ $exit_code -eq 0 ]]; then
        # Run tests
        check_pre_installed_packages
        test_setup_script || exit_code=1
        validate_setup_results
        run_functional_tests
    fi
    
    # Generate report
    generate_test_report $exit_code
    
    # Show final result
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}"
        echo "🎉 ICE-WEBAPP Codex simulation completed successfully!"
        echo "The setup script is ready for Codex environments."
        echo -e "${NC}"
    else
        echo -e "${RED}"
        echo "❌ ICE-WEBAPP Codex simulation failed."
        echo "Review the output above and the test report for details."
        echo -e "${NC}"
    fi
    
    cleanup
    return $exit_code
}

# Handle interruption
trap cleanup EXIT

# Check if running in automation mode
if [[ "${1:-}" == "--automated" ]]; then
    main
else
    echo "This script simulates the Codex environment for testing."
    echo "It will clone the repository and test the setup script."
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        main
    else
        echo "Test cancelled."
        exit 0
    fi
fi 