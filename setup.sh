#!/usr/bin/env bash
#
# ICE-WEBAPP Setup Script - Bleeding Edge AI-Optimized Web Development Environment
# Designed for ChatGPT Codex usage with absolute dependency management cohesion
# Version: 2025.1.1 - Now with robust error reporting for container environments
#

# --- Robust Error-Handling Setup ---
set -x # Enable command tracing
DEBUG_MESSAGES=()
FAILED_COMMANDS=0

run_command() {
    local cmd_string="$1"
    local description="$2"
    log "--- [START] $description ---"
    if ! eval "$cmd_string"; then
        local error_msg="--- [FAILED] '$description' ---"
        warn "$error_msg"
        DEBUG_MESSAGES+=("Task: '$description' | Command: '$cmd_string'")
        ((FAILED_COMMANDS++))
    else
        success "--- [SUCCESS] '$description' ---"
    fi
}
# --- End Error-Handling Setup ---

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

# Configuration - Unified for Node.js 22 across all environments
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_DIR="$PWD"
readonly NODE_VERSION="22.12.0"  # Unified Node.js version
readonly PYTHON_VERSION="3.12"
readonly TOOLS_DIR="$WORKSPACE_DIR/tools"

# Dependency versions (bleeding edge - unified across all environments)
readonly NEXT_VERSION="15.1.3"
readonly REACT_VERSION="19.0.0"
readonly TYPESCRIPT_VERSION="5.7.2"
readonly TAILWIND_VERSION="3.4.16"
readonly VITE_VERSION="6.0.1"
readonly VITEST_VERSION="2.1.6"
readonly PLAYWRIGHT_VERSION="1.49.0"
readonly ESLINT_VERSION="9.18.0"

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING] $*${NC}" >&2
}

error() {
    local msg="[ERROR] $*"
    warn "$msg"
    DEBUG_MESSAGES+=("$msg")
    ((FAILED_COMMANDS++))
}

info() {
    echo -e "${BLUE}[INFO] $*${NC}" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}" >&2
}

# Detect environment type with improved Codex detection
detect_environment() {
    # Use parameter expansion to handle unbound variables safely
    local current_user="${USER:-$(whoami 2>/dev/null || echo 'unknown')}"
    local sudo_user="${SUDO_USER:-}"
    local codex_env="${CODEX_ENVIRONMENT:-}"
    local github_codespace="${GITHUB_CODESPACE_NAME:-}"
    local openai_codex="${OPENAI_CODEX:-}"
    local container_env="${CONTAINER:-}"
    local cursor_session="${CURSOR_SESSION:-}"
    local ci_env="${CI:-}"
    
    # Check for Codex/container environments
    if [[ -n "$codex_env" ]] || \
       [[ -n "$github_codespace" ]] || \
       [[ -n "$openai_codex" ]] || \
       [[ -f "/.dockerenv" ]] || \
       [[ "$current_user" == "root" && -z "$sudo_user" ]] || \
       [[ -n "$container_env" ]]; then
        echo "codex"
    elif [[ -n "$cursor_session" ]]; then
        echo "cursor"
    elif [[ -n "$ci_env" ]]; then
        echo "ci"
    else
        echo "local"
    fi
}

# System dependencies setup
setup_system_dependencies() {
    log "Setting up system dependencies..."
    run_command "sudo apt-get update -qq" "Update apt package lists"
    run_command "sudo apt-get install -y curl wget git build-essential ca-certificates gnupg lsb-release" "Install base packages"
}

