# 🚨 Codex Environment Troubleshooting Guide

Quick solutions for common ChatGPT Codex container environment issues.

## 🔧 Quick Fix for Codex Setup Errors

If you encounter the following errors in Codex:

```bash
ERR_PNPM_UNKNOWN_SHELL  Could not infer shell type.
npm warn Unknown env config "http-proxy"
Node.js version mismatch (v20.x instead of v22.x)
```

**Best Solution**: Use the Codex-optimized setup script with unified Node.js 22 dependencies:

```bash
# Recommended: Use specialized Codex script (Node.js 22, no sudo, bleeding-edge deps)
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/setup-codex.sh | bash
```

**Alternative Solution**: Fix environment issues then run main setup:

```bash
# Fix Codex environment issues first
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/tools/codex-setup.sh | bash

# Then run main setup
bash setup.sh
```

## 📋 Common Codex Issues & Solutions

### 1. **Shell Detection Error**
```
ERR_PNPM_UNKNOWN_SHELL Could not infer shell type
```

**Cause**: Codex containers don't set SHELL environment variable properly.

**Fix**:
```bash
export SHELL="/bin/bash"
curl -fsSL https://get.pnpm.io/install.sh | SHELL=/bin/bash sh -
```

### 2. **npm Proxy Warnings**
```
npm warn Unknown env config "http-proxy"
```

**Cause**: Container environments inherit proxy settings.

**Fix**:
```bash
unset HTTP_PROXY http_proxy HTTPS_PROXY https_proxy
npm config delete proxy --global 2>/dev/null || true
npm config delete https-proxy --global 2>/dev/null || true
```

### 3. **Node.js Version Configuration**
```
Need to set Node.js to v22.x in Codex
```

**Cause**: Node.js version needs to be configured in Codex environment.

**Fix**: Update Node.js version in your Codex environment settings to 22.x
- The setup script will verify and guide you if version needs updating
- Both Codex and standard environments now use the same Node.js 22.x

### 4. **pnpm Installation Fails**
```
Installation hangs or fails silently
```

**Fix**: Use manual installation:
```bash
mkdir -p ~/.local/share/pnpm
curl -fsSL https://github.com/pnpm/pnpm/releases/download/v9.15.0/pnpm-linux-x64 -o ~/.local/share/pnpm/pnpm
chmod +x ~/.local/share/pnpm/pnpm
export PATH="~/.local/share/pnpm:$PATH"
```

### 5. **Unbound Variable Error**
```
/setup_script.sh: line 76: USER: unbound variable
```

**Cause**: Environment variables like `USER` are not set in some Codex containers.

**Fix**: The updated script now handles unbound variables using parameter expansion:
- Uses `${USER:-$(whoami)}` to provide fallback values
- Safe environment variable checking throughout the script

### 6. **Dependency Installation Failures**
```
ERR_PNPM_NO_MATCHING_VERSION  No matching version found for @next/font@^15.1.3
npm error `network-timeout` is not a valid npm option
```

**Cause**: 
- `@next/font` was removed in Next.js 13.2+ (replaced with `next/font`)
- Invalid npm configuration options

**Fix**:
```bash
# Remove outdated dependencies from package.json
# Use next/font instead: import { Inter } from 'next/font/google'

# Use correct npm timeout setting
npm config set timeout 300000 --global  # NOT network-timeout

# Clear any lingering proxy configs
npm config delete http-proxy --global
unset npm_config_proxy npm_config_https_proxy
```

### 7. **File Creation vs Directory Error**
```
src/app/layout.tsx: Is a directory
```

**Cause**: Using `mkdir -p src/app/{file1,file2}` creates directories instead of files

**Fix**: Create directories and files separately:
```bash
mkdir -p src/app
cat > src/app/layout.tsx << 'EOF'
// file content
EOF
```

## 🚀 Codex-Optimized Workflow

### Recommended Codex Setup Process:

1. **Pre-Setup (Codex Fix)**:
```bash
bash tools/codex-setup.sh --quick
```

2. **Main Setup**:
```bash
bash setup.sh
```

3. **Verification**:
```bash
node --version  # Should show v22.x
pnpm --version  # Should work without errors
pnpm run type-check  # Verify TypeScript
```

### Alternative: One-Line Codex Setup
```bash
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/tools/codex-setup.sh | bash && bash setup.sh
```

## 🔍 Environment Detection

The setup automatically detects Codex environments by checking:
- `CODEX_ENVIRONMENT` variable
- `GITHUB_CODESPACE_NAME` variable 
- `OPENAI_CODEX` variable
- Docker environment (`/.dockerenv`)
- Root user without sudo context
- `CONTAINER` environment variable

## 🛠️ Manual Codex Environment Setup

If automatic detection fails:

```bash
export CODEX_ENVIRONMENT=true
export SHELL="/bin/bash"
export DEBIAN_FRONTEND=noninteractive
bash setup.sh
```

## ⚡ Quick Development Start

After successful setup in Codex:

```bash
# Install dependencies
pnpm install

# Start development
pnpm run dev

# Run in background (for Codex)
pnpm run dev &

# Quality checks
pnpm run lint && pnpm run type-check
```

## 🔧 Container-Specific Configurations

### APT Optimizations
```bash
echo 'Acquire::Retries "3";' | sudo tee /etc/apt/apt.conf.d/80-retries
echo 'Acquire::http::Timeout "60";' | sudo tee /etc/apt/apt.conf.d/80-timeout
```

### pnpm Configuration for Containers
```bash
pnpm config set network-timeout 300000
pnpm config set fetch-retries 5
pnpm config set fetch-retry-factor 2
pnpm config set fetch-retry-mintimeout 10000
```

## 📞 Support

If issues persist:

1. **Check logs**: All setup scripts provide detailed logging
2. **Verify environment**: Run `bash tools/codex-setup.sh --help`
3. **Manual verification**:
   ```bash
   echo "Node.js: $(node --version)"
   echo "npm: $(npm --version)" 
   echo "pnpm: $(pnpm --version)"
   echo "Shell: $SHELL"
   echo "Environment: $CODEX_ENVIRONMENT"
   ```

## 🎯 Success Indicators

Setup is successful when:
- ✅ Node.js version shows `v22.x`
- ✅ pnpm installs without shell errors
- ✅ No npm proxy warnings
- ✅ `pnpm install` completes successfully
- ✅ `pnpm run dev` starts development server

---

**This troubleshooting guide specifically addresses ChatGPT Codex container environment constraints and provides bleeding-edge solutions for optimal development velocity.** 