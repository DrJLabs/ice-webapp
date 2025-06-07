#!/usr/bin/env node

/**
 * Comprehensive Codacy MCP Server & CLI Detection Fix
 * 
 * This script fixes issues with Codacy CLI detection in Cursor by:
 * 1. Ensuring the CLI binary is properly set up
 * 2. Fixing both global and project-level MCP configurations
 * 3. Creating necessary symlinks
 * 4. Testing the CLI to verify it works
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

/**
 * Log a message with color
 */
function log(message, color = RESET) {
  console.log(`${color}${message}${RESET}`);
}

/**
 * Check if file exists
 */
function fileExists(filePath) {
  try {
    return fs.existsSync(filePath);
  } catch (error) {
    return false;
  }
}

/**
 * Ensure directory exists
 */
function ensureDirectoryExists(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    log(`Created directory: ${dirPath}`, GREEN);
  }
}

/**
 * Read JSON file safely
 */
function readJsonFile(filePath) {
  try {
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf8');
      return JSON.parse(content);
    }
  } catch (error) {
    log(`Error reading ${filePath}: ${error.message}`, RED);
  }
  return null;
}

/**
 * Write JSON file safely
 */
function writeJsonFile(filePath, data) {
  try {
    const content = JSON.stringify(data, null, 2);
    fs.writeFileSync(filePath, content, 'utf8');
    log(`Updated ${filePath}`, GREEN);
    return true;
  } catch (error) {
    log(`Error writing ${filePath}: ${error.message}`, RED);
    return false;
  }
}

/**
 * Fix the global MCP configuration
 */
function fixGlobalMcpConfig() {
  log('\n🔧 Fixing global MCP configuration...', BLUE);
  
  // Ensure the .cursor directory exists
  ensureDirectoryExists(path.join(HOME_DIR, '.cursor'));
  
  const globalConfig = readJsonFile(GLOBAL_MCP_PATH) || { mcpServers: {} };
  
  // Update or add the Codacy server configuration
  globalConfig.mcpServers = globalConfig.mcpServers || {};
  globalConfig.mcpServers.codacy = {
    command: 'npx',
    args: ['-y', '@codacy/codacy-mcp@latest'],
    env: {
      CODACY_CLI_PATH: CODACY_CLI_PATH,
      PATH: `${path.dirname(CODACY_CLI_PATH)}:${process.env.PATH}`
    }
  };
  
  writeJsonFile(GLOBAL_MCP_PATH, globalConfig);
}

/**
 * Fix the project MCP configuration
 */
function fixProjectMcpConfig() {
  log('\n🔧 Fixing project MCP configuration...', BLUE);
  
  // Ensure the .cursor directory exists
  ensureDirectoryExists(path.join(WORKSPACE_DIR, '.cursor'));
  
  const projectConfig = readJsonFile(PROJECT_MCP_PATH) || { mcpServers: {} };
  
  // Update or add the Codacy server configuration
  projectConfig.mcpServers = projectConfig.mcpServers || {};
  projectConfig.mcpServers.codacy = {
    command: 'npx',
    args: ['-y', '@codacy/codacy-mcp@latest'],
    env: {
      CODACY_CLI_PATH: CODACY_CLI_PATH,
      CODACY_CLI_VERSION: 'Information',
      // We don't set the token here as it might be sensitive
      PATH: `${path.dirname(CODACY_CLI_PATH)}:${process.env.PATH}`
    }
  };
  
  // If there's a token in an existing config, preserve it
  const existingConfig = readJsonFile(PROJECT_MCP_PATH);
  if (existingConfig?.mcpServers?.codacy?.env?.CODACY_ACCOUNT_TOKEN) {
    projectConfig.mcpServers.codacy.env.CODACY_ACCOUNT_TOKEN = 
      existingConfig.mcpServers.codacy.env.CODACY_ACCOUNT_TOKEN;
  }
  
  writeJsonFile(PROJECT_MCP_PATH, projectConfig);
}

