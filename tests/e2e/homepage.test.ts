import { test, expect } from '@playwright/test';
import { HomePage } from './pages/HomePage';
import { checkAccessibility, takeScreenshot } from './utils/test-helpers';

test.describe('Homepage Tests', () => {
  test('should load the homepage correctly', async ({ page }) => {
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
    
    // Assert
    const headingText = await homePage.getElementText(homePage.heading);
    expect(headingText).toBeTruthy();
    
    const isMainContentVisible = await homePage.isElementVisible(homePage.mainContent);
    expect(isMainContentVisible).toBe(true);
  });
  
  test('should have navigation links', async ({ page }) => {
    // Arrange
    const homePage = new HomePage(page);
    
    // Act
    await homePage.goto();
    const linkTexts = await homePage.getNavigationLinkTexts();
    
    // Assert
    expect(linkTexts.length).toBeGreaterThan(0);
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