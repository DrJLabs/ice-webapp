#!/usr/bin/env node

/**
 * fix-codacy-cli-detection.js
 * Ensures Cursor can detect the Codacy CLI by fixing configuration and environment issues
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

// Main function
async function main() {
  console.log('🔍 Fixing Codacy CLI detection issues...');
  
  const workspacePath = process.cwd();
  const codacyCliPath = path.join(workspacePath, 'tools', 'codacy');
  
  // Check if CLI exists
  if (!fs.existsSync(codacyCliPath)) {
    console.error('❌ Codacy CLI not found at:', codacyCliPath);
    console.log('Attempting to download...');
    
    try {
      // Create tools directory if it doesn't exist
      fs.mkdirSync(path.dirname(codacyCliPath), { recursive: true });
      
      // Download Codacy CLI
      execSync(`curl -fsSL https://cli.codacy.com/download/linux -o ${codacyCliPath}`);
      execSync(`chmod +x ${codacyCliPath}`);
      
      console.log('✅ Downloaded Codacy CLI');
    } catch (err) {
      console.error('Failed to download Codacy CLI:', err.message);
      process.exit(1);
    }
  }
  
  // Make executable
  try {
    fs.chmodSync(codacyCliPath, '755');
  } catch (err) {
    console.warn('Warning: Could not change CLI permissions:', err.message);
  }
  
  // Verify CLI works
  try {
    const version = execSync(`${codacyCliPath} version`).toString();
    console.log('✅ Codacy CLI found:', version.split('\n')[2]);
  } catch (err) {
    console.error('❌ Codacy CLI execution failed:', err.message);
    process.exit(1);
  }
  
  // Fix project MCP config
  const projectMcpPath = path.join(workspacePath, '.cursor', 'mcp.json');
  
  // Ensure directory exists
  if (!fs.existsSync(path.dirname(projectMcpPath))) {
    fs.mkdirSync(path.dirname(projectMcpPath), { recursive: true });
  }
  
  // Get CLI version
  let cliVersion = '';
  try {
    cliVersion = execSync(`${codacyCliPath} version | grep Version | awk '{print $2}'`).toString().trim();
  } catch (err) {
    console.warn('Warning: Could not get CLI version:', err.message);
  }
  
  // Create proper config
  const projectConfig = {
    mcpServers: {
      codacy: {
        command: 'npx',
        args: ['-y', '@codacy/codacy-mcp@latest'],
        env: {
          CODACY_CLI_PATH: codacyCliPath,
          PATH: `${path.dirname(codacyCliPath)}:${process.env.PATH}`
        }
      }
    }
  };
  
  // Add version if available
  if (cliVersion) {
    projectConfig.mcpServers.codacy.env.CODACY_CLI_VERSION = cliVersion;
  }
  
  fs.writeFileSync(projectMcpPath, JSON.stringify(projectConfig, null, 2));
  console.log('✅ Fixed project MCP configuration at:', projectMcpPath);
  
  // Fix global MCP config
  const globalMcpPath = path.join(os.homedir(), '.cursor', 'mcp.json');
  
  // Ensure directory exists
  if (!fs.existsSync(path.dirname(globalMcpPath))) {
    fs.mkdirSync(path.dirname(globalMcpPath), { recursive: true });
  }
  
  // Create proper config (lighter version for global)
  const globalConfig = {
    mcpServers: {
      codacy: {
        command: 'npx',
        args: ['-y', '@codacy/codacy-mcp@latest']
      }
    }
  };
  
  fs.writeFileSync(globalMcpPath, JSON.stringify(globalConfig, null, 2));
  console.log('✅ Fixed global MCP configuration at:', globalMcpPath);
  
  // Fix any duplicate configurations
  const duplicatePath = path.join(workspacePath, '~', '.cursor', 'mcp.json');
  const duplicateDir = path.dirname(duplicatePath);
  
  if (fs.existsSync(duplicateDir)) {
    console.log('🧹 Cleaning up duplicate configuration at:', duplicateDir);
    try {
      fs.rmSync(path.dirname(duplicateDir), { recursive: true, force: true });
    } catch (err) {
      console.warn('Warning: Could not remove duplicate directory:', err.message);
    }
  }
  
  // Create a symlink to make CLI globally available
  const binDir = path.join(os.homedir(), 'bin');
  const symlink = path.join(binDir, 'codacy');
  
  try {
    // Create bin directory if it doesn't exist
    if (!fs.existsSync(binDir)) {
      fs.mkdirSync(binDir, { recursive: true });
    }
    
    // Remove existing symlink if it exists
    if (fs.existsSync(symlink)) {
      fs.unlinkSync(symlink);
    }
    
    // Create new symlink
    fs.symlinkSync(codacyCliPath, symlink);
    console.log('✅ Created symlink to Codacy CLI at:', symlink);
  } catch (err) {
    console.warn('Warning: Could not create symlink:', err.message);
  }
  
  // Add environment variables to shell profile
  const profiles = [
    path.join(os.homedir(), '.bashrc'),
    path.join(os.homedir(), '.zshrc'),
    path.join(os.homedir(), '.profile')
  ];
  
  const envSetup = `
# Codacy CLI configuration
export CODACY_CLI_PATH="${codacyCliPath}"
export PATH="${path.dirname(codacyCliPath)}:$PATH"
`;
  
  let profileUpdated = false;
  
  for (const profile of profiles) {
    if (fs.existsSync(profile)) {
      try {
        const content = fs.readFileSync(profile, 'utf8');
        
        if (!content.includes('CODACY_CLI_PATH')) {
          fs.appendFileSync(profile, envSetup);
          console.log('✅ Added environment variables to:', profile);
          profileUpdated = true;
        }
      } catch (err) {
        console.warn(`Warning: Could not update ${profile}:`, err.message);
      }
    }
  }
  
  if (!profileUpdated) {
    console.log('⚠️ Could not update any shell profiles. Please add these lines manually:');
    console.log(envSetup);
  }
  
  console.log('✅ Codacy CLI detection fixes complete');
  console.log('ℹ️  Please restart Cursor for the changes to take effect');
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
}); 