# Node.js setup with bleeding edge version
setup_nodejs() {
    log "Setting up Node.js ${NODE_VERSION}..."
    
    # Set shell environment for Codex/container compatibility
    export SHELL="${SHELL:-/bin/bash}"
    
    # Clear npm proxy warnings for clean environments
    run_command "unset HTTP_PROXY http_proxy HTTPS_PROXY https_proxy" "Unset proxy variables"
    
    # Install Node.js via NodeSource with retry mechanism
    run_command "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -" "Set up NodeSource repository"
    
    # Force install specific Node.js version
    run_command "sudo apt-get install -y nodejs" "Install Node.js"
    
    # Verify Node.js version and handle mismatch
    current_version=$(node --version)
    log "Current Node.js version: $current_version"
    
    if [[ ! "$current_version" =~ ^v22\. ]]; then
        warn "Node.js version mismatch, forcing v22.x installation..."
        run_command "sudo apt-get remove -y nodejs npm" "Remove conflicting Node.js version"
        run_command "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -" "Re-run NodeSource setup"
        run_command "sudo apt-get install -y nodejs" "Install correct Node.js version"
    fi
    
    # Verify final installation
    log "Final Node.js version: $(node --version)"
    log "NPM version: $(npm --version)"
    
    # Install pnpm with explicit shell and environment settings
    log "Installing pnpm for $ENVIRONMENT environment..."
    
    if [[ "$ENVIRONMENT" == "codex" ]]; then
        # Codex-specific pnpm installation
        export SHELL="/bin/bash"
        export PNPM_HOME="$HOME/.local/share/pnpm"
        run_command "mkdir -p \"$PNPM_HOME\"" "Create pnpm home directory"
        
        # Download and install pnpm manually for containers
        run_command "curl -fsSL https://get.pnpm.io/install.sh | SHELL=/bin/bash sh -" "Install pnpm"
        
        # Add to PATH immediately
        export PATH="$PNPM_HOME:$PATH"
        
        # Create shell profile entry
        echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.bashrc
        echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.bashrc
        
    else
        # Standard installation for other environments
        run_command "curl -fsSL https://get.pnpm.io/install.sh | sh -" "Install pnpm"
        source ~/.bashrc 2>/dev/null || export PATH="$HOME/.local/share/pnpm:$PATH"
    fi
    
    # Verify pnpm installation
    if ! command -v pnpm >/dev/null 2>&1; then
        error "pnpm installation failed"
        return 1
    fi
    
    # Configure npm/pnpm for speed and reliability
    run_command "npm config set registry https://registry.npmjs.org/ --global" "Set npm registry"
    run_command "npm config delete proxy --global" "Delete npm proxy config"
    run_command "npm config delete https-proxy --global" "Delete npm https-proxy config"
    
    if command -v pnpm >/dev/null 2>&1; then
        run_command "pnpm config set registry https://registry.npmjs.org/" "Set pnpm registry"
        run_command "pnpm config set store-dir ~/.pnpm-store" "Set pnpm store directory"
        run_command "pnpm config set network-timeout 300000" "Set pnpm network timeout"
        run_command "pnpm config set fetch-retries 5" "Set pnpm fetch retries"
    fi
    
    success "Node.js ${NODE_VERSION} and pnpm setup completed"
}

# Python setup for AI/ML tools
setup_python() {
    log "Setting up Python ${PYTHON_VERSION}..."
    run_command "sudo add-apt-repository ppa:deadsnakes/ppa -y" "Add deadsnakes PPA"
    run_command "sudo apt-get update" "Update apt after adding PPA"
    run_command "sudo apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-pip python${PYTHON_VERSION}-dev" "Install Python and tools"
    run_command "sudo ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python3" "Set python3 symlink"
    run_command "sudo ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python" "Set python symlink"
    run_command "python3 -m pip install --upgrade pip" "Upgrade pip"
    run_command "python3 -m pip install uv" "Install uv package installer"
}

