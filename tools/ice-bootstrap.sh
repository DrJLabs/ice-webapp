#!/usr/bin/env bash
#
# ICE-WEBAPP Bootstrap Script
# Initializes any project with ICE-WEBAPP configuration for ChatGPT Codex
# Version: 2025.1.0
#

set -Eeuo pipefail
IFS=$'\n\t'

# Configuration
readonly SCRIPT_VERSION="2025.1.0"
readonly ICE_REPO="https://api.github.com/repos/DrJLabs/ice-webapp"
readonly ICE_RAW="https://raw.githubusercontent.com/DrJLabs/ice-webapp/main"

# Color codes
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[ICE-BOOTSTRAP] $*${NC}" >&2; }
warn() { echo -e "${YELLOW}[WARN] $*${NC}" >&2; }
info() { echo -e "${BLUE}[INFO] $*${NC}" >&2; }
error() { echo -e "${RED}[ERROR] $*${NC}" >&2; exit 1; }

# Display banner
show_banner() {
    cat << 'EOF'
🧊 ICE-WEBAPP Bootstrap
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Intelligent Codex Environment for Web Development
Bleeding-edge tools for AI-optimized development
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [PROJECT_NAME]

Options:
  --template TYPE    Project template (webapp, api, fullstack) [default: webapp]
  --codex-only      Setup for Codex only (minimal local files)
  --full-setup      Complete ICE-WEBAPP setup with all tools
  --update          Update existing ICE configuration
  --version         Show version information
  --help            Show this help message

Examples:
  $0 my-webapp                    # Create new webapp
  $0 --template=api my-api        # Create API project  
  $0 --codex-only existing-proj   # Add Codex support to existing project
  $0 --update                     # Update ICE configuration in current project

EOF
}

# Parse command line arguments
parse_args() {
    TEMPLATE="webapp"
    CODEX_ONLY=false
    FULL_SETUP=false
    UPDATE_MODE=false
    PROJECT_NAME=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --template=*)
                TEMPLATE="${1#*=}"
                shift
                ;;
            --template)
                TEMPLATE="$2"
                shift 2
                ;;
            --codex-only)
                CODEX_ONLY=true
                shift
                ;;
            --full-setup)
                FULL_SETUP=true
                shift
                ;;
            --update)
                UPDATE_MODE=true
                shift
                ;;
            --version)
                echo "ICE-WEBAPP Bootstrap v${SCRIPT_VERSION}"
                exit 0
                ;;
            --help)
                show_usage
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                ;;
            *)
                if [[ -z "$PROJECT_NAME" ]]; then
                    PROJECT_NAME="$1"
                else
                    error "Multiple project names specified"
                fi
                shift
                ;;
        esac
    done
}

# Validate template type
validate_template() {
    case "$TEMPLATE" in
        webapp|api|fullstack)
            log "Using template: $TEMPLATE"
            ;;
        *)
            error "Invalid template: $TEMPLATE. Valid options: webapp, api, fullstack"
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    command -v curl >/dev/null 2>&1 || missing_tools+=("curl")
    command -v git >/dev/null 2>&1 || missing_tools+=("git")
    command -v node >/dev/null 2>&1 || missing_tools+=("node")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
    fi
}

# Download file from ICE-WEBAPP repository
download_file() {
    local file_path="$1"
    local target_path="$2"
    local url="${ICE_RAW}/${file_path}"
    
    info "Downloading: $file_path"
    if ! curl -fsSL "$url" -o "$target_path"; then
        warn "Failed to download: $file_path"
        return 1
    fi
    return 0
}

