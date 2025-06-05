# Development Prompts for ICE-WEBAPP

This file contains optimized prompts for AI-assisted development using the ICE-WEBAPP stack.

## Component Generation

### Basic Component Prompt
```
Create a React component called {ComponentName} that:
- Uses TypeScript with proper type definitions
- Implements {functionality description}
- Follows our design system with Tailwind CSS
- Includes proper accessibility attributes
- Has responsive design for mobile and desktop
- Uses the cn() utility for conditional classes
- Exports both the component and its props interface

Component requirements:
- {specific requirements}

Design specifications:
- {design details}
```

### Advanced Component with State
```
Create a React component called {ComponentName} with the following specifications:

Functionality:
- {detailed functionality}
- Use Zustand for state management if needed
- Implement proper error handling
- Include loading states
- Use React Hook Form for forms if applicable

Technical Requirements:
- TypeScript with strict typing
- Responsive design using Tailwind CSS
- Accessibility compliance (WCAG 2.1)
- Performance optimized (use React.memo if needed)
- Proper prop validation with Zod if needed

Testing Requirements:
- Include unit tests using Vitest
- Test all user interactions
- Test accessibility with testing-library

File Structure:
- Main component: src/components/{ComponentName}.tsx
- Types: include in the same file or separate types file
- Tests: tests/unit/{ComponentName}.test.tsx
```

## Page Generation

### Landing Page Prompt
```
Create a modern landing page for {product/service} with the following sections:

Sections Required:
1. Hero section with compelling headline and CTA
2. Features section highlighting key benefits
3. Social proof (testimonials/reviews)
4. Pricing section (if applicable)
5. FAQ section
6. Contact/CTA section

Technical Specifications:
- Use Next.js App Router structure
- Implement proper SEO with metadata
- Responsive design with mobile-first approach
- Smooth animations using Framer Motion
- Optimize for Core Web Vitals
- Include proper TypeScript typing

Design Requirements:
- Modern, clean aesthetic
- Consistent color scheme using CSS variables
- Proper typography hierarchy
- Accessible design (contrast, focus states)
- Fast loading images with Next.js Image component

Performance Requirements:
- Lazy load sections below the fold
- Optimize images and assets
- Minimal JavaScript bundle
- Proper caching headers
```

### Dashboard Page Prompt
```
Create a dashboard page with the following features:

Layout:
- Sidebar navigation with main menu items
- Header with user profile and notifications
- Main content area with grid layout
- Responsive design that collapses sidebar on mobile

Components:
- Data visualization charts (using a chart library)
- Statistics cards with key metrics
- Recent activity feed
- Quick action buttons

Technical Implementation:
- Use React Query for data fetching
- Implement proper loading states
- Error boundaries for graceful error handling
- Real-time updates where applicable
- Proper TypeScript interfaces for all data

State Management:
- Use Zustand for global state
- Local state for component-specific data
- Persist user preferences in localStorage

Testing:
- Unit tests for all components
- Integration tests for user workflows
- Accessibility tests
```

## API Integration

### API Route Prompt
```
Create a Next.js API route for {endpoint purpose}:

Endpoint: /api/{endpoint-name}
Method: {GET/POST/PUT/DELETE}

Functionality:
- {detailed description of what the endpoint does}
- Proper request validation using Zod
- Error handling with appropriate HTTP status codes
- Rate limiting if needed
- Authentication/authorization checks

Request/Response:
- Request body structure: {describe structure}
- Response format: {describe expected response}
- Error response format with meaningful messages

Security:
- Input sanitization
- SQL injection prevention
- CORS configuration if needed
- Rate limiting for public endpoints

Testing:
- Unit tests for the API logic
- Integration tests for the full request/response cycle
- Error case testing
```

### Database Integration Prompt
```
Create database operations for {entity name}:

Schema Requirements:
- {describe the data structure}
- Proper indexing for performance
- Foreign key relationships if applicable

Operations Needed:
- CRUD operations (Create, Read, Update, Delete)
- Bulk operations if needed
- Search/filtering capabilities
- Pagination for large datasets

Implementation:
- Use {database solution - e.g., Prisma, Drizzle}
- Proper error handling
- Transaction support where needed
- Connection pooling optimization

Type Safety:
- TypeScript interfaces for all data models
- Zod schemas for validation
- Proper null/undefined handling

Testing:
- Unit tests for all database operations
- Test with mock data
- Test error scenarios
```

## Styling and Design

