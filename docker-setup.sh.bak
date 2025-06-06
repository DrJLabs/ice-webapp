#!/bin/bash
#
# ICE-WEBAPP Docker Setup Script v2025.1.0
# Optimized for Codex Universal Container Testing
# Follows Docker best practices and security guidelines
#

set -euo pipefail

# Configuration
readonly SCRIPT_VERSION="2025.1.0"
readonly CONTAINER_PREFIX="ice-webapp"
readonly CODEX_IMAGE="ghcr.io/openai/codex-universal:latest"
readonly COMPOSE_FILE="docker-compose.codex.yml"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

# Print header
print_header() {
    echo "================================================================"
    echo "🧊 ICE-WEBAPP Docker Setup Script v${SCRIPT_VERSION}"
    echo "================================================================"
    echo "Timestamp: $(date)"
    echo "Docker Version: $(docker --version)"
    echo "Docker Compose: $(docker compose version)"
    echo "Working Directory: $(pwd)"
    echo "================================================================"
}

# Verify Docker is running
verify_docker() {
    log "Verifying Docker daemon..."
    
    if ! docker info >/dev/null 2>&1; then
        error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi
    
    success "Docker daemon is running"
}

# Clean up existing containers and networks
cleanup_existing() {
    log "Cleaning up existing ICE-WEBAPP containers..."
    
    # Stop and remove containers
    docker ps -a --filter "name=${CONTAINER_PREFIX}" --format "{{.Names}}" | while read -r container; do
        if [[ -n "$container" ]]; then
            log "Stopping container: $container"
            docker stop "$container" >/dev/null 2>&1 || true
            log "Removing container: $container"
            docker rm "$container" >/dev/null 2>&1 || true
        fi
    done
    
    # Remove unused networks
    docker network prune -f >/dev/null 2>&1 || true
    
    success "Cleanup completed"
}

# Pull latest Codex Universal image
pull_codex_image() {
    log "Pulling latest Codex Universal image..."
    
    if docker pull "$CODEX_IMAGE"; then
        success "Codex Universal image pulled successfully"
    else
        warn "Failed to pull latest image - using cached version if available"
        if ! docker image inspect "$CODEX_IMAGE" >/dev/null 2>&1; then
            error "No Codex Universal image available. Please check your internet connection."
            exit 1
        fi
    fi
}

# Validate Docker Compose file
validate_compose() {
    log "Validating Docker Compose configuration..."
    
    if [[ ! -f "$COMPOSE_FILE" ]]; then
        error "Docker Compose file not found: $COMPOSE_FILE"
        exit 1
    fi
    
    if docker compose -f "$COMPOSE_FILE" config >/dev/null 2>&1; then
        success "Docker Compose configuration is valid"
    else
        error "Docker Compose configuration is invalid"
        docker compose -f "$COMPOSE_FILE" config
        exit 1
    fi
}

# Create Docker network for ICE-WEBAPP
create_network() {
    log "Creating ICE-WEBAPP Docker network..."
    
    local network_name="${CONTAINER_PREFIX}-network"
    
    if docker network inspect "$network_name" >/dev/null 2>&1; then
        log "Network $network_name already exists"
    else
        docker network create \
            --driver bridge \
            --subnet=172.20.0.0/16 \
            --ip-range=172.20.240.0/20 \
            "$network_name"
        success "Network $network_name created"
    fi
}

# Set up volume permissions
setup_volumes() {
    log "Setting up Docker volumes with proper permissions..."
    
    # Create bind mount directories if they don't exist
    mkdir -p ./tests ./tools ./config
    
    # Set proper permissions for container access
    chmod 755 ./tests ./tools ./config
    
    success "Volume permissions configured"
}

# Start Codex mirror container
start_codex_mirror() {
    log "Starting Codex Universal mirror container..."
    
    docker compose -f "$COMPOSE_FILE" up -d codex-mirror
    
    # Wait for container to be ready
    local container_name="${CONTAINER_PREFIX}-codex-test"
    local max_wait=30
    local wait_time=0
    
    while [[ $wait_time -lt $max_wait ]]; do
        if docker ps --filter "name=$container_name" --filter "status=running" | grep -q "$container_name"; then
            success "Codex mirror container is running"
            return 0
        fi
        sleep 2
        ((wait_time += 2))
        log "Waiting for container to start... ($wait_time/${max_wait}s)"
    done
    
    error "Container failed to start within ${max_wait} seconds"
    docker logs "$container_name" 2>/dev/null || true
    exit 1
}

# Test container connectivity
test_connectivity() {
    log "Testing container connectivity..."
    
    local container_name="${CONTAINER_PREFIX}-codex-test"
    
    # Test basic connectivity
    if docker exec "$container_name" echo "Container connectivity test" >/dev/null 2>&1; then
        success "Container is accessible"
    else
        error "Cannot connect to container"
        exit 1
    fi
    
    # Test environment setup
    log "Verifying container environment..."
    docker exec "$container_name" bash -c "
        echo 'Node.js: \$(node --version)'
        echo 'npm: \$(npm --version)'
        echo 'Python: \$(python3 --version)'
        echo 'Working directory: \$(pwd)'
        echo 'User: \$(whoami)'
    "
}

# Run setup script in container
run_setup_script() {
    log "Running setup-codex.sh in container..."
    
    local container_name="${CONTAINER_PREFIX}-codex-test"
    
    # Copy setup script to container if needed
    docker exec "$container_name" bash -c "
        if [[ -f /workspace/ice-webapp/setup-codex.sh ]]; then
            cd /workspace/ice-webapp
            echo '🚀 Running ICE-WEBAPP setup in Codex Universal container...'
            bash setup-codex.sh
        else
            echo '⚠️ setup-codex.sh not found in mounted volume'
            echo 'Available files:'
            ls -la /workspace/ice-webapp/ || echo 'Directory not found'
        fi
    "
}

# Display container information
show_container_info() {
    log "Container Information:"
    echo
    
    # Show running containers
    echo "Running ICE-WEBAPP containers:"
    docker ps --filter "name=${CONTAINER_PREFIX}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo
    
    # Show useful commands
    echo "Useful commands:"
    echo "  Connect to container:    docker exec -it ${CONTAINER_PREFIX}-codex-test bash"
    echo "  View container logs:     docker logs ${CONTAINER_PREFIX}-codex-test"
    echo "  Stop containers:         docker compose -f ${COMPOSE_FILE} down"
    echo "  Run test suite:          docker compose -f ${COMPOSE_FILE} --profile test up"
    echo "  Restart setup:           docker exec ${CONTAINER_PREFIX}-codex-test bash setup-codex.sh"
    echo
}

# Main execution function
main() {
    print_header
    
    # Pre-flight checks
    verify_docker
    validate_compose
    
    # Setup phase
    cleanup_existing
    pull_codex_image
    create_network
    setup_volumes
    
    # Container startup
    start_codex_mirror
    test_connectivity
    
    # Configuration
    run_setup_script
    
    # Final status
    show_container_info
    
    success "🎉 ICE-WEBAPP Docker setup completed successfully!"
    echo
    log "Your Codex Universal testing environment is ready!"
    log "The container mirrors the ChatGPT Codex environment for local testing."
}

# Error handling
trap 'error "Setup failed at line $LINENO"' ERR

# Execute main function
main "$@" 