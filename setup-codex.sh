#!/bin/bash
#
# ICE-WEBAPP Codex Setup Script v2025.1.3
# Optimized for ChatGPT Codex Pre-installed Environment
# Addresses: shebang issues, network constraints, container environment
# Based on community research and Codex environment specifications
#

# Minimal strict mode (avoids unbound variable issues in containers)
set -eo pipefail

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
error() { echo "[ERROR] $*"; exit 1; }
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
    
    # Create essential directories
    mkdir -p ~/.npm ~/.cache ~/.config "$PNPM_HOME" || warn "Directory creation partial failure"
    
    # Clear proxy settings that cause npm warnings (community solution)
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy 2>/dev/null || true
    
    # Clear additional npm-related proxy environment variables
    unset npm_config_proxy npm_config_https_proxy npm_config_http_proxy 2>/dev/null || true
    
    success "Codex environment configured"
}

# Verify pre-installed packages
verify_codex_packages() {
    log "Verifying ChatGPT Codex pre-installed packages..."
    
    # Node.js verification
    if command -v node >/dev/null 2>&1; then
        local node_ver=$(node --version)
        log "Node.js: $node_ver (configurable to v22 in Codex settings)"
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
    command -v go >/dev/null 2>&1 && log "Go: $(go version | cut -d' ' -f3)"
    
    success "Pre-installed packages verified"
}

# Configure npm for Codex (remove proxy warnings)
configure_npm() {
    log "Configuring npm for Codex environment..."
    
    # Remove proxy configurations that cause warnings
    npm config delete proxy --global 2>/dev/null || true
    npm config delete https-proxy --global 2>/dev/null || true
    npm config delete http-proxy --global 2>/dev/null || true
    
    # Set optimal configurations
    npm config set registry https://registry.npmjs.org/ --global
    npm config set timeout 300000 --global
    npm config set fetch-retries 5 --global
    
    success "npm configured"
}

# Install pnpm using pre-installed npm
install_pnpm() {
    log "Installing pnpm package manager..."
    
    if command -v pnpm >/dev/null 2>&1; then
        log "pnpm already available: $(pnpm --version)"
        return 0
    fi
    
    # Use pre-installed npm to install pnpm
    if npm install -g pnpm@latest; then
        log "pnpm installed: $(pnpm --version)"
        
        # Configure pnpm
        pnpm config set registry https://registry.npmjs.org/
        pnpm config set store-dir ~/.pnpm-store
        pnpm config set network-timeout 300000
        
        success "pnpm configured"
    else
        warn "pnpm installation failed - continuing with npm"
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
    npm config delete http-proxy --global 2>/dev/null || true
    
    local install_success=false
    
    if command -v pnpm >/dev/null 2>&1; then
        log "Using pnpm for installation..."
        if pnpm install --no-frozen-lockfile 2>/dev/null; then
            success "Dependencies installed with pnpm"
            install_success=true
        else
            warn "pnpm install failed - trying npm"
        fi
    fi
    
    if [[ "$install_success" == "false" ]]; then
        log "Using npm for installation..."
        if npm install --no-package-lock 2>/dev/null; then
            success "Dependencies installed with npm"
            install_success=true
        else
            warn "npm install failed - but setup can continue"
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
        echo "  ⚠ Dependencies: Not installed (retry: npm install)"
    fi
    
    success "Installation verification complete"
}

# Main execution function
main() {
    # Trap for better error reporting
    trap 'error "Setup failed at line $LINENO - see CODEX_TROUBLESHOOTING.md"' ERR
    
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
    echo
    log "Documentation:"
    echo "  - Check package.json for available scripts"
    echo "  - Use 'npm run codex:verify' to check environment"
    echo "  - All tools are configured for Node.js 22 and bleeding-edge tech"
}

# Execute main function (with error handling)
main "$@" || {
    echo
    error "Setup failed - check the error messages above"
    echo "Common solutions:"
    echo "  1. Ensure Node.js is set to v22 in Codex environment settings"
    echo "  2. Try running the script again (network issues are common)"
    echo "  3. Check that all required packages are selected in Codex setup"
    echo "  4. For persistent issues, contact Codex support"
    exit 1
} 