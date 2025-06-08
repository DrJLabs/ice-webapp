import { Page, TestInfo, expect } from '@playwright/test';
import { AxeBuilder } from '@axe-core/playwright';
import fs from 'fs';
import path from 'path';

/**
 * Run accessibility tests on the current page
 * @param page - Playwright page object
 * @param testInfo - Playwright test info object
 * @param options - Options for accessibility testing
 */
export async function checkAccessibility(
  page: Page, 
  testInfo: TestInfo, 
  options = { timeout: 5000, skipAttachment: false }
) {
  try {
    // Use timeout to prevent hanging
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => reject(new Error('Accessibility test timeout')), options.timeout);
    });

    const axePromise = new AxeBuilder({ page })
      .exclude('[aria-hidden="true"]') // Exclude hidden elements for performance
      .analyze();

    const accessibilityScanResults = await Promise.race([axePromise, timeoutPromise]) as any;
    
    // Only save results as attachment if there are violations or explicitly requested
    if (!options.skipAttachment && accessibilityScanResults.violations.length > 0) {
      await testInfo.attach('accessibility-results', {
        body: JSON.stringify(accessibilityScanResults, null, 2),
        contentType: 'application/json'
      });
    }
    
    // Log any violations
    if (accessibilityScanResults.violations.length > 0) {
      console.log(`Found ${accessibilityScanResults.violations.length} accessibility violations`);
      for (const violation of accessibilityScanResults.violations) {
        console.log(`- ${violation.id}: ${violation.help} (${violation.impact} impact)`);
      }
    }
    
    // Assert no violations
    expect(accessibilityScanResults.violations.length).toBe(0);
    return accessibilityScanResults;
  } catch (error) {
    console.error('Error running accessibility tests:', error);
    throw error;
  }
}

/**
 * Take a screenshot and save it with the test name
 * @param page - Playwright page object
 * @param testInfo - Playwright test info object
 */
export async function takeScreenshot(page: Page, testInfo: TestInfo) {
  // Only take screenshots on CI or when explicitly set in environment
  if (!process.env.CI && !process.env.FORCE_SCREENSHOTS) {
    return null;
  }
  
  const screenshotPath = path.join(testInfo.outputDir, `${testInfo.title.replace(/\s+/g, '-')}.png`);
  
  // Create directory if it doesn't exist
  const dir = path.dirname(screenshotPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  await page.screenshot({ path: screenshotPath, fullPage: false }); // Partial screenshots are faster
  await testInfo.attach('screenshot', { path: screenshotPath, contentType: 'image/png' });
  
  return screenshotPath;
}

/**
 * Wait for Next.js app router stability
 * Helps address common flakiness issues with Next.js tests
 * @param page - Playwright page object
 * @param options - Options for stability waiting
 */
export async function waitForStable(
  page: Page, 
  options = { timeout: 2000, checkNetwork: true, checkAnimations: true }
) {
  // Wait for network to be idle
  if (options.checkNetwork) {
    await page.waitForLoadState('networkidle', { timeout: options.timeout });
  }
  
  // Wait for any animations to complete
  if (options.checkAnimations) {
    await page.evaluate(() => {
      return new Promise<void>((resolve) => {
        // Check if any animations are running
        const hasAnimations = document.getAnimations().some(animation => 
          animation.playState === 'running'
        );
        
        if (!hasAnimations) {
          resolve();
          return;
        }
        
        // Wait a bit for animations to finish
        setTimeout(resolve, 500);
      });
    }).catch(() => {
      // Ignore errors from animation check
    });
  }
  
  // Small additional wait to ensure stability
  await page.waitForTimeout(100);
}

/**
 * Get performance metrics (Chromium only)
 * @param page - Playwright page object
 */
export async function getPerformanceMetrics(page: Page) {
  // This only works in Chromium-based browsers
  if (page.context().browser()?.browserType().name() !== 'chromium') {
    return null;
  }

  const metrics = await page.evaluate(() => JSON.stringify(window.performance));
  return JSON.parse(metrics);
}

/**
 * Check performance budget
 * @param page - Playwright page object
 * @param testInfo - Playwright test info object
 * @param budget - Performance budget in milliseconds
 */
export async function checkPerformanceBudget(page: Page, testInfo: TestInfo, budget: number = 3000) {
  // Skip on non-Chromium browsers
  const metrics = await getPerformanceMetrics(page);
  if (!metrics) return null;
  
  const loadTime = metrics.timing.loadEventEnd - metrics.timing.navigationStart;
  
  await testInfo.attach('performance-metrics', {
    body: JSON.stringify(metrics, null, 2),
    contentType: 'application/json'
  });
  
  expect(loadTime).toBeLessThan(budget);
  return metrics;
} 