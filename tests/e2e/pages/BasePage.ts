import { Page, Locator, expect } from '@playwright/test';
import { AxeBuilder } from '@axe-core/playwright';
import { getElementText, waitForNetworkIdle } from '../utils/test-helpers';

/**
 * Base Page Object Model class
 * All page objects should extend this class
 */
export class BasePage {
  readonly page: Page;
  readonly url: string;
  readonly baseUrl: string;

  /**
   * @param {Page} page - Playwright page
   * @param {string} path - Page URL path (relative to baseURL)
   */
  constructor(page: Page, path: string) {
    this.page = page;
    this.baseUrl = process.env.BASE_URL || 'http://localhost:3000';
    this.url = `${this.baseUrl}${path}`;
  }

  /**
   * Navigate to the page
   * @param params Optional query parameters
   */
  async goto(params?: Record<string, string>): Promise<void> {
    let url = this.url;
    
    if (params) {
      const searchParams = new URLSearchParams();
      Object.entries(params).forEach(([key, value]) => {
        searchParams.append(key, value);
      });
      url = `${url}?${searchParams.toString()}`;
    }
    
    await this.page.goto(url);
    await this.waitForPageLoad();
  }

  /**
   * Wait for the page to be loaded
   */
  async waitForPageLoad(): Promise<void> {
    await this.page.waitForLoadState('domcontentloaded');
    await waitForNetworkIdle(this.page);
  }

  /**
   * Get the page title
   */
  async getTitle(): Promise<string> {
    return await this.page.title();
  }

  /**
   * Verify page is loaded correctly
   * Should be overridden by specific page implementations
   */
  async verifyPage() {
    const title = await this.getTitle();
    expect(title).toBeTruthy();
    return true;
  }

  /**
   * Check if an element is visible
   * @param {string|Locator} locator - Element locator
   */
  async isVisible(locator: string | Locator): Promise<boolean> {
    const element = typeof locator === 'string' ? this.page.locator(locator) : locator;
    return await element.isVisible();
  }

  /**
   * Get element text
   * @param {Locator} locator - Element locator
   */
  async getElementText(locator: Locator): Promise<string> {
    return getElementText(locator);
  }

  /**
   * Check if element is visible
   * @param {Locator} locator - Element locator
   */
  async isElementVisible(locator: Locator): Promise<boolean> {
    return await locator.isVisible();
  }

  /**
   * Fill input field
   * @param {Locator} locator - Input element locator
   * @param {string} value - Value to fill
   */
  async fillInput(locator: Locator, value: string) {
    await locator.waitFor({ state: 'visible' });
    await locator.fill(value);
  }

  /**
   * Click element
   * @param {Locator} locator - Element locator
   */
  async clickElement(locator: Locator) {
    await locator.waitFor({ state: 'visible' });
    await locator.click();
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

  /**
   * Get count of elements matching a selector
   * @param locator Element locator
   */
  async getElementCount(locator: Locator): Promise<number> {
    return await locator.count();
  }
} 