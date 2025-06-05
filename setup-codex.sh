#!/usr/bin/env bash
#
# ICE-WEBAPP Codex Setup Script - Optimized for ChatGPT Codex Pre-installed Environment
# Leverages Codex pre-installed packages: Node.js 20, Python 3.12, Bun 1.2.14, etc.
# Based on OpenAI Codex environment specifications and community best practices
# Version: 2025.1.1 - Codex Optimized
#

set -Eeuo pipefail
IFS=$'\n\t'

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuration - Optimized for Codex pre-installed packages
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_DIR="$PWD"
readonly TOOLS_DIR="$WORKSPACE_DIR/tools"

# Codex Environment Package Versions (updated to Node.js 22)
readonly NODE_VERSION="22.12.0"   # Updated to Node.js 22 (configurable in Codex)
readonly PYTHON_VERSION="3.12"    # Pre-installed Python 3.12
readonly BUN_VERSION="1.2.14"     # Pre-installed Bun 1.2.14
readonly JAVA_VERSION="21"        # Pre-installed Java 21
readonly GO_VERSION="1.23.8"      # Pre-installed Go 1.23.8
readonly RUST_VERSION="1.87.0"    # Pre-installed Rust 1.87.0
readonly RUBY_VERSION="3.4.4"     # Pre-installed Ruby 3.4.4
readonly SWIFT_VERSION="6.1"      # Pre-installed Swift 6.1

# Bleeding-edge dependency versions (unified for Node.js 22)
readonly NEXT_VERSION="15.1.3"    # Latest Next.js
readonly REACT_VERSION="19.0.0"   # Latest React
readonly TYPESCRIPT_VERSION="5.7.2"
readonly TAILWIND_VERSION="3.4.16"
readonly VITE_VERSION="6.0.1"
readonly VITEST_VERSION="2.1.6"
readonly PLAYWRIGHT_VERSION="1.49.0"
readonly ESLINT_VERSION="9.18.0"  # Latest ESLint

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING] $*${NC}" >&2
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
    exit 1
}

info() {
    echo -e "${BLUE}[INFO] $*${NC}" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}" >&2
}

# Detect Codex environment
detect_codex_environment() {
    info "Detecting ChatGPT Codex environment..."
    
    # Codex-specific environment checks
    if [[ "$USER" == "root" ]] && \
       [[ -z "${SUDO_USER:-}" ]] && \
       [[ -f "/.dockerenv" || -n "${CONTAINER:-}" ]]; then
        echo "codex"
    else
        echo "unknown"
    fi
}

# Setup Codex environment optimizations
setup_codex_environment() {
    log "Setting up ChatGPT Codex environment optimizations..."
    
    # Essential environment variables for Codex containers
    export SHELL="/bin/bash"
    export DEBIAN_FRONTEND=noninteractive
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    
    # Create necessary directories
    mkdir -p "$PNPM_HOME" ~/.npm ~/.cache ~/.config "$TOOLS_DIR"
    
    # Clear proxy settings that cause npm warnings (from community discussions)
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
    
    # Configure apt for Codex containers (no sudo needed - runs as root)
    if command -v apt-get >/dev/null 2>&1; then
        echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
        echo 'Acquire::http::Timeout "60";' > /etc/apt/apt.conf.d/80-timeout
        
        # Update package lists (no sudo - already root in Codex)
        apt-get update -qq 2>/dev/null || warn "apt-get update failed (expected in some Codex environments)"
    fi
    
    success "Codex environment optimized"
}

# Verify and configure pre-installed packages
verify_preinstalled_packages() {
    log "Verifying ChatGPT Codex pre-installed packages..."
    
    # Check Node.js (should be v22.x)
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version)
        info "✅ Node.js: $node_version (configurable in Codex)"
        
        if [[ ! "$node_version" =~ ^v22\. ]]; then
            warn "Expected Node.js v22.x, got $node_version"
            info "💡 You can update Node.js in Codex environment settings"
        fi
    else
        error "Node.js not found - Codex environment issue"
    fi
    
    # Check npm
    if command -v npm >/dev/null 2>&1; then
        info "✅ npm: $(npm --version) (pre-installed)"
    else
        error "npm not found - Codex environment issue"
    fi
    
    # Check Python (should be 3.12)
    if command -v python3 >/dev/null 2>&1; then
        local python_version=$(python3 --version)
        info "✅ Python: $python_version (pre-installed)"
    else
        warn "Python3 not found in expected location"
    fi
    
    # Check other pre-installed tools
    command -v bun >/dev/null 2>&1 && info "✅ Bun: $(bun --version) (pre-installed)"
    command -v java >/dev/null 2>&1 && info "✅ Java: $(java --version | head -1) (pre-installed)"
    command -v go >/dev/null 2>&1 && info "✅ Go: $(go version) (pre-installed)"
    command -v rustc >/dev/null 2>&1 && info "✅ Rust: $(rustc --version) (pre-installed)"
    command -v ruby >/dev/null 2>&1 && info "✅ Ruby: $(ruby --version) (pre-installed)"
    command -v swift >/dev/null 2>&1 && info "✅ Swift: $(swift --version | head -1) (pre-installed)"
    
    success "Pre-installed packages verified"
}

