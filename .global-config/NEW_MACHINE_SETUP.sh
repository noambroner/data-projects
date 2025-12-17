#!/bin/bash

#################################################################
# OVU Project - New Machine Setup Script
# 
# This script will:
# 1. Install required tools (Git, GitHub CLI)
# 2. Configure Git
# 3. Clone all OVU repositories
# 4. Setup worktrees
# 5. Install sync-all alias
#################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

#################################################################
# Step 1: Install Tools
#################################################################

install_tools() {
    print_header "STEP 1: Installing Required Tools"
    echo ""
    
    # Check if running on Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_warning "This script is designed for Linux. Continue anyway? (y/n)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Install Git
    if command -v git &> /dev/null; then
        print_success "Git already installed: $(git --version)"
    else
        print_info "Installing Git..."
        sudo apt update
        sudo apt install -y git
        print_success "Git installed"
    fi
    
    # Install GitHub CLI
    if command -v gh &> /dev/null; then
        print_success "GitHub CLI already installed: $(gh --version | head -1)"
    else
        print_info "Installing GitHub CLI..."
        type -p curl >/dev/null || sudo apt install curl -y
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
        print_success "GitHub CLI installed"
    fi
    
    echo ""
}

#################################################################
# Step 2: Configure Git
#################################################################

configure_git() {
    print_header "STEP 2: Configuring Git"
    echo ""
    
    # Check if already configured
    if git config --global user.name &> /dev/null && git config --global user.email &> /dev/null; then
        print_info "Git already configured:"
        echo "  Name: $(git config --global user.name)"
        echo "  Email: $(git config --global user.email)"
        print_warning "Keep this configuration? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo ""
            return
        fi
    fi
    
    # Get user info
    echo "Enter your name (for Git commits):"
    read -r git_name
    
    echo "Enter your email (for Git commits):"
    read -r git_email
    
    # Configure Git
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global core.autocrlf input
    
    print_success "Git configured"
    echo ""
}

#################################################################
# Step 3: Authenticate with GitHub
#################################################################

authenticate_github() {
    print_header "STEP 3: Authenticating with GitHub"
    echo ""
    
    if gh auth status &> /dev/null; then
        print_success "Already authenticated with GitHub"
    else
        print_info "Please authenticate with GitHub..."
        gh auth login
        print_success "GitHub authentication complete"
    fi
    
    echo ""
}

#################################################################
# Step 4: Clone Repositories
#################################################################

clone_repositories() {
    print_header "STEP 4: Cloning OVU Repositories"
    echo ""
    
    # Create directory structure
    mkdir -p ~/projects/ovu/dev
    mkdir -p ~/projects/ovu/worktrees
    
    cd ~/projects/ovu
    
    # Clone data-projects (includes global config)
    if [ ! -d ~/projects/.git ]; then
        print_info "Cloning data-projects repository..."
        cd ~
        git clone https://github.com/noambroner/data-projects.git projects
        cd ~/projects/ovu
        print_success "data-projects cloned"
    else
        print_success "projects directory already exists"
        cd ~/projects/ovu
    fi
    
    # Clone ULM
    if [ ! -d "dev/ulm" ]; then
        print_info "Cloning ovu-ulm..."
        git clone --bare https://github.com/noambroner/ovu-ulm.git dev/ulm
        git -C dev/ulm worktree add ../../worktrees/ulm-work dev
        print_success "ovu-ulm cloned"
    else
        print_success "ovu-ulm already exists"
    fi
    
    # Clone AAM
    if [ ! -d "dev/aam" ]; then
        print_info "Cloning ovu-aam..."
        git clone --bare https://github.com/noambroner/ovu-aam.git dev/aam
        git -C dev/aam worktree add ../../worktrees/aam-work dev
        print_success "ovu-aam cloned"
    else
        print_success "ovu-aam already exists"
    fi
    
    # Clone Shared
    if [ ! -d "dev/shared" ]; then
        print_info "Cloning ovu-shared..."
        git clone --bare https://github.com/noambroner/ovu-shared.git dev/shared
        git -C dev/shared worktree add ../../worktrees/shared-work dev
        print_success "ovu-shared cloned"
    else
        print_success "ovu-shared already exists"
    fi
    
    # Create symlink for shared
    cd ~/projects
    if [ ! -L "shared" ]; then
        ln -s ovu/worktrees/shared-work shared
        print_success "Created symlink for shared"
    fi
    
    echo ""
}

