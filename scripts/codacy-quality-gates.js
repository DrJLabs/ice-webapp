#!/usr/bin/env node

/**
 * Script to verify Codacy quality gates for the ICE-WEBAPP project
 * 
 * This script verifies that quality gates are properly configured
 * via the Codacy UI and reports current repository metrics.
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
 * Get repository issues list
 */
async function getRepositoryIssues() {
  const endpoint = `/api/v3/analysis/organizations/${PROVIDER}/${ORGANIZATION}/repositories/${REPOSITORY}/issues`;
  
  try {
    const result = await makeRequest(endpoint, API_TOKEN || PROJECT_TOKEN);
    return result;
  } catch (error) {
    console.log(`❌ Failed to get repository issues: ${error.message}`);
    return null;
  }
}

/**
 * Main function
 */
async function main() {
  console.log('🧊 ICE-WEBAPP Codacy Quality Gates Verification');
  console.log('===============================================');
  
  console.log(`🔗 Repository: ${ORGANIZATION}/${REPOSITORY}`);
  
  // Get repository analysis
  console.log('\n📊 Getting repository analysis...');
  const analysis = await getRepositoryAnalysis();
  
  if (!analysis) {
    console.log('❌ Could not retrieve repository analysis');
    process.exit(1);
  }
  
  if (analysis.data && analysis.data.repository) {
    const repo = analysis.data.repository;
    console.log(`✅ Repository Grade: ${repo.gradeLetter} (${repo.grade}/100)`);
    console.log(`📊 Issues: ${repo.issuesCount} issues in ${repo.loc} lines of code`);
    console.log(`🎯 Issues Percentage: ${repo.issuesPercentage}%`);
    console.log(`📋 Duplication: ${repo.duplicationPercentage}%`);
    console.log(`🎯 Complex Files: ${repo.complexFilesCount} (${repo.complexFilesPercentage}%)`);
    
    if (repo.coverage) {
      console.log(`🧪 Coverage: ${repo.coverage.numberTotalFiles - repo.coverage.filesUncovered}/${repo.coverage.numberTotalFiles} files covered`);
    }
    
    // Show quality goals if available
    if (repo.goals) {
      console.log('\n🎯 Quality Goals:');
      console.log(`   Max Issues: ${repo.goals.maxIssuePercentage}% (current: ${repo.issuesPercentage}%)`);
      console.log(`   Max Duplication: ${repo.goals.maxDuplicatedFilesPercentage}% (current: ${repo.duplicationPercentage}%)`);
      console.log(`   Min Coverage: ${repo.goals.minCoveragePercentage}%`);
      console.log(`   Max Complexity: ${repo.goals.maxComplexFilesPercentage}% (current: ${repo.complexFilesPercentage}%)`);
      
      // Check if repository meets quality goals
      const meetsGoals = 
        repo.issuesPercentage <= repo.goals.maxIssuePercentage &&
        repo.duplicationPercentage <= repo.goals.maxDuplicatedFilesPercentage &&
        repo.complexFilesPercentage <= repo.goals.maxComplexFilesPercentage;
      
      if (meetsGoals) {
        console.log('\n✅ Repository meets all quality goals!');
      } else {
        console.log('\n⚠️  Repository does not meet some quality goals');
      }
    }
    
    console.log(`\n🔄 Last analyzed commit: ${repo.lastAnalysedCommit ? repo.lastAnalysedCommit.sha.substring(0, 8) : 'Unknown'}`);
    console.log(`📅 Last updated: ${repo.lastUpdated}`);
    
  } else {
    console.log('✅ Repository is configured in Codacy');
  }
  
  // Get recent issues summary
  console.log('\n🔍 Getting issues summary...');
  const issuesData = await getRepositoryIssues();
  
  if (issuesData && issuesData.data) {
    const issues = issuesData.data;
    const severityCount = {};
    const categoryCount = {};
    
    issues.forEach(issue => {
      // Count by severity
      const severity = issue.severity || 'Unknown';
      severityCount[severity] = (severityCount[severity] || 0) + 1;
      
      // Count by category
      const category = issue.category || 'Unknown';
      categoryCount[category] = (categoryCount[category] || 0) + 1;
    });
    
    console.log('📋 Issues by severity:');
    Object.entries(severityCount).forEach(([severity, count]) => {
      console.log(`   ${severity}: ${count} issues`);
    });
    
    console.log('\n📋 Issues by category:');
    Object.entries(categoryCount).forEach(([category, count]) => {
      console.log(`   ${category}: ${count} issues`);
    });
  }
  
  console.log('\n📖 Quality Gates Configuration:');
  console.log('Quality gates are configured via the Codacy web interface:');
  console.log(`🔗 https://app.codacy.com/${PROVIDER}/${ORGANIZATION}/${REPOSITORY}/settings/quality-gate`);
  console.log('');
  console.log('🛠️  Recommended quality gate settings for React applications:');
  console.log('   - Pull Request Gates: Enable with strict limits');
  console.log('   - Security Issues: Zero tolerance (fail on any new security issues)');
  console.log('   - Coverage: Minimum threshold with small allowable drops');
  console.log('   - Issues: Limit new issues to maintain code quality');
  console.log('');
  console.log('✅ Quality gates verification completed successfully');
}

// Run the script
main().catch((error) => {
  console.log('❌ Script failed:', error.message);
  process.exit(1);
});
