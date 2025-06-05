# ChatGPT Codex Integration Guide

## OpenAI Codex Best Practices for ICE-WEBAPP

This guide provides comprehensive instructions for using ICE-WEBAPP with OpenAI's ChatGPT Codex, based on the latest [OpenAI Model Specification](https://model-spec.openai.com/2025-02-12.html) and cloud-based software engineering agent best practices.

---

## 🎯 Quick Setup for Codex

### 1. Codex-Optimized Setup (Recommended)

**Use the specialized Codex setup script that leverages pre-installed packages:**

```bash
# Optimized for Codex pre-installed packages (Node.js 20, Python 3.12, etc.)
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/setup-codex.sh | bash
```

**Key advantages of the Codex-optimized script:**
- ✅ Uses pre-installed Node.js 20 (no version conflicts)
- ✅ No sudo requirements (runs as root in Codex)
- ✅ Optimized dependency versions for Node.js 20
- ✅ Container-specific configurations
- ✅ Faster setup (leverages pre-installed tools)

**Alternative: Fix common issues then use main setup:**
```bash
# Fix shell detection, Node.js version, and npm proxy issues
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/tools/codex-setup.sh | bash

# Then run main setup
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/setup.sh | bash
```

**If you encounter setup errors**, see the [Codex Troubleshooting Guide](CODEX_TROUBLESHOOTING.md) for specific solutions.

### 2. Legacy Setup (If Codex Issues Persist)

**Copy this setup script to your Codex environment:**

```bash
#!/usr/bin/env bash
# ICE-WEBAPP Codex Environment Setup (Fallback)
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/setup.sh | bash
```

**Or use the complete setup.sh contents** from the ICE-WEBAPP repository for offline-capable environments.

### 3. Environment Variables (Optional)

Add these to your Codex secrets:

```bash
# Code quality and security
CODACY_ACCOUNT_TOKEN=your_account_token
CODACY_PROJECT_TOKEN=your_project_token

# Development
NODE_ENV=development
NEXT_PUBLIC_APP_NAME="My Codex WebApp"
```

### 4. Verify Setup

Your Codex environment will automatically configure:
- ✅ Node.js 22.12.0
- ✅ pnpm package manager
- ✅ Bleeding-edge dependencies
- ✅ AI-optimized project structure
- ✅ Quality assurance tools

---

## 🤖 Optimal Ruleset Configuration

### Core Agent Rules

Based on OpenAI Model Specification and victorb's AGENTS.md best practices:

```markdown
## Development Guidelines for this Task

### Scope Management
- Keep all changes LIMITED to what is explicitly mentioned in this task
- VALIDATE your understanding by restating the requirements in different words
- If the task is large, DIVIDE it into smaller milestones and work through them sequentially
- Make MULTIPLE SMALL commits instead of one large commit

### Code Quality Standards
- Write PRODUCTION-READY code from the first commit
- Prioritize SIMPLICITY over complexity
- Make code EASY TO REASON ABOUT and extend
- Use EXISTING PATTERNS established in the ICE-WEBAPP codebase

### Technology Constraints
- DON'T use 3rd party libraries unless explicitly requested or already in package.json
- DON'T create new abstractions unless absolutely required
- USE EXISTING utilities from src/lib/utils.ts
- FOLLOW the established project structure

### ICE-WEBAPP Specific Patterns
- Use the cn() utility for conditional CSS classes
- Follow TypeScript strict mode requirements
- Implement proper error handling and loading states
- Use Zod schemas for data validation
- Write tests alongside implementation

### Quality Checklist
Before marking task complete, verify:
- [ ] TypeScript compilation passes (pnpm run type-check)
- [ ] Linting passes (pnpm run lint)
- [ ] Tests pass (pnpm run test)
- [ ] Code follows existing patterns
- [ ] Proper accessibility implementation
- [ ] Responsive design works on mobile/desktop
```

### Enhanced Ruleset for Complex Tasks

