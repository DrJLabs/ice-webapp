import { Page, Locator, expect } from '@playwright/test';

/**
 * Base Page Object Model class
 * All page objects should extend this class
 */
export class BasePage {
  readonly page: Page;
  readonly url: string;

  /**
   * @param {Page} page - Playwright page
   * @param {string} url - Page URL path (relative to baseURL)
   */
  constructor(page: Page, url: string = '/') {
    this.page = page;
    this.url = url;
  }

  /**
   * Navigate to the page
   */
  async goto() {
    await this.page.goto(this.url);
  }

  /**
   * Wait for page to be loaded
   * Override in specific page objects with more precise conditions
   */
  async waitForPageLoad() {
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Get page title
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
   * Take a screenshot
   * @param {string} name - Screenshot name
   */
  async takeScreenshot(name: string) {
    await this.page.screenshot({ path: `./test-results/screenshots/${name}.png` });
  }

  /**
   * Get element text
   * @param {Locator} locator - Element locator
   */
  async getElementText(locator: Locator): Promise<string> {
    await locator.waitFor({ state: 'visible' });
    return await locator.innerText();
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
} 