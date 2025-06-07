#!/bin/bash
# fix-codacy-cursor-integration.sh - Script to fix Codacy integration with Cursor

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🧊 Fixing Codacy integration with Cursor...${NC}"

# Get paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CODACY_CLI="${SCRIPT_DIR}/codacy"
USER_HOME="${HOME}"
CURSOR_DIR="${USER_HOME}/.cursor"
PROJECT_CURSOR_DIR="${ROOT_DIR}/.cursor"
CODACY_DIR="${ROOT_DIR}/.codacy"

# 1. Ensure Codacy CLI exists and is executable
echo -e "${BLUE}✅ Verifying Codacy CLI...${NC}"
if [ ! -f "$CODACY_CLI" ]; then
  echo -e "${YELLOW}⚠️ Codacy CLI not found, downloading...${NC}"
  
  # Create a temporary directory
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  
  # Download the latest Codacy CLI
  LATEST_URL=$(curl -s https://api.github.com/repos/codacy/codacy-cli-v2/releases/latest | grep -Po '"browser_download_url":\s*"\K.*linux_amd64.*\.tar\.gz(?=")' | head -n1)
  if [ -z "$LATEST_URL" ]; then
    echo -e "${RED}❌ Failed to get the latest Codacy CLI URL${NC}"
    exit 1
  fi
  
  curl -fsSL "$LATEST_URL" -o "$TMP_DIR/cli.tgz"
  tar -xzf "$TMP_DIR/cli.tgz" -C "$TMP_DIR"
  mv "$TMP_DIR"/codacy-cli* "$CODACY_CLI" && chmod +x "$CODACY_CLI"
  
  echo -e "${GREEN}✅ Codacy CLI downloaded to $CODACY_CLI${NC}"
else
  echo -e "${GREEN}✅ Codacy CLI already exists at $CODACY_CLI${NC}"
  # Ensure it's executable
  chmod +x "$CODACY_CLI"
fi

# 2. Check Codacy CLI works
echo -e "${BLUE}✅ Checking Codacy CLI functionality...${NC}"
CLI_VERSION=$("$CODACY_CLI" version | grep "Version:" | awk '{print $2}')
if [ -z "$CLI_VERSION" ]; then
  echo -e "${RED}❌ Codacy CLI not working properly${NC}"
  exit 1
else
  echo -e "${GREEN}✅ Codacy CLI version: $CLI_VERSION${NC}"
fi

# 3. Clean up any existing Codacy MCP server configs
echo -e "${BLUE}✅ Cleaning up existing Codacy MCP server configs...${NC}"

# Create necessary directories
mkdir -p "$CURSOR_DIR"
mkdir -p "$PROJECT_CURSOR_DIR"
mkdir -p "$CODACY_DIR"

# Create a proper MCP configuration for Codacy
echo -e "${BLUE}✅ Creating Codacy MCP configuration...${NC}"

# Get the absolute path to the Codacy CLI
CODACY_CLI_ABSOLUTE_PATH=$(realpath "$CODACY_CLI")
echo -e "${GREEN}✅ Using Codacy CLI at: $CODACY_CLI_ABSOLUTE_PATH${NC}"

# Create configuration content
MCP_CONFIG='{
  "mcpServers": {
    "codacy": {
      "command": "npx",
      "args": [
        "-y",
        "@codacy/codacy-mcp@0.6.13"
      ],
      "env": {
        "CODACY_ACCOUNT_TOKEN": "aG4RohRfiK7hzbneKHJ2",
        "CODACY_CLI_VERSION": "'$CLI_VERSION'",
        "CODACY_CLI_PATH": "'$CODACY_CLI_ABSOLUTE_PATH'"
      }
    }
  }
}'

# Write the configuration to the project-specific location
echo "$MCP_CONFIG" > "$PROJECT_CURSOR_DIR/mcp.json"
echo -e "${GREEN}✅ Project MCP configuration updated${NC}"

# Also write to global configuration to ensure consistency
echo "$MCP_CONFIG" > "$CURSOR_DIR/mcp.json"
echo -e "${GREEN}✅ Global MCP configuration updated${NC}"

# 4. Install Codacy MCP package globally
echo -e "${BLUE}✅ Installing Codacy MCP package...${NC}"
npm install -g @codacy/codacy-mcp@0.6.13
echo -e "${GREEN}✅ Codacy MCP package installed globally${NC}"

# 5. Ensure Codacy CLI is in PATH
echo -e "${BLUE}✅ Ensuring Codacy CLI is in PATH...${NC}"
if [[ ":$PATH:" != *":$SCRIPT_DIR:"* ]]; then
  # Add to user's bash profile
  PROFILE_FILE="$USER_HOME/.bashrc"
  if [ -f "$USER_HOME/.bash_profile" ]; then
    PROFILE_FILE="$USER_HOME/.bash_profile"
  elif [ -f "$USER_HOME/.profile" ]; then
    PROFILE_FILE="$USER_HOME/.profile"
  fi
  
  echo 'export PATH="'$SCRIPT_DIR':$PATH"' >> "$PROFILE_FILE"
  echo -e "${GREEN}✅ Added Codacy CLI directory to PATH in $PROFILE_FILE${NC}"
  echo -e "${YELLOW}⚠️ Please run 'source $PROFILE_FILE' to apply changes${NC}"
  
  # Also export it for the current session
  export PATH="$SCRIPT_DIR:$PATH"
else
  echo -e "${GREEN}✅ Codacy CLI directory already in PATH${NC}"
fi

# 6. Configure Codacy CLI
echo -e "${BLUE}✅ Configuring Codacy CLI...${NC}"
if [ ! -f "${CODACY_DIR}/codacy.yaml" ] || [ ! -s "${CODACY_DIR}/codacy.yaml" ]; then
  echo -e "${BLUE}✅ Creating default Codacy configuration...${NC}"
  mkdir -p "${CODACY_DIR}"
  cat > "${CODACY_DIR}/codacy.yaml" << EOF
runtimes:
    - dart@3.7.2
    - java@17.0.10
    - node@22.2.0
    - python@3.11.11
tools:
    - dartanalyzer@3.7.2
    - eslint@8.57.0
    - lizard@1.17.19
    - pmd@6.55.0
    - pylint@3.3.6
    - semgrep@1.78.0
    - trivy@0.59.1
EOF
  echo -e "${GREEN}✅ Created default Codacy configuration${NC}"
else
  echo -e "${GREEN}✅ Codacy configuration already exists${NC}"
fi

# Configure CLI mode
echo -e "${BLUE}✅ Setting CLI mode to local...${NC}"
mkdir -p "${CODACY_DIR}"
cat > "${CODACY_DIR}/cli-config.yaml" << EOF
mode: local
EOF
echo -e "${GREEN}✅ CLI mode set to local${NC}"

# 7. Final instructions
echo -e "${GREEN}✅ Codacy integration with Cursor has been fixed!${NC}"
echo -e "${CYAN}📝 Please restart Cursor completely for the changes to take effect.${NC}"
echo -e "${CYAN}📝 If the issue persists, please remove any duplicate Codacy servers from Cursor settings manually.${NC}"
echo -e "${CYAN}📝 After restarting, you should only see ONE Codacy server in Cursor settings.${NC}" 