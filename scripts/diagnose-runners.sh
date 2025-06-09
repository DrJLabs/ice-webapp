#!/bin/bash

# ICE-WEBAPP Runner Diagnostics Script
# June 2025 - Organization-Level Runner Troubleshooting

set -euo pipefail

echo "🧊 ICE-WEBAPP Runner Diagnostics"
echo "=================================="
echo "Date: $(date)"
echo "Repository: DrJLabs/ice-webapp"
echo ""

# Check GitHub CLI authentication
echo "🔐 Checking GitHub CLI authentication..."
if gh auth status > /dev/null 2>&1; then
    echo "✅ GitHub CLI authenticated"
    gh auth status
else
    echo "❌ GitHub CLI not authenticated"
    echo "Please run: gh auth login"
    exit 1
fi

echo ""

# Check repository information
echo "📋 Repository Information:"
echo "Current branch: $(git branch --show-current)"
echo "Remote origin: $(git remote get-url origin)"
echo "Latest commit: $(git log -1 --oneline)"
echo ""

# Check recent workflow runs
echo "🚀 Recent Workflow Runs:"
echo "------------------------"
gh run list --limit 5 --json id,name,status,conclusion,createdAt,headBranch --template '{{range .}}{{.id}} | {{.name}} | {{.status}} | {{.conclusion}} | {{.createdAt}} | {{.headBranch}}
{{end}}' || echo "⚠️  Could not fetch workflow runs"

echo ""

# Check for any queued workflows
echo "⏳ Queued Workflows:"
echo "-------------------"
gh run list --status queued --limit 10 --json id,name,status,createdAt --template '{{range .}}{{.id}} | {{.name}} | {{.status}} | {{.createdAt}}
{{end}}' || echo "No queued workflows"

echo ""

# Check workflow files
echo "📄 Workflow Files:"
echo "------------------"
ls -la .github/workflows/ | grep -E '\.(yml|yaml)$' || echo "No workflow files found"

echo ""

# Check for organization runners (requires admin access)
echo "🏃 Organization Runner Information:"
echo "----------------------------------"
echo "Note: This requires organization admin access"
gh api orgs/DrJLabs/actions/runners --jq '.runners[] | {id: .id, name: .name, status: .status, busy: .busy, labels: [.labels[].name]}' 2>/dev/null || echo "⚠️  Cannot access organization runners (requires admin access)"

echo ""

# Trigger test workflow
echo "🧪 Triggering Test Workflow:"
echo "----------------------------"
if gh workflow run test-runners.yml --ref "$(git branch --show-current)"; then
    echo "✅ Test workflow triggered successfully"
    echo "Monitor progress with: gh run list --workflow=test-runners.yml"
else
    echo "❌ Failed to trigger test workflow"
fi

echo ""

# Check for common issues
echo "🔍 Common Issues Checklist:"
echo "---------------------------"
echo "❓ Are your runners registered at the organization level?"
echo "❓ Do your runners have the correct labels (self-hosted, linux, quality)?"
echo "❓ Are your runners in the correct runner group with repository access?"
echo "❓ Are your runners online and not busy with other jobs?"
echo "❓ Do you have the necessary permissions to use organization runners?"
echo ""

echo "📖 For more information, see:"
echo "• GitHub Docs: https://docs.github.com/en/actions/hosting-your-own-runners"
echo "• Organization Runner Groups: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/managing-access-to-self-hosted-runners-using-groups"
echo ""

echo "✅ Diagnostics completed. Check the output above for any issues." 