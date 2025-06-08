import { Page, Locator, expect } from '@playwright/test';
import { BasePage } from './BasePage';

/**
 * Page Object Model for the Home Page
 */
export class HomePage extends BasePage {
  constructor(page: Page) {
    super(page, '/');
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
   * Get all navigation links
   */
  async getNavigationLinks(): Promise<string[]> {
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
          const text = await links.nth(i).textContent();
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
   */
  async clickNavigationLink(text: string): Promise<void> {
    const navSelectors = [
      'nav',
      '[role="navigation"]',
      'header ul',
      '.navbar',
    ];

    for (const selector of navSelectors) {
      const nav = this.page.locator(selector).first();
      
      if (await nav.isVisible()) {
        await this.page.getByRole('link', { name: text }).click();
        return;
      }
    }

    throw new Error(`Navigation link with text "${text}" not found`);
  }

  /**
   * Check if the page has a footer
   */
  async hasFooter() {
    return await this.isVisible('footer');
  }

  /**
   * Verify the homepage has loaded correctly
   */
  async verifyHomePageLoaded() {
    await this.waitForPageLoad();
    const title = await this.getTitle();
    expect(title).toContain('ICE-WEBAPP');
    expect(await this.hasNavigation()).toBeTruthy();
  }
} 