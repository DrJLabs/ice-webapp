import { Page, expect } from '@playwright/test';
import fs from 'fs';
import path from 'path';

/**
 * Test helper functions for E2E tests
 */

/**
 * Wait for network to be idle
 * @param {Page} page - Playwright page
 * @param {number} timeout - Timeout in milliseconds (default: 5000)
 */
export async function waitForNetworkIdle(page: Page, timeout: number = 5000) {
  await page.waitForLoadState('networkidle', { timeout });
}

/**
 * Take a screenshot and save it with a timestamp
 * @param {Page} page - Playwright page
 * @param {string} name - Screenshot name
 */
export async function takeScreenshot(page: Page, name: string) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const dirPath = path.join(process.cwd(), 'test-results', 'screenshots');
  
  // Create directory if it doesn't exist
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
  
  const filePath = path.join(dirPath, `${name}-${timestamp}.png`);
  await page.screenshot({ path: filePath, fullPage: true });
  
  return filePath;
}

/**
 * Check accessibility issues using Playwright's accessibility scanner
 * @param {Page} page - Playwright page
 */
export async function checkAccessibility(page: Page) {
  const accessibilitySnapshot = await page.accessibility.snapshot();
  expect(accessibilitySnapshot).toBeTruthy();
  return accessibilitySnapshot;
}

/**
 * Test page performance metrics
 * @param {Page} page - Playwright page
 */
export async function getPerformanceMetrics(page: Page) {
  // Get performance metrics
  const performanceMetrics = await page.evaluate(() => {
    const { loadEventEnd, domContentLoadedEventEnd, navigationStart } = performance.timing;
    return {
      loadTime: loadEventEnd - navigationStart,
      domContentLoaded: domContentLoadedEventEnd - navigationStart,
      // Add more metrics as needed
    };
  });
  
  return performanceMetrics;
}

/**
 * Generate a random string
 * @param {number} length - Length of the string (default: 10)
 */
export function generateRandomString(length: number = 10): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

/**
 * Check if an element is in viewport
 * @param {Page} page - Playwright page
 * @param {string} selector - Element selector
 */
export async function isElementInViewport(page: Page, selector: string): Promise<boolean> {
  return await page.evaluate((sel: string) => {
    const element = document.querySelector(sel);
    if (!element) return false;
    
    const rect = element.getBoundingClientRect();
    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
      rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
  }, selector);
} 