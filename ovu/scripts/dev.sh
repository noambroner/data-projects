#!/bin/bash
# ================================================
# 🚀 OVU Development Environment
# ================================================

echo "🚀 Starting OVU Development Environment..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

WORKTREES_DIR="/home/noam/projects/worktrees"

echo -e "${YELLOW}Available services:${NC}"
echo "  1. ULM Frontend (React)"
echo "  2. ULM Backend (FastAPI)"
echo "  3. AAM (All services)"
echo ""

echo -e "${GREEN}To start a specific service:${NC}"
echo ""
echo "ULM Frontend:"
echo "  cd $WORKTREES_DIR/ulm-work/frontend/react && npm run dev"
echo ""
echo "ULM Backend:"
echo "  cd $WORKTREES_DIR/ulm-work/backend && source venv/bin/activate && uvicorn app.main:app --reload --port 8001"
echo ""
echo "AAM Services are running on production servers."
echo ""

echo -e "${YELLOW}⚠️  Customize this script based on your needs!${NC}"