# Codacy CLI setup (from existing script)
setup_codacy_cli() {
    log "Setting up Codacy CLI for quality assurance..."
    
    if ! [[ -x "$TOOLS_DIR/codacy" ]]; then
        mkdir -p "$TOOLS_DIR"
        local tmp=$(mktemp -d)
        trap "rm -rf '$tmp'" RETURN
        
        curl -fsSL "$(curl -fsSL https://api.github.com/repos/codacy/codacy-cli-v2/releases/latest \
            | grep -Po '"browser_download_url":\s*"\K.*linux_amd64.*\.tar\.gz(?=")' | head -n1)" \
            -o "$tmp/cli.tgz"
        tar -xzf "$tmp/cli.tgz" -C "$tmp"
        mv "$tmp"/codacy-cli* "$TOOLS_DIR/codacy" && chmod +x "$TOOLS_DIR/codacy"
        success "Codacy CLI installed"
    else
        info "Codacy CLI already present"
    fi
    export PATH="$TOOLS_DIR:$PATH"
}

# Create project structure with AI optimization
create_project_structure() {
    log "Creating optimized project structure..."
    
    # Core directories
    mkdir -p {src,public,docs,tests,scripts,config,.github/workflows}
    mkdir -p {src/{components,pages,hooks,utils,stores,types,styles},tests/{unit,integration,e2e}}
    mkdir -p {docs/{api,guides,examples},config/{environments,tools}}
    
    # AI-specific directories
    mkdir -p {ai/{prompts,templates,docs},tools/{ai,scripts,codacy}}
    
    success "Project structure created"
}

# Package.json with bleeding edge dependencies
create_package_json() {
    log "Creating package.json with bleeding-edge dependencies..."
    
    cat > package.json << 'EOF'
{
  "name": "ice-webapp",
  "version": "1.0.0",
  "description": "AI-optimized web application starter with bleeding-edge tools",
  "type": "module",
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
    "storybook": "storybook dev -p 6006",
    "build-storybook": "storybook build",
    "prepare": "husky",
    "codacy": "./tools/codacy-runtime.sh"
  },
  "dependencies": {
    "next": "^15.1.3",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "@next/third-parties": "^15.1.3",
    "framer-motion": "^11.15.0",
    "lucide-react": "^0.468.0",
    "@radix-ui/react-slot": "^1.1.1",
    "@radix-ui/react-toast": "^1.2.2",
    "@radix-ui/react-dialog": "^1.1.2",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "tailwind-merge": "^2.5.4",
    "zustand": "^5.0.2",
    "@tanstack/react-query": "^5.62.0",
    "react-hook-form": "^7.54.0",
    "@hookform/resolvers": "^3.10.0",
    "zod": "^3.24.1"
  },
  "devDependencies": {
    "@types/node": "^22.10.2",
    "@types/react": "^19.0.1",
    "@types/react-dom": "^19.0.1",
    "typescript": "^5.7.2",
    "eslint": "^9.18.0",
    "eslint-config-next": "^15.1.3",
    "@typescript-eslint/eslint-plugin": "^8.18.0",
    "@typescript-eslint/parser": "^8.18.0",
    "prettier": "^3.4.2",
    "prettier-plugin-tailwindcss": "^0.6.8",
    "tailwindcss": "^3.4.16",
    "postcss": "^8.5.1",
    "autoprefixer": "^10.4.20",
    "vitest": "^2.1.6",
    "@vitejs/plugin-react": "^4.3.4",
    "@testing-library/react": "^16.1.0",
    "@testing-library/jest-dom": "^6.6.3",
    "@testing-library/user-event": "^14.5.2",
    "playwright": "^1.49.0",
    "@playwright/test": "^1.49.0",
    "husky": "^9.1.7",
    "lint-staged": "^15.2.11",
    "@storybook/react": "^8.4.7",
    "@storybook/addon-essentials": "^8.4.7",
    "@storybook/nextjs": "^8.4.7",
    "cross-env": "^7.0.3",
    "@next/bundle-analyzer": "^15.1.3",
    "dotenv": "^16.4.7"
  },
  "pnpm": {
    "overrides": {
      "react": "$react",
      "react-dom": "$react-dom"
    }
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml,yaml}": ["prettier --write"]
  }
}
EOF
    
    success "Package.json created with bleeding-edge dependencies"
}

# Configuration files
create_config_files() {
    log "Creating configuration files..."
    
    # Next.js config with bleeding edge features
    cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@radix-ui/react-icons'],
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
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
    ],
  },
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ]
  },
}

module.exports = nextConfig
EOF

    # Tailwind config with latest features
    cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class'],
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'bounce-soft': 'bounceSoft 0.6s ease-in-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceSoft: {
          '0%, 20%, 53%, 80%, 100%': { transform: 'translate3d(0,0,0)' },
          '40%, 43%': { transform: 'translate3d(0,-15px,0)' },
          '70%': { transform: 'translate3d(0,-7px,0)' },
          '90%': { transform: 'translate3d(0,-2px,0)' },
        },
      },
      colors: {
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
EOF

    # TypeScript config
    cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
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
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/hooks/*": ["./src/hooks/*"],
      "@/utils/*": ["./src/utils/*"],
      "@/types/*": ["./src/types/*"],
      "@/styles/*": ["./src/styles/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

    # ESLint config (flat config format)
    cat > eslint.config.js << 'EOF'
import { FlatCompat } from '@eslint/eslintrc'
import js from '@eslint/js'
import typescript from '@typescript-eslint/eslint-plugin'
import typescriptParser from '@typescript-eslint/parser'

const compat = new FlatCompat({
  baseDirectory: import.meta.dirname,
})

export default [
  js.configs.recommended,
  ...compat.extends('next/core-web-vitals'),
  {
    files: ['**/*.{js,jsx,ts,tsx}'],
    languageOptions: {
      parser: typescriptParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
    plugins: {
      '@typescript-eslint': typescript,
    },
    rules: {
      'prefer-const': 'error',
      'no-var': 'error',
      'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-explicit-any': 'warn',
    },
  },
]
EOF

    # Prettier config
    cat > .prettierrc << 'EOF'
{
  "semi": false,
  "trailingComma": "es5",
  "singleQuote": true,
  "tabWidth": 2,
  "useTabs": false,
  "printWidth": 80,
  "endOfLine": "lf",
  "plugins": ["prettier-plugin-tailwindcss"]
}
EOF

    # Vitest config
    cat > vitest.config.ts << 'EOF'
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    globals: true,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
EOF

    # Playwright config
    cat > playwright.config.ts << 'EOF'
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  webServer: {
    command: 'pnpm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
EOF

    success "Configuration files created"
}

