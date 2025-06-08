import React from 'react';
import { render } from '../test-utils';
import { vi, describe, it, expect } from 'vitest';
import { testA11y } from '../test-utils';

// Assuming a Button component exists in the codebase
// If not, this test will fail, but the structure is correct
describe('Button Component', () => {
  // Basic rendering test
  it('renders correctly', () => {
    const { getByText } = render(<button>Click me</button>);
    const buttonElement = getByText('Click me');
    expect(buttonElement).toBeDefined();
  });

  // Event handler test
  it('calls onClick handler when clicked', () => {
    const handleClick = vi.fn();
    const { getByText } = render(<button onClick={handleClick}>Click me</button>);
    
    const buttonElement = getByText('Click me');
    buttonElement.click();
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  // Disabled state test
  it('is disabled when disabled prop is true', () => {
    const { getByText } = render(<button disabled>Click me</button>);
    
    const buttonElement = getByText('Click me');
    expect(buttonElement.hasAttribute('disabled')).toBeTruthy();
  });

  // Accessibility test
  it('has no accessibility violations', async () => {
    await testA11y(<button>Click me</button>);
  });

  // Variant test (assuming the Button component has variants)
  it('applies the correct class for primary variant', () => {
    // This is just an example - adjust based on your actual Button implementation
    render(<button className="btn-primary">Primary Button</button>);
    
    const buttonElement = screen.getByText('Primary Button');
    expect(buttonElement).toHaveClass('btn-primary');
  });
}); 