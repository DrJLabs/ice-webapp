import React, { ReactElement } from 'react';
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';

// Add custom jest matchers
expect.extend(toHaveNoViolations);

// Define custom render options type
type CustomRenderOptions = Parameters<typeof render>[1] & {
  wrapper?: React.ComponentType<{ children: React.ReactNode }>;
};

// Define a custom render method that includes common providers
const customRender = (
  ui: ReactElement,
  options?: Omit<CustomRenderOptions, 'wrapper'>,
) => {
  return render(ui, { ...options });
};

// Re-export everything from testing-library
export * from '@testing-library/react';

// Override render method
export { customRender as render };

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

/**
 * Helper function to wait for a specified time
 * @param ms - Milliseconds to wait
 * @returns Promise that resolves after the specified time
 */
export const wait = (ms: number) => new Promise(resolve => setTimeout(resolve, ms)); 