# Install pnpm for better package management (Codex optimized)
install_pnpm_codex() {
    log "Installing pnpm package manager..."
    
    # Check if pnpm is already available
    if command -v pnpm >/dev/null 2>&1; then
        info "pnpm already installed: $(pnpm --version)"
        return 0
    fi
    
    # Install pnpm using the pre-installed npm (no curl needed)
    npm install -g pnpm@latest
    
    # Verify installation
    if command -v pnpm >/dev/null 2>&1; then
        info "✅ pnpm installed: $(pnpm --version)"
    else
        error "pnpm installation failed"
    fi
    
    # Configure pnpm for Codex environment
    pnpm config set registry https://registry.npmjs.org/
    pnpm config set store-dir ~/.pnpm-store
    pnpm config set network-timeout 300000
    pnpm config set fetch-retries 5
    pnpm config set fetch-retry-factor 2
    pnpm config set fetch-retry-mintimeout 10000
    
    success "pnpm configured for Codex environment"
}

# Configure npm for clean operation (no proxy warnings)
configure_npm_codex() {
    log "Configuring npm for Codex environment..."
    
    # Remove problematic configurations (from community solutions)
    npm config delete proxy --global 2>/dev/null || true
    npm config delete https-proxy --global 2>/dev/null || true
    npm config delete http-proxy --global 2>/dev/null || true
    
    # Set optimal configurations for Codex
    npm config set registry https://registry.npmjs.org/ --global
    npm config set fetch-retries 5 --global
    npm config set fetch-retry-factor 2 --global
    npm config set fetch-retry-mintimeout 10000 --global
    npm config set audit false --global  # Skip audit in containers
    
    success "npm configured for Codex"
}

# Install essential build tools for Codex (no sudo needed)
install_build_tools() {
    log "Installing essential build tools..."
    
    # Install only if apt-get is available and working
    if command -v apt-get >/dev/null 2>&1; then
        # Try to install build essentials (might fail in some Codex environments)
        apt-get install -y curl wget git build-essential ca-certificates 2>/dev/null || \
            warn "Some packages failed to install (expected in restricted Codex environments)"
    fi
    
    success "Build tools setup completed"
}

# Create optimized project structure for Codex
create_project_structure() {
    log "Creating ICE-WEBAPP project structure..."
    
    # Core directories
    mkdir -p {src,public,docs,tests,scripts,config,.github/workflows}
    mkdir -p {src/{components,pages,hooks,utils,stores,types,styles},tests/{unit,integration,e2e}}
    mkdir -p {docs/{api,guides,examples},config/{environments,tools}}
    
    # AI/Codex-specific directories
    mkdir -p {ai/{prompts,templates,docs},tools/{ai,scripts,codex}}
    
    # Codex workspace organization
    mkdir -p {workspace/{specs,pseudo,arch,src,tests,docs}}
    
    success "Project structure created"
}

