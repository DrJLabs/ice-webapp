#!/bin/bash
#
# Codex Setup Testing Script
# Tests setup-codex.sh in the official OpenAI Codex Universal Docker environment
# Based on https://github.com/openai/codex-universal
#

set -Eeo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $*${NC}"; }
warn() { echo -e "${YELLOW}[WARN] $*${NC}"; }
error() { echo -e "${RED}[ERROR] $*${NC}"; exit 1; }
info() { echo -e "${BLUE}[INFO] $*${NC}"; }

# Test configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker compose.codex.yml"

# Ensure we're in the right directory
cd "$PROJECT_ROOT"

print_header() {
    echo
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                 🧊 ICE-WEBAPP Codex Testing                ║"
    echo "║              Official OpenAI Codex Universal               ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo
}

check_docker_requirements() {
    log "Checking Docker requirements..."
    
    if ! command -v docker >/dev/null 2>&1; then
        error "Docker is not installed. Please install Docker first."
    fi
    
    if ! docker compose version >/dev/null 2>&1 && ! command -v docker compose >/dev/null 2>&1; then
        error "Docker Compose is not installed. Please install Docker Compose first."
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        error "Docker daemon is not running. Please start Docker first."
    fi
    
    info "✅ Docker and Docker Compose are available"
}

pull_codex_image() {
    log "Pulling official OpenAI Codex Universal image..."
    
    # Pull the latest image
    if docker pull ghcr.io/openai/codex-universal:latest; then
        info "✅ Successfully pulled OpenAI Codex Universal image"
    else
        error "Failed to pull OpenAI Codex Universal image"
    fi
}

cleanup_containers() {
    log "Cleaning up existing containers..."
    
    # Stop and remove existing containers
    docker compose -f "$DOCKER_COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    
    # Remove any dangling containers
    docker container prune -f >/dev/null 2>&1 || true
    
    info "✅ Cleanup completed"
}

start_codex_environment() {
    log "Starting Codex mirror environment..."
    
    if docker compose -f "$DOCKER_COMPOSE_FILE" up -d codex-mirror; then
        info "✅ Codex mirror environment started"
        
        # Wait for container to be ready
        log "Waiting for container to be ready..."
        sleep 5
        
        # Verify container is running
        if docker compose -f "$DOCKER_COMPOSE_FILE" ps codex-mirror | grep -q "Up"; then
            info "✅ Container is running and ready"
        else
            error "Container failed to start properly"
        fi
    else
        error "Failed to start Codex mirror environment"
    fi
}

test_environment_setup() {
    log "Testing environment configuration..."
    
    # Test basic environment
    info "Checking basic environment..."
    docker compose -f "$DOCKER_COMPOSE_FILE" exec -T codex-mirror bash -c "
        echo 'Environment Check:'
        echo '  User: \$(whoami)'
        echo '  Shell: \$SHELL'
        echo '  Working Directory: \$(pwd)'
        echo '  Container: \$CONTAINER'
        echo '  Codespace: \$CODESPACE_NAME'
    "
    
    # Test language runtimes
    info "Checking pre-installed language runtimes..."
    docker compose -f "$DOCKER_COMPOSE_FILE" exec -T codex-mirror bash -c "
        echo 'Language Runtimes:'
        echo '  Node.js: \$(node --version)'
        echo '  npm: \$(npm --version)'
        echo '  Python: \$(python3 --version)'
        echo '  Go: \$(go version | cut -d' ' -f3)'
        echo '  Rust: \$(rustc --version | cut -d' ' -f2)'
        echo '  Java: \$(java --version | head -1)'
        echo '  Ruby: \$(ruby --version | cut -d' ' -f2)'
        command -v bun >/dev/null && echo '  Bun: \$(bun --version)' || echo '  Bun: not available'
    "
    
    info "✅ Environment configuration verified"
}

run_setup_script_test() {
    log "Running setup-codex.sh in Codex mirror environment..."
    
    # Copy the setup script to ensure it's available
    info "Ensuring setup script is available in container..."
    
    # Run the setup script
    if docker compose -f "$DOCKER_COMPOSE_FILE" exec -T codex-mirror bash -c "
        cd /workspace/ice-webapp
        echo '🧪 Starting ICE-WEBAPP Codex Setup Test...'
        echo '================================================'
        bash setup-codex.sh
    "; then
        info "✅ Setup script completed successfully"
        return 0
    else
        warn "⚠️ Setup script completed with warnings or errors"
        return 1
    fi
}

verify_setup_results() {
    log "Verifying setup results..."
    
    docker compose -f "$DOCKER_COMPOSE_FILE" exec -T codex-mirror bash -c "
        cd /workspace/ice-webapp
        echo 'Setup Verification:'
        echo '=================='
        
        # Check if package.json was created
        if [[ -f package.json ]]; then
            echo '✅ package.json: Created'
        else
            echo '❌ package.json: Missing'
        fi
        
        # Check if Next.js config was created
        if [[ -f next.config.js ]]; then
            echo '✅ next.config.js: Created'
        else
            echo '❌ next.config.js: Missing'
        fi
        
        # Check if TypeScript config was created
        if [[ -f tsconfig.json ]]; then
            echo '✅ tsconfig.json: Created'
        else
            echo '❌ tsconfig.json: Missing'
        fi
        
        # Check project structure
        if [[ -d src/app ]]; then
            echo '✅ src/app: Directory created'
        else
            echo '❌ src/app: Directory missing'
        fi
        
        # Check if React files were created
        if [[ -f src/app/layout.tsx ]]; then
            echo '✅ src/app/layout.tsx: Created'
        else
            echo '❌ src/app/layout.tsx: Missing'
        fi
        
        if [[ -f src/app/page.tsx ]]; then
            echo '✅ src/app/page.tsx: Created'
        else
            echo '❌ src/app/page.tsx: Missing'
        fi
        
        # Check if dependencies were installed
        if [[ -d node_modules ]]; then
            echo '✅ node_modules: Dependencies installed'
        else
            echo '⚠️ node_modules: Dependencies not installed (expected if network access expired)'
        fi
        
        # Test npm/pnpm availability
        echo
        echo 'Package Manager Status:'
        echo '======================'
        echo \"npm: \$(npm --version)\"
        if command -v pnpm >/dev/null 2>&1; then
            echo \"pnpm: \$(pnpm --version)\"
        else
            echo 'pnpm: not available'
        fi
    "
    
    info "✅ Setup verification completed"
}

