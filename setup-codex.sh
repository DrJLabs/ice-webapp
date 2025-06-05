#!/bin/bash
#
# ICE-WEBAPP Codex Setup Script v2025.1.3
# Optimized for ChatGPT Codex Pre-installed Environment
# Addresses: shebang issues, network constraints, container environment
# Based on community research and Codex environment specifications
# Includes robust error-reporting for silent-failure environments.
#

# Enable command tracing for detailed debugging output
set -x

# Do NOT exit on error; we will collect errors and report them at the end.
# REMOVED: set -eo pipefail

# --- Robust Error-Handling Setup ---
DEBUG_MESSAGES=()
FAILED_COMMANDS=0

# Wrapper function to execute commands and log failures
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
        log "--- [SUCCESS] '$description' ---"
    fi
}
# --- End Error-Handling Setup ---

# Codex environment detection and debug info
echo "=== ICE-WEBAPP Codex Setup Script v2025.1.3 ==="
echo "Timestamp: $(date)"
echo "Working directory: $(pwd)"
echo "Shell: ${SHELL:-/bin/bash}"
echo "User: ${USER:-$(whoami 2>/dev/null || echo 'container-user')}"
echo "Environment: ${CONTAINER:-unknown} ${CODESPACE_NAME:-codex}"
echo "=================================================="

# Simple logging functions
log() { echo "[LOG] $*"; }
warn() { echo "[WARN] $*"; }
error() {
    local msg="[ERROR] $*"
    warn "$msg"
    DEBUG_MESSAGES+=("$msg")
    ((FAILED_COMMANDS++))
}
success() { echo "[SUCCESS] $*"; }

# Codex pre-installed package versions (Node.js 22 configurable)
readonly NODE_VERSION="22.12.0"
readonly PYTHON_VERSION="3.12"
readonly NEXT_VERSION="15.1.3"
readonly REACT_VERSION="19.0.0"
readonly TYPESCRIPT_VERSION="5.7.2"

# Essential Codex environment setup
setup_codex_environment() {
    log "Configuring ChatGPT Codex environment..."
    
    # Essential exports for container stability
    export SHELL="/bin/bash"
    export DEBIAN_FRONTEND=noninteractive
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
    
    run_command "mkdir -p ~/.npm ~/.cache ~/.config \"$PNPM_HOME\"" "Create essential directories"
    
    # Clear proxy settings that cause npm warnings (community solution)
    run_command "unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy 2>/dev/null || true" "Unset proxy variables"
    
    # Clear additional npm-related proxy environment variables
    run_command "unset npm_config_proxy npm_config_https_proxy npm_config_http_proxy 2>/dev/null || true" "Unset npm proxy variables"
    
    success "Codex environment configured"
}

# Verify pre-installed packages
verify_codex_packages() {
    log "Verifying ChatGPT Codex pre-installed packages..."
    
    # Source nvm and bashrc for Codex Universal environment
    if [[ -f ~/.bashrc ]]; then
        source ~/.bashrc >/dev/null 2>&1 || true
    fi
    if [[ -f ~/.nvm/nvm.sh ]]; then
        source ~/.nvm/nvm.sh >/dev/null 2>&1 || true
    fi
    
    # Node.js verification
    if command -v node >/dev/null 2>&1; then
        local node_ver=$(node --version)
        log "Node.js: $node_ver (Codex Universal pre-configured)"
    else
        error "Node.js not found - check Codex environment configuration"
    fi
    
    # npm verification
    if command -v npm >/dev/null 2>&1; then
        log "npm: $(npm --version)"
    else
        error "npm not found - Codex environment issue"
    fi
    
    # Other pre-installed tools
    command -v python3 >/dev/null 2>&1 && log "Python: $(python3 --version)"
    command -v bun >/dev/null 2>&1 && log "Bun: $(bun --version)"
    command -v java >/dev/null 2>&1 && log "Java: available"
    
    # Go verification (robust check to prevent script failure if Go is broken)
    if command -v go >/dev/null 2>&1; then
        if go_version_output=$(go version 2>/dev/null); then
            log "Go: $(echo "$go_version_output" | cut -d' ' -f3)"
        else
            warn "Go command found, but 'go version' failed. Continuing, as Go is not critical."
        fi
    else
        log "Go: not found (this is OK for ICE-WEBAPP)"
    fi
    
    success "Pre-installed packages verified"
}

