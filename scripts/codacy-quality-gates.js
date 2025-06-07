#!/usr/bin/env node

/**
 * Script to configure Codacy quality gates for the ICE-WEBAPP project
 * 
 * This script configures best practices for React applications:
 * 1. Zero tolerance for security issues
 * 2. Strict limits on new issues (max 2 of Error level or above)
 * 3. Reasonable code coverage requirements (minimum 70% diff coverage)
 * 4. Allow small coverage drops (-0.1%) to avoid blocking refactoring
 * 5. Limits on complexity and duplication
 * 
 * @global require, process, console, __dirname
 */

/* eslint-env node */

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
  ORGANIZATION: '', // Set to your GitHub organization or username
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
        console.log(`Detected repository: ${CONFIG.ORGANIZATION}/${CONFIG.REPOSITORY}`);
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

// Configure quality gates based on best practices
async function configureQualityGates() {
  try {
    // 1. Get current quality gates configuration
    console.log('🔍 Getting current quality gates configuration...');
    
    // Try using the Project API first (more reliable)
    const projectEndpoint = `/project/${CONFIG.PROJECT_TOKEN}/settings/quality/gates`;
    
    try {
      const currentSettings = await makeApiRequest('GET', projectEndpoint);
      console.log('Current quality gate settings:');
      Object.entries(currentSettings).forEach(([key, value]) => {
        if (value && typeof value === 'object') {
          console.log(`  ${key}: ${value.enabled ? 'enabled' : 'disabled'}, value: ${value.value}`);
        }
      });
      
      // 2. Update with our recommended settings
      console.log('\n🔄 Updating quality gates to ICE-WEBAPP standards...');
      
      // Quality gate settings optimized for React applications
      const updatedSettings = {
        ...currentSettings,
        'security': { enabled: true, value: 0 },  // Zero tolerance for security issues
        'issues': { enabled: true, value: 2 },    // Max 2 new issues of Error severity
        'duplication': { enabled: true, value: 3 }, // Max 3 new duplicated blocks
        'complexity': { enabled: true, value: 4 }, // Max complexity of 4
        'coverage': { enabled: true, value: -0.1 }, // Allow tiny coverage drops
        'diff_coverage': { enabled: true, value: 70 } // 70% coverage for changed code
      };
      
      // 3. Apply the updated settings
      const result = await makeApiRequest('PUT', projectEndpoint, updatedSettings);
      
      console.log('✅ Quality gates updated successfully:');
      Object.entries(result).forEach(([key, value]) => {
        if (value && typeof value === 'object') {
          console.log(`  ${key}: ${value.enabled ? 'enabled' : 'disabled'}, value: ${value.value}`);
        }
      });
      
      return true;
    } catch (error) {
      console.error('Error using project token API:', error.message);
      console.log('⚠️ Falling back to organization/repository API...');
      
      // Extract repo info from Git if not already set
      if (!CONFIG.ORGANIZATION) {
        extractRepoInfoFromGit();
      }
      
      if (!CONFIG.ORGANIZATION || !CONFIG.REPOSITORY) {
        throw new Error('Could not determine organization/repository. Please set them in the CONFIG object.');
      }
      
      // Try the organization/repository API
      const orgRepoEndpoint = `/${CONFIG.PROVIDER}/organizations/${CONFIG.ORGANIZATION}/repositories/${CONFIG.REPOSITORY}/settings/quality/gates`;
      
      const currentSettings = await makeApiRequest('GET', orgRepoEndpoint);
      console.log('Current quality gate settings:');
      Object.entries(currentSettings).forEach(([key, value]) => {
        if (value && typeof value === 'object') {
          console.log(`  ${key}: ${value.enabled ? 'enabled' : 'disabled'}, value: ${value.value}`);
        }
      });
      
      // Update with our recommended settings
      console.log('\n🔄 Updating quality gates to ICE-WEBAPP standards...');
      
      // Quality gate settings optimized for React applications
      const updatedSettings = {
        ...currentSettings,
        'security': { enabled: true, value: 0 },
        'issues': { enabled: true, value: 2 },
        'duplication': { enabled: true, value: 3 },
        'complexity': { enabled: true, value: 4 },
        'coverage': { enabled: true, value: -0.1 },
        'diff_coverage': { enabled: true, value: 70 }
      };
      
      // Apply the updated settings
      const result = await makeApiRequest('PUT', orgRepoEndpoint, updatedSettings);
      
      console.log('✅ Quality gates updated successfully:');
      Object.entries(result).forEach(([key, value]) => {
        if (value && typeof value === 'object') {
          console.log(`  ${key}: ${value.enabled ? 'enabled' : 'disabled'}, value: ${value.value}`);
        }
      });
      
      return true;
    }
  } catch (error) {
    console.error('❌ Failed to configure quality gates:', error.message);
    
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
  console.log('🧊 ICE-WEBAPP Codacy Quality Gates Setup');
  console.log('=======================================');
  
  // Validate configuration
  if (!CONFIG.ACCOUNT_TOKEN) {
    console.error('❌ Missing CODACY_ACCOUNT_TOKEN. Please set it in your environment or tools/.codacy-tokens file.');
    process.exit(1);
  }
  
  if (!CONFIG.PROJECT_TOKEN) {
    console.error('❌ Missing CODACY_PROJECT_TOKEN. Please set it in your environment or tools/.codacy-tokens file.');
    process.exit(1);
  }
  
  try {
    const success = await configureQualityGates();
    if (success) {
      console.log('\n✅ Quality gates configuration complete!');
      console.log('Quality standards now enforced:');
      console.log('- Zero tolerance for security issues');
      console.log('- Maximum 2 new issues of Error severity');
      console.log('- Minimum 70% test coverage for changed code');
      console.log('- Reasonable limits on complexity and duplication');
      process.exit(0);
    } else {
      console.error('\n❌ Failed to configure quality gates.');
      process.exit(1);
    }
  } catch (error) {
    console.error('\n❌ An unexpected error occurred:', error.message);
    process.exit(1);
  }
}

// Run the script
main();
