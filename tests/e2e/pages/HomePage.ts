import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * Home Page Object
 * Represents the main landing page of the application
 */
export class HomePage extends BasePage {
  // Locators
  readonly heading: Locator;
  readonly mainContent: Locator;
  readonly navigationLinks: Locator;

  /**
   * @param {Page} page - Playwright page
   */
  constructor(page: Page) {
    super(page, '/');
    
    // Initialize locators
    this.heading = page.locator('h1');
    this.mainContent = page.locator('main');
    this.navigationLinks = page.locator('nav a');
  }

  /**
   * Override waitForPageLoad to provide more specific wait conditions
   */
  async waitForPageLoad() {
    await this.heading.waitFor({ state: 'visible' });
    await this.mainContent.waitFor({ state: 'visible' });
  }

  /**
   * Verify the home page is loaded correctly
   */
  async verifyPage() {
    await this.waitForPageLoad();
    
    const headingText = await this.getElementText(this.heading);
    expect(headingText).toBeTruthy();
    
    const isMainContentVisible = await this.isElementVisible(this.mainContent);
    expect(isMainContentVisible).toBeTruthy();
    
    return true;
  }

  /**
   * Get all navigation link texts
   */
  async getNavigationLinkTexts(): Promise<string[]> {
    await this.navigationLinks.first().waitFor({ state: 'visible' });
    const count = await this.navigationLinks.count();
    
    const linkTexts: string[] = [];
    for (let i = 0; i < count; i++) {
      const link = this.navigationLinks.nth(i);
      linkTexts.push(await link.innerText());
    }
    
    return linkTexts;
  }

  /**
   * Click on a navigation link by its text
   * @param {string} linkText - The text of the link to click
   */
  async clickNavigationLink(linkText: string) {
    const link = this.page.locator('nav a', { hasText: linkText });
    await this.clickElement(link);
  }
} 