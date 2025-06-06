#!/usr/bin/env bash
# setup-codex.sh - ICE-WEBAPP environment setup for ChatGPT Codex
# Ensures Node.js, Python, pnpm, and Codacy CLI are properly installed and configured.

set -Eeuo pipefail   # Exit on error, unset var usage, or pipeline failure
trap 'echo "[setup-codex] ❌ Error on line $LINENO"; exit 1' ERR

# Determine if we need sudo (Codex runs as root, but script should handle both cases)
if [[ "$(id -u)" -ne 0 ]]; then
    SUDO="sudo"
else
    SUDO=""
fi

# 1. Update system and install base dependencies (non-interactive)
export DEBIAN_FRONTEND=noninteractive
echo "[setup-codex] Updating package list and installing base tools..."
$SUDO apt-get update -qq
$SUDO apt-get install -y curl wget git build-essential ca-certificates gnupg lsb-release > /dev/null

# 2. Ensure Node.js 22.x is installed
echo "[setup-codex] Checking Node.js installation..."
CURRENT_NODE_VERSION="none"
if command -v node >/dev/null 2>&1; then
    CURRENT_NODE_VERSION="$(node --version || echo none)"
fi
echo "[setup-codex] Current Node.js version: $CURRENT_NODE_VERSION"
if [[ ! "$CURRENT_NODE_VERSION" =~ ^v22\. ]]; then
    echo "[setup-codex] Installing Node.js 22.x (required version not found)..."
    # Remove any existing Node.js to avoid conflicts
    $SUDO apt-get remove -y nodejs npm > /dev/null 2>&1 || true
    $SUDO apt-get autoremove -y > /dev/null 2>&1 || true
    # Add NodeSource repository for Node 22 and install Node.js
    # Retry the NodeSource setup script up to 3 times if it fails (network issues)
    NODESETUP_OK=false
    for attempt in 1 2 3; do
        if curl -fsSL https://deb.nodesource.com/setup_22.x | $SUDO -E bash -; then
            NODESETUP_OK=true
            break
        else
            echo "[setup-codex] Warning: NodeSource setup failed (attempt $attempt). Retrying..."
            sleep 2
        fi
    done
    if [[ "$NODESETUP_OK" != true ]]; then
        echo "[setup-codex] ❌ NodeSource setup failed after 3 attempts. Exiting."
        exit 1
    fi
    $SUDO apt-get install -y nodejs
    # Verify Node installation
    if ! command -v node >/dev/null 2>&1 || [[ ! "$(node --version)" =~ ^v22\. ]]; then
        echo "[setup-codex] ❌ Failed to install Node.js 22.x. Current version: $(node --version 2>/dev/null || echo none)"
        exit 1
    fi
    echo "[setup-codex] Node.js $(node --version) installed successfully."
else
    echo "[setup-codex] Node.js is already at required version ($CURRENT_NODE_VERSION)."
fi

# 3. Ensure Python 3.12 is installed
echo "[setup-codex] Verifying Python 3.12 installation..."
PY_OK=false
if command -v python3 >/dev/null 2>&1; then
    PY_VER="$(python3 -V 2>&1 || echo "")"
    # Check if the current python3 version starts with "Python 3.12"
    if [[ "$PY_VER" == "Python 3.12."* ]]; then
        PY_OK=true
    fi
fi
if ! $PY_OK; then
    echo "[setup-codex] Installing Python 3.12..."
    $SUDO apt-get install -y software-properties-common > /dev/null 2>&1 || true
    $SUDO add-apt-repository ppa:deadsnakes/ppa -y > /dev/null
    $SUDO apt-get update -qq
    $SUDO apt-get install -y python3.12 python3.12-venv python3.12-dev python3.12-distutils > /dev/null
    # Update 'python3' symlink to point to 3.12
    if [[ -x "/usr/bin/python3.12" ]]; then
        $SUDO ln -sf /usr/bin/python3.12 /usr/bin/python3
        $SUDO ln -sf /usr/bin/python3.12 /usr/bin/python
    fi
    # Ensure pip for 3.12 and upgrade it
    if command -v python3 >/dev/null 2>&1; then
        python3 -m ensurepip || true   # in case pip isn't already installed with python3.12
        python3 -m pip install --upgrade pip > /dev/null
    fi
fi
echo "[setup-codex] Python version: $(python3 --version 2>&1)"

# 4. Configure npm (Node package manager) to avoid proxies and use default registry
echo "[setup-codex] Configuring npm..."
npm config delete proxy --global 2>/dev/null || true
npm config delete https-proxy --global 2>/dev/null || true
npm config delete http-proxy --global 2>/dev/null || true
npm config set registry "https://registry.npmjs.org/" --global
npm config set fetch-retries 5 --global
npm config set fetch-retry-factor 2 --global
npm config set fetch-retry-mintimeout 10000 --global

# 5. Install pnpm (Node.js package manager)
echo "[setup-codex] Installing pnpm..."
# Prepare environment variables for pnpm installation
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
mkdir -p "$PNPM_HOME" "$HOME/.npm" "$HOME/.cache" "$HOME/.config"
# Attempt official pnpm installer script
if curl -fsSL https://get.pnpm.io/install.sh | SHELL=/bin/bash sh -; then
    echo "[setup-codex] pnpm installed via official script."
