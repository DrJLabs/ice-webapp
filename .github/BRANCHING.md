# ICE-WEBAPP Branching Strategy & Protection

This document outlines the branching model and the protection rules for the main branches of the ICE-WEBAPP repository.

## Branching Model

- **`main`**: This branch represents the production-ready code. All development should be done in other branches and merged into `main` only after passing all quality gates and reviews.
- **`develop`**: This is the primary development branch. All feature branches (`ice/*`) should be based on `develop` and merged back into it. This branch is protected to ensure code quality and stability.

## Branch Protection Rules

### `develop` Branch Protection Ruleset

To maintain the quality and stability of the `develop` branch, a branch protection ruleset should be configured in GitHub with the following settings.

**Targeted Branch:** `develop`

**Rules:**

1.  **Require a pull request before merging**
    -   All changes must be made through a pull request. Direct pushes are disabled.
    -   **Required approvals:** At least 1 approving review is required.

2.  **Require status checks to pass before merging**
    -   All quality gates must pass before a pull request can be merged.
    -   **Required status checks:**
        -   `type-check` (or the name of your TypeScript check in CI)
        -   `lint` (or the name of your linting check in CI)
        -   `test` (or the name of your test check in CI)
        -   `codacy/security` (or the name of your Codacy security scan in CI)
        -   `codacy/coverage` (or the name of your Codacy coverage check in CI)

3.  **Require branches to be up to date before merging**
    -   This ensures that pull requests are tested against the latest version of the `develop` branch.

4.  **Require conversation resolution before merging**
    -   All comments on a pull request must be resolved before merging.

5.  **Restrict who can dismiss pull request reviews**
    -   Only authorized users or teams should be able to dismiss reviews.

### `main` Branch Protection Ruleset

The `main` branch should have similar, but more strict, protection rules. It should be protected against direct pushes and require all the same status checks as `develop`. Additionally, you might consider:
- Requiring more approvals.
- Restricting who can push to the branch.

This file should be placed in a `.github` directory to be easily found. 