```markdown
## Advanced Development Guidelines

### Task Validation Process
1. READ and understand the complete task requirements
2. IDENTIFY dependencies on existing code or external services
3. CONFIRM scope by restating the task requirements
4. ASK clarifying questions if any requirements are ambiguous
5. PROPOSE your approach before implementing complex features

### Error Handling Strategy
- Implement GRACEFUL DEGRADATION for all user-facing features
- Use proper ERROR BOUNDARIES for React components
- Provide MEANINGFUL error messages that help users
- Log errors appropriately without exposing sensitive data

### Security Implementation
- VALIDATE ALL INPUTS using Zod schemas
- SANITIZE user data before rendering or storing
- Use PROPER AUTHENTICATION patterns from the codebase
- NEVER EXPOSE sensitive data in client-side code

### Performance Considerations
- Use React.memo ONLY when performance testing shows it's needed
- Implement proper LOADING STATES for async operations
- OPTIMIZE bundle size - avoid importing entire libraries
- Use NEXT.JS IMAGE component for all images

### Testing Requirements
- Write UNIT TESTS for all components using Vitest
- Use TESTING-LIBRARY patterns from existing tests
- Test ACCESSIBILITY features with proper ARIA testing
- Include ERROR STATE testing for all user interactions
```

---

## 📝 Task-Specific Prompt Templates

### Component Development Prompt

```
Task: Create a React component called {ComponentName}

Requirements:
- TypeScript with proper interfaces
- Responsive design using Tailwind CSS
- Accessibility compliance (WCAG 2.1)
- Error handling and loading states
- Unit tests with Vitest

Technical Specifications:
- Use cn() utility from @/lib/utils for conditional classes
- Export both component and props interface
- Follow existing component patterns in src/components/
- Implement proper ARIA attributes
- Ensure mobile-first responsive design

Quality Requirements:
- Pass TypeScript strict mode
- Zero linting errors
- >90% test coverage
- Accessibility compliance

Please validate your understanding of these requirements before starting implementation.
```

### API Development Prompt

```
Task: Create a Next.js API route for {purpose}

Requirements:
- Proper TypeScript typing throughout
- Zod schema validation for requests
- Comprehensive error handling
- Security best practices implementation

Technical Specifications:
- Endpoint: /api/{endpoint-name}
- Method: {GET/POST/PUT/DELETE}
- Request validation using Zod
- Response format: JSON with proper HTTP status codes
- Rate limiting if needed
- Authentication/authorization checks

Security Requirements:
- Input sanitization
- SQL injection prevention
- Proper error responses without data leakage
- CORS configuration if needed

Testing Requirements:
- Unit tests for API logic
- Integration tests for request/response cycle
- Error case testing

Please confirm your understanding and propose the API structure before implementation.
```

### Page Development Prompt

```
Task: Create a Next.js page for {purpose}

Requirements:
- Modern, responsive design
- SEO optimization
- Performance optimization
- Accessibility compliance

Technical Specifications:
- Use Next.js App Router structure
- Implement proper metadata for SEO
- Mobile-first responsive design
- Core Web Vitals optimization
- TypeScript throughout

Design Requirements:
- Follow existing design system
- Consistent color scheme and typography
- Proper loading states
- Error boundaries
- Smooth animations (if appropriate)

Performance Requirements:
- Lazy load content below the fold
- Optimize images with Next.js Image
- Minimal JavaScript bundle
- Proper caching strategies

Please validate requirements and propose page structure before starting.
```

---

## 🔧 Environment-Specific Configurations

### Codex Environment Optimizations

**Memory Management**
```bash
# Configure Node.js for Codex containers
export NODE_OPTIONS="--max-old-space-size=4096"
export PNPM_STORE="/tmp/.pnpm-store"
```

**Build Optimizations**
```bash
# Faster builds in Codex
export NEXT_TELEMETRY_DISABLED=1
export DISABLE_ESLINT_PLUGIN=true  # Only during development
```

**Development Speed**
```bash
# Quick development iteration
pnpm run dev --turbo  # Use Turbo for faster builds
pnpm run test --run   # Single test run, no watch mode
```

### Codex-Specific Scripts

