# 🧊 ICE-WEBAPP

**I**ntelligent **C**odex **E**nvironment for bleeding-edge web application development.

A comprehensive starter scaffold optimized for AI-generated web applications using ChatGPT Codex with absolute dependency management cohesion across all environments.

## ✨ Features

### 🔥 Bleeding Edge Tech Stack
- **Next.js 15** with App Router and Turbo
- **React 19** with latest features
- **TypeScript 5.7** with strict typing
- **Tailwind CSS 3.4** with latest utilities
- **pnpm** for ultra-fast package management

### 🤖 AI-Optimized Development
- **ChatGPT Codex** compatible setup script
- **AI prompt templates** for rapid development
- **Semantic component structure** for AI understanding
- **Bleeding-edge tools** for maximum AI assistance

### 🛠️ Developer Experience
- **Vite 6** for lightning-fast builds
- **Vitest** for modern testing
- **Playwright** for E2E testing
- **ESLint 9** with flat config
- **Prettier** with Tailwind plugin
- **Husky** for git hooks

### 📊 Quality Assurance
- **Codacy** integration for static analysis
- **Automatic security scanning** with Trivy
- **TypeScript strict mode** enabled
- **Comprehensive linting** rules
- **100% test coverage** targets

### 🌐 Production Ready
- **Multi-environment** deployment support
- **Docker** configuration included
- **GitHub Actions** CI/CD pipeline
- **Performance optimization** built-in
- **SEO-friendly** structure

## 🚀 Quick Start

### For ChatGPT Codex (Recommended)

**Method 1: Codex-Optimized Setup** ⭐
```bash
# Optimized for Codex with Node.js 22 and bleeding-edge dependencies
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/setup-codex.sh | bash
```

**Method 2: Bootstrap New Project**
```bash
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/tools/ice-bootstrap.sh | bash -s my-project-name
```

**Method 3: Copy Setup Script**
1. Copy the complete contents of [`setup-codex.sh`](setup-codex.sh) to your Codex environment setup field
2. Run your task - environment auto-configures with pre-installed tools

**Method 4: Add to Existing Project**
```bash
cd existing-project
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/tools/ice-bootstrap.sh | bash -s --update
```

### For Local Development

**Bootstrap New Project**
```bash
# Create new webapp
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/tools/ice-bootstrap.sh | bash -s my-webapp

# Or create API project
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/tools/ice-bootstrap.sh | bash -s --template=api my-api

cd my-webapp && pnpm install && pnpm run dev
```

**Traditional Clone Method**
```bash
git clone https://github.com/DrJLabs/ice-webapp.git
cd ice-webapp
chmod +x setup.sh && ./setup.sh
pnpm run dev
```

## 📁 Project Structure

```
ice-webapp/
├── 📁 ai/                    # AI optimization files
│   ├── 📁 prompts/           # Development prompts
│   ├── 📁 templates/         # Code templates
│   └── 📁 docs/              # AI documentation
├── 📁 src/                   # Source code
│   ├── 📁 components/        # React components
│   ├── 📁 hooks/             # Custom hooks
│   ├── 📁 lib/               # Utilities
│   ├── 📁 styles/            # Global styles
│   └── 📁 types/             # TypeScript types
├── 📁 tests/                 # Test files
│   ├── 📁 unit/              # Unit tests
│   ├── 📁 integration/       # Integration tests
│   └── 📁 e2e/               # E2E tests
├── 📁 tools/                 # Development tools
├── 📁 scripts/               # Build scripts
├── 📁 config/                # Configuration files
└── 📁 .github/               # GitHub workflows
```

## 🔧 Environment Compatibility

The ICE-WEBAPP maintains **absolute dependency management cohesion** across:

| Environment | Status | Node.js | Package Manager | Auto-Setup | Script |
|-------------|--------|---------|----------------|------------|--------|
| **ChatGPT Codex** | ✅ | 22.12.0 | npm → pnpm | Yes | `setup-codex.sh` |
| **Cursor (Local)** | ✅ | 22.12.0 | pnpm 9 | Yes | `setup.sh` |
| **CI/CD Runner** | ✅ | 22.12.0 | pnpm 9 | Yes | `setup.sh` |
| **Docker** | ✅ | 22.12.0 | pnpm 9 | Yes | `setup.sh` |

**🎯 Unified Dependencies**: All environments now use identical bleeding-edge dependency versions for true absolute dependency management cohesion.

### Dependency Synchronization

Run the dependency sync script to ensure cohesion:
```bash
./scripts/dependency-sync.sh
```

This automatically updates:
- `.nvmrc` for Node.js version
- `Dockerfile` with correct base image
- VS Code settings for optimal DX
- Dependency manifest for validation

## 🎯 AI Development Prompts

The project includes optimized prompts for AI-assisted development:

```typescript
// Example: Component Generation
Create a React component called UserProfile that:
- Uses TypeScript with proper type definitions
- Implements user data display with avatar
- Follows our design system with Tailwind CSS
- Includes proper accessibility attributes
- Has responsive design for mobile and desktop
- Uses the cn() utility for conditional classes
```

See [`ai/prompts/development-prompts.md`](ai/prompts/development-prompts.md) for the complete collection.

## 📊 Quality Gates

### Static Analysis (Codacy)
- **ESLint** with TypeScript rules
- **Zero tolerance** for linting errors
- **Automated fixes** where possible
- **Security vulnerability** scanning

### Testing Requirements
- **Unit tests** with Vitest
- **Integration tests** for user flows
- **E2E tests** with Playwright
- **Accessibility testing** included

### Performance Standards
- **Core Web Vitals** optimization
- **Bundle size** monitoring
- **Runtime performance** tracking
- **SEO score** validation

## 🛡️ Security

### Automated Security Scanning
- **Trivy** for dependency vulnerabilities
- **Codacy** for security patterns
- **GitHub Security** advisories
- **SARIF** report upload

### Security Headers
- Content Security Policy
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection

## 🚀 Deployment

### Supported Platforms
- **Vercel** (recommended for Next.js)
- **Netlify** with build optimization
- **Docker** containers
- **Static hosting** (build output)

### Environment Variables
Copy `.env.example` to `.env.local` and configure:
```bash
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME="ICE WebApp"
# Add your service keys...
```

## 📈 Performance Features

### Built-in Optimizations
- **Automatic code splitting** by route
- **Image optimization** with Next.js Image
- **Bundle analysis** with webpack-bundle-analyzer
- **Tree shaking** for smaller bundles
- **Caching strategies** implemented

### Monitoring
- **Web Vitals** tracking
- **Performance budgets** enforced
- **Bundle size** alerts
- **Runtime metrics** collection

## 🧪 Testing Strategy

### Unit Testing
```bash
pnpm run test          # Run all tests
pnpm run test:ui       # Visual test runner
pnpm run test:coverage # Coverage report
```

### E2E Testing
```bash
pnpm run test:e2e      # Run Playwright tests
pnpm run test:e2e:ui   # Visual E2E runner
```

### Accessibility Testing
```bash
pnpm run test:a11y     # Accessibility tests
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
- **Dependency installation** with caching
- **Type checking** with TypeScript
- **Linting** with ESLint
- **Testing** with full coverage
- **Security scanning** with Trivy
- **Codacy analysis** integration
- **Performance budgets** validation

### Branch Protection
- **AI feature branches** (codex-*, cursor-*): Codacy only
- **Develop branch**: Codacy + Coverage required
- **Main branch**: Full review process

## 🎨 Design System

### Tailwind Configuration
- **CSS custom properties** for theming
- **Dark mode** support built-in
- **Responsive breakpoints** optimized
- **Animation utilities** included
- **Accessibility** utilities

### Component Architecture
- **Compound components** pattern
- **Variant-based** styling with CVA
- **Proper TypeScript** interfaces
- **Storybook** documentation ready

## 📚 Documentation

### Available Guides
- [AI Prompts Collection](ai/prompts/development-prompts.md)
- [Codex Integration Guide](CODEX_GUIDE.md)
- [Codacy & Cursor Integration](docs/CODACY_CURSOR_INTEGRATION.md)
- [Codacy Quality Gates](docs/CODACY_QUALITY_GATES.md)
- [Codacy Fix Summary](docs/CODACY_FIX_SUMMARY.md)
- [Deployment Guide](DEPLOYMENT.md)

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Follow** the coding standards (enforced by ESLint/Prettier)
4. **Write** tests for new features
5. **Ensure** all quality gates pass
6. **Submit** a pull request

### Development Workflow
```bash
# Install dependencies
pnpm install

# Start development server
pnpm run dev

# Run tests
pnpm run test

# Build for production
pnpm run build

# Validate everything
pnpm run codacy
```

## 📝 License

MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Next.js** team for the amazing framework
- **Vercel** for hosting and optimization tools
- **Tailwind CSS** for the utility-first approach
- **Codacy** for code quality assurance
- **OpenAI** for ChatGPT Codex integration

---

**Built with 🧊 ICE-WEBAPP** - The bleeding-edge AI-optimized web development starter.

> 💡 **Tip**: Use the AI prompts in `ai/prompts/` to accelerate your development with ChatGPT Codex!

[<img src="https://img.shields.io/codacy/grade/YOUR_PROJECT_ID?style=for-the-badge" alt="Codacy Badge"/>](https://app.codacy.com/gh/DrJLabs/ice-webapp/dashboard)
[![Coverage](https://app.codacy.com/project/badge/Coverage/your-project-id)](https://www.codacy.com/gh/DrJLabs/ice-webapp/dashboard)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=your-project&metric=security_rating)](https://sonarcloud.io/dashboard?id=your-project)