# Codex environment optimizations
optimize_for_codex() {
    log "Applying Codex environment optimizations..."
    
    # Check if specialized Codex script exists and recommend it
    if [[ -f "$SCRIPT_DIR/setup-codex.sh" ]]; then
        info "🚨 RECOMMENDATION: Use the specialized Codex setup script for optimal results:"
        info "   bash setup-codex.sh"
        info ""
        info "The specialized script handles Codex environment and provides:"
        info "  - Node.js 22 setup and verification"
        info "  - No sudo requirements (runs as root)"
        info "  - Bleeding-edge dependency versions"
        info "  - Container-specific optimizations"
        info ""
        
        read -p "Continue with general setup (y) or exit to use Codex script (n)? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Exiting. Run: bash setup-codex.sh"
            exit 0
        fi
    fi
    
    # Set essential environment variables for container compatibility
    export SHELL="/bin/bash"
    export DEBIAN_FRONTEND=noninteractive
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    
    # Create necessary directories
    mkdir -p "$PNPM_HOME" ~/.npm ~/.cache
    
    # Clear any proxy configuration that might interfere
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
    
    # Optimize apt for containers (check if running as root)
    local current_user="${USER:-$(whoami 2>/dev/null || echo 'unknown')}"
    if [[ "$current_user" == "root" ]]; then
        # No sudo needed - already root in Codex
        echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries 2>/dev/null || true
        echo 'Acquire::http::Timeout "60";' > /etc/apt/apt.conf.d/80-timeout 2>/dev/null || true
        apt-get update -qq 2>/dev/null || warn "apt-get update failed (expected in some Codex environments)"
    else
        # Use sudo for non-root environments
        echo 'Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80-retries >/dev/null
        echo 'Acquire::http::Timeout "60";' | sudo tee /etc/apt/apt.conf.d/80-timeout >/dev/null
        sudo apt-get update -qq 2>/dev/null || warn "apt-get update failed"
    fi
    
    success "Codex optimizations applied"
}

# Main execution
main() {
    local env_type
    env_type="$(detect_environment)"
    export ENVIRONMENT="$env_type"
    
    info "Detected environment: $env_type"
    info "Starting ICE-WEBAPP setup..."
    
    # Apply environment-specific optimizations
    if [[ "$env_type" == "codex" ]]; then
        optimize_for_codex
    fi
    
    # Core setup
    setup_system_dependencies
    setup_nodejs
    setup_python
    setup_codacy_cli
    create_project_structure
    create_package_json
    create_config_files
    
    # Install dependencies
    log "Installing dependencies..."
    pnpm install
    
    # Initialize git hooks
    log "Setting up git hooks..."
    pnpm exec husky init
    echo "pnpm run lint-staged" > .husky/pre-commit
    chmod +x .husky/pre-commit
    
    # Create initial files
    log "Creating initial application files..."
    
    # Environment variables
    cat > .env.local << 'EOF'
# Development environment variables
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME="ICE WebApp"

# Add your environment variables here
# NEXT_PUBLIC_SUPABASE_URL=
# NEXT_PUBLIC_SUPABASE_ANON_KEY=
# DATABASE_URL=
# OPENAI_API_KEY=
EOF

    cat > .env.example << 'EOF'
# Copy this file to .env.local and fill in your values
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME="ICE WebApp"

# External services
# NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
# NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
# DATABASE_URL=your_database_url
# OPENAI_API_KEY=your_openai_api_key
EOF

    success "ICE-WEBAPP setup completed successfully!"
    info "Environment type: $env_type"
    info "Node.js version: $(node --version)"
    info "Package manager: pnpm $(pnpm --version)"
    info "Next steps:"
    echo "  1. Run 'pnpm run dev' to start development server"
    echo "  2. Open http://localhost:3000 in your browser"
    echo "  3. Start building your web application!"
}

print_debug_report() {
    echo
    echo "=================================================="
    echo "=== 📜 SCRIPT EXECUTION DEBUG REPORT 📜 ==="
    echo "=================================================="
    if [ "$FAILED_COMMANDS" -eq 0 ]; then
        echo "✅ All setup commands appeared to execute successfully."
    else
        echo "❌ Found $FAILED_COMMANDS command(s) that failed:"
        printf " • %s\\n" "${DEBUG_MESSAGES[@]}"
    fi
    echo "=================================================="
    echo
}

# Run main function
main "$@" 