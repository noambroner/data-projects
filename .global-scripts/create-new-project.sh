#!/bin/bash
# ================================================
# 🆕 Create New Project Script
# ================================================
# Usage: ./create-new-project.sh <project-name>
# Example: ./create-new-project.sh my-awesome-app
# ================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECTS_ROOT="/home/noam/projects"
GLOBAL_CONFIG="$PROJECTS_ROOT/.global-config"
GLOBAL_SCRIPTS="$PROJECTS_ROOT/.global-scripts"

# ================================================
# Functions
# ================================================

print_header() {
    echo -e "\n${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# ================================================
# Validation
# ================================================

if [ -z "$1" ]; then
    print_error "Usage: $0 <project-name>"
    echo "Example: $0 my-awesome-app"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_PATH="$PROJECTS_ROOT/$PROJECT_NAME"

if [ -d "$PROJECT_PATH" ]; then
    print_error "Project '$PROJECT_NAME' already exists at $PROJECT_PATH"
    exit 1
fi

# ================================================
# Main Script
# ================================================

print_header "🆕 Creating New Project: $PROJECT_NAME"

# Create project structure
echo "📁 Creating project structure..."

mkdir -p "$PROJECT_PATH"/{scripts,docs/sessions,worktrees}

print_success "Created directory structure"

# Copy templates
echo "📋 Copying templates..."

# Workspace file
cp "$GLOBAL_CONFIG/workspace-template.code-workspace" "$PROJECT_PATH/${PROJECT_NAME}-workspace.code-workspace"
sed -i "s/\[PROJECT\]/$PROJECT_NAME/g" "$PROJECT_PATH/${PROJECT_NAME}-workspace.code-workspace"

# Cursorrules
cp "$GLOBAL_CONFIG/.cursorrules-template" "$PROJECT_PATH/.${PROJECT_NAME}-cursorrules"
sed -i "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" "$PROJECT_PATH/.${PROJECT_NAME}-cursorrules"
sed -i "s/\[DATE\]/$(date +%Y-%m-%d)/g" "$PROJECT_PATH/.${PROJECT_NAME}-cursorrules"

print_success "Copied templates"

# Create PROJECT_README.md
echo "📝 Creating PROJECT_README.md..."

cat > "$PROJECT_PATH/PROJECT_README.md" << EOF
# 🚀 $PROJECT_NAME

**Created:** $(date +%Y-%m-%d)  
**Global Standards Version:** 1.0.0  

---

## 📋 Quick Start

### Prerequisites
- Node.js 20+
- Python 3.10+
- Docker (optional)

### Running Locally

\`\`\`bash
# Start development
./scripts/dev.sh

# Run quality checks
./scripts/quality.sh

# Run tests
./scripts/test.sh
\`\`\`

---

## 📁 Project Structure

\`\`\`
$PROJECT_NAME/
├── ${PROJECT_NAME}-workspace.code-workspace  ← Open this in Cursor
├── PROJECT_README.md                          ← You are here
├── .${PROJECT_NAME}-cursorrules               ← Project rules for Cursor
├── worktrees/                                 ← Working directories
├── scripts/                                   ← Automation scripts
└── docs/                                      ← Documentation
    ├── SESSION_HANDOFF.md                     ← Current session status
    └── sessions/                              ← Session history
\`\`\`

---

## 🔧 Development

### Starting a Session
1. Open \`${PROJECT_NAME}-workspace.code-workspace\` in Cursor
2. Read \`docs/SESSION_HANDOFF.md\`
3. Tell Cursor your goal for the session

### Ending a Session
1. Run \`./scripts/session-end.sh\`
2. Verify \`docs/SESSION_HANDOFF.md\` is updated
3. Save all files

---

## 📝 Documentation

- [Global Standards](../.global-config/PROJECT_ARCHITECTURE_SPEC.md)
- [Quick Start Guide](../.global-config/CURSOR_QUICK_START.md)

---

## 👥 Team

- **Project Lead:** [Name]
- **Contact:** [Email]
EOF

print_success "Created PROJECT_README.md"

# Create initial SESSION_HANDOFF.md
echo "📝 Creating initial SESSION_HANDOFF.md..."

cat > "$PROJECT_PATH/docs/SESSION_HANDOFF.md" << EOF
# 📝 Session Handoff — $PROJECT_NAME

---

## 🆕 Project Just Created!

**Created:** $(date +%Y-%m-%d %H:%M)  
**Global Standards Version:** 1.0.0

---

## 📋 Next Steps

1. [ ] Set up the tech stack (backend/frontend)
2. [ ] Create initial worktrees
3. [ ] Configure CI/CD
4. [ ] Start development

---

## 🎯 Project Goal

[Define the main goal of this project]

---

## 📝 Notes

This is a new project. The first session should focus on:
- Setting up the development environment
- Creating the initial code structure
- Configuring tooling (ESLint, Prettier, etc.)

---

**Ready to start! 🚀**
EOF

print_success "Created SESSION_HANDOFF.md"

# Create scripts
echo "📜 Creating scripts..."

# dev.sh
cat > "$PROJECT_PATH/scripts/dev.sh" << 'EOF'
#!/bin/bash
# Start development environment
echo "🚀 Starting development environment..."
echo "⚠️  TODO: Configure this script for your project"
# Add your dev commands here:
# npm run dev
# uvicorn app.main:app --reload
EOF

# quality.sh
cat > "$PROJECT_PATH/scripts/quality.sh" << 'EOF'
#!/bin/bash
# Run quality checks (lint, format, typecheck)
echo "✅ Running quality checks..."

# JavaScript/TypeScript
if [ -f "package.json" ]; then
    echo "📦 Checking JavaScript/TypeScript..."
    npm run lint 2>/dev/null || echo "⚠️  No lint script found"
    npm run format:check 2>/dev/null || echo "⚠️  No format:check script found"
fi

# Python
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    echo "🐍 Checking Python..."
    black --check . 2>/dev/null || echo "⚠️  Black not installed"
    ruff check . 2>/dev/null || echo "⚠️  Ruff not installed"
fi

echo "✅ Quality checks complete!"
EOF

# test.sh
cat > "$PROJECT_PATH/scripts/test.sh" << 'EOF'
#!/bin/bash
# Run tests
echo "🧪 Running tests..."

# JavaScript/TypeScript
if [ -f "package.json" ]; then
    npm test 2>/dev/null || echo "⚠️  No test script found"
fi

# Python
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    pytest 2>/dev/null || echo "⚠️  Pytest not installed"
fi

echo "🧪 Tests complete!"
EOF

# session-end.sh
cat > "$PROJECT_PATH/scripts/session-end.sh" << 'EOF'
#!/bin/bash
# End session and verify handoff
echo "📝 Ending session..."

HANDOFF_FILE="docs/SESSION_HANDOFF.md"

if [ ! -f "$HANDOFF_FILE" ]; then
    echo "❌ Error: $HANDOFF_FILE not found!"
    exit 1
fi

# Show changed files
echo ""
echo "📁 Changed files in this session:"
git diff --name-only 2>/dev/null || echo "(Not a git repository)"

echo ""
echo "📝 Please verify SESSION_HANDOFF.md contains:"
echo "   ✅ What was the goal"
echo "   ✅ What was done"
echo "   ✅ What's next"
echo ""

# Check if handoff was updated today
TODAY=$(date +%Y-%m-%d)
if grep -q "$TODAY" "$HANDOFF_FILE" 2>/dev/null; then
    echo "✅ Handoff appears to be updated today"
else
    echo "⚠️  Warning: Handoff may not be updated. Please check!"
fi

echo ""
echo "✅ Session end complete. Don't forget to save all files!"
EOF

chmod +x "$PROJECT_PATH/scripts/"*.sh

print_success "Created scripts"

# Final summary
print_header "✅ Project Created Successfully!"

echo "📁 Project location: $PROJECT_PATH"
echo ""
echo "📋 Next steps:"
echo "   1. Open ${PROJECT_NAME}-workspace.code-workspace in Cursor"
echo "   2. Read docs/SESSION_HANDOFF.md"
echo "   3. Start coding!"
echo ""
echo "📖 For more info, read:"
echo "   - $GLOBAL_CONFIG/CURSOR_QUICK_START.md"
echo "   - $GLOBAL_CONFIG/PROJECT_ARCHITECTURE_SPEC.md"
echo ""

print_success "Done! Happy coding! 🚀"

