#!/bin/bash

# fix-codacy-integration.sh
# 
# This script fixes Codacy integration issues in Cursor IDE
# by ensuring proper CLI detection and MCP server configuration
#
# Usage: ./tools/fix-codacy-integration.sh

set -e

# Check if running in project root
if [ ! -d "tools" ] || [ ! -f "package.json" ]; then
  echo "❌ Error: Please run this script from the project root directory."
  exit 1
fi

# Make sure our fix script is executable
chmod +x tools/fix-codacy-cli-detection.js

# Run the fix script
echo "🔧 Running Codacy CLI detection fix..."
node tools/fix-codacy-cli-detection.js

# Fix cursor rules directory if needed
RULES_DIR=".cursor/rules"
if [ ! -d "$RULES_DIR" ]; then
  mkdir -p "$RULES_DIR"
  echo "✅ Created Cursor rules directory."
fi

# Make sure the frontmatter is correct
if [ -f "$RULES_DIR/codacy-quality-gates.mdc" ]; then
  # Check if frontmatter exists
  if ! grep -q "^---" "$RULES_DIR/codacy-quality-gates.mdc"; then
    # Add frontmatter
    TEMP_FILE=$(mktemp)
    echo "---" > "$TEMP_FILE"
    echo "description: \"Codacy quality gates and code analysis integration for Cursor IDE\"" >> "$TEMP_FILE"
    echo "globs: \"**/*.{ts,tsx,js,jsx,py,java,go,rb}\"" >> "$TEMP_FILE"
    echo "---" >> "$TEMP_FILE"
    cat "$RULES_DIR/codacy-quality-gates.mdc" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$RULES_DIR/codacy-quality-gates.mdc"
    echo "✅ Fixed frontmatter in codacy-quality-gates.mdc"
  fi
fi

# Verify that Codacy CLI works
echo "🔍 Verifying Codacy CLI..."
./tools/codacy version

echo ""
echo "✅ Codacy integration fix complete!"
echo ""
echo "To make sure changes take effect:"
echo "1. Restart Cursor IDE"
echo "2. For shell environment changes, run: source ~/.bashrc (or your shell profile)"
echo "3. Verify Codacy CLI detection in Cursor by opening the Codacy panel"
echo ""
echo "If issues persist, please check docs/CODACY_CURSOR_INTEGRATION.md for troubleshooting." 