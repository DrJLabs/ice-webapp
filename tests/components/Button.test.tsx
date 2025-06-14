import React from 'react';
import { render, screen, checkAccessibility, createUserEvent } from '../test-utils';
import { vi, expect } from 'vitest';

// Mock component for testing purposes
const Button = ({
  onClick,
  disabled = false,
  variant = 'primary',
  children,
  ...props
}: {
  onClick?: () => void;
  disabled?: boolean;
  variant?: 'primary' | 'secondary' | 'outline';
  children: React.ReactNode;
  [key: string]: any;
}) => {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant}`}
      {...props}
    >
      {children}
    </button>
  );
};

describe('Button Component', () => {
  it('renders correctly with default props', () => {
    render(<Button>Click me</Button>);
    
    const button = screen.getByRole('button', { name: /click me/i });
    expect(button).toBeDefined();
    expect(button.classList.contains('btn')).toBe(true);
    expect(button.classList.contains('btn-primary')).toBe(true);
  });
  
  it('renders with correct variant class', () => {
    render(<Button variant="secondary">Secondary Button</Button>);
    
    const button = screen.getByRole('button', { name: /secondary button/i });
    expect(button.classList.contains('btn-secondary')).toBe(true);
  });
  
  it('applies disabled attribute when disabled', () => {
    render(<Button disabled>Disabled Button</Button>);
    
    const button = screen.getByRole('button', { name: /disabled button/i });
    expect(button.hasAttribute('disabled')).toBe(true);
  });
  
  it('calls onClick handler when clicked', async () => {
    const handleClick = vi.fn();
    const user = createUserEvent();
    
    render(<Button onClick={handleClick}>Clickable Button</Button>);
    
    const button = screen.getByRole('button', { name: /clickable button/i });
    await user.click(button);
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
  
  it('does not call onClick handler when disabled and clicked', async () => {
    const handleClick = vi.fn();
    const user = createUserEvent();
    
    render(
      <Button onClick={handleClick} disabled>
        Disabled Button
      </Button>
    );
    
    const button = screen.getByRole('button', { name: /disabled button/i });
    await user.click(button);
    
    expect(handleClick).not.toHaveBeenCalled();
  });
  
  it('passes accessibility tests', async () => {
    const { container } = render(<Button>Accessible Button</Button>);
    await checkAccessibility(container);
  });
}); 