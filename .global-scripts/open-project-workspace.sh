#!/bin/bash
# ================================================
# 📂 Open Project Workspace in Cursor
# ================================================
# Usage: ./open-project-workspace.sh <project-name>
# Example: ./open-project-workspace.sh ovu
# ================================================

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECTS_ROOT="/home/noam/projects"

# ================================================
# Validation
# ================================================

if [ -z "$1" ]; then
    echo -e "${YELLOW}Available projects:${NC}"
    echo ""
    # List directories that have a workspace file
    for dir in "$PROJECTS_ROOT"/*/; do
        if ls "$dir"*-workspace.code-workspace 1>/dev/null 2>&1; then
            PROJECT=$(basename "$dir")
            echo "  - $PROJECT"
        fi
    done
    echo ""
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_PATH="$PROJECTS_ROOT/$PROJECT_NAME"

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}❌ Project '$PROJECT_NAME' not found at $PROJECT_PATH${NC}"
    exit 1
fi

# Find workspace file
WORKSPACE_FILE=$(ls "$PROJECT_PATH"/*-workspace.code-workspace 2>/dev/null | head -1)

if [ -z "$WORKSPACE_FILE" ]; then
    echo -e "${RED}❌ No workspace file found in $PROJECT_PATH${NC}"
    echo "Expected: ${PROJECT_NAME}-workspace.code-workspace"
    exit 1
fi

# ================================================
# Open in Cursor
# ================================================

echo -e "${GREEN}📂 Opening workspace: $WORKSPACE_FILE${NC}"

# Try different ways to open Cursor
if command -v cursor &>/dev/null; then
    cursor "$WORKSPACE_FILE"
elif command -v code &>/dev/null; then
    # Cursor might be aliased as 'code'
    code "$WORKSPACE_FILE"
elif [ -f "/usr/bin/cursor" ]; then
    /usr/bin/cursor "$WORKSPACE_FILE"
else
    echo -e "${YELLOW}⚠️  Cursor command not found in PATH${NC}"
    echo "Please open manually: $WORKSPACE_FILE"
    echo ""
    echo "Or try:"
    echo "  cursor \"$WORKSPACE_FILE\""
fi

echo -e "${GREEN}✅ Done!${NC}"