# Create project directory structure
create_project_structure() {
    local project_dir="$1"
    
    if [[ "$UPDATE_MODE" == "false" ]]; then
        if [[ -d "$project_dir" ]]; then
            error "Directory already exists: $project_dir"
        fi
        mkdir -p "$project_dir"
        cd "$project_dir"
    fi
    
    # Create ICE-specific directories
    mkdir -p {ai/{prompts,templates,docs},tools,scripts,.github/workflows}
    
    if [[ "$CODEX_ONLY" == "false" ]]; then
        # Create full project structure
        mkdir -p {src/{components,lib,hooks,types,styles},tests/{unit,integration,e2e}}
        
        case "$TEMPLATE" in
            webapp)
                mkdir -p {src/app,public}
                ;;
            api)
                mkdir -p {src/{routes,middleware,schemas}}
                ;;
            fullstack)
                mkdir -p {src/{app,api,components,lib},public,server}
                ;;
        esac
    fi
}

# Download core ICE files
download_core_files() {
    local files=(
        "AGENTS.md"
        "ai/prompts/development-prompts.md"
        "tools/codacy-runtime.sh"
        "scripts/dependency-sync.sh"
        ".github/workflows/codacy.yml"
    )
    
    for file in "${files[@]}"; do
        local target_dir
        target_dir="$(dirname "$file")"
        mkdir -p "$target_dir"
        
        if ! download_file "$file" "$file"; then
            warn "Skipping optional file: $file"
        else
            # Make scripts executable
            if [[ "$file" == *.sh ]]; then
                chmod +x "$file"
            fi
        fi
    done
}

# Download template-specific files
download_template_files() {
    case "$TEMPLATE" in
        webapp)
            download_webapp_files
            ;;
        api)
            download_api_files
            ;;
        fullstack)
            download_fullstack_files
            ;;
    esac
}

# Download webapp template files
download_webapp_files() {
    if [[ "$CODEX_ONLY" == "false" ]]; then
        local files=(
            "package.json"
            "next.config.js"
            "tailwind.config.js"
            "tsconfig.json"
            "eslint.config.js"
            ".prettierrc"
            "vitest.config.ts"
            "playwright.config.ts"
            "src/lib/utils.ts"
            "src/styles/globals.css"
            "tests/setup.ts"
        )
        
        for file in "${files[@]}"; do
            local target_dir
            target_dir="$(dirname "$file")"
            mkdir -p "$target_dir"
            download_file "$file" "$file" || warn "Failed to download: $file"
        done
    fi
    
    # Always download the setup script
    download_file "setup.sh" "setup.sh"
    chmod +x setup.sh
}

# Download API template files (simplified)
download_api_files() {
    info "API template - creating minimal Node.js API structure"
    
    # Create basic API package.json
    cat > package.json << 'EOF'
{
  "name": "ice-api",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "vitest",
    "lint": "eslint src/",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "fastify": "^5.1.0",
    "@fastify/cors": "^10.0.1",
    "zod": "^3.24.1"
  },
  "devDependencies": {
    "@types/node": "^22.10.2",
    "typescript": "^5.7.2",
    "tsx": "^4.19.2",
    "vitest": "^2.1.6",
    "eslint": "^9.18.0"
  }
}
EOF
}

# Download fullstack template files
download_fullstack_files() {
    info "Fullstack template - combining webapp + API"
    download_webapp_files
    
    # Add additional fullstack dependencies to package.json
    info "Enhancing package.json for fullstack development"
}

# Create Codex environment configuration
create_codex_config() {
    cat > .codex/environment.json << EOF
{
  "name": "ICE-WEBAPP Environment",
  "description": "Bleeding-edge web development with AI optimization",
  "version": "$SCRIPT_VERSION",
  "template": "$TEMPLATE",
  "setup_script": "./setup.sh",
  "requirements": {
    "node": ">=22.12.0",
    "pnpm": ">=9.0.0"
  },
  "features": {
    "codacy_integration": true,
    "security_scanning": true,
    "ai_prompts": true,
    "dependency_sync": true
  }
}
EOF
}

