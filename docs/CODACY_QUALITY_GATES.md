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

### Branching Strategy

For all quality gate changes, follow the ICE-WEBAPP branching strategy:

1. Create a new branch with the `ice/` prefix:
   ```bash
   git checkout -b ice/quality-gate-feature
   ```

2. Make your changes and commit them:
   ```bash
   git add .
   git commit -m "feat: descriptive commit message"
   ```

3. Push the branch with upstream tracking:
   ```bash
   git push -u origin ice/quality-gate-feature
   ```

4. Create a pull request for review before merging to main.

### Git Hooks

We use Husky to enforce quality gates locally before commits and pushes:

#### Pre-commit Hook

The pre-commit hook runs the following quality gates:
- TypeScript validation
- ESLint checks
- Unit tests with coverage
- Security scan with Codacy
- Coverage upload to Codacy

To bypass the pre-commit hook in exceptional cases:
```bash
# Using the --no-verify flag
git commit --no-verify -m "Your commit message"

# Using environment variables
SKIP_PRE_COMMIT=1 git commit -m "Your commit message"
# or
SKIP_HOOKS=1 git commit -m "Your commit message"
```

#### Pre-push Hook

The pre-push hook enforces minimum test coverage thresholds:
- Lines coverage: 70%
- Statements coverage: 70%
- Functions coverage: 65%
- Branches coverage: 60%

To bypass the pre-push hook in exceptional cases:
```bash
# Using the --no-verify flag
git push --no-verify

# Using environment variables
SKIP_PRE_PUSH=1 git push
# or
SKIP_HOOKS=1 git push
```

> **Note**: The bypass mechanisms should only be used in exceptional circumstances, such as:
> - When dealing with permission issues in the development environment
> - During experimental or exploratory development phases
> - When making documentation-only changes that don't affect code quality
> - In emergency hotfix situations where time is critical

This ensures that all code pushed to the repository meets our quality standards while providing flexibility when needed.

## Troubleshooting

### Common Issues

#### Permission Issues with Git Hooks

If you encounter "permission denied" errors when Git tries to run hooks:

1. **Make hooks executable**:
   ```bash
   chmod +x .husky/pre-commit .husky/pre-push
   ```

2. **Check filesystem mount issues**:
   If you're working on a mounted filesystem (network drive, external drive), it may have the `noexec` flag set.
   
   Solutions:
   - Remount with exec permission: `sudo mount -o remount,exec /path/to/mount`
   - Use Git's built-in bypass: `git commit --no-verify`, `git push --no-verify`

3. **Use environment variables for bypass**:
   ```bash
   # Skip only pre-commit hook
   SKIP_PRE_COMMIT=1 git commit

   # Skip only pre-push hook
   SKIP_PRE_PUSH=1 git push

   # Skip all hooks
   SKIP_HOOKS=1 git commit
   SKIP_HOOKS=1 git push
   ```

4. **Fix Docker environment issues**:
   If using Docker, ensure permissions are correctly set in the container:
   ```bash
   chmod -R +x .husky/
   ```

5. **Address Windows-specific issues**:
   - Set correct shell: `git config --global core.shebang "#!/usr/bin/env sh"`
   - Check WSL file permissions after transferring files between Windows and WSL

#### Fix Other Permissions

```bash
# Fix permissions for TypeScript
sudo chown -R $(whoami) tsconfig.tsbuildinfo

# Fix permissions for Next.js
sudo chown -R $(whoami) .next
```

#### Coverage Report Not Found

If the coverage report is not being generated:

1. Make sure the tests are running with the `--coverage` flag
2. Check that the `coverage` directory is not in `.gitignore`
3. Try running `pnpm run test:coverage` manually to see the output

#### Tests Failing in Hooks but Passing Manually

This could be due to environment variables not being available in the hook context. Try:

```bash
# Run with environment variables
ENV_VAR=value git commit
```

Or modify the hook to source your environment variables.

## Best Practices

- **Start Strict**: Begin with stricter quality gates, then relax them if needed
- **Security First**: Never compromise on security-related quality gates
- **Coverage Balance**: Set reasonable coverage requirements (70-80% is a good target)
- **Team Alignment**: Ensure your team understands the quality standards
- **Bypass Sparingly**: Use hook bypass mechanisms only when absolutely necessary
- **Document Exceptions**: When bypassing hooks, document the reason in your commit message

## Additional Support

If you encounter other issues:

- Verify your Codacy tokens have sufficient permissions
- Check that your repository exists in Codacy
- Examine the API response errors in the console output

## References

- [Codacy API Documentation](https://api.codacy.com/api/api-docs)
- [Adjusting Quality Gates in Codacy](https://docs.codacy.com/repositories-configure/adjusting-quality-gates/)
- [Integrating Codacy with Git Workflow](https://docs.codacy.com/getting-started/integrating-codacy-with-your-git-workflow/)
