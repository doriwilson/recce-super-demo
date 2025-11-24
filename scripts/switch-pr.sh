#!/bin/bash
# switch-pr.sh
# Helper script to switch between PR branches and run Recce
# Usage: ./scripts/switch-pr.sh [1|2|3]

set -e  # Exit on error

# Map PR numbers to branch names
case "$1" in
    1)
        BRANCH="pr1-incremental-filter"
        ;;
    2)
        BRANCH="pr2-model-rename"
        ;;
    3)
        BRANCH="pr3-timestamp-logic"
        ;;
    *)
        echo "Usage: ./scripts/switch-pr.sh [1|2|3]"
        echo ""
        echo "Switches to the specified PR branch and prepares it for Recce:"
        echo "  1 = pr1-incremental-filter (Incremental model changes)"
        echo "  2 = pr2-model-rename (Breaking change detection)"
        echo "  3 = pr3-timestamp-logic (Timestamp validation)"
        exit 1
        ;;
esac

echo "🔄 Switching to $BRANCH..."

# Check if venv is activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "⚠️  Virtual environment not activated. Activating now..."
    if [ -f "venv/bin/activate" ]; then
        source venv/bin/activate
    else
        echo "❌ Virtual environment not found. Run ./scripts/setup.sh first."
        exit 1
    fi
fi

# Check for uncommitted changes and discard them (demo mode - we don't care about preserving changes)
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "⚠️  Uncommitted changes detected. Discarding them for clean demo..."
    git reset --hard HEAD
    git clean -fd
fi

# Switch to the branch
echo "📦 Checking out $BRANCH..."
git checkout "$BRANCH" 2>&1 || {
    echo "❌ Failed to checkout $BRANCH"
    exit 1
}

# Build to dev schema (creates dev data for comparison)
echo "🔨 Building models to dev schema..."
dbt build --target dev

echo ""
echo "✅ Ready to run Recce!"
echo ""
echo "Next step:"
echo "   recce server recce_state.json"
echo ""
echo "Then open http://localhost:8000 in your browser"


