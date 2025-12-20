#!/bin/bash
# ==============================================
# OVU App Template Generator v2.0
# Creates new OVU apps with worktree structure
# ==============================================
#
# Usage: ./new-app.sh --name myapp [OPTIONS]
#
# This script creates:
#   1. Bare repository in /dev/{app-name}/
#   2. Worktree in /worktrees/{app-name}-work/
#   3. Configured with template and ready for GitHub
#
# See --help for full options

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
APP_NAME=""
FRONTEND_PORT="3000"
BACKEND_PORT="8000"
APP_COLOR="blue"
SKIP_INSTALL=false
GITHUB_REPO=""  # Optional: GitHub repo URL

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      APP_NAME="$2"
      shift 2
      ;;
    --frontend-port)
      FRONTEND_PORT="$2"
      shift 2
      ;;
    --backend-port)
      BACKEND_PORT="$2"
      shift 2
      ;;
    --color)
      APP_COLOR="$2"
      shift 2
      ;;
    --github)
      GITHUB_REPO="$2"
      shift 2
      ;;
    --skip-install)
      SKIP_INSTALL=true
      shift
      ;;
    --help|-h)
      echo -e "${CYAN}OVU App Template Generator v2.0${NC}"
      echo ""
      echo "Usage: $0 --name APP_NAME [OPTIONS]"
      echo ""
      echo -e "${YELLOW}Required:${NC}"
      echo "  --name NAME              Application name (lowercase, no spaces)"
      echo ""
      echo -e "${YELLOW}Optional:${NC}"
      echo "  --frontend-port PORT     Frontend dev server port (default: 3000)"
      echo "  --backend-port PORT      Backend server port (default: 8000)"
      echo "  --color COLOR            Primary color: blue or purple (default: blue)"
      echo "  --github URL             GitHub repository URL (e.g., https://github.com/user/repo.git)"
      echo "  --skip-install           Skip npm/pip install (faster for testing)"
      echo "  --help, -h               Show this help message"
      echo ""
      echo -e "${YELLOW}Examples:${NC}"
      echo "  $0 --name sam"
      echo "  $0 --name crm --color purple --frontend-port 3004 --backend-port 8004"
      echo "  $0 --name inventory --github https://github.com/noambroner/ovu-inventory.git"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Validate app name
if [[ -z "$APP_NAME" ]]; then
  echo -e "${RED}Error: --name is required${NC}"
  echo "Use --help for usage information"
  exit 1
fi