/**
 * Create symlink to the Codacy CLI binary
 */
function createSymlink() {
  log('\n🔧 Creating symlink to Codacy CLI...', BLUE);
  
  if (!fileExists(CODACY_CLI_PATH)) {
    log(`Error: Codacy CLI binary not found at ${CODACY_CLI_PATH}`, RED);
    return false;
  }
  
  // Create local symlink in project tools directory
  const localSymlink = path.join(WORKSPACE_DIR, 'tools', 'codacy-analysis-cli');
  try {
    if (fileExists(localSymlink)) {
      fs.unlinkSync(localSymlink);
    }
    fs.symlinkSync(CODACY_CLI_PATH, localSymlink);
    log(`Created local symlink: ${localSymlink}`, GREEN);
  } catch (error) {
    log(`Error creating local symlink: ${error.message}`, YELLOW);
  }
  
  // Try to create system-wide symlink (requires sudo)
  try {
    if (fileExists(SYSTEM_BIN_PATH)) {
      execSync(`sudo rm ${SYSTEM_BIN_PATH}`);
    }
    execSync(`sudo ln -s ${CODACY_CLI_PATH} ${SYSTEM_BIN_PATH}`);
    log(`Created system symlink: ${SYSTEM_BIN_PATH}`, GREEN);
  } catch (error) {
    log(`Could not create system symlink (not critical): ${error.message}`, YELLOW);
  }
  
  return true;
}

/**
 * Ensure Codacy CLI has execute permissions
 */
function ensureExecutePermissions() {
  log('\n🔧 Ensuring Codacy CLI has execute permissions...', BLUE);
  
  if (!fileExists(CODACY_CLI_PATH)) {
    log(`Error: Codacy CLI binary not found at ${CODACY_CLI_PATH}`, RED);
    return false;
  }
  
  try {
    execSync(`chmod +x ${CODACY_CLI_PATH}`);
    log('Execute permissions set', GREEN);
    return true;
  } catch (error) {
    log(`Error setting execute permissions: ${error.message}`, RED);
    return false;
  }
}

/**
 * Test Codacy CLI
 */
function testCodacyCli() {
  log('\n🔧 Testing Codacy CLI...', BLUE);
  
  try {
    const output = execSync(`${CODACY_CLI_PATH} version`, { encoding: 'utf8' });
    log(`Codacy CLI version: ${output.trim()}`, GREEN);
    return true;
  } catch (error) {
    log(`Error running Codacy CLI: ${error.message}`, RED);
    return false;
  }
}

/**
 * Create a shell script to export environment variables
 */
function createEnvScript() {
  log('\n🔧 Creating environment script...', BLUE);
  
  const scriptPath = path.join(WORKSPACE_DIR, 'tools', 'codacy-env.sh');
  const scriptContent = `#!/bin/bash
# Codacy Environment Variables
export CODACY_CLI_PATH="${CODACY_CLI_PATH}"
export PATH="${path.dirname(CODACY_CLI_PATH)}:$PATH"

# Test if Codacy CLI is working
echo "Testing Codacy CLI..."
"${CODACY_CLI_PATH}" --version

echo "Codacy environment is set up. If you have issues with Cursor, please restart Cursor."
`;
  
  try {
    fs.writeFileSync(scriptPath, scriptContent, 'utf8');
    execSync(`chmod +x ${scriptPath}`);
    log(`Created environment script: ${scriptPath}`, GREEN);
    log(`Run 'source ${scriptPath}' if needed in terminal`, BLUE);
    return true;
  } catch (error) {
    log(`Error creating environment script: ${error.message}`, RED);
    return false;
  }
}

/**
 * Create a Codacy rule file for Cursor
 */
