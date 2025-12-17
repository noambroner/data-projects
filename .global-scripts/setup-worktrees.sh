#!/bin/bash
# ================================================
# 🌳 Setup Git Worktrees Script
# ================================================
# Usage: ./setup-worktrees.sh <project-path> <repo-url> <worktree-name>
# Example: ./setup-worktrees.sh /home/noam/projects/ovu git@github.com:user/repo.git main-work
# ================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ================================================
# Help
# ================================================

show_help() {
    echo "Usage: $0 <project-path> <repo-url> <worktree-name> [branch]"
    echo ""
    echo "Arguments:"
    echo "  project-path   Path to the project directory"
    echo "  repo-url       Git repository URL"
    echo "  worktree-name  Name for the worktree (e.g., main-work, feature-auth)"
    echo "  branch         Optional: branch name (default: main)"
    echo ""
    echo "Example:"
    echo "  $0 /home/noam/projects/ovu git@github.com:user/ovu-ulm.git ulm-work main"
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
    exit 0
fi

# ================================================
# Validation
# ================================================

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    print_error "Missing arguments!"
    show_help
    exit 1
fi

PROJECT_PATH="$1"
REPO_URL="$2"
WORKTREE_NAME="$3"
BRANCH="${4:-main}"

REPOS_DIR="$PROJECT_PATH/repositories"
WORKTREES_DIR="$PROJECT_PATH/worktrees"
REPO_NAME=$(basename "$REPO_URL" .git)

# ================================================
# Main
# ================================================

print_header "🌳 Setting up Worktree: $WORKTREE_NAME"

# Create directories if needed
mkdir -p "$REPOS_DIR" "$WORKTREES_DIR"

# Clone if repository doesn't exist
REPO_PATH="$REPOS_DIR/$REPO_NAME"
if [ ! -d "$REPO_PATH" ]; then
    echo "📥 Cloning repository..."
    git clone --bare "$REPO_URL" "$REPO_PATH"
    print_success "Cloned repository"
else
    echo "📁 Repository already exists at $REPO_PATH"
fi

# Create worktree
WORKTREE_PATH="$WORKTREES_DIR/$WORKTREE_NAME"
if [ ! -d "$WORKTREE_PATH" ]; then
    echo "🌳 Creating worktree..."
    cd "$REPO_PATH"
    git worktree add "$WORKTREE_PATH" "$BRANCH"
    print_success "Created worktree at $WORKTREE_PATH"
else
    echo "📁 Worktree already exists at $WORKTREE_PATH"
fi

# Create .cursorrules in worktree if not exists
if [ ! -f "$WORKTREE_PATH/.cursorrules" ]; then
    echo "📋 Creating .cursorrules..."
    cp /home/noam/projects/.global-config/.cursorrules-template "$WORKTREE_PATH/.cursorrules"
    sed -i "s/\[PROJECT_NAME\]/$WORKTREE_NAME/g" "$WORKTREE_PATH/.cursorrules"
    sed -i "s/\[DATE\]/$(date +%Y-%m-%d)/g" "$WORKTREE_PATH/.cursorrules"
    print_success "Created .cursorrules"
fi

# Create AI_AGENT_README.md if not exists
if [ ! -f "$WORKTREE_PATH/AI_AGENT_README.md" ]; then
    echo "📝 Creating AI_AGENT_README.md..."
    cat > "$WORKTREE_PATH/AI_AGENT_README.md" << EOF
# 🤖 AI Agent README — $WORKTREE_NAME

## Quick Context
- **What:** [Brief description of this service]
- **Tech Stack:** [Technologies used]
- **Dependencies:** [Other services this depends on]

## Before You Start
1. ✅ Read \`.cursorrules\` in this directory
2. ✅ Read \`../../docs/SESSION_HANDOFF.md\`
3. ✅ Check for any open issues/PRs

## Key Locations
- API Endpoints: \`backend/app/api/\`
- Database Models: \`backend/app/models/\`
- Components: \`frontend/src/components/\`

## Common Tasks
- Run dev: \`npm run dev\` or \`uvicorn app.main:app --reload\`
- Run tests: \`npm test\` or \`pytest\`
- Lint: \`npm run lint\` or \`ruff check .\`

## Critical Rules
1. [Add service-specific rules here]

---

*Last updated: $(date +%Y-%m-%d)*
EOF
    print_success "Created AI_AGENT_README.md"
fi

print_header "✅ Worktree Setup Complete!"

echo "📁 Repository: $REPO_PATH"
echo "🌳 Worktree: $WORKTREE_PATH"
echo "🌿 Branch: $BRANCH"
echo ""
echo "📋 Next steps:"
echo "   1. cd $WORKTREE_PATH"
echo "   2. Edit .cursorrules for this service"
echo "   3. Update AI_AGENT_README.md"
echo ""

print_success "Done!"

