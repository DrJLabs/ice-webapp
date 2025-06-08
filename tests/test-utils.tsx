import React, { ReactElement } from 'react';
import { render, RenderOptions as RTLRenderOptions, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe, toHaveNoViolations } from 'jest-axe';

// Add custom jest matchers for accessibility testing
expect.extend(toHaveNoViolations);

// Define custom render options type
type CustomRenderOptions = Parameters<typeof render>[1] & {
  wrapper?: React.ComponentType<{ children: React.ReactNode }>;
};

/**
 * Custom render function with common providers
 * @param ui Component to render
 * @param options Render options
 * @returns Rendered component with additional utilities
 */
function customRender(
  ui: ReactElement,
  options?: Omit<CustomRenderOptions, 'wrapper'>
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

// Export custom functions
export { 
  customRender as render,
  createUserEvent,
  checkAccessibility,
  delay,
  axe,
  screen
}; 

/**
 * Test component for accessibility violations
 * @param ui - React component to test
 * @param options - Render options
 * @returns Promise that resolves when accessibility tests are complete
 */
export const testA11y = async (
  ui: ReactElement,
  options?: Omit<CustomRenderOptions, 'wrapper'>,
) => {
  const container = render(ui, options).container;
  const results = await axe(container);
  expect(results).toHaveNoViolations();
  return results;
};