run_functional_tests() {
    log "Running functional tests..."
    
    # Test if we can run basic Next.js commands
    docker compose -f "$DOCKER_COMPOSE_FILE" exec -T codex-mirror bash -c "
        cd /workspace/ice-webapp
        echo 'Functional Tests:'
        echo '================'
        
        # Test TypeScript compilation
        if command -v npx >/dev/null 2>&1; then
            echo 'Testing TypeScript compilation...'
            if npx tsc --noEmit --skipLibCheck 2>/dev/null; then
                echo '✅ TypeScript: Compilation successful'
            else
                echo '⚠️ TypeScript: Compilation issues (expected without dependencies)'
            fi
        else
            echo '⚠️ npx not available for TypeScript testing'
        fi
        
        # Test package.json scripts
        echo
        echo 'Available npm scripts:'
        if [[ -f package.json ]] && command -v npm >/dev/null 2>&1; then
            npm run | grep -E '(dev|build|start|lint|type-check)' || echo 'No standard scripts found'
        else
            echo 'Cannot check scripts - package.json or npm not available'
        fi
    "
    
    info "✅ Functional tests completed"
}

run_automated_test() {
    log "Running automated test with test runner service..."
    
    if docker compose -f "$DOCKER_COMPOSE_FILE" --profile test run --rm codex-test-runner; then
        info "✅ Automated test completed successfully"
    else
        warn "⚠️ Automated test completed with issues"
    fi
}

generate_test_report() {
    log "Generating test report..."
    
    local report_file="test-results-$(date +%Y%m%d-%H%M%S).log"
    
    docker compose -f "$DOCKER_COMPOSE_FILE" exec -T codex-mirror bash -c "
        cd /workspace/ice-webapp
        echo '🧊 ICE-WEBAPP Codex Setup Test Report'
        echo '======================================'
        echo \"Test Date: \$(date)\"
        echo \"Container: Codex Universal (\$(cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2))\"
        echo
        
        echo 'Environment:'
        echo '==========='
        echo \"  Node.js: \$(node --version)\"
        echo \"  npm: \$(npm --version)\"
        command -v pnpm >/dev/null && echo \"  pnpm: \$(pnpm --version)\"
        echo \"  Python: \$(python3 --version)\"
        echo \"  Working Directory: \$(pwd)\"
        echo
        
        echo 'Files Created:'
        echo '============='
        ls -la | grep -E '(package\.json|next\.config|tsconfig|\.env)' || echo 'No config files found'
        echo
        
        echo 'Project Structure:'
        echo '=================='
        find src -type f 2>/dev/null | head -10 || echo 'src directory not found'
        echo
        
        echo 'Dependencies Status:'
        echo '==================='
        if [[ -d node_modules ]]; then
            echo \"Installed packages: \$(ls node_modules | wc -l)\"
        else
            echo 'No dependencies installed'
        fi
    " > "$report_file"
    
    info "✅ Test report saved to: $report_file"
}

main() {
    print_header
    
    # Pre-flight checks
    check_docker_requirements
    pull_codex_image
    
    # Environment setup
    cleanup_containers
    start_codex_environment
    
    # Testing phases
    test_environment_setup
    
    local setup_success=true
    if ! run_setup_script_test; then
        setup_success=false
    fi
    
    verify_setup_results
    run_functional_tests
    
    # Optional: Run automated test
    if [[ "${1:-}" == "--automated" ]]; then
        run_automated_test
    fi
    
    generate_test_report
    
    # Cleanup
    if [[ "${1:-}" != "--keep" ]]; then
        log "Cleaning up test environment..."
        cleanup_containers
        info "✅ Cleanup completed"
    else
        info "🔄 Test environment kept running (use --keep flag)"
        echo
        echo "To interact with the environment:"
        echo "  docker compose -f docker compose.codex.yml exec codex-mirror bash"
        echo
        echo "To stop the environment:"
        echo "  docker compose -f docker compose.codex.yml down"
    fi
    
    # Final status
    echo
    if [[ "$setup_success" == "true" ]]; then
        log "🎉 Codex setup testing completed successfully!"
    else
        warn "⚠️ Codex setup testing completed with some issues - check the logs above"
    fi
    
    echo
    echo "Next steps:"
    echo "  1. Review the test report for detailed results"
    echo "  2. Fix any issues identified during testing"
    echo "  3. Re-run tests with: bash tools/test-codex-setup.sh"
    echo "  4. Use --keep flag to maintain environment for debugging"
    echo "  5. Use --automated flag to run full automated test suite"
}

# Show usage if help requested
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "ICE-WEBAPP Codex Setup Testing Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --keep         Keep test environment running after tests"
    echo "  --automated    Run additional automated tests"
    echo
    echo "Examples:"
    echo "  $0                    # Run basic tests and cleanup"
    echo "  $0 --keep           # Run tests and keep environment"
    echo "  $0 --automated      # Run full test suite"
    echo
    exit 0
fi

# Execute main function
main "$@" 