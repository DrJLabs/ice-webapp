#!/usr/bin/env node

/**
 * Test Generator Script
 * 
 * This script generates test files for components and pages.
 * Usage: node scripts/generate-tests.js --type=component|page --name=ComponentName
 */

/* eslint-env node */
/* global process, require, console */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Parse command line arguments
const args = process.argv.slice(2);
const params = {};

args.forEach(arg => {
  const [key, value] = arg.split('=');
  if (key && value) {
    params[key.replace(/^--/, '')] = value;
  }
});

// Validate required parameters
if (!params.type || !params.name) {
  console.error('Error: Missing required parameters');
  console.log('Usage: node scripts/generate-tests.js --type=component|page --name=ComponentName');
  process.exit(1);
}

const { type, name } = params;

// Templates
const componentTestTemplate = `import React from 'react';
import { render, screen, checkAccessibility, createUserEvent } from '../test-utils';
import ${name} from '@/components/${name}';

describe('${name} Component', () => {
  it('renders correctly', () => {
    render(<${name} />);
    // Add your assertions here
  });
  
  it('handles user interactions', async () => {
    const user = createUserEvent();
    render(<${name} />);
    // Add your interaction tests here
  });
  
  it('passes accessibility tests', async () => {
    const { container } = render(<${name} />);
    await checkAccessibility(container);
  });
});
`;

const pageTestTemplate = `import { test, expect } from '@playwright/test';
import { ${name}Page } from './pages/${name}Page';
import { checkAccessibility, takeScreenshot } from './utils/test-helpers';

test.describe('${name} Page Tests', () => {
  test('should load the page correctly', async ({ page }) => {
    const testPage = new ${name}Page(page);
    await testPage.goto();
    await testPage.waitForPageLoad();
    
    const title = await testPage.getTitle();
    expect(title).toBeTruthy();
    
    // Take screenshot for visual reference
    await takeScreenshot(page, '${name.toLowerCase()}-loaded');
  });
  
  test('should pass basic accessibility checks', async ({ page }) => {
    const testPage = new ${name}Page(page);
    await testPage.goto();
    await testPage.waitForPageLoad();
    
    const accessibilitySnapshot = await checkAccessibility(page);
    expect(accessibilitySnapshot).toBeTruthy();
  });
});
`;

const pageObjectTemplate = `import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * ${name} Page Object
 */
export class ${name}Page extends BasePage {
  // Add locators here
  readonly heading: Locator;
  readonly mainContent: Locator;

  /**
   * @param {Page} page - Playwright page
   */
  constructor(page: Page) {
    super(page, '/${name.toLowerCase()}');
    
    // Initialize locators
    this.heading = page.locator('h1');
    this.mainContent = page.locator('main');
  }

  /**
   * Override waitForPageLoad to provide more specific wait conditions
   */
  async waitForPageLoad() {
    await this.heading.waitFor({ state: 'visible' });
    await this.mainContent.waitFor({ state: 'visible' });
  }

  /**
   * Verify the page is loaded correctly
   */
  async verifyPage() {
    await this.waitForPageLoad();
    
    const headingText = await this.getElementText(this.heading);
    expect(headingText).toBeTruthy();
    
    const isMainContentVisible = await this.isElementVisible(this.mainContent);
    expect(isMainContentVisible).toBeTruthy();
    
    return true;
  }
}`;

// Generate the test file
function generateTest() {
  let targetPath, content, pageObjectPath;
  
  if (type === 'component') {
    targetPath = path.join(process.cwd(), 'tests', 'components', `${name}.test.tsx`);
    content = componentTestTemplate;
  } else if (type === 'page') {
    targetPath = path.join(process.cwd(), 'tests', 'e2e', `${name.toLowerCase()}.test.ts`);
    pageObjectPath = path.join(process.cwd(), 'tests', 'e2e', 'pages', `${name}Page.ts`);
    content = pageTestTemplate;
  } else {
    console.error(`Error: Invalid type "${type}". Use "component" or "page".`);
    process.exit(1);
  }
  
  // Create directory if it doesn't exist
  const directory = path.dirname(targetPath);
  if (!fs.existsSync(directory)) {
    fs.mkdirSync(directory, { recursive: true });
  }
  
  // Write the test file
  fs.writeFileSync(targetPath, content);
  console.log(`Generated test file: ${targetPath}`);
  
  // Create page object if type is page
  if (type === 'page' && pageObjectPath) {
    const pageObjectDir = path.dirname(pageObjectPath);
    if (!fs.existsSync(pageObjectDir)) {
      fs.mkdirSync(pageObjectDir, { recursive: true });
    }
    
    fs.writeFileSync(pageObjectPath, pageObjectTemplate);
    console.log(`Generated page object: ${pageObjectPath}`);
  }
  
  // Format the files
  try {
    if (fs.existsSync(targetPath)) {
      execSync(`npx prettier --write "${targetPath}"`, { stdio: 'inherit' });
    }
    
    if (pageObjectPath && fs.existsSync(pageObjectPath)) {
      execSync(`npx prettier --write "${pageObjectPath}"`, { stdio: 'inherit' });
    }
  } catch (error) {
    console.warn('Warning: Could not format files. Prettier might not be installed.');
  }
}

// Execute
generateTest(); 