#################################################################
# Step 5: Install Aliases
#################################################################

install_aliases() {
    print_header "STEP 5: Installing Convenient Aliases"
    echo ""
    
    # Install sync-all alias
    SHELL_RC=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    fi
    
    if [ -n "$SHELL_RC" ]; then
        if ! grep -q "alias sync-all=" "$SHELL_RC" 2>/dev/null; then
            echo "" >> "$SHELL_RC"
            echo "# OVU Sync Alias" >> "$SHELL_RC"
            echo "alias sync-all='/home/noam/projects/.global-scripts/sync-all.sh'" >> "$SHELL_RC"
            print_success "sync-all alias installed to $SHELL_RC"
        else
            print_success "sync-all alias already exists"
        fi
    fi
    
    echo ""
}

#################################################################
# Step 6: Install Dependencies (Optional)
#################################################################

install_dependencies() {
    print_header "STEP 6: Installing Project Dependencies (Optional)"
    echo ""
    
    print_warning "Do you want to install Python and Node.js dependencies? (y/n)"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_info "Skipping dependency installation"
        echo ""
        return
    fi
    
    # Python dependencies
    print_info "Installing Python dependencies..."
    
    for backend in ~/projects/ovu/worktrees/ulm-work/backend ~/projects/ovu/worktrees/aam-work/backend; do
        if [ -f "$backend/requirements.txt" ]; then
            echo "  Setting up: $backend"
            cd "$backend"
            python3 -m venv venv
            source venv/bin/activate
            pip install -q -r requirements.txt
            deactivate
            print_success "$(basename $(dirname $backend)) backend dependencies installed"
        fi
    done
    
    # Node.js dependencies
    print_info "Installing Node.js dependencies..."
    
    for frontend in ~/projects/ovu/worktrees/ulm-work/frontend/react ~/projects/ovu/worktrees/aam-work/frontend/react; do
        if [ -f "$frontend/package.json" ]; then
            echo "  Setting up: $frontend"
            cd "$frontend"
            npm install --silent
            print_success "$(basename $(dirname $(dirname $frontend))) frontend dependencies installed"
        fi
    done
    
    echo ""
}

#################################################################
# Main
#################################################################

print_header "OVU PROJECT - NEW MACHINE SETUP"
echo ""
echo "This script will set up your OVU development environment."
echo "It will:"
echo "  1. Install required tools (Git, GitHub CLI)"
echo "  2. Configure Git with your name and email"
echo "  3. Authenticate with GitHub"
echo "  4. Clone all OVU repositories"
echo "  5. Install convenient aliases"
echo "  6. (Optional) Install project dependencies"
echo ""
print_warning "Continue? (y/n)"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""

# Run setup steps
install_tools
configure_git
authenticate_github
clone_repositories
install_aliases
install_dependencies

# Done!
print_header "SETUP COMPLETE! 🎉"
echo ""
echo "Your OVU development environment is ready!"
echo ""
echo "📁 Project location: ~/projects/ovu"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run: source ~/.bashrc)"
echo "  2. Open project in Cursor:"
echo "     cursor ~/projects/ovu/ovu-workspace.code-workspace"
echo "  3. Use 'sync-all' command to sync with GitHub:"
echo "     sync-all pull   - Pull latest changes"
echo "     sync-all push   - Push your changes"
echo "     sync-all status - Check status"
echo ""
echo "📚 Documentation:"
echo "  - Quick Guide: ~/projects/.global-config/QUICK_SYNC_GUIDE.md"
echo "  - Full Guide: ~/projects/.global-config/MULTI_MACHINE_WORKFLOW.md"
echo ""
print_success "Happy coding! 🚀"