function createCursorRule() {
  log('\n🔧 Creating Cursor rule for Codacy...', BLUE);
  
  const ruleDir = path.join(WORKSPACE_DIR, '.cursor', 'rules');
  ensureDirectoryExists(ruleDir);
  
  const rulePath = path.join(ruleDir, 'codacy-quality-gates.mdc');
  const ruleContent = `---
description: "Codacy integration rules for automated quality gates and security scanning in ICE-WEBAPP development"
globs: "**/*.{ts,tsx,js,jsx}, package.json, requirements.txt"
---

# Codacy Quality Gates Integration
Configuration for AI behavior when interacting with Codacy's MCP Server

## After ANY successful \`edit_file\` or \`reapply\` operation
- YOU MUST IMMEDIATELY run the \`codacy_cli_analyze\` tool from Codacy's MCP Server for each file that was edited, with:
 - \`rootPath\`: set to the workspace path
 - \`file\`: set to the path of the edited file
 - \`tool\`: leave empty or unset
- If any issues are found in the new edits, propose and apply fixes for them.
- > NOTE: Failure to follow this rule is considered a critical error.

## CRITICAL: Dependencies and Security Checks
- IMMEDIATELY after ANY of these actions:
 - Running npm/yarn/pnpm install
 - Adding dependencies to package.json
 - Adding requirements to requirements.txt
 - Adding dependencies to pom.xml
 - Adding dependencies to build.gradle
 - Any other package manager operations
- You MUST run the \`codacy_cli_analyze\` tool with:
 - \`rootPath\`: set to the workspace path
 - \`tool\`: set to "trivy"
 - \`file\`: leave empty or unset
- If any vulnerabilities are found because of the newly added packages:
 - Stop all other operations
 - Propose and apply fixes for the security issues
 - Only continue with the original task after security issues are resolved
- EXAMPLE:
 - After: npm install react-markdown
 - Do: Run codacy_cli_analyze with trivy
 - Before: Continuing with any other tasks

## General
- Repeat the relevant steps for each modified file.
- "Propose fixes" means to both suggest and, if possible, automatically apply the fixes.
- You MUST NOT wait for the user to ask for analysis or remind you to run the tool.
`;
  
  try {
    fs.writeFileSync(rulePath, ruleContent, 'utf8');
    log(`Created Cursor rule: ${rulePath}`, GREEN);
    return true;
  } catch (error) {
    log(`Error creating Cursor rule: ${error.message}`, RED);
    return false;
  }
}

/**
 * Create a documentation file for Codacy-Cursor integration
 */