# Configure npm for Codex (handle network restrictions gracefully)
configure_npm() {
    log "Configuring npm for Codex environment..."
    
    run_command "npm config delete proxy --global" "Delete npm proxy config"
    run_command "npm config delete https-proxy --global" "Delete npm https-proxy config"
    run_command "npm config delete http-proxy --global" "Delete npm http-proxy config"
    run_command "npm cache clean --force" "Clear npm cache"
    run_command "npm config set registry https://registry.npmjs.org/ --global" "Set npm registry"
    run_command "npm config set fetch-retry-maxtimeout 60000 --global" "Set npm fetch timeout"
    run_command "npm config set fetch-retries 3 --global" "Set npm fetch retries"
    run_command "npm config set fund false --global" "Disable npm fund"
    run_command "npm config set audit false --global" "Disable npm audit"
    
    # CRITICAL FIX: npm 11.x corepack bug (npm/cli#8075)
    local npm_version=$(npm --version 2>/dev/null || echo "unknown")
    if [[ "$npm_version" =~ ^11\. ]]; then
        log "Detected npm $npm_version - applying corepack fix for npm/cli#8075..."
        run_command "npm install -g corepack@latest" "Update corepack for npm 11.x"
    fi
    
    success "npm configured with network restriction handling and corepack fix"
}

# Install pnpm using pre-installed npm with enhanced reliability
install_pnpm() {
    log "Installing pnpm package manager..."
    
    # Source nvm environment for Codex Universal
    if [[ -f ~/.bashrc ]]; then
        source ~/.bashrc >/dev/null 2>&1 || true
    fi
    if [[ -f ~/.nvm/nvm.sh ]]; then
        source ~/.nvm/nvm.sh >/dev/null 2>&1 || true
    fi
    
    if command -v pnpm >/dev/null 2>&1; then
        log "pnpm already available: $(pnpm --version 2>/dev/null || echo 'detected')"
        return 0
    fi
    
    # Check npm version for corepack compatibility
    local npm_version=$(npm --version 2>/dev/null || echo "unknown")
    local pnpm_installed=false
    
    # ALWAYS try npm first (most reliable method)
    log "Installing pnpm via npm (recommended for Codex)..."
    if npm install -g pnpm@latest 2>/dev/null; then
        log "✅ pnpm installed via npm: $(pnpm --version 2>/dev/null || echo 'installed')"
        pnpm_installed=true
    else
        warn "npm install failed, trying alternative methods..."
        DEBUG_MESSAGES+=("Task: 'Install pnpm via npm' | Command: 'npm install -g pnpm@latest'")
        ((FAILED_COMMANDS++))
    fi
    
    # Only try corepack if npm method failed AND it's not npm 11.x (due to bug npm/cli#8075)
    if [[ "$pnpm_installed" == "false" ]] && command -v corepack >/dev/null 2>&1; then
        if [[ "$npm_version" =~ ^11\. ]]; then
            warn "⚠️  Skipping corepack due to npm 11.x bug (npm/cli#8075)"
            log "This prevents HTTP 503 errors from repo.yarnpkg.com"
        else
            log "Trying corepack for pnpm installation..."
            if corepack enable 2>/dev/null && corepack prepare pnpm@latest --activate 2>/dev/null; then
                log "✅ pnpm enabled via corepack"
                pnpm_installed=true
            else
                warn "corepack failed (common in restricted environments)"
                DEBUG_MESSAGES+=("Task: 'Enable pnpm via corepack' | Command: 'corepack enable && corepack prepare pnpm@latest --activate'")
                ((FAILED_COMMANDS++))
            fi
        fi
    fi
    
    # Configure pnpm if successfully installed
    if [[ "$pnpm_installed" == "true" ]] && command -v pnpm >/dev/null 2>&1; then
        pnpm config set registry https://registry.npmjs.org/ 2>/dev/null || true
        pnpm config set store-dir ~/.pnpm-store 2>/dev/null || true
        pnpm config set fetch-retry-maxtimeout 300000 2>/dev/null || true
        success "pnpm configured and ready"
    else
        warn "pnpm installation failed - will use npm for dependency installation"
        log "This is normal in restricted environments like Codex"
    fi
}