Add these to your Codex tasks:

```bash
# Quick quality check
alias qcheck="pnpm run type-check && pnpm run lint && pnpm run test --run"

# Fast development cycle
alias dev-fast="pnpm run dev --turbo"

# Production readiness check
alias prod-check="pnpm run build && pnpm run test && ./tools/codacy-runtime.sh"
```

---

## 🚀 Advanced Codex Workflows

### Multi-Stage Development

**Stage 1: Foundation**
```bash
# Initial setup and basic structure
./tools/ice-bootstrap.sh --codex-only my-feature
cd my-feature
pnpm install
```

**Stage 2: Core Implementation**
```bash
# Follow AGENTS.md guidelines for core features
pnpm run dev
# Implement main functionality
pnpm run test
```

**Stage 3: Quality Assurance**
```bash
# Run comprehensive quality checks
pnpm run type-check
pnpm run lint:fix
./tools/codacy-runtime.sh
```

**Stage 4: Production Readiness**
```bash
# Final validation
pnpm run build
pnpm run test:e2e
./scripts/dependency-sync.sh --validate
```

### Parallel Task Processing

Codex supports parallel task execution. Use this pattern:

```bash
# Task 1: Component development
# Task 2: API implementation  
# Task 3: Testing and quality assurance

# Each task runs in isolated container
# Use shared codebase through git
```

---

## 🔍 Debugging in Codex Environment

### Common Issues and Solutions

**TypeScript Errors**
```bash
# Check for type errors
pnpm run type-check

# Common fixes
- Ensure all imports use proper paths
- Check for missing dependencies
- Verify TypeScript configuration
```

**Build Failures**
```bash
# Clear cache and rebuild
rm -rf .next node_modules
pnpm install
pnpm run build
```

**Test Failures**
```bash
# Run tests with verbose output
pnpm run test --reporter=verbose

# Debug specific test
pnpm run test path/to/test.test.ts
```

**Linting Issues**
```bash
# Auto-fix most linting errors
pnpm run lint:fix

# Check specific files
pnpm run lint src/components/MyComponent.tsx
```

### Performance Monitoring

```bash
# Bundle analysis
pnpm run analyze

# Build performance
time pnpm run build

# Test performance
pnpm run test --reporter=verbose --run
```

---

## 📊 Quality Metrics and Gates

### Required Quality Gates

| Check | Command | Required Result |
|-------|---------|-----------------|
| TypeScript | `pnpm run type-check` | ✅ No errors |
| Linting | `pnpm run lint` | ✅ No errors |
| Testing | `pnpm run test` | ✅ All pass |
| Build | `pnpm run build` | ✅ Successful |
| Security | `./tools/codacy-runtime.sh` | ✅ No critical issues |

### Performance Benchmarks

| Metric | Target | Measurement |
|--------|--------|-------------|
| Bundle Size | <500KB | `pnpm run analyze` |
| Build Time | <30s | `time pnpm run build` |
| Test Speed | <10s | `time pnpm run test --run` |
| Type Check | <5s | `time pnpm run type-check` |

---

## 🎯 Best Practices Summary

### For Optimal Codex Performance

1. **Start each task by reading AGENTS.md**
2. **Use the provided prompt templates**
3. **Validate understanding before implementation**
4. **Follow the quality checklist**
5. **Run quality gates frequently**
6. **Keep commits small and focused**
7. **Use existing patterns and utilities**
8. **Test thoroughly before completion**

### For Team Collaboration

1. **Maintain consistent coding standards**
2. **Document complex decisions**
3. **Use semantic commit messages**
4. **Review AGENTS.md guidelines regularly**
5. **Share successful prompt patterns**

### For Production Readiness

1. **Always run the complete quality gate**
2. **Test in production-like environment**
3. **Verify security with Codacy/Trivy**
4. **Ensure accessibility compliance**
5. **Monitor performance metrics**

---

**ICE-WEBAPP with ChatGPT Codex provides a bleeding-edge, AI-optimized development environment that maintains quality, security, and performance standards while maximizing development velocity.** 