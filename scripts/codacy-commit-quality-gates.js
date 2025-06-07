#!/usr/bin/env node
/**
 * Codacy Commit Quality Gates Configuration
 * 
 * This script configures quality gates for commits in Codacy.
 * It sets standards for code quality, security, and test coverage.
 */

const https = require('https');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Load Codacy tokens from environment or file
const loadTokens = () => {
  if (process.env.CODACY_ACCOUNT_TOKEN && process.env.CODACY_PROJECT_TOKEN) {
    return {
      accountToken: process.env.CODACY_ACCOUNT_TOKEN,
      projectToken: process.env.CODACY_PROJECT_TOKEN
    };
  }
  
  // Try to load from file
  const tokenPath = path.join(__dirname, '../tools/.codacy-tokens');
  if (fs.existsSync(tokenPath)) {
    const content = fs.readFileSync(tokenPath, 'utf8');
    const accountTokenMatch = content.match(/CODACY_ACCOUNT_TOKEN="([^"]+)"/);
    const projectTokenMatch = content.match(/CODACY_PROJECT_TOKEN="([^"]+)"/);
    
    if (accountTokenMatch && projectTokenMatch) {
      return {
        accountToken: accountTokenMatch[1],
        projectToken: projectTokenMatch[1]
      };
    }
  }
  
  throw new Error('Codacy tokens not found. Please set CODACY_ACCOUNT_TOKEN and CODACY_PROJECT_TOKEN environment variables or create tools/.codacy-tokens file.');
};

// Configure commit quality gates using project token
const configureCommitQualityGates = async () => {
  const { projectToken } = loadTokens();
  
  console.log(`🧊 Configuring Codacy commit quality gates using project token...`);
  
  // Quality gate settings based on best practices for this project
  const qualityGateSettings = {
    'security': { enabled: true, value: 0 },           // Zero tolerance for security issues
    'issues': { enabled: true, value: 2 },             // Maximum 2 new issues of Error severity
    'duplication': { enabled: true, value: 3 },        // Maximum 3 new duplicated blocks
    'complexity': { enabled: true, value: 4 },         // Maximum 4 new complexity
    'coverage': { enabled: true, value: -1 }           // Allow 1% drop in coverage
    // Note: diff_coverage is not available for commits, only for PRs
  };
  
  // Configure each quality gate for commits
  const endpoint = `https://app.codacy.com/api/v3/project/${projectToken}/settings/quality/commit-gates`;
  
  try {
    const response = await makeRequest('GET', endpoint);
    const currentSettings = JSON.parse(response);
    
    console.log('Current commit quality gate settings:');
    Object.entries(currentSettings).forEach(([key, value]) => {
      console.log(`  ${key}: ${value.enabled ? 'enabled' : 'disabled'}, value: ${value.value}`);
    });
    
    // Update settings
    const updatedSettings = { ...currentSettings };
    Object.entries(qualityGateSettings).forEach(([key, value]) => {
      if (updatedSettings[key]) {
        updatedSettings[key] = value;
      }
    });
    
    const updateResponse = await makeRequest('PUT', endpoint, updatedSettings);
    const result = JSON.parse(updateResponse);
    
    console.log('\n✅ Commit quality gates updated successfully:');
    Object.entries(result).forEach(([key, value]) => {
      console.log(`  ${key}: ${value.enabled ? 'enabled' : 'disabled'}, value: ${value.value}`);
    });
  } catch (error) {
    console.error('❌ Error configuring commit quality gates:', error.message);
    process.exit(1);
  }
};

// Helper function to make HTTP requests
const makeRequest = (method, url, data = null) => {
  return new Promise((resolve, reject) => {
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json'
      }
    };
    
    const req = https.request(url, options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(responseData);
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
};

// Run the script
configureCommitQualityGates().catch(error => {
  console.error('Error:', error.message);
  process.exit(1);
}); 