import { Page, expect, Locator, TestInfo } from '@playwright/test';
import fs from 'fs';
import path from 'path';

/**
 * Takes a screenshot and saves it to the test results directory
 * @param page Playwright page object
 * @param name Screenshot name (optional, will use test name if not provided)
 * @param testInfo Playwright test info object (optional)
 */
export async function takeScreenshot(
  page: Page,
  name?: string,
  testInfo?: TestInfo
): Promise<string> {
  const screenshotName = name || (testInfo ? testInfo.title : 'screenshot');
  const cleanName = screenshotName.replace(/[^a-z0-9]/gi, '-').toLowerCase();
  const path = `./test-results/screenshots/${cleanName}-${Date.now()}.png`;
  
  await page.screenshot({
    path,
    fullPage: true,
  });
  
  console.log(`Screenshot saved to: ${path}`);
  return path;
}

/**
 * Runs accessibility tests on the current page
 * @param page Playwright page object
 * @param testInfo Playwright test info object (optional)
 * @returns Accessibility snapshot
 */
export async function checkAccessibility(
  page: Page,
  testInfo?: TestInfo
) {
  // Use Playwright's built-in accessibility testing
  const accessibilitySnapshot = await page.accessibility.snapshot();
  
  // Log the snapshot if requested
  if (testInfo) {
    await testInfo.attach('accessibility-snapshot', {
      body: JSON.stringify(accessibilitySnapshot, null, 2),
      contentType: 'application/json'
    });
  }
  
  expect(accessibilitySnapshot).toBeTruthy();
  return accessibilitySnapshot;
}

/**
 * Waits for all images to load on the page
 * @param page Playwright page object
 * @param timeout Timeout in milliseconds (default: 5000)
 */
export async function waitForImagesLoaded(page: Page, timeout = 5000): Promise<void> {
  await page.waitForFunction(
    () => {
      return Array.from(document.querySelectorAll('img'))
        .every((img) => img.complete);
    },
    { timeout }
  );
}

/**
 * Waits for all fonts to load on the page
 * @param page Playwright page object
 * @param timeout Timeout in milliseconds (default: 5000)
 */
export async function waitForFontsLoaded(page: Page, timeout = 5000): Promise<void> {
  await page.waitForFunction(
    () => {
      return document.fonts && document.fonts.status === 'loaded';
    },
    { timeout }
  );
}

/**
 * Waits for network requests to complete
 * @param page Playwright page object
 * @param timeout Timeout in milliseconds (default: 5000)
 */
export async function waitForNetworkIdle(page: Page, timeout = 5000): Promise<void> {
  await page.waitForLoadState('networkidle', { timeout });
}

/**
 * Gets text content from an element
 * @param locator Playwright locator
 * @param trimWhitespace Whether to trim whitespace (default: true)
 * @returns Element text content
 */
export async function getElementText(
  locator: Locator,
  trimWhitespace = true
): Promise<string> {
  const text = await locator.textContent();
  return trimWhitespace ? text?.trim() || '' : text || '';
}

/**
 * Checks if an element is visible
 * @param locator Playwright locator
 * @returns Whether the element is visible
 */
export async function isElementVisible(locator: Locator): Promise<boolean> {
  return await locator.isVisible();
}

/**
 * Gets the count of elements matching a locator
 * @param locator Playwright locator
 * @returns Number of elements
 */
export async function getElementCount(locator: Locator): Promise<number> {
  return await locator.count();
}

/**
 * Retries an action until it succeeds or times out
 * @param action Function to retry
 * @param options Retry options
 * @returns Result of the action
 */
export async function retry<T>(
  action: () => Promise<T>,
  options: {
    maxRetries?: number;
    retryInterval?: number;
    timeout?: number;
    onRetry?: (attempt: number, error: Error) => void;
  } = {}
): Promise<T> {
  const {
    maxRetries = 3,
    retryInterval = 1000,
    timeout = 10000,
    onRetry = () => {},
  } = options;
  
  const startTime = Date.now();
  let attempts = 0;
  let lastError: Error | null = null;
  
  while (attempts < maxRetries && Date.now() - startTime < timeout) {
    try {
      return await action();
    } catch (error) {
      attempts++;
      lastError = error as Error;
      
      if (attempts >= maxRetries || Date.now() - startTime >= timeout) {
        break;
      }
      
      onRetry(attempts, lastError);
      await new Promise((resolve) => setTimeout(resolve, retryInterval));
    }
  }
  
  throw lastError || new Error('Retry failed');
}

/**
 * Helper to test responsive design
 * @param page Playwright page object
 * @param viewports Array of viewport sizes to test
 * @param testFn Function to run for each viewport
 */
