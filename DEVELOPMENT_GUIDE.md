# 🧊 ICE-WEBAPP Development Guide

## Overview

This guide provides comprehensive development standards and best practices for the ICE-WEBAPP project. It's designed to help both human developers and AI assistants maintain high-quality, consistent code.

## 🎯 Core Development Principles

### 1. Scope Management
- **Keep changes focused** - Only implement what's explicitly requested
- **Validate understanding** - Restate requirements before implementation
- **Break down complexity** - Divide large tasks into manageable steps
- **Incremental commits** - Make small, focused commits rather than large ones

### 2. Code Quality Standards
- **Production-ready code** from the first commit
- **Simple over complex** - Prioritize clarity and maintainability
- **Self-documenting code** - Minimize comments, use clear naming
- **Follow existing patterns** - Maintain consistency with the codebase

### 3. Technology Stack
- **Next.js 15** with App Router
- **React 19** with latest features
- **TypeScript 5.7** in strict mode
- **Tailwind CSS 3.4** for styling
- **pnpm** for package management

## 📋 Quality Gates

### Required Checks
All code must pass these checks before commit:

```bash
pnpm run type-check    # TypeScript compilation
pnpm run lint          # ESLint validation
pnpm run test          # Unit tests
pnpm run test:e2e      # E2E tests (when applicable)
```

### Codacy Integration
- **Automatic analysis** after file edits
- **Security scanning** with Trivy for dependencies
- **Quality gates** enforced on all branches

## 🏗️ Project Structure

```
src/
├── app/              # Next.js App Router pages and layouts
├── components/       # Reusable React components
├── lib/              # Utility functions and configurations
├── hooks/            # Custom React hooks
├── types/            # TypeScript type definitions
└── styles/           # Global styles and theme definitions

tests/
├── components/       # Component unit tests
├── e2e/             # End-to-end tests
└── lib/             # Utility function tests
```

## 🔧 Development Standards

### TypeScript
- **Strict mode enabled** - No `any` types allowed
- **Proper interfaces** for all component props
- **Zod schemas** for API validation
- **Export type definitions** alongside implementations

### React Components
```typescript
import { cn } from '@/lib/utils'

interface ComponentProps {
  className?: string
  children?: React.ReactNode
  // ... other props with proper types
}

export function Component({ className, children, ...props }: ComponentProps) {
  return (
    <div className={cn("base-styles", className)} {...props}>
      {children}
    </div>
  )
}

export type { ComponentProps }
```

### API Routes
```typescript
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const RequestSchema = z.object({
  // Define validation schema
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const validatedData = RequestSchema.parse(body)
    
    // Implementation
    
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json(
      { error: 'Validation failed' },
      { status: 400 }
    )
  }
}
```

## 🧪 Testing Strategy

### Unit Tests
- **Vitest** for test runner
- **Testing Library** for React component testing
- **Test user interactions** not implementation details
- **Mock external dependencies** appropriately

### E2E Tests
- **Playwright** for browser automation
- **Docker environment** available for isolated testing
- **Test critical user flows** end-to-end
- **Accessibility testing** included

### Testing Patterns
```typescript
import { render, screen } from '@testing-library/react'
import { userEvent } from '@testing-library/user-event'
import { expect, test } from 'vitest'
import { Component } from './Component'

test('component handles user interaction', async () => {
  const user = userEvent.setup()
  render(<Component />)
  
  const button = screen.getByRole('button', { name: /click me/i })
  await user.click(button)
  
  expect(screen.getByText(/success/i)).toBeInTheDocument()
})
```

## 🛡️ Security Practices

### Input Validation
- **Zod schemas** for all external data
- **Sanitize user input** before rendering
- **Validate on both client and server** sides

### Dependency Management
- **Exact version numbers** - No semver ranges
- **Security scanning** with Trivy
- **Regular updates** for security patches only
- **Approval required** for dependency changes

### Content Security
- **CSP headers** configured
- **XSS protection** enabled
- **Secure cookie settings**
- **HTTPS enforcement**

## 🎨 Styling Guidelines

### Tailwind CSS
- **Utility-first approach** - Use Tailwind classes
- **Custom components** for complex reusable styles
- **Responsive design** - Mobile-first approach
- **Dark mode support** - Built-in theme switching

### Design System
- **Consistent spacing** using Tailwind spacing scale
- **Typography hierarchy** with defined text styles
- **Color palette** following accessibility standards
- **Component variants** using class variance authority (CVA)

## 🚀 Performance Standards

### Core Web Vitals
- **LCP < 2.5s** - Largest Contentful Paint
- **FID < 100ms** - First Input Delay
- **CLS < 0.1** - Cumulative Layout Shift

### Optimization Techniques
- **Code splitting** by route and component
- **Image optimization** with Next.js Image
- **Bundle analysis** to monitor size
- **Lazy loading** for non-critical content

## 🔄 Development Workflow

### Branch Strategy
- **Main branch** - Production-ready code
- **Develop branch** - Integration branch
- **Feature branches** - Specific features or fixes
- **AI branches** - `cursor/*` or `codex/*` prefixes

### Commit Guidelines
- **Conventional commits** format
- **Clear, descriptive messages**
- **Single concern** per commit
- **Include issue references** when applicable

### Code Review Process
- **All changes** require review
- **Quality gates** must pass
- **Accessibility** requirements verified
- **Performance impact** assessed

## 🔧 Tools and Utilities

### Essential Utilities
- **`cn()` utility** - For conditional class names
- **`clsx`** - Class name concatenation
- **`tailwind-merge`** - Tailwind class merging

### Development Tools
- **ESLint** - Code linting and style enforcement
- **Prettier** - Code formatting
- **Husky** - Git hooks for quality gates
- **Playwright** - E2E testing framework

## 📚 Learning Resources

### Documentation
- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

### Project-Specific Guides
- [Quick Start Guide](QUICK_START.md) - Getting started quickly
- [Codex Integration](CODEX_GUIDE.md) - AI assistant setup
- [E2E Testing](E2E_SETUP_GUIDE.md) - End-to-end testing setup
- [Deployment Guide](DEPLOYMENT.md) - Production deployment

## 🤝 Contributing

### Before Starting
1. **Read this guide** thoroughly
2. **Set up development environment** using setup scripts
3. **Run quality checks** to ensure environment is ready
4. **Review existing code** to understand patterns

### During Development
1. **Follow established patterns** in the codebase
2. **Write tests** for new functionality
3. **Run quality checks** frequently
4. **Commit small, focused changes**

### Before Submitting
1. **All quality gates** must pass
2. **Tests provide adequate coverage**
3. **Documentation updated** if needed
4. **Performance impact** considered

---

**Remember**: This guide evolves with the project. Keep it updated as standards and practices change. 