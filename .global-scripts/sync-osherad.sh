#!/bin/bash

#################################################################
# Osherad Project - Sync All Repositories
# 
# Use this script to:
# - Pull latest changes from GitHub (start of work day)
# - Push your changes to GitHub (end of work day)
#################################################################

set -e  # Exit on error

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
OSHERAD_ROOT="$(dirname "$SCRIPT_DIR")/osherad"

REPOS=(
    "worktrees/web-work"
    "worktrees/shared-work"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#################################################################
# Functions
#################################################################

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

#################################################################
# Pull Mode
#################################################################

pull_all() {
    print_header "PULLING LATEST CHANGES FROM GITHUB - OSHERAD"
    echo ""
    
    for repo in "${REPOS[@]}"; do
        repo_path="$OSHERAD_ROOT/$repo"
        repo_name=$(basename "$repo")
        
        echo -e "${BLUE}📦 $repo_name${NC}"
        
        if [ ! -d "$repo_path" ]; then
            print_error "Repository not found: $repo_path"
            continue
        fi
        
        cd "$repo_path"
        
        # Check current branch
        branch=$(git branch --show-current)
        echo "   Branch: $branch"
        
        # Check for local changes
        if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            print_warning "Local changes detected! Stashing..."
            git stash push -m "Auto-stash before pull $(date +%Y-%m-%d_%H:%M:%S)"
            STASHED=true
        else
            STASHED=false
        fi
        
        # Pull changes
        echo "   Pulling from origin..."
        if git pull origin "$branch"; then
            print_success "Pulled successfully"
        else
            print_error "Pull failed!"
            if [ "$STASHED" = true ]; then
                print_warning "Your changes are stashed. Run 'git stash pop' to restore them."
            fi
            continue
        fi
        
        # Pop stash if we stashed
        if [ "$STASHED" = true ]; then
            echo "   Restoring your changes..."
            if git stash pop; then
                print_success "Changes restored"
            else
                print_error "Conflicts detected! Please resolve manually."
            fi
        fi
        
        echo ""
    done
    
    print_success "All Osherad repositories synced!"
}

#################################################################
# Push Mode
#################################################################

push_all() {
    print_header "PUSHING CHANGES TO GITHUB - OSHERAD"
    echo ""
    
    COMMIT_MSG="$1"
    
    if [ -z "$COMMIT_MSG" ]; then
        echo -e "${YELLOW}No commit message provided.${NC}"
        read -p "Enter commit message: " COMMIT_MSG
        
        if [ -z "$COMMIT_MSG" ]; then
            print_error "Commit message is required!"
            exit 1
        fi
    fi
    
    for repo in "${REPOS[@]}"; do
        repo_path="$OSHERAD_ROOT/$repo"
        repo_name=$(basename "$repo")
        
        echo -e "${BLUE}📦 $repo_name${NC}"
        
        if [ ! -d "$repo_path" ]; then
            print_error "Repository not found: $repo_path"
            continue
        fi
        
        cd "$repo_path"
        
        # Check current branch
        branch=$(git branch --show-current)
        echo "   Branch: $branch"
        
        # Check for changes
        if git diff-index --quiet HEAD -- 2>/dev/null; then
            print_warning "No changes to commit"
            echo ""
            continue
        fi
        
        # Show status
        echo "   Changed files:"
        git status --short | head -10
        
        # Add all changes
        echo "   Adding changes..."
        git add .
        
        # Commit
        echo "   Committing..."
        if git commit -m "$COMMIT_MSG"; then
            print_success "Committed"
        else
            print_error "Commit failed!"
            continue
        fi
        
        # Push
        echo "   Pushing to origin..."
        if git push origin "$branch"; then
            print_success "Pushed successfully"
        else
            print_error "Push failed!"
        fi
        
        echo ""
    done
    
    print_success "All Osherad changes pushed!"
}

#################################################################
# Status Mode
#################################################################

status_all() {
    print_header "OSHERAD REPOSITORIES STATUS"
    echo ""
    
    for repo in "${REPOS[@]}"; do
        repo_path="$OSHERAD_ROOT/$repo"
        repo_name=$(basename "$repo")
        
        echo -e "${BLUE}📦 $repo_name${NC}"
        
        if [ ! -d "$repo_path" ]; then
            print_error "Repository not found: $repo_path"
            echo ""
            continue
        fi
        
        cd "$repo_path"
        
        # Current branch
        branch=$(git branch --show-current)
        echo "   Branch: $branch"
        
        # Remote
        remote=$(git remote get-url origin 2>/dev/null || echo "No remote")
        echo "   Remote: $remote"
        
        # Check for changes
        if git diff-index --quiet HEAD -- 2>/dev/null; then
            print_success "Clean (no changes)"
        else
            changed_count=$(git status --short | wc -l)
            print_warning "$changed_count files changed"
            git status --short | head -5
        fi
        
        # Check if ahead/behind remote
        git fetch origin "$branch" 2>/dev/null
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
        
        if [ -n "$REMOTE" ]; then
            if [ "$LOCAL" = "$REMOTE" ]; then
                echo "   Sync: ✅ Up to date"
            elif [ "$LOCAL" != "$REMOTE" ]; then
                print_warning "Out of sync with remote!"
            fi
        fi
        
        # Last commit
        last_commit=$(git log -1 --oneline 2>/dev/null || echo "No commits")
        echo "   Last commit: $last_commit"
        
        echo ""
    done
}

#################################################################
# Main
#################################################################

case "$1" in
    pull)
        pull_all
        ;;
    push)
        push_all "$2"
        ;;
    status)
        status_all
        ;;
    *)
        echo "🔄 Osherad Project - Sync All Repositories"
        echo ""
        echo "Usage:"
        echo "  $0 pull                      Pull latest changes from GitHub"
        echo "  $0 push \"commit message\"     Push your changes to GitHub"
        echo "  $0 status                    Show status of all repositories"
        echo ""
        echo "Examples:"
        echo "  $0 pull"
        echo "  $0 push \"Feature: Added new dashboard\""
        echo "  $0 status"
        exit 1
        ;;
esac

