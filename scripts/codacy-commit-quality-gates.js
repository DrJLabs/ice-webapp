#!/usr/bin/env node

/**
 * Script to configure Codacy quality gates for commits in the ICE-WEBAPP project
 * 
 * This script configures best practices for React applications:
 * 1. Zero tolerance for security issues
 * 2. Strict limits on new issues (max 2 of Error level or above)
 * 3. Allow small coverage drops (-0.1%) to avoid blocking refactoring
 * 4. Limits on complexity and duplication
 * 
 * Note: diffCoverageThreshold is not available for commits, only for PRs
 * 
 * @global require, process, console, __dirname
 */

/* eslint-env node */
/* eslint-disable no-undef */

const fs = require('fs');
const path = require('path');
const https = require('https');

// Load Codacy tokens from env file
require('dotenv').config({ path: path.join(__dirname, '../tools/.codacy-tokens') });

// Configuration values
const CONFIG = {
  ACCOUNT_TOKEN: process.env.CODACY_ACCOUNT_TOKEN,
  PROJECT_TOKEN: process.env.CODACY_PROJECT_TOKEN,
  API_BASE_URL: 'api.codacy.com',
  // Get these values from your repository URL
  PROVIDER: 'gh', // Use 'gh' for GitHub, 'gl' for GitLab, 'bb' for Bitbucket
  ORGANIZATION: 'DrJLabs', // Set to your GitHub organization or username
  REPOSITORY: 'ice-webapp', // Set to your repository name
};

// Extract organization and repository from Git remote URL
function extractRepoInfoFromGit() {
  try {
    const gitConfigPath = path.join(process.cwd(), '.git', 'config');
    if (fs.existsSync(gitConfigPath)) {
      const gitConfig = fs.readFileSync(gitConfigPath, 'utf8');
      const remoteUrlMatch = gitConfig.match(/url\s*=\s*(?:https:\/\/github\.com\/|git@github\.com:)([^/]+)\/([^.]+)(?:\.git)?/);
      
      if (remoteUrlMatch && remoteUrlMatch.length >= 3) {
        CONFIG.ORGANIZATION = remoteUrlMatch[1];
        CONFIG.REPOSITORY = remoteUrlMatch[2];
        console.log(`✅ Detected repository: ${CONFIG.ORGANIZATION}/${CONFIG.REPOSITORY}`);
      }
    }
  } catch (error) {
    console.error('Error extracting repository info from Git:', error.message);
  }
}

// Make API request to Codacy
function makeApiRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: CONFIG.API_BASE_URL,
      path: `/api/v3${path}`,
      method: method,
      headers: {
        'api-token': CONFIG.ACCOUNT_TOKEN,
        'Content-Type': 'application/json',
      },
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            resolve(responseData ? JSON.parse(responseData) : {});
          } catch (e) {
            resolve(responseData);
          }
        } else {
          reject(new Error(`Request failed with status code ${res.statusCode}: ${responseData}`));
        }
      });
    });
    
    req.on('error', (error) => {
      reject(error);
    });
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

