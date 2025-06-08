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
    this.heading = page.locator('h1').first();
    this.mainContent = page.locator('main');
    this.navigationLinks = page.locator('nav a');
  }

  /**
   * Override waitForPageLoad to provide more specific wait conditions
   */
  async waitForPageLoad() {
    // Wait for the page to be stable
    await super.waitForPageLoad();
    
    // Try to wait for common elements, but don't fail if they don't exist
    try {
      await this.heading.waitFor({ state: 'visible', timeout: 3000 }).catch(() => {});
      await this.mainContent.waitFor({ state: 'visible', timeout: 3000 }).catch(() => {});
    } catch (error) {
      // Continue even if elements aren't found
    }
  }

  /**
   * Get the main heading of the page
   */
  async getMainHeading(): Promise<string | null> {
    // Try to find the main heading using different common selectors
    const headingSelectors = [
      'h1',
      '[role="heading"][aria-level="1"]',
      '.main-heading',
      '#hero-heading',
    ];

    for (const selector of headingSelectors) {
      const heading = this.page.locator(selector).first();
      if (await heading.isVisible()) {
        return await heading.textContent();
      }
    }

    return null;
  }

  /**
   * Check if navigation exists on the page
   */
  async hasNavigation(): Promise<boolean> {
    const navSelectors = [
      'nav',
      '[role="navigation"]',
      'header ul',
      '.navbar',
    ];

    for (const selector of navSelectors) {
      const nav = this.page.locator(selector).first();
      if (await nav.isVisible()) {
        return true;
      }
    }

    return false;
  }

  /**
   * Get all navigation link texts
   */
  async getNavigationLinkTexts(): Promise<string[]> {
    const navSelectors = [
      'nav a',
      '[role="navigation"] a',
      'header ul a',
      '.navbar a',
    ];

    for (const selector of navSelectors) {
      const links = this.page.locator(selector);
      const count = await links.count();
      
      if (count > 0) {
        const linkTexts: string[] = [];
        
        for (let i = 0; i < count; i++) {
          const link = links.nth(i);
          const text = await link.textContent();
          if (text) {
            linkTexts.push(text.trim());
          }
        }
        
        return linkTexts;
      }
    }

    return [];
  }

  /**
   * Click a navigation link by text
   * @param {string} linkText - The text of the link to click
   */
  async clickNavigationLink(linkText: string) {
    const link = this.page.getByRole('link', { name: linkText });
    await this.clickElement(link);
  }
  
  /**
   * Verify the home page is loaded correctly
   */
  async verifyPage() {
    await this.waitForPageLoad();
    
    const heading = await this.getMainHeading();
    expect(heading).toBeTruthy();
    
    return true;
  }
} 