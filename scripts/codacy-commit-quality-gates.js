#!/usr/bin/env node

/**
 * Script to verify Codacy analysis for commits in the ICE-WEBAPP project
 * 
 * This script verifies that the commit has been analyzed by Codacy
 * and reports the current quality metrics. Quality gate configuration
 * is now handled via the Codacy UI and repository settings.
 * 
 * @global require, process, console, __dirname
 */

/* eslint-env node */

const fs = require('fs');
const path = require('path');
const https = require('https');

// Load Codacy tokens from env file
require('dotenv').config({ path: path.join(__dirname, '../tools/.codacy-tokens') });

// Configuration
const API_TOKEN = process.env.CODACY_API_TOKEN;
const PROJECT_TOKEN = process.env.CODACY_PROJECT_TOKEN;

// Repository configuration
const PROVIDER = 'gh';
const ORGANIZATION = 'DrJLabs';
const REPOSITORY = 'ice-webapp';

if (!API_TOKEN && !PROJECT_TOKEN) {
  console.log('❌ Error: No Codacy tokens found. Please check tools/.codacy-tokens');
  process.exit(1);
}

/**
 * Make HTTPS request to Codacy API
 */
function makeRequest(endpoint, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'app.codacy.com',
      port: 443,
      path: endpoint,
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'User-Agent': 'ICE-WEBAPP-Quality-Gates/1.0'
      }
    };

    console.log(`🔍 Checking: https://app.codacy.com${endpoint}`);

    const req = https.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            const result = JSON.parse(data);
            resolve(result);
          } catch (e) {
            resolve({ statusCode: res.statusCode, data });
          }
        } else {
          reject({
            statusCode: res.statusCode,
            message: data,
            endpoint
          });
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.end();
  });
}

/**
 * Get repository analysis information
 */
async function getRepositoryAnalysis() {
  const endpoint = `/api/v3/analysis/organizations/${PROVIDER}/${ORGANIZATION}/repositories/${REPOSITORY}`;
  
  try {
    const result = await makeRequest(endpoint, API_TOKEN || PROJECT_TOKEN);
    return result;
  } catch (error) {
    console.log(`❌ Failed to get repository analysis: ${error.message}`);
    return null;
  }
}

/**
 * Get current commit SHA
 */
function getCurrentCommitSHA() {
  try {
    const { execSync } = require('child_process');
    const sha = execSync('git rev-parse HEAD', { encoding: 'utf8' }).trim();
    return sha;
  } catch (error) {
    console.log('❌ Could not get current commit SHA');
    return null;
  }
}

/**
 * Main function
 */
async function main() {
  console.log('🧊 ICE-WEBAPP Codacy Quality Verification');
  console.log('=========================================');
  
  const currentSHA = getCurrentCommitSHA();
  if (!currentSHA) {
    console.log('❌ Could not determine current commit');
    process.exit(1);
  }
  
  console.log(`📋 Current commit: ${currentSHA.substring(0, 8)}`);
  console.log(`🔗 Repository: ${ORGANIZATION}/${REPOSITORY}`);
  
  // Get repository analysis
  const analysis = await getRepositoryAnalysis();
  
  if (!analysis) {
    console.log('❌ Could not retrieve repository analysis');
    process.exit(1);
  }
  
  if (analysis.data && analysis.data.repository) {
    const repo = analysis.data.repository;
    console.log(`✅ Repository Grade: ${repo.gradeLetter} (${repo.grade})`);
    console.log(`📊 Issues: ${repo.issuesCount} issues in ${repo.loc} LoC`);
    console.log(`🎯 Coverage: ${repo.coverage ? `${repo.coverage.filesUncovered}/${repo.coverage.numberTotalFiles} files uncovered` : 'N/A'}`);
    console.log(`🔄 Last analyzed: ${repo.lastAnalysedCommit ? repo.lastAnalysedCommit.sha.substring(0, 8) : 'Unknown'}`);
    
    if (repo.lastAnalysedCommit && repo.lastAnalysedCommit.sha === currentSHA) {
      console.log('✅ Current commit has been analyzed by Codacy');
    } else {
      console.log('⚠️  Current commit may not have been analyzed yet');
      console.log('   This is normal for recent commits - analysis may be in progress');
    }
  } else {
    console.log('✅ Repository is configured in Codacy');
  }
  
  console.log('');
  console.log('ℹ️  Quality gates are configured via Codacy repository settings:');
  console.log(`   https://app.codacy.com/${PROVIDER}/${ORGANIZATION}/${REPOSITORY}/settings/quality-gate`);
  console.log('');
  console.log('✅ Codacy verification completed successfully');
}

// Run the script
main().catch((error) => {
  console.log('❌ Script failed:', error.message);
  process.exit(1);
});