// Configure commit quality gates based on best practices
async function configureCommitQualityGates() {
  try {
    console.log('🔍 Getting current commit quality gates configuration...');
    
    // Use the organization/repository API for commit gates
    const orgRepoEndpoint = `/${CONFIG.PROVIDER}/organizations/${CONFIG.ORGANIZATION}/repositories/${CONFIG.REPOSITORY}/settings/quality/commit-gates`;
    
    let currentSettings = {};
    try {
      currentSettings = await makeApiRequest('GET', orgRepoEndpoint);
      console.log('✅ Retrieved current commit quality gate settings');
      
      if (Object.keys(currentSettings).length > 0) {
        console.log('Current commit settings overview:');
        Object.entries(currentSettings).forEach(([key, value]) => {
          if (value && typeof value === 'object' && value.enabled !== undefined) {
            console.log(`  ${key}: ${value.enabled ? 'enabled' : 'disabled'}${value.value !== undefined ? `, value: ${value.value}` : ''}`);
          }
        });
      }
    } catch (error) {
      console.log(`⚠️ Could not retrieve current commit settings: ${error.message}`);
      console.log('Will proceed with default configuration...');
    }
    
    // Update with our recommended settings
    console.log('\n🔄 Updating commit quality gates to ICE-WEBAPP standards...');
    
    // Quality gate settings optimized for React applications
    const updatedSettings = {
      ...currentSettings,
      'security': { enabled: true, value: 0 },  // Zero tolerance for security issues
      'issues': { enabled: true, value: 2 },    // Max 2 new issues of Error severity
      'duplication': { enabled: true, value: 3 }, // Max 3 new duplicated blocks
      'complexity': { enabled: true, value: 4 }, // Max complexity of 4
      'coverage': { enabled: true, value: -0.1 }, // Allow tiny coverage drops
    };
    
    // Apply the updated settings
    const result = await makeApiRequest('PUT', orgRepoEndpoint, updatedSettings);
    
    console.log('✅ Commit quality gates updated successfully:');
    Object.entries(result).forEach(([key, value]) => {
      if (value && typeof value === 'object' && value.enabled !== undefined) {
        console.log(`  ${key}: ${value.enabled ? 'enabled' : 'disabled'}${value.value !== undefined ? `, value: ${value.value}` : ''}`);
      }
    });
    
    return true;
  } catch (error) {
    console.error('❌ Failed to configure commit quality gates:', error.message);
    
    // Provide more helpful error messaging
    if (error.message.includes('404')) {
      console.error('\n💡 Troubleshooting suggestions:');
      console.error('1. Verify the repository is added to Codacy at: https://app.codacy.com');
      console.error('2. Check that your CODACY_ACCOUNT_TOKEN has the right permissions');
      console.error('3. Ensure the organization/repository names are correct');
      console.error(`   Current: ${CONFIG.ORGANIZATION}/${CONFIG.REPOSITORY}`);
    } else if (error.message.includes('401') || error.message.includes('403')) {
      console.error('\n💡 Authentication issue:');
      console.error('1. Verify your CODACY_ACCOUNT_TOKEN is valid and not expired');
      console.error('2. Check token permissions include quality gate management');
    }
    
    if (!CONFIG.ACCOUNT_TOKEN || !CONFIG.PROJECT_TOKEN) {
      console.error('\n⚠️ Codacy tokens not found or invalid!');
      console.error('Please ensure you have set up the following:');
      console.error('1. Create a tools/.codacy-tokens file with:');
      console.error('   export CODACY_ACCOUNT_TOKEN="your-account-token"');
      console.error('   export CODACY_PROJECT_TOKEN="your-project-token"');
      console.error('2. Or set these environment variables directly');
    }
    
    return false;
  }
}

// Main function
async function main() {
  console.log('🧊 ICE-WEBAPP Codacy Commit Quality Gates Setup');
  console.log('=======================================');
  
  // Extract repo info from Git if not already set
  if (!CONFIG.ORGANIZATION || CONFIG.ORGANIZATION === '') {
    extractRepoInfoFromGit();
  }
  
  // Validate configuration
  if (!CONFIG.ACCOUNT_TOKEN) {
    console.error('❌ Missing CODACY_ACCOUNT_TOKEN. Please set it in your environment or tools/.codacy-tokens file.');
    process.exit(1);
  }
  
  if (!CONFIG.PROJECT_TOKEN) {
    console.error('❌ Missing CODACY_PROJECT_TOKEN. Please set it in your environment or tools/.codacy-tokens file.');
    process.exit(1);
  }
  
  if (!CONFIG.ORGANIZATION || !CONFIG.REPOSITORY) {
    console.error('❌ Could not determine organization/repository information.');
    console.error('Please verify your Git remote configuration or update the CONFIG object.');
    process.exit(1);
  }
  
  try {
    const success = await configureCommitQualityGates();
    if (success) {
      console.log('\n✅ Commit quality gates configuration complete!');
      console.log('Quality standards now enforced:');
      console.log('- Zero tolerance for security issues');
      console.log('- Maximum 2 new issues of Error severity');
      console.log('- Reasonable limits on complexity and duplication');
      console.log('- Allows minimal coverage drops to enable refactoring');
      process.exit(0);
    } else {
      console.error('\n❌ Failed to configure commit quality gates.');
      process.exit(1);
    }
  } catch (error) {
    console.error('\n❌ An unexpected error occurred:', error.message);
    process.exit(1);
  }
}

// Run the script
main();
