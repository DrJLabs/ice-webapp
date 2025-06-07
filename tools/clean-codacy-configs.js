#!/usr/bin/env node

/**
 * Clean Codacy Configurations
 * 
 * This script searches for and cleans up duplicate Codacy server configurations
 * in Cursor settings files across the system.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const os = require('os');

// ANSI color codes
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

// Find all mcp.json files in the system
function findMcpJsonFiles() {
  try {
    const homeDir = os.homedir();
    const result = execSync(`find ${homeDir} -name "mcp.json" -type f 2>/dev/null | grep -i cursor`, { encoding: 'utf8' });
    return result.trim().split('\n').filter(Boolean);
  } catch (error) {
    logWithColor('yellow', '⚠️ Error finding mcp.json files, falling back to known locations');
    
    const homeDir = os.homedir();
    const knownLocations = [
      path.join(homeDir, '.cursor', 'mcp.json'),
      path.join(process.cwd(), '.cursor', 'mcp.json'),
      path.join(homeDir, 'cursor-backup-20250604', 'mcp.json'),
      path.join(homeDir, 'cursorbackup', 'mcp.json'),
    ];
    
    return knownLocations.filter(location => fs.existsSync(location));
  }
}

// Clean duplicate Codacy configurations from an mcp.json file
function cleanMcpJsonFile(filePath) {
  try {
    logWithColor('cyan', `🔍 Checking ${filePath}`);
    
    if (!fs.existsSync(filePath)) {
      logWithColor('yellow', `⚠️ File does not exist: ${filePath}`);
      return false;
    }
    
    const fileContent = fs.readFileSync(filePath, 'utf8');
    let config;
    
    try {
      config = JSON.parse(fileContent);
    } catch (error) {
      logWithColor('red', `❌ Error parsing JSON in ${filePath}: ${error.message}`);
      return false;
    }
    
    if (!config.mcpServers) {
      logWithColor('yellow', `⚠️ No mcpServers found in ${filePath}`);
      return false;
    }
    
    // Check for multiple Codacy servers
    const codacyServers = Object.keys(config.mcpServers).filter(key => 
      key === 'codacy' || key.startsWith('codacy-') || key.includes('codacy')
    );
    
    if (codacyServers.length <= 1) {
      logWithColor('green', `✅ ${filePath} has ${codacyServers.length} Codacy servers - no cleanup needed`);
      return false;
    }
    
    logWithColor('yellow', `⚠️ Found ${codacyServers.length} Codacy servers in ${filePath}: ${codacyServers.join(', ')}`);
    
    // Keep only the 'codacy' server if it exists, otherwise keep the first one
    const serverToKeep = codacyServers.includes('codacy') ? 'codacy' : codacyServers[0];
    
    logWithColor('blue', `📝 Keeping server '${serverToKeep}' and removing others`);
    
    const newMcpServers = {};
    newMcpServers[serverToKeep] = config.mcpServers[serverToKeep];
    
    // If the server we're keeping doesn't have CLI path, try to get it from other servers
    if (!newMcpServers[serverToKeep].env?.CODACY_CLI_PATH) {
      for (const server of codacyServers) {
        if (server !== serverToKeep && config.mcpServers[server].env?.CODACY_CLI_PATH) {
          logWithColor('blue', `📝 Copying CLI path from '${server}' to '${serverToKeep}'`);
          newMcpServers[serverToKeep].env = newMcpServers[serverToKeep].env || {};
          newMcpServers[serverToKeep].env.CODACY_CLI_PATH = config.mcpServers[server].env.CODACY_CLI_PATH;
          break;
        }
      }
    }
    
    // Create new config with only the server we're keeping
    const newConfig = {
      ...config,
      mcpServers: newMcpServers
    };
    
    // Backup the original file
    const backupPath = `${filePath}.backup`;
    fs.writeFileSync(backupPath, fileContent);
    logWithColor('blue', `📝 Backed up original to ${backupPath}`);
    
    // Write the new config
    fs.writeFileSync(filePath, JSON.stringify(newConfig, null, 2));
    logWithColor('green', `✅ Updated ${filePath} with single Codacy server '${serverToKeep}'`);
    
    return true;
  } catch (error) {
    logWithColor('red', `❌ Error processing ${filePath}: ${error.message}`);
    return false;
  }
}

// Main function
async function main() {
  logWithColor('magenta', '🧊 ICE-WEBAPP Codacy Configuration Cleaner');
  logWithColor('magenta', '=========================================');
  
  // Find all mcp.json files
  const mcpJsonFiles = findMcpJsonFiles();
  
  if (mcpJsonFiles.length === 0) {
    logWithColor('yellow', '⚠️ No mcp.json files found');
    return;
  }
  
  logWithColor('blue', `📝 Found ${mcpJsonFiles.length} mcp.json files`);
  
  // Clean each file
  let cleanedCount = 0;
  
  for (const filePath of mcpJsonFiles) {
    const cleaned = cleanMcpJsonFile(filePath);
    if (cleaned) cleanedCount++;
  }
  
  if (cleanedCount === 0) {
    logWithColor('green', '✅ No files needed cleaning');
  } else {
    logWithColor('green', `✅ Cleaned ${cleanedCount} files`);
    logWithColor('cyan', '📝 Please restart Cursor for the changes to take effect');
  }
}

// Run the main function
main().catch(error => {
  logWithColor('red', `❌ Unexpected error: ${error.message}`);
  process.exit(1);
}); 