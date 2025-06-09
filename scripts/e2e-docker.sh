#!/bin/bash
set -e

# E2E Testing in Docker Container
# This script provides a complete, isolated environment for Playwright E2E testing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${PROJECT_ROOT}/docker-compose.e2e.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[E2E-Docker]${NC} $1"
}

success() {
    echo -e "${GREEN}[E2E-Docker]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[E2E-Docker]${NC} $1"
}

error() {
    echo -e "${RED}[E2E-Docker]${NC} $1"
    exit 1
}

# Function to check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed or not available in PATH"
    fi
    
    if ! docker info &> /dev/null; then
        error "Docker daemon is not running"
    fi
    
    success "Docker is available and running"
}

# Function to check if the app is running
check_app_running() {
    local max_attempts=30
    local attempt=1
    
    log "Checking if Next.js app is running on port 3000..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            success "Next.js app is running"
            return 0
        fi
        
        warn "Attempt $attempt/$max_attempts: App not ready, waiting 2 seconds..."
        sleep 2
        ((attempt++))
    done
    
    error "Next.js app is not running on port 3000. Please start it with 'pnpm dev' or 'pnpm build && pnpm start'"
}

# Function to setup the container environment
setup_container() {
    log "Setting up E2E testing container..."
    
    # Create necessary directories
    mkdir -p ~/.cache/ms-playwright
    mkdir -p /tmp/playwright-cache
    
    # Pull the latest Playwright image
    log "Pulling Playwright Docker image..."
    docker pull mcr.microsoft.com/playwright:v1.52.0-noble
    
    success "Container environment setup complete"
}

# Function to run E2E tests
run_e2e_tests() {
    local test_args="$*"
    
    log "Starting E2E tests in Docker container..."
    log "Test arguments: ${test_args:-"(default)"}"
    
    # Run the E2E tests
    docker-compose -f "$COMPOSE_FILE" run --rm \
        -e TMPDIR=/tmp/playwright-tmp \
        e2e-runner bash -c "
            set -e
            cd /workspace
            
            # Install dependencies if needed
            if [ ! -d node_modules ] || [ ! -f node_modules/.pnpm-stamp ]; then
                echo 'Installing Node.js dependencies...'
                corepack enable
                pnpm install --frozen-lockfile
                touch node_modules/.pnpm-stamp
            fi
            
            # Install Playwright browsers if needed
            if [ ! -d /ms-playwright/chromium* ]; then
                echo 'Installing Playwright browsers...'
                npx playwright install chromium
            fi
            
            # Run the tests
            echo 'Running E2E tests...'
            export PLAYWRIGHT_TEST_BASE_URL='http://host.docker.internal:3000'
            npx playwright test ${test_args}
        "
}

# Function to cleanup
cleanup() {
    log "Cleaning up containers and resources..."
    docker-compose -f "$COMPOSE_FILE" down --volumes --remove-orphans 2>/dev/null || true
    success "Cleanup complete"
}

# Function to show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [PLAYWRIGHT_ARGS]

Run E2E tests in a Docker container with all dependencies pre-installed.

OPTIONS:
    --setup-only    Only setup the container environment, don't run tests
    --cleanup       Only cleanup containers and resources
    --help          Show this help message

PLAYWRIGHT_ARGS:
    Any arguments to pass to 'npx playwright test'
    Examples:
        --headed        Run tests in headed mode
        --debug         Run tests in debug mode
        --ui            Run tests with Playwright UI
        tests/e2e/login.spec.ts    Run specific test file

EXAMPLES:
    $0                                  # Run all E2E tests
    $0 --headed                         # Run tests in headed mode
    $0 tests/e2e/login.spec.ts          # Run specific test
    $0 --setup-only                     # Just setup the environment
    $0 --cleanup                        # Cleanup containers

REQUIREMENTS:
    - Docker must be installed and running
    - Next.js app must be running on port 3000
    - Run 'pnpm dev' or 'pnpm build && pnpm start' first

EOF
}

# Main execution logic
main() {
    # Handle special flags
    case "$1" in
        --help)
            show_help
            exit 0
            ;;
        --cleanup)
            cleanup
            exit 0
            ;;
        --setup-only)
            check_docker
            setup_container
            exit 0
            ;;
    esac
    
    # Pre-flight checks
    check_docker
    
    # Setup container if needed
    setup_container
    
    # Set trap for cleanup on exit
    trap cleanup EXIT
    
    # Run the tests
    run_e2e_tests "$@"
    
    success "E2E tests completed successfully!"
}

# Execute main function with all arguments
main "$@" 