### Styling System Prompt
```
Create a comprehensive styling system for {component/page}:

Design Tokens:
- Color palette with semantic naming
- Typography scale with proper line heights
- Spacing system using Tailwind utilities
- Border radius and shadow definitions

Component Variants:
- Size variants (sm, md, lg, xl)
- Color variants (primary, secondary, success, warning, error)
- State variants (default, hover, focus, active, disabled)

Responsive Design:
- Mobile-first approach
- Breakpoint usage: sm (640px), md (768px), lg (1024px), xl (1280px)
- Touch-friendly interfaces for mobile

Accessibility:
- Proper contrast ratios
- Focus management
- Screen reader compatibility
- Keyboard navigation support

Dark Mode:
- CSS variables for theme switching
- Consistent color mapping
- Proper contrast in both modes
```

## Testing Prompts

### Unit Testing Prompt
```
Create comprehensive unit tests for {component/function name}:

Test Coverage Requirements:
- All props and prop combinations
- User interactions (clicks, form submissions, etc.)
- Conditional rendering scenarios
- Error states and edge cases
- Accessibility features

Testing Structure:
- Descriptive test names
- Proper setup and cleanup
- Mock external dependencies
- Use testing-library best practices

Accessibility Testing:
- Screen reader compatibility
- Keyboard navigation
- ARIA attributes
- Color contrast (if applicable)

Performance Testing:
- Re-render optimization
- Memory leak prevention
- Large dataset handling
```

### E2E Testing Prompt
```
Create end-to-end tests for {user workflow}:

User Journey:
- {step-by-step user flow}
- Happy path scenarios
- Error scenarios
- Edge cases

Test Implementation:
- Use Playwright for cross-browser testing
- Page Object Model for maintainability
- Proper wait strategies
- Screenshot comparison if needed

Data Management:
- Test data setup and cleanup
- Database seeding for consistent tests
- API mocking when appropriate

Performance:
- Page load times
- Time to interactive
- Core Web Vitals measurements
```

## Optimization Prompts

### Performance Optimization Prompt
```
Optimize {component/page} for maximum performance:

Code Splitting:
- Dynamic imports for heavy components
- Route-based code splitting
- Component lazy loading

Bundle Optimization:
- Tree shaking unused code
- Analyze bundle size with webpack-bundle-analyzer
- Remove unnecessary dependencies

Runtime Performance:
- React.memo for expensive components
- useMemo and useCallback optimization
- Virtual scrolling for large lists

Image Optimization:
- Next.js Image component usage
- WebP and AVIF format support
- Responsive image sizes
- Lazy loading implementation

Caching Strategy:
- Browser caching headers
- Service worker implementation
- API response caching
- Static asset optimization
```

### SEO Optimization Prompt
```
Implement comprehensive SEO for {page/section}:

Meta Tags:
- Title tag optimization (50-60 characters)
- Meta description (150-160 characters)
- Open Graph tags for social sharing
- Twitter Card meta tags
- Canonical URL specification

Structured Data:
- JSON-LD markup for relevant schema types
- Rich snippets optimization
- Local business markup if applicable

Performance for SEO:
- Core Web Vitals optimization
- Mobile-first indexing compliance
- Page load speed optimization
- Proper heading hierarchy (H1-H6)

Content Optimization:
- Semantic HTML structure
- Alt text for images
- Internal linking strategy
- Sitemap generation
```

## Security Prompts

### Security Implementation Prompt
```
Implement security measures for {feature/endpoint}:

Authentication:
- JWT token handling
- Session management
- Multi-factor authentication if needed
- Password security requirements

Authorization:
- Role-based access control
- Permission checking
- Resource-level authorization
- API route protection

Input Validation:
- Zod schema validation
- SQL injection prevention
- XSS protection
- CSRF token implementation

Data Protection:
- Sensitive data encryption
- Secure cookie configuration
- HTTPS enforcement
- Content Security Policy headers

Security Testing:
- Penetration testing scenarios
- Vulnerability scanning
- Security headers validation
```

## Usage Guidelines

1. **Customize prompts** by replacing placeholders `{like this}` with specific details
2. **Combine prompts** for complex features that require multiple aspects
3. **Iterate and refine** based on the AI's output and your specific needs
4. **Add context** about your project's specific requirements and constraints
5. **Include examples** when the desired output format is complex

## Best Practices

- Always specify TypeScript usage
- Include accessibility requirements
- Mention testing requirements upfront
- Specify responsive design needs
- Include performance considerations
- Request proper error handling
- Ask for meaningful comments in complex code 