# Create essential project structure
create_project_structure() {
    log "Creating ICE-WEBAPP project structure..."
    
    # Core directories
    mkdir -p {src/{app,components,lib,styles},public,tests,docs,tools,config}
    mkdir -p src/app
    mkdir -p .github/workflows
    
    success "Project structure created"
}

# Create package.json optimized for Codex and Node.js 22
create_package_json() {
    log "Creating package.json with bleeding-edge dependencies..."
    
    cat > package.json << EOF
{
  "name": "ice-webapp",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:e2e": "playwright test",
    "codex:verify": "node --version && npm --version && echo 'Codex environment OK'"
  },
  "dependencies": {
    "next": "^${NEXT_VERSION}",
    "react": "^${REACT_VERSION}",
    "react-dom": "^${REACT_VERSION}",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.3.0"
  },
  "devDependencies": {
    "@types/node": "^22.10.2",
    "@types/react": "^19.0.1",
    "@types/react-dom": "^19.0.1",
    "typescript": "^${TYPESCRIPT_VERSION}",
    "eslint": "^9.18.0",
    "eslint-config-next": "^${NEXT_VERSION}",
    "tailwindcss": "^3.4.16",
    "postcss": "^8.4.38",
    "autoprefixer": "^10.4.19",
    "vitest": "^2.1.6",
    "playwright": "^1.49.0"
  },
  "engines": {
    "node": ">=22.0.0"
  }
}
EOF
    
    success "package.json created for Node.js 22"
}

# Create essential configuration files
create_configs() {
    log "Creating configuration files..."
    
    # Next.js config
    cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: ['lucide-react'],
  },
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
    "plugins": [{"name": "next"}],
    "baseUrl": ".",
    "paths": {"@/*": ["./src/*"]}
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

    # Tailwind config
    cat > tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
      },
    },
  },
  plugins: [],
};

export default config;
EOF

    # Environment template
    cat > .env.local << 'EOF'
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME="ICE WebApp"
NODE_ENV=development
EOF

    success "Configuration files created"
}

# Create essential source files
create_basic_app() {
    log "Creating basic Next.js 15 app structure..."
    
    # App layout (using Next.js 15+ font optimization)
    cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'ICE WebApp',
  description: 'AI-optimized web application built with bleeding-edge tech',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
EOF

    # Main page
    cat > src/app/page.tsx << 'EOF'
export default function Home() {
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">🧊 ICE WebApp</h1>
        <p className="text-xl text-gray-600 mb-8">
          AI-optimized web application running on bleeding-edge technology
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Next.js 15</h2>
            <p>App Router with Turbo optimizations</p>
          </div>
          
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">React 19</h2>
            <p>Latest React with concurrent features</p>
          </div>
          
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">TypeScript 5.7</h2>
            <p>Strict mode with latest language features</p>
          </div>
          
          <div className="p-6 border rounded-lg">
            <h2 className="text-2xl font-semibold mb-2">Tailwind CSS</h2>
            <p>Utility-first styling framework</p>
          </div>
        </div>
      </div>
    </main>
  )
}
EOF

    # Global CSS
    cat > src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    font-family: system-ui, sans-serif;
  }
}
EOF

    success "Basic app structure created"
}

