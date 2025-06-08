import React, { ReactElement } from 'react';
import { render, RenderOptions as RTLRenderOptions } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe, toHaveNoViolations } from 'jest-axe';

// Add custom jest matchers for accessibility testing
expect.extend(toHaveNoViolations);

/**
 * Custom render function with common providers
 * @param ui Component to render
 * @param options Render options
 * @returns Rendered component with additional utilities
 */
function customRender(
  ui: ReactElement,
  options?: Omit<RTLRenderOptions, 'wrapper'>
) {
  return render(ui, { ...options });
}

/**
 * Creates a user event for interaction testing
 * @returns User event instance
 */
function createUserEvent() {
  return userEvent.setup();
}

/**
 * Tests a component for accessibility violations
 * @param element The rendered HTML element to test
 * @returns Promise with axe results
 */
async function checkAccessibility(element: Element) {
  const results = await axe(element);
  expect(results).toHaveNoViolations();
  return results;
}

/**
 * Wait for a specified amount of time
 * @param ms Milliseconds to wait
 * @returns Promise that resolves after the specified time
 */
function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Re-export everything from testing-library
export * from '@testing-library/react';

// Override render method
export { 
  customRender as render,
  createUserEvent,
  checkAccessibility,
  delay,
  axe
}; 