# Organization-Level Runner Troubleshooting Guide
## Based on GitHub Documentation - June 2025

### 🔍 **Root Cause Analysis**

Our diagnostics revealed that organization-level runners are not picking up jobs due to access/configuration issues. Based on the [GitHub documentation on self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners), here are the potential causes:

### 📋 **Issue 1: GitHub CLI Organization Access**

**Problem**: GitHub CLI doesn't have proper access to the DrJLabs organization
**Solution**: Re-authenticate with proper organization permissions

```bash
# Re-authenticate GitHub CLI with organization access
gh auth logout
gh auth login --scopes "repo,workflow,admin:org"

# Verify organization access
gh api user/orgs --jq '.[].login'
```

### 📋 **Issue 2: Runner Groups Configuration**

**Problem**: Repository may not have access to organization runner groups
**Solution**: Configure runner groups properly

According to the [GitHub documentation on runner groups](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/managing-access-to-self-hosted-runners-using-groups):

1. **Check Current Runner Groups**:
   ```bash
   gh api orgs/DrJLabs/actions/runner-groups
   ```

2. **Verify Repository Access**:
   - Go to GitHub.com → DrJLabs Organization → Settings → Actions → Runner groups
   - Ensure `ice-webapp` repository has access to the appropriate runner group
   - If using "Default" group, ensure it allows public repositories (if applicable)

3. **Add Repository to Runner Group** (if needed):
   ```bash
   gh api --method PUT \
     "orgs/DrJLabs/actions/runner-groups/{group_id}/repositories/{repo_id}"
   ```

### 📋 **Issue 3: Runner Registration and Labels**

**Problem**: Runners may not be registered correctly at organization level
**Solution**: Verify runner registration and labels

1. **Check Organization Runners**:
   ```bash
   gh api orgs/DrJLabs/actions/runners
   ```

2. **Verify Runner Labels**: Ensure runners have correct labels:
   - `self-hosted` (always required)
   - `linux` (OS label)
   - `quality` (specialized label, if used)

3. **Re-register Runners** (if needed):
   ```bash
   # Get registration token
   gh api --method POST orgs/DrJLabs/actions/runners/registration-token

   # On runner machine, re-register with correct labels
   ./config.sh --url https://github.com/DrJLabs \
               --token <TOKEN> \
               --labels self-hosted,linux,quality
   ```

### 📋 **Issue 4: Repository Settings**

**Problem**: Repository may be restricted from using organization runners
**Solution**: Check repository action settings

1. **Repository Action Permissions**:
   - Go to GitHub.com → DrJLabs/ice-webapp → Settings → Actions → General
   - Ensure "Actions permissions" allows actions
   - Check "Fork pull request workflows" settings

2. **Organization Action Policies**:
   - Go to GitHub.com → DrJLabs Organization → Settings → Actions → General
   - Verify policies allow repositories to use organization runners

### 📋 **Issue 5: Workflow Configuration**

**Problem**: Workflows may not be targeting runners correctly
**Solution**: Use proper runner targeting syntax

Based on [GitHub documentation on using labels](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/using-labels-with-self-hosted-runners):

```yaml
# ✅ Correct: Always include 'self-hosted'
runs-on: [self-hosted, linux]

# ✅ Correct: With specialized labels
runs-on: [self-hosted, linux, quality]

# ❌ Incorrect: Missing 'self-hosted'
runs-on: [linux]

# ✅ Correct: Matrix with labels
runs-on: [self-hosted, "${{ matrix.label }}"]
```

### 🧪 **Testing Steps**

1. **Run Authentication Fix**:
   ```bash
   gh auth logout
   gh auth login --scopes "repo,workflow,admin:org"
   ```

2. **Test Organization Access**:
   ```bash
   bash scripts/fix-runner-access.sh
   ```

3. **Test Workflow Execution**:
   ```bash
   gh workflow run runner-priority-test.yml
   ```

4. **Monitor Workflow Progress**:
   ```bash
   gh run list --workflow=runner-priority-test.yml --limit 3
   ```

### 🔧 **Manual Configuration Steps**

If you have organization admin access, perform these steps:

1. **GitHub.com → DrJLabs Organization → Settings → Actions → Runner groups**
   - Create a runner group for `ice-webapp` (if not using Default)
   - Add `ice-webapp` repository to the group
   - Ensure group allows public repositories (if applicable)

2. **GitHub.com → DrJLabs Organization → Settings → Actions → Runners**
   - Verify runners are online and have correct labels
   - Check runner group assignments

3. **GitHub.com → DrJLabs/ice-webapp → Settings → Actions → General**
   - Ensure actions are enabled
   - Verify runner access permissions

### 📖 **GitHub Documentation References**

- [About self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)
- [Managing access with runner groups](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/managing-access-to-self-hosted-runners-using-groups)
- [Using labels with self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/using-labels-with-self-hosted-runners)
- [Adding self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners)

### ✅ **Expected Results**

After following these steps:
- Organization runners should be visible and accessible
- Workflows should be picked up by organization-level runners
- Test workflows should execute successfully
- Runner diagnostics should show proper organization access

### 🚨 **If Issues Persist**

1. Check organization permissions (admin access required for many operations)
2. Verify runner machine connectivity to GitHub
3. Review organization action policies and restrictions
4. Contact organization admin for runner group configuration
5. Consider using repository-level runners as temporary fallback 