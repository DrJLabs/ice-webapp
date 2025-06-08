# AGENTS.md - ICE-WEBAPP Development Guidelines

## Guidelines for OpenAI Codex Agent Development

Based on the latest [OpenAI Model Specification](https://model-spec.openai.com/2025-02-12.html) and best practices for cloud-based software engineering agents.

---

## Core Development Principles

### 1. Scope and Focus
- **Always keep changes limited** to what is explicitly mentioned in the task
- **Validate understanding** by re-iterating requirements in different words before starting
- **Divide large tasks** into multiple milestones using "divide and conquer" approach
- **Make multiple small commits** instead of one large commit due to size limitations

### 2. Code Quality Standards
- **Simple is better than complicated** - prioritize clarity over cleverness
- **All code must be production-ready** from the first commit
- **Easy to reason about** - code should be self-documenting
- **Easy to extend and modify** in the future
- **Maintainable by design** - consider long-term maintenance burden

### 3. Technology Constraints
- **Don't use 3rd party libraries** unless explicitly requested or already in package.json
- **Focus on simplicity** in both design/architecture and implementation
- **Don't create new abstractions** unless absolutely required
- **Use existing patterns** established in the ICE-WEBAPP codebase

### 4. Code Documentation
- **Minimize comments** - write self-documenting code instead
- **Only add comments** when the next line is genuinely complex or counter-intuitive
- **Use TypeScript types** as primary documentation for data structures
- **Leverage existing utility functions** in `src/lib/utils.ts`

### 5. Dependency Management
- **Use exact version numbers** for all dependencies, never semver ranges
- **Do not update dependencies** without explicit permission from project maintainers
- **Each dependency update** must include proper security scanning with Trivy
- **Create dedicated branches** for dependency updates to isolate changes
- **Provide clear justification** for each dependency update (security, critical bug fix, etc.)
- **Run all tests and quality gates** after dependency updates
- **Immediately address security vulnerabilities** found during dependency scanning

---

## ICE-WEBAPP Specific Guidelines

### Project Structure Adherence
```
src/
├── components/     # Reusable React components only
├── app/           # Next.js App Router pages and layouts
├── lib/           # Utility functions and configurations
├── hooks/         # Custom React hooks
├── types/         # TypeScript type definitions
└── styles/        # Global styles and theme definitions
```

### TypeScript Requirements
- **Use strict TypeScript** - all code must pass `pnpm run type-check`
- **Define proper interfaces** for all component props
- **Use Zod schemas** for API validation and data parsing
- **Leverage existing types** from `src/types/` before creating new ones

### Component Development
- **Use the `cn()` utility** from `src/lib/utils.ts` for conditional classes
- **Follow Tailwind CSS patterns** established in existing components
- **Implement proper accessibility** with ARIA attributes
- **Ensure responsive design** works on mobile and desktop
- **Export both component and props interface**

### Testing Requirements
- **Write unit tests** for all components using Vitest
- **Use testing-library patterns** established in existing tests
- **Test accessibility features** with proper ARIA testing
- **Include error state testing** for all user interactions

### Performance Considerations
- **Use React.memo** only when performance testing shows it's needed
- **Implement proper loading states** for async operations
- **Optimize bundle size** - avoid importing entire libraries
- **Use Next.js Image component** for all images

---

## AI Agent Interaction Patterns

### Task Validation Process
1. **Read and understand** the complete task requirements
2. **Identify dependencies** on existing code or external services
3. **Confirm scope** by restating the task in your own words
4. **Ask clarifying questions** if requirements are ambiguous
5. **Propose approach** before implementing if the task is complex

### Development Workflow
1. **Analyze existing patterns** in the codebase first
2. **Follow established conventions** for file naming and structure
3. **Implement in small, testable chunks**
4. **Run quality checks** (`pnpm run lint`, `pnpm run type-check`) frequently
5. **Write or update tests** alongside implementation

### Error Handling Strategy
- **Implement graceful degradation** for all user-facing features
- **Use proper error boundaries** for React components
- **Provide meaningful error messages** that help users understand what went wrong
- **Log errors appropriately** for debugging without exposing sensitive data

### Security Considerations
- **Validate all inputs** using Zod schemas
- **Sanitize user data** before rendering or storing
- **Use proper authentication** patterns established in the codebase
- **Never expose sensitive data** in client-side code
- **Scan dependencies** for vulnerabilities before adding to the project
- **Keep dependencies updated** to patch versions with security fixes

---

## Code Review Checklist

Before submitting any code, verify:

### Functionality
- [ ] Code works as specified in the requirements
- [ ] All edge cases are handled appropriately
- [ ] Error states are properly managed
- [ ] Loading states are implemented where needed

### Quality
- [ ] TypeScript compilation passes (`pnpm run type-check`)
- [ ] Linting passes (`pnpm run lint`)
- [ ] Tests pass (`pnpm run test`)
- [ ] Code follows existing patterns in the codebase

### Performance
- [ ] No unnecessary re-renders
- [ ] Proper use of React hooks
- [ ] Bundle size impact is minimal
- [ ] Images are optimized

### Accessibility
- [ ] Proper ARIA attributes
- [ ] Keyboard navigation works
- [ ] Color contrast meets standards
- [ ] Screen reader compatibility

### Security
- [ ] Input validation is implemented
- [ ] No XSS vulnerabilities
- [ ] Sensitive data is protected
- [ ] Authentication/authorization is proper
- [ ] Dependencies are scanned for vulnerabilities
- [ ] No dependency versions with known security issues

---

## Common Patterns and Utilities

### Component Creation Pattern
```typescript
import { cn } from '@/lib/utils'

interface ComponentProps {
  // Define props with proper TypeScript types
}

export function Component({ ...props }: ComponentProps) {
  // Implementation with proper error handling
}

export type { ComponentProps }
```

### API Route Pattern
```typescript
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const RequestSchema = z.object({
  // Define request validation
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const validatedData = RequestSchema.parse(body)
    
    // Implementation with proper error handling
    
    return NextResponse.json({ success: true })
  } catch (error) {
    return NextResponse.json(
      { error: 'Validation failed' },
      { status: 400 }
    )
  }
}
```

### Custom Hook Pattern
```typescript
import { useState, useEffect } from 'react'

export function useCustomHook() {
  // Implementation with proper cleanup
  return {
    // Return object with stable references
  }
}
```

---

## Emergency Procedures

### When Things Go Wrong
1. **Stop and assess** - don't rush to fix without understanding
2. **Check the logs** for specific error messages
3. **Revert to last working state** if necessary
4. **Test in isolation** to identify the root cause
5. **Ask for help** if the issue is beyond your understanding

### Debugging Strategy
1. **Use TypeScript errors** as the first debugging tool
2. **Check the browser console** for runtime errors
3. **Use React DevTools** for component state inspection
4. **Verify API responses** using network tab
5. **Check test failures** for clues about the issue

---

## Success Metrics

### Definition of Done
- [ ] Feature works as specified
- [ ] All tests pass
- [ ] Code quality gates pass
- [ ] Documentation is updated if needed
- [ ] Performance impact is acceptable
- [ ] Security review is complete (for sensitive features)

### Code Quality Metrics
- **TypeScript coverage**: 100% (no `any` types)
- **Test coverage**: >90% for new code
- **Lint errors**: 0 tolerance
- **Bundle size impact**: <10% increase per feature

---

*This document is based on the OpenAI Model Specification and best practices for cloud-based software engineering agents. It should be referenced for all development work within the ICE-WEBAPP project.* 