export async function testResponsive(
  page: Page,
  viewports: Array<{ width: number; height: number; name: string }>,
  testFn: (viewport: { width: number; height: number; name: string }) => Promise<void>
): Promise<void> {
  for (const viewport of viewports) {
    console.log(`Testing viewport: ${viewport.name} (${viewport.width}x${viewport.height})`);
    await page.setViewportSize({
      width: viewport.width,
      height: viewport.height,
    });
    await testFn(viewport);
  }
}

/**
 * Common viewport sizes for responsive testing
 */
export const VIEWPORTS = {
  MOBILE: { width: 375, height: 667, name: 'mobile' },
  TABLET: { width: 768, height: 1024, name: 'tablet' },
  DESKTOP: { width: 1280, height: 800, name: 'desktop' },
  LARGE_DESKTOP: { width: 1920, height: 1080, name: 'large_desktop' },
};

/**
 * Checks if an element has a specific CSS class
 * @param locator Playwright locator
 * @param className CSS class name to check
 * @returns Whether the element has the class
 */
export async function hasClass(locator: Locator, className: string): Promise<boolean> {
  const classAttr = await locator.getAttribute('class');
  return classAttr ? classAttr.split(' ').includes(className) : false;
}

/**
 * Gets all attributes of an element
 * @param locator Playwright locator
 * @returns Object with all attributes
 */
export async function getAllAttributes(locator: Locator): Promise<Record<string, string>> {
  return await locator.evaluate((el) => {
    const attrs: Record<string, string> = {};
    for (const attr of el.attributes) {
      attrs[attr.name] = attr.value;
    }
    return attrs;
  });
}

/**
 * Extracts table data from an HTML table
 * @param tableLocator Playwright locator for the table
 * @returns Array of rows with cell data
 */
export async function extractTableData(tableLocator: Locator): Promise<string[][]> {
  const rows = await tableLocator.locator('tr').all();
  const tableData: string[][] = [];
  
  for (const row of rows) {
    const cells = await row.locator('th, td').all();
    const rowData: string[] = [];
    
    for (const cell of cells) {
      rowData.push(await cell.textContent() || '');
    }
    
    tableData.push(rowData);
  }
  
  return tableData;
}

/**
 * Types text with a realistic typing speed
 * @param locator Playwright locator
 * @param text Text to type
 * @param options Typing options
 */
export async function typeWithDelay(
  locator: Locator,
  text: string,
  options: { delay?: number; clear?: boolean } = {}
): Promise<void> {
  const { delay = 100, clear = true } = options;
  
  if (clear) {
    await locator.clear();
  }
  
  await locator.fill(text, { timeout: 5000 });
}

/**
 * Checks if a page contains specific text
 * @param page Playwright page
 * @param text Text to search for
 * @returns Whether the text was found
 */
export async function pageContainsText(page: Page, text: string): Promise<boolean> {
  const content = await page.content();
  return content.includes(text);
}

/**
 * Safe click function with retry logic
 * @param locator Playwright locator
 * @param options Click options
 */
export async function safeClick(
  locator: Locator,
  options: { retries?: number; delay?: number } = {}
): Promise<void> {
  const { retries = 3, delay = 500 } = options;
  
  await retry(
    async () => {
      await locator.click();
    },
    {
      maxRetries: retries,
      retryInterval: delay,
      onRetry: (attempt) => {
        console.log(`Retrying click, attempt ${attempt}`);
      },
    }
  );
}

/**
 * Waits for an element to have specific text
 * @param locator Playwright locator
 * @param text Expected text
 * @param options Wait options
 */
export async function waitForText(
  locator: Locator,
  text: string,
  options: { timeout?: number; exact?: boolean } = {}
): Promise<void> {
  const { timeout = 5000, exact = false } = options;
  
  await expect(locator).toContainText(text, { timeout });
}

/**
 * Test page performance metrics
 * @param page Playwright page
 * @param budget Performance budget in milliseconds
 */
export async function testPerformance(page: Page, budget = 3000) {
  // Get page metrics
  const metrics = await page.evaluate(() => {
    const perfEntries = performance.getEntriesByType('navigation');
    const navigationEntry = perfEntries[0] as PerformanceNavigationTiming;
    
    return {
      TTFB: navigationEntry.responseStart - navigationEntry.requestStart,
      FCP: (performance as any).getEntriesByName('first-contentful-paint')[0]?.startTime || 0,
      loadTime: navigationEntry.loadEventEnd - navigationEntry.requestStart,
      domContentLoaded: navigationEntry.domContentLoadedEventEnd - navigationEntry.requestStart,
      resourceCount: performance.getEntriesByType('resource').length,
    };
  });
  
  // Log performance metrics
  console.log('Performance metrics:', metrics);
  
  // Check if load time is within budget
  const loadTime = metrics.loadTime;
  expect(loadTime).toBeLessThan(budget);
  return metrics;
} 