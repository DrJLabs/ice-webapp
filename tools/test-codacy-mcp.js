#!/usr/bin/env node

/**
 * Test script for the Codacy MCP server
 * This script checks if the Codacy MCP server is configured correctly
 * and can be accessed by Cursor.
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Get the paths
const rootDir = path.resolve(__dirname, '..');
const cursorMcpPath = path.join(rootDir, '.cursor', 'mcp.json');

// ANSI color codes for output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

// Helper function to log with colors
function logWithColor(color, message) {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// Check if cursor mcp.json exists
function checkCursorMcp() {
  logWithColor('cyan', '🔍 Checking Cursor MCP configuration...');
  
  if (!fs.existsSync(cursorMcpPath)) {
    logWithColor('red', '❌ Cursor MCP configuration file not found at: ' + cursorMcpPath);
    return false;
  }
  
  try {
    const mcpConfig = JSON.parse(fs.readFileSync(cursorMcpPath, 'utf8'));
    
    if (!mcpConfig.mcpServers || !mcpConfig.mcpServers.codacy) {
      logWithColor('red', '❌ Codacy MCP server not configured in Cursor MCP configuration.');
      return false;
    }
    
    const codacyConfig = mcpConfig.mcpServers.codacy;
    
    if (!codacyConfig.env || !codacyConfig.env.CODACY_ACCOUNT_TOKEN) {
      logWithColor('red', '❌ Codacy account token not found in Cursor MCP configuration.');
      return false;
    }
    
    if (codacyConfig.env.CODACY_ACCOUNT_TOKEN === '{$CODACY_ACCOUNT_TOKEN}') {
      logWithColor('red', '❌ Codacy account token is a placeholder, not a real token.');
      return false;
    }
    
    logWithColor('green', '✅ Cursor MCP configuration looks good!');
    return true;
  } catch (error) {
    logWithColor('red', `❌ Error parsing Cursor MCP configuration: ${error.message}`);
    return false;
  }
}

// Test if Codacy MCP server can be started
function testCodacyMcp() {
  return new Promise((resolve) => {
    logWithColor('cyan', '🔍 Testing Codacy MCP server...');
    
    try {
      const mcpConfig = JSON.parse(fs.readFileSync(cursorMcpPath, 'utf8'));
      const codacyConfig = mcpConfig.mcpServers.codacy;
      
      const command = codacyConfig.command || 'npx';
      const args = codacyConfig.args || ['-y', '@codacy/codacy-mcp'];
      const env = {
        ...process.env,
        ...codacyConfig.env
      };
      
      logWithColor('blue', `📋 Running command: ${command} ${args.join(' ')}`);
      
      const mcpProcess = spawn(command, args, {
        env,
        stdio: ['ignore', 'pipe', 'pipe']
      });
      
      let output = '';
      let errorOutput = '';
      
      mcpProcess.stdout.on('data', (data) => {
        output += data.toString();
      });
      
      mcpProcess.stderr.on('data', (data) => {
        errorOutput += data.toString();
      });
      
      // Set a timeout to kill the process after 10 seconds
      const timeout = setTimeout(() => {
        mcpProcess.kill();
        logWithColor('yellow', '⚠️ Codacy MCP server test timed out after 10 seconds.');
        logWithColor('green', '✅ This is normal for long-running servers.');
        
        if (output.includes('Server started') || output.includes('Codacy')) {
          logWithColor('green', '✅ Codacy MCP server started successfully!');
          resolve(true);
        } else {
          logWithColor('red', '❌ Could not verify Codacy MCP server started correctly.');
          logWithColor('yellow', 'Output:');
          console.log(output);
          logWithColor('yellow', 'Error output:');
          console.log(errorOutput);
          resolve(false);
        }
      }, 10000);
      
      mcpProcess.on('close', (code) => {
        clearTimeout(timeout);
        
        if (code === 0) {
          logWithColor('green', '✅ Codacy MCP server exited successfully.');
          resolve(true);
        } else {
          logWithColor('red', `❌ Codacy MCP server exited with code ${code}.`);
          logWithColor('yellow', 'Output:');
          console.log(output);
          logWithColor('yellow', 'Error output:');
          console.log(errorOutput);
          resolve(false);
        }
      });
    } catch (error) {
      logWithColor('red', `❌ Error starting Codacy MCP server: ${error.message}`);
      resolve(false);
    }
  });
}

// Check if Codacy CLI is installed
function checkCodacyCli() {
  return new Promise((resolve) => {
    logWithColor('cyan', '🔍 Checking Codacy CLI installation...');
    
    const cliProcess = spawn('bash', [path.join(__dirname, 'codacy-cli.sh'), 'version'], {
      stdio: ['ignore', 'pipe', 'pipe']
    });
    
    let output = '';
    let errorOutput = '';
    
    cliProcess.stdout.on('data', (data) => {
      output += data.toString();
    });
    
    cliProcess.stderr.on('data', (data) => {
      errorOutput += data.toString();
    });
    
    cliProcess.on('close', (code) => {
      if (code === 0) {
        logWithColor('green', '✅ Codacy CLI is installed and working.');
        logWithColor('green', output.trim());
        resolve(true);
      } else {
        logWithColor('red', '❌ Codacy CLI check failed.');
        logWithColor('yellow', 'Error output:');
        console.log(errorOutput);
        resolve(false);
      }
    });
  });
}

// Main function
async function main() {
  logWithColor('magenta', '🧊 ICE-WEBAPP Codacy MCP & CLI Test');
  logWithColor('magenta', '=====================================');
  
  // Check Cursor MCP configuration
  const mcpConfigOk = checkCursorMcp();
  
  if (!mcpConfigOk) {
    logWithColor('yellow', '⚠️ Cursor MCP configuration needs to be fixed.');
    logWithColor('cyan', '📝 Run the setup script: bash tools/codacy-cli-setup.sh');
    return;
  }
  
  // Check if Codacy CLI script exists
  if (!fs.existsSync(path.join(__dirname, 'codacy-cli.sh'))) {
    logWithColor('yellow', '⚠️ Codacy CLI script not found.');
    logWithColor('cyan', '📝 Run the setup script: bash tools/codacy-cli-setup.sh');
    return;
  }
  
  // Check Codacy CLI
  const cliOk = await checkCodacyCli();
  
  if (!cliOk) {
    logWithColor('yellow', '⚠️ Codacy CLI needs to be installed or fixed.');
    logWithColor('cyan', '📝 Run the setup script: bash tools/codacy-cli-setup.sh');
    return;
  }
  
  // Test Codacy MCP server
  const mcpOk = await testCodacyMcp();
  
  if (!mcpOk) {
    logWithColor('yellow', '⚠️ Codacy MCP server test failed.');
    logWithColor('cyan', '📝 Check your Codacy account token and retry.');
    return;
  }
  
  logWithColor('green', '✅ All Codacy components are working correctly!');
  logWithColor('cyan', '📝 To run Codacy analysis, use:');
  logWithColor('yellow', '   tools/codacy-cli.sh analyze --tool eslint src/your-file.tsx');
  logWithColor('cyan', '📝 In Cursor, the Codacy MCP server should now be available for AI commands.');
}

// Run the main function
main().catch((error) => {
  logWithColor('red', `❌ Unexpected error: ${error.message}`);
  process.exit(1);
}); 