# Validate app name format (lowercase, alphanumeric, hyphens only)
if [[ ! "$APP_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo -e "${RED}Error: App name must start with a letter and contain only lowercase letters, numbers, and hyphens${NC}"
  exit 1
fi

# Validate ports are numbers
if ! [[ "$FRONTEND_PORT" =~ ^[0-9]+$ ]] || ! [[ "$BACKEND_PORT" =~ ^[0-9]+$ ]]; then
  echo -e "${RED}Error: Ports must be numbers${NC}"
  exit 1
fi

# Validate color
if [[ "$APP_COLOR" != "blue" && "$APP_COLOR" != "purple" ]]; then
  echo -e "${RED}Error: Color must be 'blue' or 'purple'${NC}"
  exit 1
fi

# Get script directory (to find template)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
TEMPLATE_DIR="$PROJECT_ROOT/templates/ovu-app-template"
DEV_DIR="$PROJECT_ROOT/dev"
WORKTREES_DIR="$PROJECT_ROOT/worktrees"

# Paths for new app
BARE_REPO_PATH="$DEV_DIR/$APP_NAME"
WORKTREE_PATH="$WORKTREES_DIR/${APP_NAME}-work"

# Validate template exists
if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo -e "${RED}Error: Template not found at $TEMPLATE_DIR${NC}"
  exit 1
fi

# Create dev and worktrees directories if they don't exist
mkdir -p "$DEV_DIR"
mkdir -p "$WORKTREES_DIR"

# Check if app already exists
if [[ -d "$BARE_REPO_PATH" ]] || [[ -d "$WORKTREE_PATH" ]]; then
  echo -e "${RED}Error: App '$APP_NAME' already exists${NC}"
  echo "  Bare repo: $BARE_REPO_PATH"
  echo "  Worktree:  $WORKTREE_PATH"
  exit 1
fi

# Set color values based on selection
if [[ "$APP_COLOR" == "purple" ]]; then
  COLOR_HEX="#a855f7"
  COLOR_HOVER="#9333ea"
  COLOR_LIGHT="#c084fc"
  COLOR_DARK="#7e22ce"
else
  COLOR_HEX="#3b82f6"
  COLOR_HOVER="#2563eb"
  COLOR_LIGHT="#60a5fa"
  COLOR_DARK="#1e40af"
fi

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════╗"
echo "║    OVU App Template Generator v2.0        ║"
echo "║         Worktree Structure 🌳             ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

# Summary
echo -e "${CYAN}Creating new OVU app:${NC}"
echo -e "  📦 Name:          ${GREEN}$APP_NAME${NC}"
echo -e "  🎨 Color:         ${GREEN}$APP_COLOR${NC}"
echo -e "  🌐 Frontend port: ${GREEN}$FRONTEND_PORT${NC}"
echo -e "  🔌 Backend port:  ${GREEN}$BACKEND_PORT${NC}"
echo -e "  📁 Bare repo:     ${GREEN}$BARE_REPO_PATH${NC}"
echo -e "  🌳 Worktree:      ${GREEN}$WORKTREE_PATH${NC}"
if [[ -n "$GITHUB_REPO" ]]; then
  echo -e "  🐙 GitHub:        ${GREEN}$GITHUB_REPO${NC}"
fi
echo ""

# Confirm
read -p "$(echo -e ${YELLOW}Continue? [y/N]: ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${RED}Cancelled.${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}🚀 Starting generation...${NC}"
echo ""

# Step 1: Create bare repository
echo -e "${BLUE}[1/9]${NC} Creating bare repository..."
git init --bare "$BARE_REPO_PATH" > /dev/null 2>&1
echo -e "      ${GREEN}✓${NC} Bare repository created at $BARE_REPO_PATH"

# Step 2: Configure remote if GitHub URL provided
if [[ -n "$GITHUB_REPO" ]]; then
  echo -e "${BLUE}[2/9]${NC} Configuring GitHub remote..."
  (cd "$BARE_REPO_PATH" && git remote add origin "$GITHUB_REPO" > /dev/null 2>&1)
  echo -e "      ${GREEN}✓${NC} Remote 'origin' configured: $GITHUB_REPO"
else
  echo -e "${BLUE}[2/9]${NC} ${YELLOW}Skipped${NC} GitHub remote (use --github to configure)"
fi

# Step 3: Create worktree
echo -e "${BLUE}[3/9]${NC} Creating worktree..."
(cd "$BARE_REPO_PATH" && git worktree add "$WORKTREE_PATH" -b main > /dev/null 2>&1)
echo -e "      ${GREEN}✓${NC} Worktree created at $WORKTREE_PATH"

# Step 4: Copy template to worktree
echo -e "${BLUE}[4/9]${NC} Copying template..."
cp -r "$TEMPLATE_DIR/." "$WORKTREE_PATH/"
# Remove the template's README if it exists (we'll keep app-specific one)
rm -f "$WORKTREE_PATH/README.md"
echo -e "      ${GREEN}✓${NC} Template files copied"

# Step 5: Replace placeholders in app name
echo -e "${BLUE}[5/9]${NC} Configuring app name..."
find "$WORKTREE_PATH" -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.md" -o -name "*.html" -o -name ".env.example" \) -exec sed -i.bak "s/__APP_NAME__/$APP_NAME/g" {} \;
find "$WORKTREE_PATH" -type f -name "*.bak" -delete
echo -e "      ${GREEN}✓${NC} App name configured: $APP_NAME"

# Step 6: Replace port placeholders
echo -e "${BLUE}[6/9]${NC} Configuring ports..."
find "$WORKTREE_PATH" -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.md" -o -name ".env.example" \) -exec sed -i.bak "s/__FRONTEND_PORT__/$FRONTEND_PORT/g" {} \;
find "$WORKTREE_PATH" -type f \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.md" -o -name ".env.example" \) -exec sed -i.bak "s/__BACKEND_PORT__/$BACKEND_PORT/g" {} \;
find "$WORKTREE_PATH" -type f -name "*.bak" -delete
echo -e "      ${GREEN}✓${NC} Ports configured: Frontend=$FRONTEND_PORT, Backend=$BACKEND_PORT"

# Step 7: Generate secrets and create .env files
echo -e "${BLUE}[7/9]${NC} Generating secrets..."
SECRET_KEY=$(openssl rand -base64 32)

# Create actual .env files from .env.example
cp "$WORKTREE_PATH/frontend/.env.example" "$WORKTREE_PATH/frontend/.env"
cp "$WORKTREE_PATH/backend/.env.example" "$WORKTREE_PATH/backend/.env"

# Replace secret in backend .env (using | as delimiter to avoid issues with /)
sed -i.bak "s|__SECRET_KEY__|$SECRET_KEY|g" "$WORKTREE_PATH/backend/.env"
rm -f "$WORKTREE_PATH/backend/.env.bak"

echo -e "      ${GREEN}✓${NC} Secret key generated"
echo -e "      ${GREEN}✓${NC} .env files created"

# Step 8: Set color theme
echo -e "${BLUE}[8/9]${NC} Setting color theme..."

# Update theme.css with actual colors
sed -i.bak "s/--app-primary: #3b82f6/--app-primary: $COLOR_HEX/g" "$WORKTREE_PATH/frontend/src/styles/theme.css"
sed -i.bak "s/--app-primary-hover: #2563eb/--app-primary-hover: $COLOR_HOVER/g" "$WORKTREE_PATH/frontend/src/styles/theme.css"
sed -i.bak "s/--app-primary-light: #60a5fa/--app-primary-light: $COLOR_LIGHT/g" "$WORKTREE_PATH/frontend/src/styles/theme.css"
sed -i.bak "s/--app-primary-dark: #1e40af/--app-primary-dark: $COLOR_DARK/g" "$WORKTREE_PATH/frontend/src/styles/theme.css"
find "$WORKTREE_PATH" -type f -name "*.bak" -delete

echo -e "      ${GREEN}✓${NC} Color theme set: $APP_COLOR ($COLOR_HEX)"

# Step 9: Initial git commit
echo -e "${BLUE}[9/9]${NC} Creating initial commit..."

# Create .gitignore at worktree root
cat > "$WORKTREE_PATH/.gitignore" << 'EOF'
# Environment files
.env
.env.local

# Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# Build outputs
dist/
build/
*.egg-info/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# Testing
.coverage
htmlcov/
.pytest_cache/

# Misc
.env.backup
*.bak
EOF

(cd "$WORKTREE_PATH" && git add . > /dev/null 2>&1)
(cd "$WORKTREE_PATH" && git commit -m "Initial commit from OVU template - $APP_NAME application" > /dev/null 2>&1)
echo -e "      ${GREEN}✓${NC} Initial commit created"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ Success! App ready! ✅          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""

# Step 10: Install dependencies (optional)
if [[ "$SKIP_INSTALL" == false ]]; then
  echo -e "${CYAN}Installing dependencies...${NC}"
  echo ""

  echo -e "${BLUE}[Dependencies]${NC} Installing frontend..."
  echo -e "      ${YELLOW}⏳${NC} This may take a few minutes..."
  (cd "$WORKTREE_PATH/frontend" && npm install > /dev/null 2>&1)
  echo -e "      ${GREEN}✓${NC} Frontend dependencies installed"

  echo -e "${BLUE}[Dependencies]${NC} Installing backend..."
  echo -e "      ${YELLOW}⏳${NC} This may take a few minutes..."
  (cd "$WORKTREE_PATH/backend" && python3 -m venv venv && source venv/bin/activate && pip install --quiet -r requirements.txt)
  echo -e "      ${GREEN}✓${NC} Backend dependencies installed (venv created)"

  echo ""
fi

# Summary
echo -e "${CYAN}📊 What was created:${NC}"
echo -e "  • Bare repository at ${GREEN}dev/$APP_NAME/${NC}"
echo -e "  • Worktree at ${GREEN}worktrees/${APP_NAME}-work/${NC}"
echo -e "  • Frontend (React + TypeScript + Vite)"
echo -e "  • Backend (FastAPI + Python)"
echo -e "  • Auth integration with ULM"
echo -e "  • 3-language support (he/en/ar)"
echo -e "  • Dark/light theme"
echo -e "  • Initial git commit on 'main' branch"
echo ""

if [[ -n "$GITHUB_REPO" ]]; then
  echo -e "${YELLOW}🐙 GitHub Setup:${NC}"
  echo -e "  Your app is configured with remote: ${GREEN}$GITHUB_REPO${NC}"
  echo -e "  To push to GitHub:"
  echo -e "  ${CYAN}cd $WORKTREE_PATH${NC}"
  echo -e "  ${CYAN}git push -u origin main${NC}"
  echo ""
fi

echo -e "${YELLOW}🚀 Next steps:${NC}"
echo ""
echo -e "  ${BLUE}1.${NC} Start the backend:"
echo -e "     ${CYAN}cd $WORKTREE_PATH/backend${NC}"
echo -e "     ${CYAN}source venv/bin/activate${NC}"
echo -e "     ${CYAN}uvicorn app.main:app --reload --port $BACKEND_PORT${NC}"
echo ""
echo -e "  ${BLUE}2.${NC} In a new terminal, start the frontend:"
echo -e "     ${CYAN}cd $WORKTREE_PATH/frontend${NC}"
echo -e "     ${CYAN}npm run dev${NC}"
echo ""
echo -e "  ${BLUE}3.${NC} Open in browser:"
echo -e "     ${CYAN}http://localhost:$FRONTEND_PORT${NC}"
echo ""

echo -e "${CYAN}📚 Documentation:${NC}"
echo -e "  • Frontend: ${CYAN}$WORKTREE_PATH/frontend/README.md${NC}"
echo -e "  • Backend:  ${CYAN}$WORKTREE_PATH/backend/README.md${NC}"
echo ""

if [[ "$SKIP_INSTALL" == true ]]; then
  echo -e "${YELLOW}⚠️  Remember to install dependencies:${NC}"
  echo -e "  ${CYAN}cd $WORKTREE_PATH/frontend && npm install${NC}"
  echo -e "  ${CYAN}cd $WORKTREE_PATH/backend && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt${NC}"
  echo ""
fi

echo -e "${PURPLE}💡 Tip:${NC} Test login with your ULM credentials"
echo ""
echo -e "${BLUE}Happy coding! 🎉${NC}"
