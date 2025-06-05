# 🚀 Quick Start Guide for ChatGPT Codex

This guide will help you get the ICE-WEBAPP environment up and running in ChatGPT Codex in minutes.

## 📋 Prerequisites

- Access to ChatGPT Codex environment
- Your Codacy account tokens (optional, for quality assurance)

## 🎯 Step-by-Step Setup

### Step 1: Configure Environment Setup Script

1. **Open ChatGPT Codex** and navigate to your workspace
2. **Click on "Manage Environment"** or the settings gear icon
3. **Go to the "Setup Script" section**
4. **Copy and paste the entire contents** of [`setup.sh`](setup.sh) into the setup script field

**Alternative**: Use the one-liner to fetch the latest version:
```bash
#!/usr/bin/env bash
curl -fsSL https://raw.githubusercontent.com/DrJLabs/ice-webapp/main/setup.sh | bash
```

### Step 2: Configure Environment Variables (Optional)

In the **Secrets** section of your environment, add:

```bash
# Required for Codacy integration (optional)
CODACY_ACCOUNT_TOKEN=your_account_token_here
CODACY_PROJECT_TOKEN=your_project_token_here

# Optional: Add your service API keys
OPENAI_API_KEY=your_openai_key_here
```

### Step 3: Save and Test Environment

1. **Click "Save"** to save your environment configuration
2. **Click "Test Setup"** to verify the setup script runs correctly
3. **Wait for completion** - this may take 2-3 minutes for the first run

### Step 4: Start Your First Task

1. **Create a new task** in Codex
2. **Select your configured environment**
3. **The setup will run automatically** and install all dependencies
4. **Start coding** with your bleeding-edge development environment!

## 🎨 Your First Web App

Try this prompt to get started quickly:

```
Create a modern landing page for a SaaS product with the following:

1. Hero section with gradient background and call-to-action
2. Features section with 3 key benefits
3. Pricing section with 3 tiers
4. Footer with links

Technical requirements:
- Use Next.js 15 with App Router
- Implement with TypeScript
- Style with Tailwind CSS
- Make it fully responsive
- Include proper SEO metadata
- Add smooth scroll animations
- Ensure accessibility compliance

Design requirements:
- Modern, clean aesthetic
- Professional color scheme
- Proper typography hierarchy
- Interactive hover effects
```

## 🛠️ Available Commands

Once your environment is set up, you can use these commands:

### Development
```bash
pnpm run dev          # Start development server
pnpm run build        # Build for production
pnpm run start        # Start production server
```

### Code Quality
```bash
pnpm run lint         # Run ESLint
pnpm run lint:fix     # Fix ESLint errors
pnpm run type-check   # TypeScript type checking
pnpm run format       # Format code with Prettier
```

### Testing
```bash
pnpm run test         # Run unit tests
pnpm run test:ui      # Run tests with UI
pnpm run test:e2e     # Run E2E tests
```

### Analysis
```bash
pnpm run analyze      # Bundle size analysis
pnpm run codacy       # Run Codacy analysis
```

## 📁 Project Structure Overview

Your generated project will have this structure:

```
/workspace/
├── src/
│   ├── app/              # Next.js App Router pages
│   ├── components/       # Reusable React components
│   ├── lib/              # Utility functions
│   └── styles/           # Global styles
├── tests/
│   ├── unit/             # Unit tests
│   ├── integration/      # Integration tests
│   └── e2e/              # End-to-end tests
├── ai/
│   ├── prompts/          # AI development prompts
│   └── templates/        # Code templates
└── tools/                # Development tools
```

## 🎯 AI-Optimized Development Prompts

Use these optimized prompts for faster development:

### Component Creation
```
Create a React component called {ComponentName} with:
- TypeScript interfaces
- Responsive Tailwind CSS styling
- Accessibility compliance
- Proper error handling
- Unit tests included
```

### API Development
```
Create a Next.js API route for {purpose}:
- Proper TypeScript typing
- Zod validation
- Error handling
- Security best practices
- OpenAPI documentation
```

### Page Creation
```
Create a Next.js page for {purpose}:
- App Router structure
- SEO optimization
- Responsive design
- Performance optimization
- Accessibility compliance
```

## 🔍 Troubleshooting

### Common Issues

**Issue**: Setup script fails to install dependencies
**Solution**: Check your internet connection during setup phase. Dependencies are installed before the environment goes offline.

**Issue**: TypeScript errors in generated code
**Solution**: Run `pnpm run type-check` to see specific errors. The environment uses strict TypeScript settings.

**Issue**: Linting errors prevent code execution
**Solution**: Run `pnpm run lint:fix` to automatically fix most issues.

### Getting Help

1. **Check the logs** in the Codex environment for specific error messages
2. **Review the setup script output** for any failed installations
3. **Use the AI prompts** in [`ai/prompts/development-prompts.md`](ai/prompts/development-prompts.md)
4. **Test locally** by running the setup script on your local machine

## 📈 Performance Tips

### For Faster AI Development

1. **Use specific prompts** from the AI prompts collection
2. **Leverage TypeScript** for better AI code understanding
3. **Follow the component patterns** for consistent structure
4. **Use the utility functions** in `src/lib/utils.ts`

### For Better Code Quality

1. **Run linting** before asking for code reviews
2. **Write tests** alongside component creation
3. **Use semantic component names** for AI understanding
4. **Follow the established patterns** in the codebase

## 🎉 Success!

You now have a bleeding-edge web development environment optimized for AI assistance. The setup includes:

- ✅ Next.js 15 with App Router
- ✅ React 19 with latest features
- ✅ TypeScript 5.7 with strict mode
- ✅ Tailwind CSS 3.4 with utilities
- ✅ Comprehensive testing setup
- ✅ Code quality enforcement
- ✅ Security scanning
- ✅ Performance optimization

**Happy coding with ICE-WEBAPP! 🧊**

---

> 💡 **Pro Tip**: Bookmark the [AI Prompts Collection](ai/prompts/development-prompts.md) for quick access to optimized development prompts! 