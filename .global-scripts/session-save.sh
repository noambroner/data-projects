#!/bin/bash

#################################################################
# Session Save - Save current work context
# 
# This script helps you document your current work session
# so you can continue seamlessly on another machine.
#################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_DIR="$1"

if [ -z "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Usage: session-save <project-directory>${NC}"
    echo ""
    echo "Example:"
    echo "  session-save ~/projects/ovu"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Error: Directory not found: $PROJECT_DIR${NC}"
    exit 1
fi

cd "$PROJECT_DIR"

# Find SESSION_HANDOFF file
HANDOFF_FILE=""
if [ -f "docs/SESSION_HANDOFF.md" ]; then
    HANDOFF_FILE="docs/SESSION_HANDOFF.md"
elif [ -f "SESSION_HANDOFF.md" ]; then
    HANDOFF_FILE="SESSION_HANDOFF.md"
else
    echo -e "${YELLOW}Warning: SESSION_HANDOFF.md not found${NC}"
    echo "Creating new one..."
    mkdir -p docs
    HANDOFF_FILE="docs/SESSION_HANDOFF.md"
    cat > "$HANDOFF_FILE" << 'TEMPLATE'
# Session Handoff

## Current Session

**Date:** 
**Machine:** 
**Location:** 

### What I Did Today
- 

### Current Status
- 

### Next Steps
- 

### Issues/Blockers
- 

### Notes
- 

TEMPLATE
fi

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      💾 Session Save                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Collect information
echo -e "${GREEN}📝 Tell me about this session:${NC}"
echo ""

# Date and machine
CURRENT_DATE=$(date "+%Y-%m-%d %H:%M")
CURRENT_MACHINE=$(hostname)

# What did you do?
echo -e "${BLUE}1. What did you do today?${NC}"
echo "   (Press Enter when done, type 'done' on new line)"
WHAT_DID=()
while IFS= read -r line; do
    [[ "$line" == "done" ]] && break
    WHAT_DID+=("$line")
done

# Current status
echo ""
echo -e "${BLUE}2. Current status (where are you now)?${NC}"
read -r CURRENT_STATUS

# Next steps
echo ""
echo -e "${BLUE}3. What's next?${NC}"
read -r NEXT_STEPS

# Issues
echo ""
echo -e "${BLUE}4. Any issues or blockers? (optional)${NC}"
read -r ISSUES

# Notes
echo ""
echo -e "${BLUE}5. Any additional notes? (optional)${NC}"
read -r NOTES

# Generate session handoff
cat > "$HANDOFF_FILE" << EOF
# Session Handoff

## Current Session

**Date:** $CURRENT_DATE  
**Machine:** $CURRENT_MACHINE  
**Location:** $(pwd)

### What I Did Today
$(printf '- %s\n' "${WHAT_DID[@]}")

### Current Status
$CURRENT_STATUS

### Next Steps
$NEXT_STEPS

### Issues/Blockers
${ISSUES:-None}

### Notes
${NOTES:-None}

---

## Git Status

\`\`\`
$(git status --short 2>/dev/null || echo "Not a git repository")
\`\`\`

## Recent Commits

\`\`\`
$(git log --oneline -5 2>/dev/null || echo "No commits")
\`\`\`

---
*Last updated: $CURRENT_DATE*
EOF

echo ""
echo -e "${GREEN}✅ Session saved to: $HANDOFF_FILE${NC}"
echo ""

# Ask if want to commit
echo -e "${YELLOW}Do you want to commit and push this session? (y/n)${NC}"
read -r COMMIT_CHOICE

if [[ "$COMMIT_CHOICE" =~ ^[Yy]$ ]]; then
    git add "$HANDOFF_FILE"
    git commit -m "Session: Work update from $CURRENT_MACHINE at $CURRENT_DATE"
    git push
    echo -e "${GREEN}✅ Session pushed to GitHub!${NC}"
    echo ""
    echo -e "${BLUE}On your other machine, run:${NC}"
    echo "  git pull"
    echo "  cat $HANDOFF_FILE"
else
    echo -e "${YELLOW}⚠️  Remember to commit and push manually:${NC}"
    echo "  git add $HANDOFF_FILE"
    echo "  git commit -m 'Session update'"
    echo "  git push"
fi

echo ""
echo -e "${GREEN}🎉 Done!${NC}"

