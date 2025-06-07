#!/usr/bin/env node

/**
 * verify-codacy-tools.js
 * Verifies that Codacy tools are correctly configured and available
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

function checkCodacyCli() {
  const workspacePath = process.cwd();
  const codacyCliPath = path.join(workspacePath, 'tools', 'codacy');
  
  console.log('Checking Codacy CLI...');
  
  if (!fs.existsSync(codacyCliPath)) {
    console.log('❌ Codacy CLI not found at:', codacyCliPath);
    return false;
  }
  
  try {
    const version = execSync(`${codacyCliPath} version`).toString();
    console.log('✅ Codacy CLI found:', version.split('\n')[2]);
    return true;
  } catch (err) {
    console.log('❌ Codacy CLI execution failed:', err.message);
    return false;
  }
}

function checkMcpConfig() {
  const workspacePath = process.cwd();
  const projectMcpPath = path.join(workspacePath, '.cursor', 'mcp.json');
  const globalMcpPath = path.join(os.homedir(), '.cursor', 'mcp.json');
  
  console.log('\nChecking MCP configurations...');
  
  let hasIssues = false;
  
  // Check project config
  if (fs.existsSync(projectMcpPath)) {
    try {
      const config = JSON.parse(fs.readFileSync(projectMcpPath, 'utf8'));
      
      if (!config.mcpServers?.codacy) {
        console.log('❌ Project MCP config missing Codacy server');
        hasIssues = true;
      } else if (!config.mcpServers.codacy.env?.CODACY_CLI_PATH) {
        console.log('❌ Project MCP config missing CODACY_CLI_PATH');
        hasIssues = true;
      } else {
        console.log('✅ Project MCP config OK');
      }
    } catch (err) {
      console.log('❌ Error reading project MCP config:', err.message);
      hasIssues = true;
    }
  } else {
    console.log('❌ Project MCP config not found');
    hasIssues = true;
  }
  
  // Check global config
  if (fs.existsSync(globalMcpPath)) {
    try {
      const config = JSON.parse(fs.readFileSync(globalMcpPath, 'utf8'));
      
      if (!config.mcpServers?.codacy) {
        console.log('❌ Global MCP config missing Codacy server');
        hasIssues = true;
      } else {
        console.log('✅ Global MCP config OK');
      }
    } catch (err) {
      console.log('❌ Error reading global MCP config:', err.message);
      hasIssues = true;
    }
  } else {
    console.log('❌ Global MCP config not found');
    hasIssues = true;
  }
  
  return !hasIssues;
}

function checkDuplicateConfigs() {
  const workspacePath = process.cwd();
  const duplicatePath = path.join(workspacePath, '~', '.cursor');
  
  console.log('\nChecking for duplicate configurations...');
  
  if (fs.existsSync(duplicatePath)) {
    console.log('❌ Found duplicate configuration at:', duplicatePath);
    return false;
  }
  
  console.log('✅ No duplicate configurations found');
  return true;
}

function checkPhantomServers() {
  console.log('\nChecking for phantom/ghost servers...');
  
  // We can't directly check for phantom servers since they're in Cursor's internal state
  // But we can look for common issues that cause them
  
  const cursorConfigDir = path.join(os.homedir(), '.config', 'Cursor');
  if (fs.existsSync(cursorConfigDir)) {
    console.log('✅ Found Cursor config directory:', cursorConfigDir);
    
    // Check for MCP related files in globalStorage
    const globalStoragePath = path.join(cursorConfigDir, 'User', 'globalStorage');
    if (fs.existsSync(globalStoragePath)) {
      let foundCodacyFiles = false;
      
      try {
        const items = fs.readdirSync(globalStoragePath);
        for (const item of items) {
          if (item.toLowerCase().includes('codacy') || item.toLowerCase().includes('mcp')) {
            console.log('⚠️ Found potential Codacy/MCP file in globalStorage:', item);
            foundCodacyFiles = true;
          }
        }
        
        if (!foundCodacyFiles) {
          console.log('✅ No Codacy/MCP files found in globalStorage');
        }
      } catch (err) {
        console.log('❌ Error checking globalStorage:', err.message);
      }
    }
  }
  
  return true; // We don't know for sure, so return true
}

function checkEnvironmentVariables() {
  console.log('\nChecking environment variables...');
  
  const workspacePath = process.cwd();
  const codacyCliPath = path.join(workspacePath, 'tools', 'codacy');
  
  // Check if CODACY_CLI_PATH is in environment
  if (process.env.CODACY_CLI_PATH) {
    console.log('✅ CODACY_CLI_PATH environment variable set to:', process.env.CODACY_CLI_PATH);
    
    if (process.env.CODACY_CLI_PATH !== codacyCliPath) {
      console.log('⚠️ Environment variable points to different location than workspace CLI');
    }
  } else {
    console.log('❌ CODACY_CLI_PATH environment variable not set');
  }
  
  // Check if tools directory is in PATH
  const toolsDir = path.dirname(codacyCliPath);
  if (process.env.PATH && process.env.PATH.includes(toolsDir)) {
    console.log('✅ Tools directory is in PATH');
  } else {
    console.log('❌ Tools directory not in PATH');
  }
  
  return process.env.CODACY_CLI_PATH !== undefined;
}

function main() {
  console.log('🔍 Verifying Codacy tools configuration...\n');
  
  const cliOk = checkCodacyCli();
  const mcpOk = checkMcpConfig();
  const dupsOk = checkDuplicateConfigs();
  const phantomOk = checkPhantomServers();
  const envOk = checkEnvironmentVariables();
  
  console.log('\n📊 Summary:');
  console.log(`Codacy CLI: ${cliOk ? '✅ OK' : '❌ Issues found'}`);
  console.log(`MCP Config: ${mcpOk ? '✅ OK' : '❌ Issues found'}`);
  console.log(`Duplicates: ${dupsOk ? '✅ OK' : '❌ Issues found'}`);
  console.log(`Env Variables: ${envOk ? '✅ OK' : '❌ Issues found'}`);
  
  if (cliOk && mcpOk && dupsOk && envOk) {
    console.log('\n🎉 All checks passed! Codacy tools should be working correctly.');
    console.log('If you still have issues, please try restarting Cursor.');
  } else {
    console.log('\n⚠️ Some issues were found. Run the fix-codacy-cursor-integration.sh script to resolve them.');
  }
}

main(); 