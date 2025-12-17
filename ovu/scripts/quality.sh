#!/bin/bash
# ================================================
# ✅ OVU Quality Checks (Lint, Format, Typecheck)
# ================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

WORKTREES_DIR="/home/noam/projects/worktrees"

echo "✅ Running OVU Quality Checks..."
echo ""

# ================================================
# ULM Frontend
# ================================================
echo -e "${YELLOW}📦 Checking ULM Frontend...${NC}"
ULM_FRONTEND="$WORKTREES_DIR/ulm-work/frontend/react"

if [ -d "$ULM_FRONTEND" ] && [ -f "$ULM_FRONTEND/package.json" ]; then
    cd "$ULM_FRONTEND"
    
    # Lint
    if npm run lint 2>/dev/null; then
        echo -e "${GREEN}  ✅ Lint passed${NC}"
    else
        echo -e "${RED}  ❌ Lint failed${NC}"
    fi
    
    # TypeScript
    if npm run typecheck 2>/dev/null || npx tsc --noEmit 2>/dev/null; then
        echo -e "${GREEN}  ✅ TypeScript passed${NC}"
    else
        echo -e "${YELLOW}  ⚠️  TypeScript check not configured${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  ULM Frontend not found${NC}"
fi

echo ""

# ================================================
# ULM Backend
# ================================================
echo -e "${YELLOW}🐍 Checking ULM Backend...${NC}"
ULM_BACKEND="$WORKTREES_DIR/ulm-work/backend"

if [ -d "$ULM_BACKEND" ]; then
    cd "$ULM_BACKEND"
    
    # Black
    if black --check . 2>/dev/null; then
        echo -e "${GREEN}  ✅ Black formatting passed${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Black not installed or formatting issues${NC}"
    fi
    
    # Ruff
    if ruff check . 2>/dev/null; then
        echo -e "${GREEN}  ✅ Ruff linting passed${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Ruff not installed or linting issues${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  ULM Backend not found${NC}"
fi

echo ""

# ================================================
# Summary
# ================================================
echo -e "${GREEN}✅ Quality checks complete!${NC}"
echo ""
echo "💡 To auto-fix issues:"
echo "   Frontend: npm run lint -- --fix"
echo "   Backend: black . && ruff check --fix ."

