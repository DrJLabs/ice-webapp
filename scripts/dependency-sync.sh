#!/usr/bin/env bash
#
# Dependency Synchronization Script
# Maintains dependency management cohesion between:
# - Cursor (local machine)
# - Setup script (Codex compatibility)  
# - CI runner environment
#

set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Color codes
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

log() {
    echo -e "${GREEN}[SYNC] $*${NC}" >&2
}

warn() {
    echo -e "${YELLOW}[WARN] $*${NC}" >&2
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
    exit 1
}

# Generate pnpm-lock.yaml hash for consistency
generate_lockfile_hash() {
    if [[ -f "$ROOT_DIR/pnpm-lock.yaml" ]]; then
        sha256sum "$ROOT_DIR/pnpm-lock.yaml" | cut -d' ' -f1
    else
        echo "no-lockfile"
    fi
}

# Update .nvmrc for Node.js version consistency
update_nvmrc() {
    local node_version
    node_version=$(grep '"node"' "$ROOT_DIR/package.json" | grep -o '[0-9.]*' | head -1)
    
    if [[ -n "$node_version" ]]; then
        echo "$node_version" > "$ROOT_DIR/.nvmrc"
        log "Updated .nvmrc with Node.js version: $node_version"
    fi
}

# Update Docker configuration
update_docker_config() {
    local node_version
    node_version=$(grep '"node"' "$ROOT_DIR/package.json" | grep -o '[0-9.]*' | head -1)
    
    cat > "$ROOT_DIR/Dockerfile" << EOF
# Multi-stage build for production optimization
FROM node:${node_version}-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Enable pnpm
RUN corepack enable

# Install dependencies based on the preferred package manager
COPY package.json pnpm-lock.yaml* ./
RUN pnpm i --frozen-lockfile

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Enable pnpm
RUN corepack enable

# Disable telemetry during build
ENV NEXT_TELEMETRY_DISABLED 1

RUN pnpm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
EOF
    
    log "Updated Dockerfile with Node.js version: $node_version"
}

# Update VS Code settings for consistency
update_vscode_settings() {
    mkdir -p "$ROOT_DIR/.vscode"
    
    cat > "$ROOT_DIR/.vscode/settings.json" << 'EOF'
{
  "typescript.preferences.includePackageJsonAutoImports": "auto",
  "typescript.suggest.autoImports": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "files.exclude": {
    "**/.git": true,
    "**/.svn": true,
    "**/.hg": true,
    "**/CVS": true,
    "**/.DS_Store": true,
    "**/Thumbs.db": true,
    "**/node_modules": true,
    "**/.next": true,
    "**/dist": true,
    "**/build": true
  },
  "search.exclude": {
    "**/node_modules": true,
    "**/bower_components": true,
    "**/*.code-search": true,
    "**/coverage": true,
    "**/.next": true
  },
  "emmet.includeLanguages": {
    "javascript": "javascriptreact",
    "typescript": "typescriptreact"
  },
  "tailwindCSS.includeLanguages": {
    "typescript": "javascript",
    "typescriptreact": "javascript"
  },
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ]
}
EOF

    cat > "$ROOT_DIR/.vscode/extensions.json" << 'EOF'
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "ms-playwright.playwright",
    "vitest.explorer",
    "steoates.autoimport-es6-ts"
  ]
}
EOF

    log "Updated VS Code settings for optimal development experience"
}

# Generate dependency manifest for all environments
generate_dependency_manifest() {
    local lockfile_hash
    lockfile_hash=$(generate_lockfile_hash)
    
    cat > "$ROOT_DIR/dependency-manifest.json" << EOF
{
  "generated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "lockfile_hash": "$lockfile_hash",
  "environments": {
    "local": {
      "node_version": "$(node --version 2>/dev/null || echo 'not-installed')",
      "pnpm_version": "$(pnpm --version 2>/dev/null || echo 'not-installed')",
      "os": "$(uname -s)"
    },
    "codex": {
      "supported": true,
      "requirements": {
        "node": ">=22.12.0",
        "pnpm": ">=9.0.0"
      }
    },
    "ci": {
      "platform": "ubuntu-latest",
      "node_version": "22.12.0",
      "pnpm_version": "9"
    }
  },
  "critical_dependencies": {
    "runtime": [
      "next",
      "react",
      "react-dom"
    ],
    "build": [
      "typescript",
      "eslint",
      "prettier",
      "tailwindcss"
    ],
    "testing": [
      "vitest",
      "@testing-library/react",
      "playwright"
    ]
  }
}
EOF
    
    log "Generated dependency manifest with hash: ${lockfile_hash:0:8}"
}

# Validate environment consistency
validate_environment() {
    local issues=0
    
    # Check Node.js version
    if ! command -v node >/dev/null 2>&1; then
        warn "Node.js not installed"
        ((issues++))
    else
        local node_version
        node_version=$(node --version | sed 's/v//')
        local required_version="22.12.0"
        
        if ! printf '%s\n%s\n' "$required_version" "$node_version" | sort -V -C; then
            warn "Node.js version $node_version is older than required $required_version"
            ((issues++))
        fi
    fi
    
    # Check pnpm
    if ! command -v pnpm >/dev/null 2>&1; then
        warn "pnpm not installed, falling back to npm"
        ((issues++))
    fi
    
    # Check lockfile consistency
    if [[ -f "$ROOT_DIR/pnpm-lock.yaml" ]]; then
        if ! pnpm install --frozen-lockfile --ignore-scripts >/dev/null 2>&1; then
            warn "pnpm-lock.yaml is out of sync with package.json"
            ((issues++))
        fi
    fi
    
    if [[ $issues -eq 0 ]]; then
        log "Environment validation passed ✓"
    else
        warn "Environment validation found $issues issues"
    fi
    
    return $issues
}

# Main sync function
main() {
    log "Starting dependency synchronization..."
    
    cd "$ROOT_DIR"
    
    # Update configuration files
    update_nvmrc
    update_docker_config
    update_vscode_settings
    
    # Generate manifest
    generate_dependency_manifest
    
    # Validate environment
    validate_environment
    
    log "Dependency synchronization completed"
    log "All environments should now have consistent dependency configuration"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 