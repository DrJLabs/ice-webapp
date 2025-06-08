#!/usr/bin/env node

/**
 * Test Generator Script
 * 
 * This script generates test files for components and pages.
 * Usage: node scripts/generate-tests.js --type=component|page|e2e --name=ComponentName
 */

/* eslint-env node */
/* global process, require, console, __dirname */

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
  console.log('Usage: node scripts/generate-tests.js --type=component|page|e2e --name=ComponentName');
  process.exit(1);
}

const { type, name } = params;
const ROOT_DIR = path.resolve(__dirname, '..');

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

const pageTestTemplate = `import React from 'react';
import { render, screen, checkAccessibility } from '../test-utils';
import ${name}Page from '@/app/${name.toLowerCase()}/page';

describe('${name} Page', () => {
  it('renders correctly', () => {
    render(<${name}Page />);
    // Add assertions based on page structure
  });

  it('passes accessibility tests', async () => {
    const { container } = render(<${name}Page />);
    await checkAccessibility(container);
  });

  // Add more tests specific to this page
});
`;

const e2eTestTemplate = `import { test, expect } from '@playwright/test';
import { ${name}Page } from './pages/${name}Page';
import { checkAccessibility, takeScreenshot } from './utils/test-helpers';

test.describe('${name} Page Tests', () => {
  test('should load successfully', async ({ page }) => {
    // Arrange
    const ${name.toLowerCase()}Page = new ${name}Page(page);
    
    // Act
    await ${name.toLowerCase()}Page.goto();
    await ${name.toLowerCase()}Page.waitForPageLoad();
    
    // Assert
    const title = await ${name.toLowerCase()}Page.getTitle();
    expect(title).toBeTruthy();
    
    // Take screenshot for visual reference
    await takeScreenshot(page, '${name.toLowerCase()}-loaded');
  });
  
  test('should have proper content', async ({ page }) => {
    // Arrange
    const ${name.toLowerCase()}Page = new ${name}Page(page);
    
    // Act
    await ${name.toLowerCase()}Page.goto();
    await ${name.toLowerCase()}Page.waitForPageLoad();
    
    // Assert
    // Add assertions specific to this page
    expect(await ${name.toLowerCase()}Page.verifyPage()).toBeTruthy();
  });
  
  test('should pass basic accessibility checks', async ({ page }) => {
    // Arrange
    const ${name.toLowerCase()}Page = new ${name}Page(page);
    
    // Act
    await ${name.toLowerCase()}Page.goto();
    await ${name.toLowerCase()}Page.waitForPageLoad();
    
    // Assert - Check accessibility
    const accessibilitySnapshot = await checkAccessibility(page);
    expect(accessibilitySnapshot).toBeTruthy();
  });
});
`;

const pageObjectTemplate = `import { Page, Locator } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * ${name} page object
 */
export class ${name}Page extends BasePage {
  // Define page-specific locators
  readonly heading: Locator;
  readonly mainContent: Locator;
  
  constructor(page: Page) {
    // Update the URL path as needed
    super(page, '/${name.toLowerCase()}');
    
    // Initialize locators
    this.heading = this.page.locator('h1').first();
    this.mainContent = this.page.locator('main');
  }
  
  /**
   * Override waitForPageLoad to provide page-specific wait conditions
   */
  async waitForPageLoad() {
    await super.waitForPageLoad();
    try {
      await this.heading.waitFor({ state: 'visible', timeout: 3000 }).catch(() => {});
      await this.mainContent.waitFor({ state: 'visible', timeout: 3000 }).catch(() => {});
    } catch (error) {
      // Continue even if elements aren't found
    }
  }
  
  /**
   * Verify the page is loaded correctly
   */
  async verifyPage() {
    await this.waitForPageLoad();
    const heading = await this.getElementText(this.heading);
    return !!heading;
  }
  
  // Add page-specific methods here
}
`;

// Create directories if they don't exist
function ensureDirectoryExists(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
    console.log(`Created directory: ${dirPath}`);
  }
}

// Generate the test file
function generateTest() {
  try {
    let testPath, template, additionalPath;

    switch (type.toLowerCase()) {
      case 'component':
        testPath = path.join(ROOT_DIR, 'tests', 'components', `${name}.test.tsx`);
        template = componentTestTemplate;
        break;
      
      case 'page':
        testPath = path.join(ROOT_DIR, 'tests', 'pages', `${name}.test.tsx`);
        template = pageTestTemplate;
        break;
      
      case 'e2e':
        testPath = path.join(ROOT_DIR, 'tests', 'e2e', `${name.toLowerCase()}.test.ts`);
        template = e2eTestTemplate;

        // Also create page object if it doesn't exist
        additionalPath = path.join(ROOT_DIR, 'tests', 'e2e', 'pages', `${name}Page.ts`);
        ensureDirectoryExists(path.dirname(additionalPath));
        
        if (!fs.existsSync(additionalPath)) {
          fs.writeFileSync(additionalPath, pageObjectTemplate);
          console.log(`Created page object: ${additionalPath}`);
        } else {
          console.log(`Page object already exists: ${additionalPath}`);
        }
        break;
      
      default:
        console.error(`Unknown test type: ${type}`);
        process.exit(1);
    }

    ensureDirectoryExists(path.dirname(testPath));

    if (fs.existsSync(testPath)) {
      console.error(`Test file already exists: ${testPath}`);
      process.exit(1);
    }

    fs.writeFileSync(testPath, template);
    console.log(`Created test file: ${testPath}`);

    // Format the file with Prettier if available
    try {
      execSync(`npx prettier --write "${testPath}"`);
      console.log(`Formatted test file with Prettier`);
    } catch (error) {
      console.log(`Note: Could not format with Prettier, continuing anyway`);
    }

  } catch (error) {
    console.error('Error generating test file:', error);
    process.exit(1);
  }
}

// Execute the test generation
generateTest(); 