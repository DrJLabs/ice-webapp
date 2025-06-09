#!/bin/bash

# ICE-WEBAPP Organization Runner Access Fix
# Based on GitHub Documentation: June 2025
# https://docs.github.com/en/actions/hosting-your-own-runners

set -euo pipefail

echo "🧊 ICE-WEBAPP Organization Runner Access Fix"
echo "============================================="
echo "Date: $(date)"
echo "Repository: DrJLabs/ice-webapp"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

# Check GitHub CLI authentication
echo "🔐 Checking GitHub CLI authentication..."
if gh auth status >/dev/null 2>&1; then
    print_status "GitHub CLI authenticated"
else
    print_error "GitHub CLI not authenticated. Please run: gh auth login"
    exit 1
fi

echo ""

# Check organization access
echo "🏢 Checking organization access..."
ORG_ACCESS=$(gh api user/orgs --jq '.[] | select(.login=="DrJLabs") | .login' 2>/dev/null || echo "")
if [ "$ORG_ACCESS" = "DrJLabs" ]; then
    print_status "Organization access confirmed"
else
    print_error "No access to DrJLabs organization"
    exit 1
fi

echo ""

# Check if user has admin access to organization
echo "🔑 Checking organization permissions..."
USER_ROLE=$(gh api orgs/DrJLabs/memberships/$(gh api user --jq '.login') --jq '.role' 2>/dev/null || echo "member")
if [ "$USER_ROLE" = "admin" ]; then
    print_status "Organization admin access confirmed"
    HAS_ADMIN=true
else
    print_warning "Limited organization access (role: $USER_ROLE)"
    print_info "Some operations may require organization admin privileges"
    HAS_ADMIN=false
fi

echo ""

# Function to safely call GitHub API with error handling
safe_api_call() {
    local endpoint="$1"
    local description="$2"
    
    echo "🔍 Checking $description..."
    if result=$(gh api "$endpoint" 2>/dev/null); then
        echo "$result"
        return 0
    else
        print_warning "Could not access $description (may require admin privileges)"
        return 1
    fi
}

# Check organization runners
echo "🏃 Organization Runners Status:"
echo "------------------------------"
if safe_api_call "orgs/DrJLabs/actions/runners" "organization runners"; then
    # If we can access runners, show summary
    RUNNER_COUNT=$(echo "$result" | jq '.total_count // 0')
    print_info "Total organization runners: $RUNNER_COUNT"
    
    if [ "$RUNNER_COUNT" -gt 0 ]; then
        echo "$result" | jq -r '.runners[]? | "- \(.name): \(.status) (\(.labels | map(.name) | join(", ")))"' || true
    else
        print_warning "No organization runners found"
    fi
else
    print_warning "Cannot access organization runners"
fi

echo ""

# Check runner groups
echo "👥 Runner Groups Configuration:"
echo "------------------------------"
if safe_api_call "orgs/DrJLabs/actions/runner-groups" "runner groups"; then
    GROUP_COUNT=$(echo "$result" | jq '.total_count // 0')
    print_info "Total runner groups: $GROUP_COUNT"
    
    if [ "$GROUP_COUNT" -gt 0 ]; then
        echo "$result" | jq -r '.runner_groups[]? | "- \(.name): visibility=\(.visibility), public_repos=\(.allows_public_repositories)"' || true
        
        # Check if ice-webapp has access to any groups
        print_info "Checking repository access to runner groups..."
        echo "$result" | jq -r '.runner_groups[]? | select(.visibility=="selected") | "Group \(.name) restricted to: \(.selected_repositories_url // "unknown")"' || true
    fi
else
    print_warning "Cannot access runner groups configuration"
fi

echo ""

# Check repository runners as fallback
echo "📦 Repository-Level Runners:"
echo "---------------------------"
if safe_api_call "repos/DrJLabs/ice-webapp/actions/runners" "repository runners"; then
    REPO_RUNNER_COUNT=$(echo "$result" | jq '.total_count // 0')
    print_info "Repository runners: $REPO_RUNNER_COUNT"
    
    if [ "$REPO_RUNNER_COUNT" -gt 0 ]; then
        echo "$result" | jq -r '.runners[]? | "- \(.name): \(.status) (\(.labels | map(.name) | join(", ")))"' || true
    fi
fi

echo ""

# Test workflow trigger
echo "🧪 Testing Workflow Execution:"
echo "------------------------------"
print_info "Triggering test workflow..."
if gh workflow run test-runners.yml --ref "$(git branch --show-current)" >/dev/null 2>&1; then
    print_status "Test workflow triggered successfully"
    
    # Wait a moment and check for queued runs
    sleep 3
    QUEUED_RUNS=$(gh run list --status queued --limit 1 --json status 2>/dev/null | jq length || echo 0)
    if [ "$QUEUED_RUNS" -gt 0 ]; then
        print_warning "Workflow is queued but not running (possible runner issue)"
    else
        print_info "Check workflow status with: gh run list --workflow=test-runners.yml"
    fi
else
    print_error "Failed to trigger test workflow"
fi

echo ""

# Provide solutions based on GitHub documentation
echo "🔧 Recommended Solutions (based on GitHub Documentation):"
echo "========================================================="

print_info "1. Runner Groups Access:"
echo "   If using organization runners, ensure:"
echo "   - Repository is added to the correct runner group"
echo "   - Runner group allows public repositories (if repo is public)"
echo "   - Runner group visibility is set correctly"

print_info "2. Runner Registration:"
echo "   Verify runners are registered at organization level with:"
echo "   - Correct labels: self-hosted, linux, quality"
echo "   - Online status"
echo "   - Not busy with other jobs"

print_info "3. Repository Settings:"
echo "   Check if organization has restricted runner access:"
echo "   - Organization Settings > Actions > General"
echo "   - Runner groups permissions"

print_info "4. Manual Steps Required:"
if [ "$HAS_ADMIN" = false ]; then
    echo "   ⚠️  The following require organization admin access:"
    echo "   - Add repository to runner groups"
    echo "   - Modify runner group settings"
    echo "   - Register new organization runners"
fi

echo ""
echo "📖 GitHub Documentation References:"
echo "   - Runner Groups: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/managing-access-to-self-hosted-runners-using-groups"
echo "   - Adding Runners: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners"
echo "   - Using Labels: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/using-labels-with-self-hosted-runners"

echo ""
print_status "Runner access diagnosis completed!" 