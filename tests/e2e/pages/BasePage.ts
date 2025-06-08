import { Page, Locator, expect } from '@playwright/test';
import { AxeBuilder } from '@axe-core/playwright';
import { waitForStable } from '../utils/test-helpers';

/**
 * Base Page Object Model class that all page objects should extend
 * Implements common functionality for all pages
 */
export class BasePage {
  readonly page: Page;
  readonly url: string;

  constructor(page: Page, url: string = '/') {
    this.page = page;
    this.url = url;
  }

  /**
   * Navigate to the page
   */
  async goto() {
    await this.page.goto(this.url, { 
      waitUntil: 'domcontentloaded' // Faster than 'networkidle'
    });
  }

  /**
   * Wait for the page to be loaded
   */
  async waitForPageLoad() {
    await waitForStable(this.page);
  }

  /**
   * Get the page title
   */
  async getTitle(): Promise<string> {
    return await this.page.title();
  }

  /**
   * Check if an element is visible
   */
  async isVisible(locator: string | Locator): Promise<boolean> {
    const element = typeof locator === 'string' ? this.page.locator(locator) : locator;
    return await element.isVisible();
  }

  /**
   * Run accessibility tests on the current page
   */
  async checkAccessibility() {
    // Wait for page to be stable before checking accessibility
    await this.waitForPageLoad();
    
    const accessibilityScanResults = await new AxeBuilder({ page: this.page })
      .exclude('[aria-hidden="true"]') // Exclude hidden elements for performance
      .analyze();
      
    expect(accessibilityScanResults.violations).toEqual([]);
    return accessibilityScanResults;
  }

  /**
   * Take a screenshot of the current page
   */
  async takeScreenshot(name: string) {
    // Only take screenshots on CI or when explicitly requested
    if (!process.env.CI && !process.env.FORCE_SCREENSHOTS) {
      return;
    }
    
    await this.page.screenshot({ 
      path: `./test-results/screenshots/${name}.png`, 
      fullPage: false // Partial screenshots are faster
    });
  }

  /**
   * Get performance metrics
   */
  async getPerformanceMetrics() {
    // This only works in Chromium-based browsers
    if (this.page.context().browser()?.browserType().name() !== 'chromium') {
      return null;
    }

    const metrics = await this.page.evaluate(() => JSON.stringify(window.performance));
    return JSON.parse(metrics);
  }
} 