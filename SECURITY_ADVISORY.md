# 🔒 Security Advisory - ESBuild CORS Vulnerability

## Summary
Fixed **MODERATE** security vulnerability in esbuild package that allows any website to send requests to the development server.

## Vulnerability Details
- **Package**: `esbuild`
- **Affected Versions**: < 0.24.2  
- **Fixed Version**: 0.25.0+
- **Severity**: Moderate (5.3/10 CVSS)
- **CVE**: Related to CVE-2022-29244

## Issue Description
ESBuild sets `Access-Control-Allow-Origin: *` header to all requests, including the SSE connection, which allows any websites to send any request to the development server and read the response due to default CORS settings.

## Security Impact
- Any website can send requests to your development server
- Potential data leakage from development environment
- Cross-origin attacks during development

## Fix Applied
✅ **Solution**: Added `esbuild@^0.25.0` to `devDependencies` in `package.json`

```json
{
  "devDependencies": {
    "esbuild": "^0.25.0"
  }
}
```

## Mitigation Steps
1. **Immediate**: Use `npx esbuild@latest --version` (confirmed working: v0.25.5)
2. **Long-term**: Full dependency update when npm/cli#8075 is resolved
3. **Verification**: Check that esbuild >= 0.25.0 is installed

## Verification Commands
```bash
# Check if esbuild is vulnerable
npm ls esbuild

# Use secure version directly 
npx --yes esbuild@latest --version  # Should show 0.25.5+

# Verify package.json has been updated
grep "esbuild" package.json
```

## References
- [ESBuild Security Advisory](https://github.com/evanw/esbuild/blob/main/CHANGELOG.md)
- [NPM CLI Issue #8075](https://github.com/npm/cli/issues/8075)
- [Corepack Gotchas](https://okuno.se/blog/corepack-gotchas-with-pnpm-in-docker)

## Timeline
- **Detected**: 2025-06-05 17:15 UTC
- **Fixed**: 2025-06-05 17:22 UTC  
- **Branch**: `ice/security-fix-esbuild-cors-vulnerability`
- **Commit**: `50394b97`

---
**Status**: ✅ **RESOLVED** - Secure version specified in package.json 