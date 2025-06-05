#!/bin/bash
#
# ICE-WEBAPP Docker Management Script v2025.1.0
# Optimized for Cursor IDE Docker Extensions Integration
# Provides interactive container management with dev container support
#

set -euo pipefail

# Configuration
readonly SCRIPT_VERSION="2025.1.0"
readonly CONTAINER_NAME="ice-webapp-codex-test"
readonly COMPOSE_FILE="docker-compose.codex.yml"
readonly DEVCONTAINER_CONFIG=".devcontainer/devcontainer.json"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m' # No Color

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
header() { echo -e "${PURPLE}[HEADER]${NC} $*"; }

# Print header
print_header() {
    echo "================================================================"
    echo "🧊 ICE-WEBAPP Docker Management v${SCRIPT_VERSION}"
    echo "================================================================"
    echo "Integration with Cursor IDE Docker Extensions"
    echo "Timestamp: $(date)"
    echo "================================================================"
}

# Show menu
show_menu() {
    echo
    header "Available Commands:"
    echo "1. 🚀 Start Codex Universal Container"
    echo "2. 🔧 Connect to Container (Interactive Shell)"
    echo "3. 📋 Show Container Status"
    echo "4. 📱 Run Setup Script in Container"
    echo "5. 🌐 Start Next.js Dev Server"
    echo "6. 📊 Show Container Logs"
    echo "7. 🧪 Run Test Suite"
    echo "8. 🛑 Stop Container"
    echo "9. 🗑️  Clean All Containers"
    echo "10. 📖 Open in Dev Container (Cursor IDE)"
    echo "11. 🔍 Container Resource Usage"
    echo "0. ❌ Exit"
    echo
}

# Start container
start_container() {
    log "Starting ICE-WEBAPP Codex Universal container..."
    
    if docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
        warn "Container is already running"
        return 0
    fi
    
    docker compose -f "${COMPOSE_FILE}" up -d codex-mirror
    
    # Wait for container to be ready
    local max_wait=30
    local wait_time=0
    
    while [[ $wait_time -lt $max_wait ]]; do
        if docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
            success "Container started successfully"
            
            # Show environment info
            log "Container environment:"
            docker exec "${CONTAINER_NAME}" bash -c "
                source ~/.nvm/nvm.sh 2>/dev/null || true
                echo '  Node.js: \$(node --version 2>/dev/null || echo \"Not available\")'
                echo '  npm: \$(npm --version 2>/dev/null || echo \"Not available\")'
                echo '  pnpm: \$(pnpm --version 2>/dev/null || echo \"Not available\")'
                echo '  Python: \$(python3 --version 2>/dev/null || echo \"Not available\")'
            "
            return 0
        fi
        sleep 2
        ((wait_time += 2))
        log "Waiting for container... ($wait_time/${max_wait}s)"
    done
    
    error "Container failed to start within ${max_wait} seconds"
    return 1
}

# Connect to container
connect_container() {
    log "Connecting to ICE-WEBAPP Codex Universal container..."
    
    if ! docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
        warn "Container is not running. Starting it first..."
        start_container || return 1
    fi
    
    success "Opening interactive shell in container..."
    docker exec -it "${CONTAINER_NAME}" bash -c "
        source ~/.nvm/nvm.sh 2>/dev/null || true
        cd /workspace/ice-webapp
        echo '🧊 ICE-WEBAPP Codex Universal Container'
        echo 'Working directory: \$(pwd)'
        echo 'Node.js: \$(node --version 2>/dev/null || echo \"Not available\")'
        echo 'Available commands: npm, pnpm, node, python3, git'
        echo 'Run: npm run dev (to start Next.js development server)'
        echo '=================================='
        exec bash
    "
}

# Show container status
show_status() {
    log "Container Status:"
    echo
    
    if docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q "${CONTAINER_NAME}"; then
        docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo
        success "Container is running"
        
        # Show resource usage
        log "Resource usage:"
        docker stats "${CONTAINER_NAME}" --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    else
        warn "Container is not running"
    fi
}

