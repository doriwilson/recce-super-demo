#!/bin/bash
# switch-pr.sh
# Quickly switch between PR branches and rebuild
# Usage: ./scripts/switch-pr.sh 1  # switches to PR #1

set -e  # Exit on error

if [ -z "$1" ]; then
    echo "Usage: ./scripts/switch-pr.sh <pr_number>"
    echo "  pr_number: 1, 2, or 3"
    exit 1
fi

PR_NUMBER=$1
BRANCH_NAME=""

case $PR_NUMBER in
    1)
        BRANCH_NAME="pr1-incremental-filter"
        ;;
    2)
        BRANCH_NAME="pr2-model-rename"
        ;;
    3)
        BRANCH_NAME="pr3-timestamp-logic"
        ;;
    *)
        echo "❌ Invalid PR number. Use 1, 2, or 3"
        exit 1
        ;;
esac

echo "🔄 Switching to $BRANCH_NAME..."

# Check if branch exists
if ! git show-ref --verify --quiet refs/heads/$BRANCH_NAME && ! git show-ref --verify --quiet refs/remotes/origin/$BRANCH_NAME; then
    echo "⚠️  Branch $BRANCH_NAME not found locally or remotely"
    echo "   This script assumes you've created the PR branches"
    echo "   See .github/pull_requests/ for PR details"
    exit 1
fi

# Switch to branch
git checkout $BRANCH_NAME

# Activate venv if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Install/update dbt packages first
echo "📦 Installing dbt packages..."
dbt deps

# Try to build models (may fail for PR #2 which has intentional breaking change)
echo "🔨 Rebuilding dbt models..."
if dbt build --target dev 2>&1; then
    echo "   ✅ Models built successfully"
else
    echo "   ⚠️  Build failed (this is expected for PR #2 - intentional breaking change)"
    echo "   📊 Recce can still analyze the breaking change from existing artifacts"
fi

# Try to generate artifacts (may also fail for PR #2, but that's okay)
echo "📊 Generating artifacts..."
if dbt compile --target dev 2>&1; then
    echo "   ✅ Artifacts generated"
else
    echo "   ⚠️  Compilation failed (expected for PR #2)"
    echo "   📊 Recce will use pre-committed artifacts to show the breaking change"
fi

echo ""
echo "✅ Switched to $BRANCH_NAME and rebuilt models"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff main..$BRANCH_NAME"
echo "  2. Run Recce comparison: recce run"
echo "  3. Review PR description: .github/pull_requests/pr${PR_NUMBER}-*.md"
echo ""

