#!/usr/bin/env node

/**
 * Test script for Codacy MCP server CLI path resolution
 * This script checks if the Codacy MCP server can find the Codacy CLI
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

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

// Get the workspace root directory
const rootDir = path.resolve(__dirname, '..');
const mcpConfigPath = path.join(rootDir, '.cursor', 'mcp.json');

// Check if MCP config exists
if (!fs.existsSync(mcpConfigPath)) {
  logWithColor('red', '❌ MCP configuration file not found at: ' + mcpConfigPath);
  process.exit(1);
}

// Read MCP config
const mcpConfig = JSON.parse(fs.readFileSync(mcpConfigPath, 'utf8'));
const codacyConfig = mcpConfig.mcpServers?.codacy;

if (!codacyConfig) {
  logWithColor('red', '❌ Codacy MCP server not configured in MCP configuration.');
  process.exit(1);
}

// Get CLI path from config
const cliPath = codacyConfig.env?.CODACY_CLI_PATH || '/home/drj/ice-webapp/tools/codacy';

// Check if CLI exists at configured path
if (!fs.existsSync(cliPath)) {
  logWithColor('red', `❌ Codacy CLI not found at configured path: ${cliPath}`);
  process.exit(1);
}

logWithColor('green', `✅ Codacy CLI found at: ${cliPath}`);

// Start MCP server with debugging
logWithColor('cyan', '🔍 Starting Codacy MCP server with debugging...');

const env = {
  ...process.env,
  ...codacyConfig.env,
  DEBUG: 'codacy:*'
};

const command = codacyConfig.command || 'npx';
const args = codacyConfig.args || ['-y', '@codacy/codacy-mcp'];

logWithColor('blue', `📋 Running command: ${command} ${args.join(' ')} with DEBUG=codacy:*`);

const mcpProcess = spawn(command, args, {
  env,
  stdio: ['ignore', 'pipe', 'pipe']
});

let output = '';
let errorOutput = '';

mcpProcess.stdout.on('data', (data) => {
  const text = data.toString();
  output += text;
  console.log(text);
});

mcpProcess.stderr.on('data', (data) => {
  const text = data.toString();
  errorOutput += text;
  console.log(text);
});

// Set a timeout to kill the process after 15 seconds
setTimeout(() => {
  logWithColor('yellow', '⏱️ Stopping MCP server after 15 seconds...');
  mcpProcess.kill();
  
  // Check if there were any CLI path related messages
  if (output.includes('CLI path') || errorOutput.includes('CLI path')) {
    logWithColor('green', '✅ Found CLI path references in the output.');
  } else {
    logWithColor('yellow', '⚠️ No CLI path references found in the output.');
  }
  
  process.exit(0);
}, 15000);

// Handle process exit
mcpProcess.on('close', (code) => {
  if (code !== null && code !== 0) {
    logWithColor('red', `❌ MCP server exited with code ${code}.`);
    process.exit(1);
  }
}); 