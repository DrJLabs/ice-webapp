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

// Get current quality gate settings
async function getCurrentQualityGates() {
  try {
    const pullRequestQualityGates = await makeApiRequest(
      'GET',
      `/organizations/${CONFIG.PROVIDER}/${CONFIG.ORGANIZATION}/repositories/${CONFIG.REPOSITORY}/settings/quality/pull-requests`
    );
    console.log('Current pull request quality gates:', JSON.stringify(pullRequestQualityGates, null, 2));
    return pullRequestQualityGates;
  } catch (error) {
    console.error('Error getting current quality gates:', error.message);
    throw error;
  }
}

// Update quality gates for pull requests
async function updatePullRequestQualityGates() {
  // Best practices for React applications
  const qualityGateSettings = {
    // No new security issues allowed
    securityIssueThreshold: 0,
    
    // Maximum 2 new issues of Error severity or higher
    issueThreshold: {
      threshold: 2,
      minimumSeverity: "Error"
    },
    
    // Maximum 3 new duplicated blocks
    duplicationThreshold: 3,
    
    // Maximum 4 new complexity
    complexityThreshold: 4,
    
    // Allow minimal coverage drops (-0.1%) to not block refactoring
    coverageThresholdWithDecimals: -0.01,
    
    // Require at least 70% coverage on changed lines
    diffCoverageThreshold: 70
  };

  try {
    console.log('Updating pull request quality gates with:', JSON.stringify(qualityGateSettings, null, 2));
    
    const response = await makeApiRequest(
      'PUT',
      `/organizations/${CONFIG.PROVIDER}/${CONFIG.ORGANIZATION}/repositories/${CONFIG.REPOSITORY}/settings/quality/pull-requests`,
      qualityGateSettings
    );
    
    console.log('Successfully updated pull request quality gates');
    return response;
  } catch (error) {
    console.error('Error updating pull request quality gates:', error.message);
    throw error;
  }
}

// Main function
async function main() {
  try {
    console.log('Starting Codacy quality gates configuration...');
    
    // Extract repo info from Git if not provided
    if (!CONFIG.ORGANIZATION) {
      extractRepoInfoFromGit();
    }
    
    // Validate configuration
    if (!CONFIG.ACCOUNT_TOKEN) {
      throw new Error('CODACY_ACCOUNT_TOKEN is required. Set it in tools/.codacy-tokens');
    }
    
    if (!CONFIG.ORGANIZATION || !CONFIG.REPOSITORY) {
      throw new Error('Organization and repository are required. Either configure them in the script or run from a valid Git repository.');
    }
    
    // Get current settings
    await getCurrentQualityGates();
    
    // Update settings
    await updatePullRequestQualityGates();
    
    console.log('Codacy quality gates configured successfully!');
  } catch (error) {
    console.error('Error configuring Codacy quality gates:', error.message);
    process.exit(1);
  }
}

// Run the script
main(); 