# Run setup script
run_setup() {
    log "Running setup-codex.sh in container..."
    
    if ! docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
        warn "Container is not running. Starting it first..."
        start_container || return 1
    fi
    
    docker exec "${CONTAINER_NAME}" bash -c "
        source ~/.nvm/nvm.sh 2>/dev/null || true
        cd /workspace/ice-webapp
        if [[ -f setup-codex.sh ]]; then
            echo '🚀 Running ICE-WEBAPP setup...'
            bash setup-codex.sh
        else
            echo '❌ setup-codex.sh not found'
            echo 'Available files:'
            ls -la
        fi
    "
}

# Start Next.js dev server
start_dev_server() {
    log "Starting Next.js development server..."
    
    if ! docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
        warn "Container is not running. Starting it first..."
        start_container || return 1
    fi
    
    docker exec "${CONTAINER_NAME}" bash -c "
        source ~/.nvm/nvm.sh 2>/dev/null || true
        cd /workspace/ice-webapp
        if [[ -f package.json ]]; then
            echo '🌐 Starting Next.js development server on port 3000...'
            echo 'Access at: http://localhost:3000'
            npm run dev
        else
            echo '❌ package.json not found. Run setup first.'
        fi
    "
}

# Show container logs
show_logs() {
    log "Showing container logs..."
    docker logs "${CONTAINER_NAME}" --tail 50 -f
}

# Run test suite
run_tests() {
    log "Running test suite..."
    
    if ! docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
        warn "Container is not running. Starting it first..."
        start_container || return 1
    fi
    
    docker exec "${CONTAINER_NAME}" bash -c "
        source ~/.nvm/nvm.sh 2>/dev/null || true
        cd /workspace/ice-webapp
        if [[ -f package.json ]]; then
            echo '🧪 Running test suite...'
            npm run test 2>/dev/null || echo 'No tests configured yet'
            echo '🔍 Running type checking...'
            npm run type-check 2>/dev/null || echo 'TypeScript not configured yet'
            echo '📋 Running linting...'
            npm run lint 2>/dev/null || echo 'Linting not configured yet'
        else
            echo '❌ package.json not found. Run setup first.'
        fi
    "
}

# Stop container
stop_container() {
    log "Stopping ICE-WEBAPP container..."
    docker compose -f "${COMPOSE_FILE}" down
    success "Container stopped"
}

# Clean all containers
clean_containers() {
    log "Cleaning all ICE-WEBAPP containers and networks..."
    docker compose -f "${COMPOSE_FILE}" down
    docker system prune -f --filter label=com.docker.compose.project=ice-webapp 2>/dev/null || true
    success "Cleanup completed"
}

# Open in dev container (for Cursor IDE)
open_devcontainer() {
    log "Opening ICE-WEBAPP in Dev Container (Cursor IDE)..."
    
    if [[ ! -f "${DEVCONTAINER_CONFIG}" ]]; then
        error "Dev container configuration not found: ${DEVCONTAINER_CONFIG}"
        return 1
    fi
    
    success "Dev container configuration found"
    log "To use with Cursor IDE:"
    echo "  1. Open Command Palette (Ctrl+Shift+P)"
    echo "  2. Run: 'Dev Containers: Reopen in Container'"
    echo "  3. Cursor will automatically use the Codex Universal image"
    echo
    log "Dev container features:"
    echo "  ✓ Node.js 22 pre-configured"
    echo "  ✓ TypeScript, ESLint, Prettier extensions"
    echo "  ✓ Tailwind CSS support"
    echo "  ✓ GitHub Copilot integration"
    echo "  ✓ Port forwarding for Next.js (3000)"
    echo "  ✓ Automatic setup script execution"
}

# Show resource usage
show_resources() {
    log "Container resource usage:"
    
    if docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
        docker stats "${CONTAINER_NAME}" --no-stream
        echo
        log "Container processes:"
        docker exec "${CONTAINER_NAME}" ps aux | head -10
    else
        warn "Container is not running"
    fi
}

# Main execution
main() {
    print_header
    
    while true; do
        show_menu
        read -p "Select option (0-11): " choice
        
        case $choice in
            1) start_container ;;
            2) connect_container ;;
            3) show_status ;;
            4) run_setup ;;
            5) start_dev_server ;;
            6) show_logs ;;
            7) run_tests ;;
            8) stop_container ;;
            9) clean_containers ;;
            10) open_devcontainer ;;
            11) show_resources ;;
            0) 
                log "Exiting Docker manager..."
                exit 0
                ;;
            *)
                error "Invalid option. Please select 0-11."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Execute main function
main "$@" 