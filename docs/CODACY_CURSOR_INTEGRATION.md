# Codacy & Cursor Integration Guide

This document provides guidance on fixing common issues with Codacy and Cursor integration, including the phantom/ghost server problem.

## Quick Fix for All Issues

To fix all Codacy and Cursor integration issues in one go:

```bash
./tools/fix-codacy-cursor-integration.sh
```

This script will:
- Fix phantom/ghost server issues
- Ensure proper CLI detection
- Set up environment variables
- Fix MCP configurations

After running the script, **restart Cursor completely** for changes to take effect.

## Phantom/Ghost Servers

If you see phantom/ghost Codacy servers in the MCP status that don't exist in your configuration:

1. Close Cursor completely
2. Run the cleanup script:
   ```bash
   node ./tools/clean-codacy-configs.js
   ```
3. Delete duplicate configurations:
   ```bash
   rm -rf ~/ice-webapp/~/.cursor
   ```
4. Check for misconfiguration in global settings:
   ```bash
   cat ~/.cursor/mcp.json
   ```
5. Restart Cursor

## Cursor Not Detecting Codacy CLI

If Cursor shows a red flag on the Codacy tool or shows only 3 tools instead of all:

1. Verify the Codacy CLI exists and is executable:
   ```bash
   ls -la ./tools/codacy
   chmod +x ./tools/codacy
   ```

2. Fix CLI detection issues:
   ```bash
   node ./tools/fix-codacy-cli-detection.js
   ```

3. Set up environment variables:
   ```bash
   export CODACY_CLI_PATH="$PWD/tools/codacy"
   export PATH="$PWD/tools:$PATH"
   ```

4. Restart Cursor

## Multiple Codacy Servers in Settings

If you see multiple Codacy servers in Cursor settings:

1. Close Cursor completely
2. Run the cleanup script:
   ```bash
   node ./tools/clean-codacy-configs.js
   ```
3. Check the configuration files to ensure they're correct:
   ```bash
   cat ~/.cursor/mcp.json
   cat ./.cursor/mcp.json
   ```
4. Restart Cursor

## Verify Integration

To verify that all components are working correctly:

```bash
node ./tools/verify-codacy-tools.js
```

This script will check:
- Codacy CLI availability and version
- MCP configuration
- Duplicate configurations
- Environment variables

## Debugging Steps

If you're still experiencing issues:

1. Check for stale configuration in Cursor's globalStorage:
   ```bash
   find ~/.config/Cursor -name "*codacy*" -o -name "*mcp*"
   ```

2. Look for any broken symlinks:
   ```bash
   find ~/bin ~/.local/bin -type l -name "codacy" -exec ls -la {} \;
   ```

3. Check for conflicts in PATH:
   ```bash
   which codacy
   echo $PATH | tr ':' '\n' | grep -i codacy
   ```

4. Verify CLI can be executed directly:
   ```bash
   ./tools/codacy version
   ```

## Reinstalling Codacy CLI

If your Codacy CLI binary is corrupted or outdated:

1. Delete the existing CLI:
   ```bash
   rm ./tools/codacy
   ```

2. Download a fresh copy:
   ```bash
   curl -fsSL https://cli.codacy.com/download/linux -o ./tools/codacy
   chmod +x ./tools/codacy
   ```

3. Verify the CLI works:
   ```bash
   ./tools/codacy version
   ```

## Known Issues and Solutions

### Phantom Servers After Removing from MCP Config

This is a known issue with Cursor's MCP integration where removed servers still appear in the MCP status. The fix is to clean up all related configuration files and restart Cursor.

### CLI Detection Issues

Cursor may fail to detect the Codacy CLI even when it exists, typically due to environment variable or PATH issues. This can be fixed by properly configuring the MCP server with the correct path to the CLI.

### Duplicate Server Configuration

Multiple Codacy server entries can appear if there are duplicate configurations in different locations. The cleanup script helps to standardize these configurations.

## Troubleshooting Environment Variables

If environment variables aren't being recognized:

1. Add them to your shell profile (~/.bashrc or ~/.zshrc):
   ```bash
   echo 'export CODACY_CLI_PATH="$HOME/ice-webapp/tools/codacy"' >> ~/.bashrc
   echo 'export PATH="$HOME/ice-webapp/tools:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

2. Make sure Cursor has access to these environment variables:
   - Restart Cursor after setting variables
   - Launch Cursor from the terminal where variables are set

## Maintaining the Integration

After updates to Cursor or Codacy:

1. Run the verification script:
   ```bash
   node ./tools/verify-codacy-tools.js
   ```

2. If issues are found, run the fix script:
   ```bash
   ./tools/fix-codacy-cursor-integration.sh
   ```
