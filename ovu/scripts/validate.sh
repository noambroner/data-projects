#!/bin/bash
# Validate OVU project structure
# Version: 2.0.0

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="ovu"
ERRORS=0

echo "🔍 Validating project structure: $PROJECT_NAME"
echo "================================================"

# Required files
REQUIRED_FILES=(
    "${PROJECT_NAME}-workspace.code-workspace"
    ".${PROJECT_NAME}-cursorrules"
    "PROJECT_README.md"
    "VERSION"
    ".gitignore"
    "docs/SESSION_HANDOFF.md"
)

echo ""
echo "📄 Checking required files..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ Missing: $file"
        ((ERRORS++))
    fi
done

# Required directories
REQUIRED_DIRS=(
    "docs"
    "scripts"
    "dev"
    "worktrees"
    "tests"
)

echo ""
echo "📁 Checking required directories..."
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$PROJECT_DIR/$dir" ]; then
        echo "  ✅ $dir/"
    else
        echo "  ❌ Missing directory: $dir/"
        ((ERRORS++))
    fi
done

# Check worktrees exist
echo ""
echo "🌳 Checking worktrees..."
for wt in ulm-work aam-work shared-work; do
    if [ -d "$PROJECT_DIR/worktrees/$wt" ]; then
        echo "  ✅ worktrees/$wt"
    else
        echo "  ❌ Missing worktree: $wt"
        ((ERRORS++))
    fi
done

# Check dev repos exist
echo ""
echo "📦 Checking dev repos..."
for repo in ovu-ulm ovu-aam ovu-shared; do
    if [ -d "$PROJECT_DIR/dev/$repo" ]; then
        echo "  ✅ dev/$repo"
    else
        echo "  ❌ Missing repo: $repo"
        ((ERRORS++))
    fi
done

# Check git worktree status
echo ""
echo "🔗 Checking git worktree links..."
for repo in ovu-ulm ovu-aam ovu-shared; do
    if [ -d "$PROJECT_DIR/dev/$repo/.git" ]; then
        cd "$PROJECT_DIR/dev/$repo"
        wt_count=$(git worktree list 2>/dev/null | wc -l)
        if [ "$wt_count" -gt 1 ]; then
            echo "  ✅ $repo has $(($wt_count - 1)) worktree(s)"
        else
            echo "  ⚠️ $repo has no worktrees"
        fi
    fi
done

echo ""
echo "================================================"
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed!"
    exit 0
else
    echo "❌ $ERRORS errors found"
    exit 1
fi

