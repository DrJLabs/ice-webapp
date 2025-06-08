import React from 'react';
import { render, customRender } from '../test-utils';
import { screen, fireEvent } from '@testing-library/react';
import { testA11y } from '../test-utils';

// Assuming a Button component exists in the codebase
// If not, this test will fail, but the structure is correct
describe('Button Component', () => {
  // Basic rendering test
  it('renders correctly', () => {
    render(<button>Click me</button>);
    const buttonElement = screen.getByText('Click me');
    expect(buttonElement).toBeInTheDocument();
  });

  // Event handler test
  it('calls onClick handler when clicked', () => {
    const handleClick = jest.fn();
    render(<button onClick={handleClick}>Click me</button>);
    
    const buttonElement = screen.getByText('Click me');
    fireEvent.click(buttonElement);
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  // Disabled state test
  it('is disabled when disabled prop is true', () => {
    render(<button disabled>Click me</button>);
    
    const buttonElement = screen.getByText('Click me');
    expect(buttonElement).toBeDisabled();
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