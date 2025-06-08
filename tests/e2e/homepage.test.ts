import { test, expect } from '@playwright/test';
import { HomePage } from './pages/HomePage';
import { checkAccessibility, takeScreenshot } from './utils/test-helpers';

test.describe('Homepage Tests', () => {
  test('should load successfully', async ({ page }) => {
    // Arrange
    const homePage = new HomePage(page);
    
    // Act
    await homePage.goto();
    await homePage.waitForPageLoad();
    
    // Assert
    const title = await homePage.getTitle();
    expect(title).toBeTruthy();
    
    // Take screenshot for visual reference
    await takeScreenshot(page, 'homepage-loaded');
  });
  
  test('should have proper heading and content', async ({ page }) => {
    // Arrange
    const homePage = new HomePage(page);
    
    // Act
    await homePage.goto();
    await homePage.waitForPageLoad();
    
    // Assert
    const heading = await homePage.getMainHeading();
    expect(heading).toBeTruthy();
    
    const isMainContentVisible = await homePage.isElementVisible(homePage.mainContent);
    expect(isMainContentVisible).toBe(true);
  });
  
  test('should have navigation links if present', async ({ page }) => {
    // Arrange
    const homePage = new HomePage(page);
    
    // Act
    await homePage.goto();
    await homePage.waitForPageLoad();
    
    // Get navigation links
    const hasNavigation = await homePage.hasNavigation();
    
    // Skip this test if there's no navigation
    test.skip(!hasNavigation, 'No navigation present on page');
    
    if (hasNavigation) {
      const navLinks = await homePage.getNavigationLinkTexts();
      expect(navLinks.length).toBeGreaterThan(0);
    }
  });
  
  test('should pass basic accessibility checks', async ({ page }) => {
    // Arrange
    const homePage = new HomePage(page);
    
    // Act
    await homePage.goto();
    await homePage.waitForPageLoad();
    
    // Assert - Check accessibility
    const accessibilitySnapshot = await checkAccessibility(page);
    expect(accessibilitySnapshot).toBeTruthy();
  });
}); 