# Package.json optimized for Node.js 22 (unified dependencies)
create_package_json_codex() {
    log "Creating package.json with bleeding-edge dependencies for Node.js 22..."
    
    cat > package.json << EOF
{
  "name": "ice-webapp",
  "version": "1.0.0",
  "description": "AI-optimized web application starter for ChatGPT Codex",
  "type": "module",
  "engines": {
    "node": ">=22.0.0",
    "npm": ">=10.0.0"
  },
  "scripts": {
    "dev": "next dev --turbo",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:e2e": "playwright test",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "analyze": "cross-env ANALYZE=true next build",
    "codacy": "./tools/codacy-runtime.sh",
    "codex:verify": "node --version && npm --version && pnpm --version"
  },
  "dependencies": {
    "next": "^${NEXT_VERSION}",
    "react": "^${REACT_VERSION}",
    "react-dom": "^${REACT_VERSION}",
    "framer-motion": "^11.0.0",
    "lucide-react": "^0.400.0",
    "@radix-ui/react-slot": "^1.1.0",
    "@radix-ui/react-toast": "^1.2.0",
    "@radix-ui/react-dialog": "^1.1.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.3.0",
    "zustand": "^4.5.0",
    "@tanstack/react-query": "^5.40.0",
    "react-hook-form": "^7.50.0",
    "@hookform/resolvers": "^3.6.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@types/node": "^22.10.2",
    "@types/react": "^19.0.1",
    "@types/react-dom": "^19.0.1",
    "typescript": "^${TYPESCRIPT_VERSION}",
    "eslint": "^${ESLINT_VERSION}",
    "eslint-config-next": "^${NEXT_VERSION}",
    "@typescript-eslint/eslint-plugin": "^8.18.0",
    "@typescript-eslint/parser": "^8.18.0",
    "prettier": "^3.3.0",
    "prettier-plugin-tailwindcss": "^0.6.0",
    "tailwindcss": "^${TAILWIND_VERSION}",
    "postcss": "^8.4.38",
    "autoprefixer": "^10.4.19",
    "vitest": "^${VITEST_VERSION}",
    "@vitejs/plugin-react": "^4.3.0",
    "@testing-library/react": "^16.0.0",
    "@testing-library/jest-dom": "^6.4.0",
    "@testing-library/user-event": "^14.5.0",
    "playwright": "^${PLAYWRIGHT_VERSION}",
    "@playwright/test": "^${PLAYWRIGHT_VERSION}",
    "cross-env": "^7.0.3"
  },
  "pnpm": {
    "overrides": {
      "react": "\$react",
      "react-dom": "\$react-dom"
    }
  }
}
EOF
    
    success "Package.json created with bleeding-edge dependencies for Node.js 22"
}

# Create Codex-specific configuration files
create_codex_configs() {
    log "Creating Codex-optimized configuration files..."
    
    # Next.js config optimized for Codex
    cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: ['lucide-react'],
    turbo: {
      rules: {
        '*.svg': {
          loaders: ['@svgr/webpack'],
          as: '*.js',
        },
      },
    },
  },
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },
  images: {
    domains: ['localhost'],
  },
  // Codex environment optimizations
  swcMinify: true,
  poweredByHeader: false,
}

module.exports = nextConfig
EOF

    # TypeScript config for Node.js 22
    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

    # Tailwind config
    cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

    # Environment files for Codex
    cat > .env.local << 'EOF'
# ChatGPT Codex Environment Variables
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME="ICE WebApp"
NODE_ENV=development
EOF

    cat > .env.example << 'EOF'
# Copy to .env.local and configure
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME="ICE WebApp"
NODE_ENV=development
EOF

    success "Codex configuration files created"
}

# Main Codex setup function
main() {
    local env_type
    env_type="$(detect_codex_environment)"
    
    if [[ "$env_type" != "codex" ]]; then
        warn "This script is optimized for ChatGPT Codex environments"
        warn "Detected environment: $env_type"
        warn "Use the main setup.sh for other environments"
    fi
    
    info "🧊 ICE-WEBAPP Codex Setup Starting..."
    info "Optimized for ChatGPT Codex with Node.js 22 and bleeding-edge dependencies"
    info "Environment: $env_type"
    echo
    
    # Codex-specific setup sequence
    setup_codex_environment
    verify_preinstalled_packages
    configure_npm_codex
    install_pnpm_codex
    install_build_tools
    create_project_structure
    create_package_json_codex
    create_codex_configs
    
    # Install dependencies using pre-installed npm/pnpm
    log "Installing dependencies with pnpm..."
    if command -v pnpm >/dev/null 2>&1; then
        pnpm install || warn "Dependency installation failed (may need manual retry)"
    else
        npm install || warn "Dependency installation failed (may need manual retry)"
    fi
    
    # Final verification
    log "Verifying Codex setup..."
    echo "  Node.js: $(node --version) ✓"
    echo "  npm: $(npm --version) ✓"
    if command -v pnpm >/dev/null 2>&1; then
        echo "  pnpm: $(pnpm --version) ✓"
    fi
    echo "  Environment: ChatGPT Codex ✓"
    
    success "🎉 ICE-WEBAPP Codex setup completed!"
    echo
    info "Next steps for ChatGPT Codex:"
    echo "  1. Run 'pnpm run dev' to start development server"
    echo "  2. Use 'pnpm run codex:verify' to verify environment"
    echo "  3. Run 'pnpm run lint' for code quality checks"
    echo "  4. Start building your AI-optimized web application!"
    echo
    info "📚 Documentation available in:"
    echo "  - CODEX_GUIDE.md"
    echo "  - CODEX_TROUBLESHOOTING.md"
}

# Execute main function
main "$@" 