# Codacy Integration and Workflow

This document outlines the comprehensive integration of Codacy into our development workflow, including GitHub Actions, quality gates, and local development practices.

## 1. Overview

We use Codacy to ensure code quality, security, and adherence to best practices. The integration is designed to be as automated as possible, providing feedback early and often in the development process.

## 2. GitHub Actions Workflow (`.github/workflows/codacy.yml`)

Our primary CI/CD pipeline includes a robust Codacy analysis job. This workflow runs on every push and pull request to the `main` branch.

### Key Stages:

1.  **Checkout & Setup**: The workflow begins by checking out the code and setting up the Node.js environment using `pnpm`.

2.  **Core Quality Gates**: Before any Codacy-specific steps, the following checks are run to ensure baseline quality:
    *   `pnpm run type-check`: TypeScript type checking.
    *   `pnpm run lint`: ESLint for code style and potential errors.
    *   `pnpm run test --coverage`: Jest tests with coverage generation.

3.  **Codacy Runtime Preparation**:
    *   The `./tools/codacy-runtime.sh` script is executed. This script installs the Codacy Analysis CLI and sets up necessary environment flags. It uses the `CODACY_ACCOUNT_TOKEN` and `CODACY_PROJECT_TOKEN` secrets.

4.  **Codacy Quality Gate Configuration**:
    *   The `pnpm run codacy:setup-all` command is run. This script, located at `scripts/codacy-quality-gates.js`, configures the quality gates on Codacy based on our project's standards.

5.  **Static Analysis with Codacy**:
    *   The `codacy/codacy-analysis-cli-action` GitHub Action is used to perform static analysis.
    *   It uploads the results to Codacy in SARIF format (`codacy.sarif`).
    *   The build is configured *not* to fail at this step; instead, we rely on Codacy's pull request status checks to enforce quality gates.

6.  **SARIF Upload to GitHub**:
    *   The generated `codacy.sarif` file is uploaded to GitHub's security dashboard using the `github/codeql-action/upload-sarif` action. This allows developers to see code scanning alerts directly within the GitHub repository.

7.  **Coverage Upload**:
    *   Test coverage information from `coverage/lcov.info` is uploaded to Codacy using the `codacy/codacy-coverage-reporter-action`. This helps track our project's test coverage over time.

8.  **Security Analysis**:
    *   A separate `security` job runs in parallel.
    *   `pnpm audit --audit-level moderate`: Checks for vulnerabilities in dependencies.
    *   `aquasecurity/trivy-action`: Scans the filesystem for vulnerabilities and generates a `trivy-results.sarif` report, which is also uploaded to GitHub Security.

## 3. Local Development and Codacy

To get feedback even before pushing code, developers can and should use Codacy tools locally.

### AI Assistant (Cursor) Integration

Our AI assistant is configured to work with Codacy:

*   **Automatic Analysis**: After any file is edited, the AI will automatically run `codacy_cli_analyze` on the modified file to check for new issues.
*   **Dependency Scanning**: After any dependency changes (e.g., `pnpm install`), the AI runs a Trivy scan via `codacy_cli_analyze` to check for new vulnerabilities.
*   **Fixes**: The AI assistant will attempt to automatically fix any new issues that are reported.

This integration is governed by rules defined in our workspace settings.

### Manual Local Analysis

Developers can manually trigger a local analysis by running the Codacy Analysis CLI. The necessary tokens are stored in `tools/.codacy-tokens`.

## 4. Scripts and Tooling

*   `scripts/codacy-quality-gates.js`: Sets up Codacy quality gates via the Codacy API.
*   `scripts/codacy-commit-quality-gates.js`: A script intended for pre-commit hooks to check quality gates before committing.
*   `tools/codacy-runtime.sh`: Helper script for CI to install and configure the Codacy CLI.
*   `tools/.codacy-tokens`: Stores API tokens for local development and script usage. **This file should be kept secure and not be committed to public repositories if it contained real production tokens.**

## 5. Summary of Checks

| Check                      | Tool/Action                            | Environment      | Purpose                                       |
| -------------------------- | -------------------------------------- | ---------------- | --------------------------------------------- |
| Type Checking              | `tsc`                                  | CI / Local       | Enforce TypeScript type safety.               |
| Linting                    | `eslint`                               | CI / Local       | Maintain code style and find basic errors.    |
| Unit Tests                 | `jest`                                 | CI / Local       | Verify code functionality.                    |
| Static Analysis            | `codacy/codacy-analysis-cli-action`    | CI               | Deep code quality and security analysis.      |
| Coverage Reporting         | `codacy/codacy-coverage-reporter-action` | CI               | Track test coverage.                          |
| Dependency Vulnerabilities | `pnpm audit` / `trivy-action`          | CI               | Find security issues in third-party packages. |
| Local Analysis             | Codacy CLI / AI Assistant              | Local            | Provide immediate feedback to developers.     | 