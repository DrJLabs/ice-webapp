#!/bin/bash
# setup-codacy-mcp.sh - Script to properly set up Codacy MCP for Cursor

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CURSOR_DIR="${ROOT_DIR}/.cursor"
CODACY_DIR="${ROOT_DIR}/.codacy"
CODACY_CLI="${SCRIPT_DIR}/codacy"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🧊 Setting up Codacy MCP for Cursor integration...${NC}"

# Ensure Codacy CLI exists
if [ ! -f "$CODACY_CLI" ]; then
  echo -e "${YELLOW}⚠️ Codacy CLI not found at $CODACY_CLI${NC}"
  echo -e "${BLUE}📥 Downloading Codacy CLI...${NC}"
  
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
fi

# Create .cursor directory if it doesn't exist
mkdir -p "$CURSOR_DIR"

# Create or update MCP configuration
echo -e "${BLUE}⚙️ Updating Cursor MCP configuration...${NC}"

cat > "$CURSOR_DIR/mcp.json" << EOF
{
  "mcpServers": {
    "codacy": {
      "command": "npx",
      "args": [
        "-y",
        "@codacy/codacy-mcp@0.6.13"
      ],
      "env": {
        "CODACY_ACCOUNT_TOKEN": "aG4RohRfiK7hzbneKHJ2",
        "CODACY_CLI_VERSION": "1.0.0-main.332.sha.63a2be3",
        "CODACY_CLI_PATH": "${CODACY_CLI}"
      }
    }
  }
}
EOF

echo -e "${GREEN}✅ MCP configuration updated${NC}"

# Update PATH to include Codacy CLI directory
echo -e "${BLUE}⚙️ Ensuring Codacy CLI is in PATH...${NC}"

# Check if PATH already contains Codacy CLI directory
if [[ ":$PATH:" != *":$SCRIPT_DIR:"* ]]; then
  echo 'export PATH="'$SCRIPT_DIR':$PATH"' >> ~/.bashrc
  echo -e "${GREEN}✅ Added Codacy CLI directory to PATH in ~/.bashrc${NC}"
  echo -e "${YELLOW}⚠️ Please restart your terminal or run 'source ~/.bashrc' for the changes to take effect${NC}"
else
  echo -e "${GREEN}✅ Codacy CLI directory already in PATH${NC}"
fi

# Run Codacy CLI to verify it works
echo -e "${BLUE}🔍 Verifying Codacy CLI installation...${NC}"
"$CODACY_CLI" version

# Check MCP package installation
echo -e "${BLUE}🔍 Checking Codacy MCP package installation...${NC}"

# Install the MCP package globally to ensure it's available
echo -e "${BLUE}📥 Installing Codacy MCP package globally...${NC}"
npm install -g @codacy/codacy-mcp@0.6.13

echo -e "${GREEN}✅ Codacy MCP setup complete!${NC}"
echo -e "${CYAN}📝 Please restart Cursor for the changes to take effect.${NC}" 