function createDocumentation() {
  log('\n🔧 Creating documentation for Codacy-Cursor integration...', BLUE);
  
  const docsDir = path.join(WORKSPACE_DIR, 'docs');
  ensureDirectoryExists(docsDir);
  
  const docPath = path.join(docsDir, 'CODACY_CURSOR_INTEGRATION.md');
  const docContent = `# Codacy-Cursor Integration Troubleshooting

## Common Issues

### Issue: Codacy CLI not detected by Cursor MCP Server

**Symptoms:**
- Codacy MCP server shows only 3 tools with a red indicator
- "Not in gzip format" error when trying to install Codacy CLI from Cursor
- Codacy CLI is installed but not detected by Cursor

**Solution:**

Run the comprehensive fix script:

\`\`\`bash
# Make the script executable
chmod +x tools/codacy-mcp-fix.js

# Run the script
node tools/codacy-mcp-fix.js
\`\`\`

This script will:
1. Fix global and project MCP configurations
2. Create necessary symlinks
3. Set execute permissions
4. Create environment variables
5. Add Cursor rule for Codacy integration

**After running the script:**
1. Restart Cursor completely
2. If needed, source the environment script:
   \`\`\`bash
   source tools/codacy-env.sh
   \`\`\`

### Manual Fixes

If the automated script doesn't work, try these manual steps:

1. **Verify Codacy CLI exists:**
   \`\`\`bash
   ls -la tools/codacy
   \`\`\`

2. **Make it executable:**
   \`\`\`bash
   chmod +x tools/codacy
   \`\`\`

3. **Test the CLI:**
   \`\`\`bash
   tools/codacy --version
   \`\`\`

4. **Fix the global MCP configuration:**
   Edit \`~/.cursor/mcp.json\` to include:
   \`\`\`json
   {
     "mcpServers": {
       "codacy": {
         "command": "npx",
         "args": [
           "-y",
           "@codacy/codacy-mcp@latest"
         ],
         "env": {
           "CODACY_CLI_PATH": "/absolute/path/to/workspace/tools/codacy"
         }
       }
     }
   }
   \`\`\`

5. **Fix the project MCP configuration:**
   Edit \`.cursor/mcp.json\` to include:
   \`\`\`json
   {
     "mcpServers": {
       "codacy": {
         "command": "npx",
         "args": [
           "-y",
           "@codacy/codacy-mcp@latest"
         ],
         "env": {
           "CODACY_CLI_PATH": "/absolute/path/to/workspace/tools/codacy",
           "CODACY_CLI_VERSION": "Information"
         }
       }
     }
   }
   \`\`\`

6. **Create a symlink:**
   \`\`\`bash
   # Create a local symlink
   ln -s tools/codacy tools/codacy-analysis-cli
   
   # Try to create a system-wide symlink (if you have sudo access)
   sudo ln -s $(pwd)/tools/codacy /usr/local/bin/codacy
   \`\`\`

## Common Configuration Issues

1. **Duplicate or conflicting MCP server entries**
   - Check both global (~/.cursor/mcp.json) and project (.cursor/mcp.json) configurations
   - They should have compatible settings for the Codacy server

2. **Incorrect CLI path**
   - The CODACY_CLI_PATH should point to the absolute path of the Codacy CLI binary
   - Make sure this path exists and is accessible

3. **Execution permissions**
   - The Codacy CLI binary must be executable
   - Run \`chmod +x tools/codacy\` to ensure this

4. **Missing environment variables**
   - Set PATH to include the directory with the Codacy binary

## Support

For more information on Codacy CLI troubleshooting, see the [official documentation](https://docs.codacy.com/coverage-reporter/troubleshooting-coverage-cli-issues/).
`;
  
  try {
    fs.writeFileSync(docPath, docContent, 'utf8');
    log(`Created documentation: ${docPath}`, GREEN);
    return true;
  } catch (error) {
    log(`Error creating documentation: ${error.message}`, RED);
    return false;
  }
}

/**
 * Main function
 */
function main() {
  log('\n🔍 Starting Codacy MCP and CLI detection fix...', BLUE);
  
  // Check if Codacy CLI exists
  if (!fileExists(CODACY_CLI_PATH)) {
    log(`Error: Codacy CLI binary not found at ${CODACY_CLI_PATH}`, RED);
    log('Please make sure the Codacy CLI binary is available in tools/codacy', RED);
    return false;
  }
  
  // Fix configurations
  fixGlobalMcpConfig();
  fixProjectMcpConfig();
  
  // Fix execution
  ensureExecutePermissions();
  createSymlink();
  
  // Create helpers
  createEnvScript();
  createCursorRule();
  createDocumentation();
  
  // Test
  const testResult = testCodacyCli();
  
  log('\n✅ Codacy MCP and CLI detection fix completed', BLUE);
  if (testResult) {
    log('\n🎉 SUCCESS! Codacy CLI is working', GREEN);
    log('Please restart Cursor completely for changes to take effect', BLUE);
    log('If you still have issues, try sourcing the environment script:', BLUE);
    log(`  source tools/codacy-env.sh`, YELLOW);
  } else {
    log('\n⚠️ Codacy CLI test failed', RED);
    log('Please check the error messages above and fix any issues', RED);
  }
  
  return testResult;
}

// Run the main function
main(); 