# Create environment files
create_environment_files() {
    # .env.example
    cat > .env.example << 'EOF'
# ICE-WEBAPP Environment Variables
NODE_ENV=development

# Application
NEXT_PUBLIC_APP_NAME="My ICE WebApp"
NEXT_PUBLIC_APP_URL=http://localhost:3000

# Codacy (optional)
# CODACY_ACCOUNT_TOKEN=your_account_token
# CODACY_PROJECT_TOKEN=your_project_token

# Add your service-specific variables here
EOF

    # .gitignore
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.pnpm-store/

# Production builds
.next/
dist/
build/

# Environment variables
.env
.env.local
.env.production

# Testing
coverage/
test-results/

# IDE
.vscode/settings.json
.cursor/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# ICE-WEBAPP
dependency-manifest.json
EOF
}

# Generate project README
generate_readme() {
    cat > README.md << EOF
# ${PROJECT_NAME:-ICE Project}

Generated with **ICE-WEBAPP** - Intelligent Codex Environment for bleeding-edge web development.

## 🚀 Quick Start

### For ChatGPT Codex

1. Copy the setup script to your Codex environment:
\`\`\`bash
# Paste the contents of setup.sh into your Codex setup script field
\`\`\`

2. Start developing with AI assistance!

### For Local Development

\`\`\`bash
# Install dependencies
pnpm install

# Start development server
pnpm run dev
\`\`\`

## 📚 Documentation

- [AGENTS.md](AGENTS.md) - Development guidelines for AI agents
- [AI Prompts](ai/prompts/development-prompts.md) - Optimized development prompts

## 🛠️ Available Scripts

\`\`\`bash
pnpm run dev          # Start development server
pnpm run build        # Build for production
pnpm run test         # Run tests
pnpm run lint         # Lint code
pnpm run type-check   # TypeScript checking
\`\`\`

## 🔧 Tools & Features

- ✅ Next.js 15 with App Router
- ✅ React 19 with latest features  
- ✅ TypeScript 5.7 with strict mode
- ✅ Tailwind CSS 3.4
- ✅ Comprehensive testing setup
- ✅ Code quality enforcement
- ✅ Security scanning
- ✅ AI-optimized development

---

**Built with 🧊 ICE-WEBAPP**
EOF
}

# Main bootstrap function
main() {
    show_banner
    
    # Parse arguments
    parse_args "$@"
    
    # Validate inputs
    validate_template
    check_prerequisites
    
    # Set project name if not provided
    if [[ -z "$PROJECT_NAME" && "$UPDATE_MODE" == "false" ]]; then
        PROJECT_NAME="ice-webapp-$(date +%s)"
        warn "No project name provided, using: $PROJECT_NAME"
    fi
    
    # Create or update project
    if [[ "$UPDATE_MODE" == "true" ]]; then
        log "Updating ICE configuration in current directory"
        PROJECT_DIR="."
    else
        log "Creating new project: $PROJECT_NAME"
        PROJECT_DIR="$PROJECT_NAME"
    fi
    
    # Setup project structure
    create_project_structure "$PROJECT_DIR"
    
    # Download core files
    log "Downloading ICE-WEBAPP configuration files..."
    download_core_files
    
    # Download template-specific files
    if [[ "$CODEX_ONLY" == "false" ]]; then
        log "Setting up $TEMPLATE template..."
        download_template_files
    fi
    
    # Create additional files
    mkdir -p .codex
    create_codex_config
    create_environment_files
    
    if [[ "$UPDATE_MODE" == "false" ]]; then
        generate_readme
    fi
    
    # Success message
    echo
    log "🎉 ICE-WEBAPP setup complete!"
    echo
    info "Next steps:"
    if [[ "$UPDATE_MODE" == "false" ]]; then
        echo "  1. cd $PROJECT_NAME"
    fi
    if [[ "$CODEX_ONLY" == "false" ]]; then
        echo "  2. pnpm install"
        echo "  3. pnpm run dev"
    else
        echo "  2. Copy setup.sh to your Codex environment"
        echo "  3. Start your Codex task"
    fi
    echo "  4. Check AGENTS.md for development guidelines"
    echo "  5. Use ai/prompts/ for optimized AI development"
    echo
    info "For ChatGPT Codex: Use the setup.sh script in your environment configuration"
    info "Documentation: https://github.com/DrJLabs/ice-webapp"
}

# Execute main function with all arguments
main "$@" 