#!/usr/bin/env node

/* eslint-env node */

/**
 * Test Generator Script
 * 
 * Generates test files for components and pages
 * Usage:
 *   - Generate component test:
 *     node scripts/generate-tests.js component ComponentName
 *   - Generate page test:
 *     node scripts/generate-tests.js page PageName
 *   - Generate e2e test:
 *     node scripts/generate-tests.js e2e pageName
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Get arguments
const [, , type, name] = process.argv;

if (!type || !name) {
  console.error('Please provide a type (component, page, e2e) and name');
  console.error('Example: node scripts/generate-tests.js component Button');
  process.exit(1);
}

const ROOT_DIR = path.resolve(__dirname, '..');

// Templates
const componentTestTemplate = (componentName) => `import React from 'react';
import { render, screen, fireEvent, testA11y } from '../test-utils';
import { ${componentName} } from '@/components/${componentName.toLowerCase()}/${componentName}';

describe('${componentName} Component', () => {
  it('renders correctly', () => {
    render(<${componentName} />);
    // Add assertions based on component structure
  });

  it('has no accessibility violations', async () => {
    await testA11y(<${componentName} />);
  });

  // Add more tests specific to this component
});
`;

const pageTestTemplate = (pageName) => `import React from 'react';
import { render, screen, testA11y } from '../test-utils';
import ${pageName} from '@/app/${pageName.toLowerCase()}/page';

describe('${pageName} Page', () => {
  it('renders correctly', () => {
    render(<${pageName} />);
    // Add assertions based on page structure
  });

  it('has no accessibility violations', async () => {
    await testA11y(<${pageName} />);
  });

  // Add more tests specific to this page
});
`;

const e2eTestTemplate = (pageName) => `import { test, expect } from '@playwright/test';
import { ${pageName}Page } from './pages/${pageName}Page';
import { checkAccessibility, takeScreenshot } from './utils/test-helpers';

test.describe('${pageName} Page', () => {
  test('should load successfully', async ({ page }, testInfo) => {
    const ${pageName.toLowerCase()}Page = new ${pageName}Page(page);
    await ${pageName.toLowerCase()}Page.goto();
    await ${pageName.toLowerCase()}Page.waitForPageLoad();
    
    // Take a screenshot
    await takeScreenshot(page, testInfo);
    
    // Check the title
    const title = await ${pageName.toLowerCase()}Page.getTitle();
    expect(title).toBeTruthy();
  });
  
  test('should pass accessibility tests', async ({ page }, testInfo) => {
    const ${pageName.toLowerCase()}Page = new ${pageName}Page(page);
    await ${pageName.toLowerCase()}Page.goto();
    await ${pageName.toLowerCase()}Page.waitForPageLoad();
    
    // Run accessibility tests
    await checkAccessibility(page, testInfo);
  });

  // Add more tests specific to this page
});
`;

const pageObjectTemplate = (pageName) => `import { Page } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * ${pageName} page object
 */
export class ${pageName}Page extends BasePage {
  constructor(page: Page) {
    // Update the URL path as needed
    super(page, '/${pageName.toLowerCase()}');
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
        template = componentTestTemplate(name);
        break;
      
      case 'page':
        testPath = path.join(ROOT_DIR, 'tests', 'pages', `${name}.test.tsx`);
        template = pageTestTemplate(name);
        break;
      
      case 'e2e':
        testPath = path.join(ROOT_DIR, 'tests', 'e2e', `${name.toLowerCase()}.test.ts`);
        template = e2eTestTemplate(name);

        // Also create page object if it doesn't exist
        additionalPath = path.join(ROOT_DIR, 'tests', 'e2e', 'pages', `${name}Page.ts`);
        ensureDirectoryExists(path.dirname(additionalPath));
        
        if (!fs.existsSync(additionalPath)) {
          fs.writeFileSync(additionalPath, pageObjectTemplate(name));
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
    exec(`npx prettier --write "${testPath}"`, (error) => {
      if (!error) {
        console.log(`Formatted test file with Prettier`);
      }
    });

  } catch (error) {
    console.error('Error generating test file:', error);
    process.exit(1);
  }
}

generateTest(); 