else
    echo "[setup-codex] Official pnpm installer failed, attempting manual download..."
    PNPM_VERSION="9.15.0"  # fallback to a known stable pnpm version
    PNPM_URL="https://github.com/pnpm/pnpm/releases/download/v${PNPM_VERSION}/pnpm-linux-x64"
    curl -fsSL "$PNPM_URL" -o "$PNPM_HOME/pnpm" && chmod +x "$PNPM_HOME/pnpm"
    if [[ -x "$PNPM_HOME/pnpm" ]]; then
        echo "[setup-codex] pnpm $PNPM_VERSION downloaded and installed manually."
    else
        echo "[setup-codex] ❌ Failed to install pnpm." 
        exit 1
    fi
fi
# Verify pnpm command is available
if ! command -v pnpm >/dev/null 2>&1; then
    echo "[setup-codex] ❌ pnpm installation was not successful."
    exit 1
fi
echo "[setup-codex] pnpm version: $(pnpm --version)"

# Persist pnpm path for future shells (if applicable)
if ! grep -q 'PNPM_HOME' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> "$HOME/.bashrc"
    echo 'export PATH="$PNPM_HOME:$PATH"' >> "$HOME/.bashrc"
fi

# Configure pnpm for network resiliency and consistent behavior
pnpm config set registry https://registry.npmjs.org/
pnpm config set store-dir ~/.pnpm-store
pnpm config set network-timeout 300000   # 5 minutes
pnpm config set fetch-retries 5
pnpm config set fetch-retry-factor 2
pnpm config set fetch-retry-mintimeout 10000

# 6. Install project dependencies using pnpm (if package.json exists)
if [[ -f "package.json" ]]; then
    echo "[setup-codex] Installing Node.js project dependencies (pnpm install)..."
    pnpm install
    if [[ $? -eq 0 ]]; then
        echo "[setup-codex] Project dependencies installed successfully."
    else
        echo "[setup-codex] ⚠️ pnpm install encountered errors. Proceed with caution."
    fi
else
    echo "[setup-codex] No package.json found. Skipping pnpm install."
fi

# 7. Install Codacy Analysis CLI for code quality checks
echo "[setup-codex] Setting up Codacy CLI..."
TOOLS_DIR="$PWD/tools"
CLI_PATH="$TOOLS_DIR/codacy"
mkdir -p "$TOOLS_DIR"
if [[ ! -x "$CLI_PATH" ]]; then
    # Download latest Codacy CLI release for Linux x64
    TEMP_DIR="$(mktemp -d)"
    # Ensure temp directory is removed on script exit
    trap 'rm -rf "$TEMP_DIR"' EXIT
    CODACY_URL=$(curl -fsSL https://api.github.com/repos/codacy/codacy-cli-v2/releases/latest | grep -Po '"browser_download_url":\s*"\K.*linux_amd64.*\.tar\.gz(?=")' | head -n1)
    if [[ -z "$CODACY_URL" ]]; then
        echo "[setup-codex] ❌ Could not determine Codacy CLI download URL."
        # Remove EXIT trap to avoid deleting already downloaded files if none
        trap - EXIT
        exit 1
    fi
    curl -fsSL "$CODACY_URL" -o "$TEMP_DIR/codacy.tgz"
    tar -xzf "$TEMP_DIR/codacy.tgz" -C "$TEMP_DIR"
    # Move the extracted binary to tools directory (it has a versioned name, rename to "codacy")
    mv "$TEMP_DIR"/codacy-cli* "$CLI_PATH" && chmod +x "$CLI_PATH"
    # Cleanup temp (trap will handle it)
    echo "[setup-codex] Codacy CLI installed to $CLI_PATH."
else
    echo "[setup-codex] Codacy CLI already present."
fi
# Add tools directory to PATH for current session (so 'codacy' command is usable)
export PATH="$TOOLS_DIR:$PATH"

# 8. Configure Codacy project analysis (if tokens provided)
if [[ -n "${CODACY_ACCOUNT_TOKEN:-}" && -n "${CODACY_PROJECT_TOKEN:-}" ]]; then
    echo "[setup-codex] Enabling Codacy project analysis settings..."
    # Call Codacy API to ensure buildServerAnalysis is enabled for this repo
    HTTP_CODE=$(curl -fsS -o /dev/null -w "%{http_code}" -X PATCH \
      "https://app.codacy.com/api/v3/organizations/gh/DrJLabs/repositories/ice-webapp/buildServerAnalysis" \
      -H "api-token: $CODACY_ACCOUNT_TOKEN" -H "Content-Type: application/json" \
      -d '{"enabled":true}')
    if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "204" ]]; then
        echo "[setup-codex] Codacy analysis flag enabled (buildServerAnalysis)."
    else
        echo "[setup-codex] Codacy API returned $HTTP_CODE (flag may already be set or token permissions issue). Continuing."
    fi
else
    echo "[setup-codex] CODACY_ACCOUNT_TOKEN or CODACY_PROJECT_TOKEN not provided; skipping Codacy API configuration."
fi

# 9. Final status output
echo "---------- Environment Setup Complete ----------"
echo "Node.js version: $(node --version 2>/dev/null || echo not installed)"
echo "npm version: $(npm --version 2>/dev/null || echo not installed)"
echo "pnpm version: $(pnpm --version 2>/dev/null || echo not installed)"
echo "Python version: $(python3 --version 2>/dev/null || echo not installed)"
if command -v codacy >/dev/null 2>&1; then
    echo "Codacy CLI version: $(codacy version | head -n1)"
else
    echo "Codacy CLI: not installed"
fi
echo "-------------------------------------------------"
echo "[setup-codex] ✅ Setup complete. You can now run 'pnpm run dev' or 'pnpm run build'." 