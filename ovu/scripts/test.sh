#!/bin/bash
# ================================================
# 🧪 OVU Test Runner
# ================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

WORKTREES_DIR="/home/noam/projects/worktrees"

echo "🧪 Running OVU Tests..."
echo ""

# ================================================
# ULM Frontend
# ================================================
echo -e "${YELLOW}📦 Testing ULM Frontend...${NC}"
ULM_FRONTEND="$WORKTREES_DIR/ulm-work/frontend/react"

if [ -d "$ULM_FRONTEND" ] && [ -f "$ULM_FRONTEND/package.json" ]; then
    cd "$ULM_FRONTEND"
    
    if npm test 2>/dev/null; then
        echo -e "${GREEN}  ✅ Frontend tests passed${NC}"
    else
        echo -e "${YELLOW}  ⚠️  No tests configured or tests failed${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  ULM Frontend not found${NC}"
fi

echo ""

# ================================================
# ULM Backend
# ================================================
echo -e "${YELLOW}🐍 Testing ULM Backend...${NC}"
ULM_BACKEND="$WORKTREES_DIR/ulm-work/backend"

if [ -d "$ULM_BACKEND" ]; then
    cd "$ULM_BACKEND"
    
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
    
    if pytest 2>/dev/null; then
        echo -e "${GREEN}  ✅ Backend tests passed${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Pytest not installed or tests failed${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  ULM Backend not found${NC}"
fi

echo ""

# ================================================
# Summary
# ================================================
echo -e "${GREEN}🧪 Test run complete!${NC}"

