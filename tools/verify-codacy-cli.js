#!/usr/bin/env node

/**
 * Verify Codacy CLI Detection
 * 
 * This script verifies if the Codacy CLI is properly detected by Cursor
 * by checking:
 * 1. If the CLI binary exists
 * 2. If it can be executed
 * 3. If the MCP configurations are correct
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const os = require('os');

// Constants
const HOME_DIR = os.homedir();
const WORKSPACE_DIR = process.cwd();
const GLOBAL_MCP_PATH = path.join(HOME_DIR, '.cursor', 'mcp.json');
const PROJECT_MCP_PATH = path.join(WORKSPACE_DIR, '.cursor', 'mcp.json');
const CODACY_CLI_PATH = path.join(WORKSPACE_DIR, 'tools', 'codacy');
const SYSTEM_BIN_PATH = '/usr/local/bin/codacy';

// ANSI color codes
const RESET = '\x1b[0m';
const RED = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const BLUE = '\x1b[34m';

console.log(`\n${BLUE}🔍 Verifying Codacy CLI detection...${RESET}\n`);

// Check if CLI binary exists
console.log(`${BLUE}Checking CLI binary:${RESET}`);
if (fs.existsSync(CODACY_CLI_PATH)) {
  console.log(`${GREEN}✅ Codacy CLI binary exists at ${CODACY_CLI_PATH}${RESET}`);
} else {
  console.log(`${RED}❌ Codacy CLI binary not found at ${CODACY_CLI_PATH}${RESET}`);
}

// Check if it can be executed
console.log(`\n${BLUE}Testing CLI execution:${RESET}`);
try {
  const output = execSync(`${CODACY_CLI_PATH} version`, { encoding: 'utf8' });
  console.log(`${GREEN}✅ Codacy CLI is executable${RESET}`);
  console.log(`${BLUE}Version: ${output.trim()}${RESET}`);
} catch (error) {
  console.log(`${RED}❌ Cannot execute Codacy CLI: ${error.message}${RESET}`);
}

// Check global MCP config
console.log(`\n${BLUE}Checking global MCP config:${RESET}`);
try {
  if (fs.existsSync(GLOBAL_MCP_PATH)) {
    const globalConfig = JSON.parse(fs.readFileSync(GLOBAL_MCP_PATH, 'utf8'));
    if (globalConfig?.mcpServers?.codacy) {
      console.log(`${GREEN}✅ Global MCP config has Codacy server entry${RESET}`);
      
      if (globalConfig?.mcpServers?.codacy?.env?.CODACY_CLI_PATH) {
        console.log(`${GREEN}✅ Global MCP config has CODACY_CLI_PATH: ${globalConfig.mcpServers.codacy.env.CODACY_CLI_PATH}${RESET}`);
        
        if (globalConfig.mcpServers.codacy.env.CODACY_CLI_PATH === CODACY_CLI_PATH) {
          console.log(`${GREEN}✅ Path is correct${RESET}`);
        } else {
          console.log(`${YELLOW}⚠️ Path is different from current workspace: ${CODACY_CLI_PATH}${RESET}`);
        }
      } else {
        console.log(`${YELLOW}⚠️ Global MCP config doesn't have CODACY_CLI_PATH${RESET}`);
      }
    } else {
      console.log(`${YELLOW}⚠️ Global MCP config doesn't have Codacy server entry${RESET}`);
    }
  } else {
    console.log(`${YELLOW}⚠️ Global MCP config not found${RESET}`);
  }
} catch (error) {
  console.log(`${RED}❌ Error reading global MCP config: ${error.message}${RESET}`);
}

// Check project MCP config
console.log(`\n${BLUE}Checking project MCP config:${RESET}`);
try {
  if (fs.existsSync(PROJECT_MCP_PATH)) {
    const projectConfig = JSON.parse(fs.readFileSync(PROJECT_MCP_PATH, 'utf8'));
    if (projectConfig?.mcpServers?.codacy) {
      console.log(`${GREEN}✅ Project MCP config has Codacy server entry${RESET}`);
      
      if (projectConfig?.mcpServers?.codacy?.env?.CODACY_CLI_PATH) {
        console.log(`${GREEN}✅ Project MCP config has CODACY_CLI_PATH: ${projectConfig.mcpServers.codacy.env.CODACY_CLI_PATH}${RESET}`);
        
        if (projectConfig.mcpServers.codacy.env.CODACY_CLI_PATH === CODACY_CLI_PATH) {
          console.log(`${GREEN}✅ Path is correct${RESET}`);
        } else {
          console.log(`${YELLOW}⚠️ Path is different from current workspace: ${CODACY_CLI_PATH}${RESET}`);
        }
      } else {
        console.log(`${YELLOW}⚠️ Project MCP config doesn't have CODACY_CLI_PATH${RESET}`);
      }
    } else {
      console.log(`${YELLOW}⚠️ Project MCP config doesn't have Codacy server entry${RESET}`);
    }
  } else {
    console.log(`${YELLOW}⚠️ Project MCP config not found${RESET}`);
  }
} catch (error) {
  console.log(`${RED}❌ Error reading project MCP config: ${error.message}${RESET}`);
}

// Check symlinks
console.log(`\n${BLUE}Checking symlinks:${RESET}`);
const localSymlink = path.join(WORKSPACE_DIR, 'tools', 'codacy-analysis-cli');
if (fs.existsSync(localSymlink)) {
  console.log(`${GREEN}✅ Local symlink exists at ${localSymlink}${RESET}`);
} else {
  console.log(`${YELLOW}⚠️ Local symlink not found at ${localSymlink}${RESET}`);
}

try {
  execSync('which codacy', { encoding: 'utf8' });
  console.log(`${GREEN}✅ System-wide 'codacy' command is available${RESET}`);
} catch (error) {
  console.log(`${YELLOW}⚠️ System-wide 'codacy' command not found${RESET}`);
}

// Summarize
console.log(`\n${BLUE}=== SUMMARY ===${RESET}`);
console.log(`${BLUE}To fix any issues found above:${RESET}`);
console.log(`${YELLOW}1. Run: node tools/codacy-mcp-fix.js${RESET}`);
console.log(`${YELLOW}2. Source: source tools/codacy-env.sh${RESET}`);
console.log(`${YELLOW}3. Restart Cursor completely${RESET}`);
console.log(`\n${BLUE}For more detailed information, see docs/CODACY_CURSOR_INTEGRATION.md${RESET}`); 