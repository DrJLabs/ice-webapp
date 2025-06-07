# Codacy Quality Gates Configuration

This document explains how to configure and use Codacy quality gates for your repository.

## Overview

Codacy quality gates are rules that determine when Codacy marks a pull request or commit as not meeting your quality standards. By configuring these gates properly, you can ensure your team maintains code quality and prevent issues from being merged into your codebase.

The ICE-WEBAPP project includes scripts that configure quality gates based on best practices for React applications, with a focus on:

1. **Security**: Zero tolerance for security issues
2. **Code Quality**: Strict limits on high-severity issues
3. **Code Coverage**: Maintaining reasonable test coverage on new code
4. **Code Complexity**: Limiting complexity and duplication

## Prerequisites

- Node.js 16+
- A Codacy account with your repository added
- Codacy API tokens configured in `tools/.codacy-tokens`

## Quality Gate Configuration

The ICE-WEBAPP project implements the following quality gate rules:

### Pull Request Quality Gates

| Gate | Value | Explanation |
|------|-------|-------------|
| New security issues | 0 | Zero tolerance for security issues |
| New issues (Error+) | 2 | Maximum 2 new issues of Error severity or higher |
| Duplication | 3 | Maximum 3 new duplicated blocks |
| Complexity | 4 | Maximum 4 new complexity |
| Coverage variation | -1% | Allow small coverage drops to not block refactoring |
| Diff coverage | 70% | At least 70% of changed lines must be covered by tests |

### Commit Quality Gates

| Gate | Value | Explanation |
|------|-------|-------------|
| New security issues | 0 | Zero tolerance for security issues |
| New issues (Error+) | 2 | Maximum 2 new issues of Error severity or higher |
| Duplication | 3 | Maximum 3 new duplicated blocks |
| Complexity | 4 | Maximum 4 new complexity |
| Coverage variation | -1% | Allow small coverage drops to not block refactoring |

> **Note**: Diff coverage is not available for commits, only for pull requests.

## Usage

### Setting Up Codacy Tokens

1. Create a `.codacy-tokens` file in the `tools` directory with the following content:

   ```bash
   export CODACY_ACCOUNT_TOKEN="your-account-token"
   export CODACY_PROJECT_TOKEN="your-project-token"
   ```

2. Replace `your-account-token` and `your-project-token` with your actual Codacy tokens.

### Running the Scripts

To configure all quality gates:

```bash
pnpm run codacy:setup-all
```

To configure only pull request quality gates:

```bash
pnpm run codacy:quality-gates
```

To configure only commit quality gates:

```bash
pnpm run codacy:commit-quality-gates
```

## How It Works

The scripts use the Codacy API v3 to:

1. Auto-detect your repository information from Git configuration
2. Retrieve current quality gate settings
3. Update the settings with best practices for React applications
4. Display the results

## Customizing Quality Gates

If you need to customize the quality gates for your specific project needs:

1. Edit the `qualityGateSettings` object in either:
   - `scripts/codacy-quality-gates.js` for pull request quality gates
   - `scripts/codacy-commit-quality-gates.js` for commit quality gates

2. Run the script again to apply your custom settings

## Integration with CI/CD and Git Hooks

### GitHub Actions Workflow

The Codacy quality gates are automatically configured in our GitHub Actions workflow:

```yaml
- name: Configure Codacy Quality Gates
  env:
    CODACY_ACCOUNT_TOKEN: ${{ secrets.CODACY_ACCOUNT_TOKEN }}
    CODACY_PROJECT_TOKEN: ${{ secrets.CODACY_PROJECT_TOKEN }}
  run: |
    pnpm run codacy:setup-all
```

### Git Hooks

We use Husky to enforce quality gates locally before commits and pushes:

#### Pre-commit Hook

The pre-commit hook runs the following quality gates:
- TypeScript validation
- ESLint checks
- Unit tests with coverage
- Security scan with Codacy
- Coverage upload to Codacy

#### Pre-push Hook

The pre-push hook enforces minimum test coverage thresholds:
- Lines coverage: 70%
- Statements coverage: 70%
- Functions coverage: 65%
- Branches coverage: 60%

This ensures that all code pushed to the repository meets our quality standards.

## Best Practices

- **Start Strict**: Begin with stricter quality gates, then relax them if needed
- **Security First**: Never compromise on security-related quality gates
- **Coverage Balance**: Set reasonable coverage requirements (70-80% is a good target)
- **Team Alignment**: Ensure your team understands the quality standards

## Troubleshooting

If you encounter issues:

- Verify your Codacy tokens have sufficient permissions
- Check that your repository exists in Codacy
- Examine the API response errors in the console output

## References

- [Codacy API Documentation](https://api.codacy.com/api/api-docs)
- [Adjusting Quality Gates in Codacy](https://docs.codacy.com/repositories-configure/adjusting-quality-gates/)
- [Integrating Codacy with Git Workflow](https://docs.codacy.com/getting-started/integrating-codacy-with-your-git-workflow/)
