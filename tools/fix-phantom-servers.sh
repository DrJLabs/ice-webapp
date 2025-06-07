#!/bin/bash
set -e

# fix-phantom-servers.sh - Script to fix phantom MCP servers in Cursor
echo "🧊 ICE-WEBAPP: Fixing Phantom MCP Servers"
echo "========================================"

# Make script executable
chmod +x "$0"

# Paths
WORKSPACE_PATH="$PWD"
CODACY_CLI_PATH="$WORKSPACE_PATH/tools/codacy"
GLOBAL_MCP_PATH="$HOME/.cursor/mcp.json"
PROJECT_MCP_PATH="$WORKSPACE_PATH/.cursor/mcp.json"
DUPLICATE_PATH="$WORKSPACE_PATH/~/.cursor"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Codacy CLI exists
if [ ! -f "$CODACY_CLI_PATH" ]; then
  echo -e "${RED}Codacy CLI not found at $CODACY_CLI_PATH${NC}"
  echo "You need to install Codacy CLI first"
  exit 1
fi

# Make Codacy CLI executable
chmod +x "$CODACY_CLI_PATH"

# Remove duplicate configurations
if [ -d "$DUPLICATE_PATH" ]; then
  echo -e "${YELLOW}Found duplicate configuration at $DUPLICATE_PATH${NC}"
  rm -rf "$DUPLICATE_PATH"
  echo -e "${GREEN}Removed duplicate configuration${NC}"
fi

# Backup existing configurations
if [ -f "$GLOBAL_MCP_PATH" ]; then
  cp "$GLOBAL_MCP_PATH" "${GLOBAL_MCP_PATH}.backup-$(date +%s)"
  echo -e "${BLUE}Backed up global MCP configuration${NC}"
fi

if [ -f "$PROJECT_MCP_PATH" ]; then
  cp "$PROJECT_MCP_PATH" "${PROJECT_MCP_PATH}.backup-$(date +%s)"
  echo -e "${BLUE}Backed up project MCP configuration${NC}"
fi

# Create fresh MCP configurations
mkdir -p "$(dirname "$GLOBAL_MCP_PATH")"
cat > "$GLOBAL_MCP_PATH" << EOF
{
  "mcpServers": {
    "codacy": {
      "command": "npx",
      "args": [
        "-y",
        "@codacy/codacy-mcp@latest"
      ]
    }
  }
}
EOF
echo -e "${GREEN}Created fresh global MCP configuration${NC}"

mkdir -p "$(dirname "$PROJECT_MCP_PATH")"
cat > "$PROJECT_MCP_PATH" << EOF
{
  "mcpServers": {
    "codacy": {
      "command": "npx",
      "args": [
        "-y",
        "@codacy/codacy-mcp@latest"
      ],
      "env": {
        "CODACY_CLI_PATH": "${CODACY_CLI_PATH}",
        "PATH": "${CODACY_CLI_PATH%/*}:$PATH"
      }
    }
  }
}
EOF
echo -e "${GREEN}Created fresh project MCP configuration${NC}"

# Clean up Cursor's extension storage if possible
CURSOR_CONFIG_DIR="$HOME/.config/Cursor"
if [ -d "$CURSOR_CONFIG_DIR" ]; then
  echo -e "${BLUE}Cleaning Cursor extension storage...${NC}"
  
  # Find and remove any Codacy or MCP related files in globalStorage
  find "$CURSOR_CONFIG_DIR/User/globalStorage" -name "*codacy*" -o -name "*mcp*" 2>/dev/null | while read -r file; do
    echo "Removing: $file"
    rm -rf "$file" 2>/dev/null || true
  done
  
  # Clean workspaceStorage
  find "$CURSOR_CONFIG_DIR/User/workspaceStorage" -name "*codacy*" -o -name "*mcp*" 2>/dev/null | while read -r file; do
    echo "Removing: $file"
    rm -rf "$file" 2>/dev/null || true
  done
fi

echo -e "${GREEN}✅ Phantom server cleanup complete!${NC}"
echo -e "${YELLOW}Please restart Cursor completely for the changes to take effect.${NC}" 