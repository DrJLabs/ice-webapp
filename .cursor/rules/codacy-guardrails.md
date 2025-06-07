---
description: "Codacy Guardrails integration for ICE-WEBAPP development"
globs: "**/*.{ts,tsx,js,jsx,py,java,dart}"
---

# Codacy Guardrails for ICE-WEBAPP

## Codacy Integration

### After ANY code edits, especially in files that match these patterns:
- `**/*.{ts,tsx,js,jsx,py,java,dart}`

You MUST run the Codacy analysis on the edited files by using the `codacy_cli_analyze` tool from Codacy's MCP Server with:
- `rootPath`: set to the workspace path
- `file`: set to the path of the edited file

Example:
```
mcp_codacy_codacy_cli_analyze(
  rootPath: "/home/drj/ice-webapp",
  file: "src/components/MyComponent.tsx"
)
```

## If you find issues:
1. Explain each issue clearly
2. Recommend fixes in line with ICE-WEBAPP patterns
3. Apply the fixes with the appropriate file editing tool

## Security Scanning
After any changes to dependencies (package.json, pnpm-lock.yaml, etc.), run security scanning with:
```
mcp_codacy_codacy_cli_analyze(
  rootPath: "/home/drj/ice-webapp",
  tool: "trivy"
)
```

## Codacy Tool Options
Available tools you can specify:
- `eslint` - For JavaScript/TypeScript linting
- `pylint` - For Python linting
- `pmd` - For Java code analysis
- `trivy` - For security scanning
- `dartanalyzer` - For Dart/Flutter code analysis
- `semgrep` - For generic code patterns
- `lizard` - For complexity analysis

## Quality Standards
Maintain these quality standards:
- Zero tolerance for security issues
- Maximum 2 new issues of Error severity
- Minimum 70% test coverage for changed code
- Reasonable limits on complexity and duplication

Remember: Quality gates are enforced through Git hooks and CI/CD. Bypass them only when absolutely necessary using `SKIP_HOOKS=1` or the `--no-verify` flag. 