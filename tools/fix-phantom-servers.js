#!/usr/bin/env node

/**
 * fix-phantom-servers.js
 * 
 * A specialized script to fix phantom/ghost MCP servers in Cursor
 * This focuses specifically on removing orphaned server configurations
 * that may persist in Cursor's internal state
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

console.log('🧊 ICE-WEBAPP: Fixing Phantom MCP Servers');
console.log('=======================================');

// Find all mcp.json files
function findAllMcpConfigs() {
  const configs = [];
  
  try {
    // Common locations
    const locations = [
      path.join(os.homedir(), '.cursor', 'mcp.json'),
      path.join(process.cwd(), '.cursor', 'mcp.json'),
      path.join(process.cwd(), '~', '.cursor', 'mcp.json'),
    ];
    
    // Add any from Cursor config directory
    const cursorConfigDir = path.join(os.homedir(), '.config', 'Cursor');
    if (fs.existsSync(cursorConfigDir)) {
      try {
        // Use a safer method to find files
        const findCmd = `find "${cursorConfigDir}" -name "mcp*.json" 2>/dev/null || echo ""`;
        const output = execSync(findCmd, { shell: true }).toString().trim();
        
        if (output) {
          const files = output.split('\n');
          files.forEach(file => {
            if (file) locations.push(file);
          });
        }
      } catch (err) {
        console.log('Warning: Error searching Cursor config directory:', err.message);
      }
    }
    
    // Filter out non-existent files
    locations.forEach(loc => {
      if (fs.existsSync(loc)) {
        configs.push(loc);
      }
    });
    
    return configs;
  } catch (err) {
    console.error('Error finding MCP configs:', err.message);
    return [];
  }
}

// Clean a specific MCP config file
function cleanMcpConfig(configPath) {
  console.log(`Cleaning config: ${configPath}`);
  
  try {
    const content = fs.readFileSync(configPath, 'utf8');
    let config;
    
    try {
      config = JSON.parse(content);
    } catch (err) {
      console.error(`Error parsing JSON in ${configPath}:`, err.message);
      return false;
    }
    
    // Check if there's a mcpServers property
    if (!config.mcpServers) {
      console.log(`No mcpServers in ${configPath}`);
      return false;
    }
    
    // Count the number of servers before cleaning
    const beforeCount = Object.keys(config.mcpServers).length;
    
    // Only keep the codacy server if it exists
    if (config.mcpServers.codacy) {
      const codacyServer = config.mcpServers.codacy;
      
      // Reset the mcpServers object to only contain the codacy server
      config.mcpServers = { codacy: codacyServer };
      
      // Ensure the environment is properly set for project-specific config
      if (configPath.includes(process.cwd())) {
        const codacyCliPath = path.join(process.cwd(), 'tools', 'codacy');
        
        if (fs.existsSync(codacyCliPath)) {
          config.mcpServers.codacy.env = {
            ...(config.mcpServers.codacy.env || {}),
            CODACY_CLI_PATH: codacyCliPath,
            PATH: `${path.dirname(codacyCliPath)}:${process.env.PATH}`
          };
        }
      }
    } else {
      // If no codacy server, create one
      config.mcpServers = {
        codacy: {
          command: 'npx',
          args: ['-y', '@codacy/codacy-mcp@latest']
        }
      };
      
      // Add environment for project-specific config
      if (configPath.includes(process.cwd())) {
        const codacyCliPath = path.join(process.cwd(), 'tools', 'codacy');
        
        if (fs.existsSync(codacyCliPath)) {
          config.mcpServers.codacy.env = {
            CODACY_CLI_PATH: codacyCliPath,
            PATH: `${path.dirname(codacyCliPath)}:${process.env.PATH}`
          };
        }
      }
    }
    
    // Count the number of servers after cleaning
    const afterCount = Object.keys(config.mcpServers).length;
    
    // Write the updated config
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
    
    if (beforeCount !== afterCount) {
      console.log(`✅ Removed ${beforeCount - afterCount} phantom servers from ${configPath}`);
      return true;
    } else {
      console.log(`✅ No phantom servers found in ${configPath}`);
      return false;
    }
  } catch (err) {
    console.error(`Error cleaning ${configPath}:`, err.message);
    return false;
  }
}

// Clean up Cursor's globalStorage
function cleanGlobalStorage() {
  const cursorConfigDir = path.join(os.homedir(), '.config', 'Cursor');
  if (!fs.existsSync(cursorConfigDir)) {
    console.log('Cursor config directory not found');
    return false;
  }
  
  const globalStoragePath = path.join(cursorConfigDir, 'User', 'globalStorage');
  if (!fs.existsSync(globalStoragePath)) {
    console.log('GlobalStorage directory not found');
    return false;
  }
  
  console.log('Cleaning Cursor globalStorage...');
  
  let cleaned = false;
  
  try {
    const items = fs.readdirSync(globalStoragePath);
    
    for (const item of items) {
      if (item.toLowerCase().includes('codacy') || item.toLowerCase().includes('mcp')) {
        const itemPath = path.join(globalStoragePath, item);
        
        console.log(`Found item: ${itemPath}`);
        
        try {
          if (fs.statSync(itemPath).isDirectory()) {
            fs.rmSync(itemPath, { recursive: true, force: true });
            console.log(`✅ Removed directory: ${itemPath}`);
          } else {
            fs.unlinkSync(itemPath);
            console.log(`✅ Removed file: ${itemPath}`);
          }
          
          cleaned = true;
        } catch (err) {
          console.error(`Error removing ${itemPath}:`, err.message);
        }
      }
    }
  } catch (err) {
    console.error('Error reading globalStorage:', err.message);
  }
  
  return cleaned;
}

// Clean workspaceStorage
function cleanWorkspaceStorage() {
  const cursorConfigDir = path.join(os.homedir(), '.config', 'Cursor');
  if (!fs.existsSync(cursorConfigDir)) {
    return false;
  }
  
  const workspaceStoragePath = path.join(cursorConfigDir, 'User', 'workspaceStorage');
  if (!fs.existsSync(workspaceStoragePath)) {
    return false;
  }
  
  console.log('Cleaning Cursor workspaceStorage...');
  
  let cleaned = false;
  
  try {
    const workspaces = fs.readdirSync(workspaceStoragePath);
    
    for (const workspace of workspaces) {
      const workspacePath = path.join(workspaceStoragePath, workspace);
      
      if (fs.statSync(workspacePath).isDirectory()) {
        // Look for mcp cache files
        try {
          const files = fs.readdirSync(workspacePath);
          
          for (const file of files) {
            if (file.toLowerCase().includes('mcp') || file.toLowerCase().includes('codacy')) {
              const filePath = path.join(workspacePath, file);
              
              console.log(`Found workspace cache: ${filePath}`);
              
              try {
                if (fs.statSync(filePath).isDirectory()) {
                  fs.rmSync(filePath, { recursive: true, force: true });
                  console.log(`✅ Removed directory: ${filePath}`);
                } else {
                  fs.unlinkSync(filePath);
                  console.log(`✅ Removed file: ${filePath}`);
                }
                
                cleaned = true;
              } catch (err) {
                console.error(`Error removing ${filePath}:`, err.message);
              }
            }
          }
        } catch (err) {
          // Ignore
        }
      }
    }
  } catch (err) {
    console.error('Error reading workspaceStorage:', err.message);
  }
  
  return cleaned;
}

// Remove duplicate configuration in project
function removeDuplicateConfig() {
  const duplicatePath = path.join(process.cwd(), '~', '.cursor');
  
  if (fs.existsSync(duplicatePath)) {
    console.log(`Found duplicate configuration at ${duplicatePath}`);
    
    try {
      fs.rmSync(duplicatePath, { recursive: true, force: true });
      console.log(`✅ Removed duplicate configuration at ${duplicatePath}`);
      return true;
    } catch (err) {
      console.error(`Error removing duplicate configuration:`, err.message);
    }
  }
  
  return false;
}

// Main function
function main() {
  try {
    const mcpConfigs = findAllMcpConfigs();
    console.log(`Found ${mcpConfigs.length} MCP configuration files`);
    
    let configsFixed = 0;
    
    // Clean each config
    for (const config of mcpConfigs) {
      if (cleanMcpConfig(config)) {
        configsFixed++;
      }
    }
    
    // Clean global storage
    const globalStorageCleaned = cleanGlobalStorage();
    
    // Clean workspace storage
    const workspaceStorageCleaned = cleanWorkspaceStorage();
    
    // Remove duplicate config
    const duplicateRemoved = removeDuplicateConfig();
    
    // Check if we fixed anything
    if (configsFixed > 0 || globalStorageCleaned || workspaceStorageCleaned || duplicateRemoved) {
      console.log('✅ Phantom server issues fixed!');
      console.log('Please restart Cursor for the changes to take effect.');
    } else {
      console.log('No phantom server issues found.');
    }
  } catch (err) {
    console.error('Error in main function:', err);
  }
}

// Run the main function
main(); 