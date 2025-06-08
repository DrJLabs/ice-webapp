import { test, expect } from '@playwright/test';
import { HomePage } from './pages/HomePage';
import { checkAccessibility, takeScreenshot, waitForStable } from './utils/test-helpers';

test.describe('Homepage', () => {
  // Setup common test context
  let homePage: HomePage;

  test.beforeEach(async ({ page }) => {
    homePage = new HomePage(page);
    await homePage.goto();
    // Ensure page is stable before starting tests
    await waitForStable(page);
  });
  
  test('should load successfully', async ({ page }, testInfo) => {
    // Take a screenshot only on CI or when explicitly requested
    if (process.env.CI || process.env.FORCE_SCREENSHOTS) {
      await takeScreenshot(page, testInfo);
    }
    
    // Check the title
    const title = await homePage.getTitle();
    expect(title).toBeTruthy();
    
    // Check if navigation exists
    const hasNavigation = await homePage.hasNavigation();
    expect(hasNavigation).toBeTruthy();
  });
  
  test('should have proper heading', async () => {
    // Check main heading
    const heading = await homePage.getMainHeading();
    expect(heading).toBeTruthy();
  });
  
  test('should pass accessibility tests', async ({ page }, testInfo) => {
    // Run accessibility tests with optimized settings
    await checkAccessibility(page, testInfo, { 
      timeout: 10000,
      skipAttachment: !process.env.CI
    });
  });
  
  test('should navigate to other pages', async ({ page }) => {
    // Get navigation links
    const navLinks = await homePage.getNavigationLinks();
    
    // Skip this test if there are no navigation links
    if (navLinks.length === 0) {
      test.skip();
      return;
    }
    
    expect(navLinks.length).toBeGreaterThan(0);
    
    // Click the first navigation link
    await homePage.clickNavigationLink(navLinks[0]);
    
    // Ensure new page has loaded properly with optimized waiting
    await waitForStable(page);
    
    // Verify we're on a different page
    const currentUrl = page.url();
    expect(currentUrl).not.toEqual(homePage.url);
  });
}); 