#!/bin/bash
# ================================================
# 📝 OVU Session End — Handoff Verification
# ================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

OVU_DIR="/home/noam/projects/ovu"
HANDOFF_FILE="$OVU_DIR/docs/SESSION_HANDOFF.md"

echo "📝 Ending OVU Development Session..."
echo ""

# ================================================
# Check Handoff File
# ================================================
if [ ! -f "$HANDOFF_FILE" ]; then
    echo -e "${RED}❌ Error: SESSION_HANDOFF.md not found!${NC}"
    echo "Expected location: $HANDOFF_FILE"
    exit 1
fi

echo -e "${GREEN}✅ Handoff file found${NC}"

# ================================================
# Show Changed Files
# ================================================
echo ""
echo -e "${YELLOW}📁 Changed files across worktrees:${NC}"
echo ""

WORKTREES_DIR="/home/noam/projects/worktrees"

for wt in ulm-work aam-work shared-work; do
    if [ -d "$WORKTREES_DIR/$wt/.git" ] || [ -f "$WORKTREES_DIR/$wt/.git" ]; then
        changes=$(cd "$WORKTREES_DIR/$wt" && git diff --name-only 2>/dev/null | wc -l)
        staged=$(cd "$WORKTREES_DIR/$wt" && git diff --cached --name-only 2>/dev/null | wc -l)
        if [ "$changes" -gt 0 ] || [ "$staged" -gt 0 ]; then
            echo -e "${YELLOW}  $wt: $changes unstaged, $staged staged${NC}"
            cd "$WORKTREES_DIR/$wt" && git diff --name-only 2>/dev/null | head -5 | sed 's/^/    /'
        else
            echo -e "${GREEN}  $wt: no changes${NC}"
        fi
    fi
done

# ================================================
# Check Handoff Updated Today
# ================================================
echo ""
TODAY=$(date +%Y-%m-%d)

if grep -q "$TODAY" "$HANDOFF_FILE" 2>/dev/null; then
    echo -e "${GREEN}✅ Handoff appears to be updated today ($TODAY)${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Handoff may not be updated today!${NC}"
    echo "   Please verify docs/SESSION_HANDOFF.md contains:"
    echo "   - What was the goal"
    echo "   - What was done"
    echo "   - What's next"
fi

# ================================================
# Checklist
# ================================================
echo ""
echo -e "${YELLOW}📋 Session End Checklist:${NC}"
echo "   [ ] Handoff updated with summary"
echo "   [ ] All changes tested and working"
echo "   [ ] No errors in console"
echo "   [ ] Files saved"
echo "   [ ] (If deployed) Verified in production"

# ================================================
# Done
# ================================================
echo ""
echo -e "${GREEN}✅ Session end verification complete!${NC}"
echo ""
echo "💡 Don't forget to save all files in Cursor!"

