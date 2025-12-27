#!/bin/bash
# Open OVU development environment with Agent Mode support
# Usage: ./scripts/open-dev.sh [service]
# Example: ./scripts/open-dev.sh ulm

SERVICE=${1:-ulm}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Opening OVU Development Environment"
echo "======================================="

# Run preflight sync check
echo "🔄 Running git preflight..."
"$PROJECT_DIR/scripts/git-preflight.sh"

# Open main workspace
echo ""
echo "📁 Opening main workspace..."
cursor "$PROJECT_DIR/ovu-workspace.code-workspace" &

sleep 2

# Open specific service with Agent Mode
case $SERVICE in
    ulm)
        echo "🔐 Opening ULM with Agent Mode..."
        cursor "$PROJECT_DIR/worktrees/ulm-work" &
        ;;
    aam)
        echo "👤 Opening AAM with Agent Mode..."
        cursor "$PROJECT_DIR/worktrees/aam-work" &
        ;;
    shared)
        echo "📦 Opening Shared with Agent Mode..."
        cursor "$PROJECT_DIR/worktrees/shared-work" &
        ;;
    *)
        echo "❌ Unknown service: $SERVICE"
        echo "   Available: ulm, aam, shared"
        exit 1
        ;;
esac

echo ""
echo "✅ Ready!"
echo ""
echo "📋 Window 1: Full project overview (multi-root workspace)"
echo "📋 Window 2: $SERVICE with Agent Mode enabled"
echo ""
echo "💡 Tip: Use Window 2 for AI tasks, Window 1 for navigation"