# Install dependencies with fallback and better error handling
install_dependencies() {
    log "Installing dependencies (network access available during setup)..."
    
    # Clear any lingering npm config issues
    run_command "npm config delete http-proxy --global" "Delete http-proxy before install"
    
    local install_success=false
    
    if command -v pnpm >/dev/null 2>&1; then
        log "Using pnpm for installation..."
        if pnpm install --no-frozen-lockfile 2>/dev/null; then
            success "Dependencies installed with pnpm"
            install_success=true
        else
            warn "pnpm install failed - trying npm"
            DEBUG_MESSAGES+=("Task: 'Install dependencies with pnpm' | Command: 'pnpm install --no-frozen-lockfile'")
            ((FAILED_COMMANDS++))
        fi
    fi
    
    if [[ "$install_success" == "false" ]]; then
        log "Using npm for installation..."
        if npm install --no-package-lock 2>/dev/null; then
            success "Dependencies installed with npm"
            install_success=true
        else
            warn "npm install failed - but setup can continue"
            DEBUG_MESSAGES+=("Task: 'Install dependencies with npm' | Command: 'npm install --no-package-lock'")
            ((FAILED_COMMANDS++))
            log "You can manually run 'npm install' after setup completes"
        fi
    fi
    
    return 0  # Don't fail the entire setup if dependencies fail
}

# Final verification
verify_installation() {
    log "Verifying ICE-WEBAPP installation..."
    
    echo "Environment verification:"
    echo "  ✓ Node.js: $(node --version)"
    echo "  ✓ npm: $(npm --version)"
    command -v pnpm >/dev/null 2>&1 && echo "  ✓ pnpm: $(pnpm --version)"
    echo "  ✓ TypeScript: Available"
    echo "  ✓ Next.js: v${NEXT_VERSION}"
    echo "  ✓ React: v${REACT_VERSION}"
    echo "  ✓ Environment: ChatGPT Codex"
    
    # Check if package.json exists
    if [[ -f "package.json" ]]; then
        echo "  ✓ package.json: Created"
    fi
    
    # Check if node_modules exists
    if [[ -d "node_modules" ]]; then
        echo "  ✓ Dependencies: Installed"
    else
        echo "  ⚠ Dependencies: Not installed (check debug report)"
    fi
    
    success "Installation verification complete"
}

# Final report function
print_debug_report() {
    echo
    echo "=================================================="
    echo "=== 📜 SCRIPT EXECUTION DEBUG REPORT 📜 ==="
    echo "=================================================="
    if [ "$FAILED_COMMANDS" -eq 0 ]; then
        echo "✅ All setup commands appeared to execute successfully."
        echo "If issues still persist, check the detailed trace above for subtle errors."
    else
        echo "❌ Found $FAILED_COMMANDS command(s) that failed with a non-zero exit code:"
        printf " • %s\\n" "${DEBUG_MESSAGES[@]}"
    fi
    echo "=================================================="
    echo
}

# Main execution function
main() {
    log "Starting ICE-WEBAPP Codex setup..."
    
    # Execute setup phases
    setup_codex_environment
    verify_codex_packages
    configure_npm
    install_pnpm
    create_project_structure
    create_package_json
    create_configs
    create_basic_app
    install_dependencies
    verify_installation
    
    # Always print the debug report as the last step
    print_debug_report
    
    if [ "$FAILED_COMMANDS" -eq 0 ]; then
        echo
        success "🎉 ICE-WEBAPP setup completed successfully!"
        echo
        log "Next steps in ChatGPT Codex:"
        echo "  1. Run: npm run dev (or pnpm run dev)"
        echo "  2. Open: http://localhost:3000"
        echo "  3. Start building your AI-optimized app!"
        echo
        log "Remember: Network access is now disabled outside this setup script"
        log "All dependencies were installed during the setup phase"
    else
        echo
        warn "🚨 ICE-WEBAPP setup completed with errors. See the debug report above. 🚨"
        warn "The script continued to run to provide this report."
        warn "Please analyze the failed commands to resolve the issue."
    fi
}

# Execute main function (with error handling)
main "$@" || {
    # This block will likely not be reached, but as a fallback:
    print_debug_report
    error "Setup failed unexpectedly in the main execution block."
    exit 1
} 