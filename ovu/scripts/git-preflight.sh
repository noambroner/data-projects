#!/bin/bash
# ================================================
# 🔄 OVU Git Preflight Check
# Verifies local branches are in sync before coding
# ================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREES_DIR="$PROJECT_DIR/worktrees"
DEV_DIR="$PROJECT_DIR/dev"

declare -A REPOS=(
  [ulm]="ovu-ulm"
  [aam]="ovu-aam"
  [shared]="ovu-shared"
)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
  echo "🔄 OVU Git Preflight Check"
  echo "==========================="
  echo ""
}

check_branch() {
  local path="$1"
  local expected_branch="$2"
  local label="$3"

  if [ ! -d "$path" ]; then
    echo -e "${YELLOW}⚠️  Skipping ${label}: path not found ($path)${NC}"
    return
  fi

  if [ ! -d "$path/.git" ] && [ ! -f "$path/.git" ]; then
    echo -e "${YELLOW}⚠️  Skipping ${label}: not a git repository ($path)${NC}"
    return
  fi

  echo -e "${YELLOW}• ${label}${NC}"

  if ! git -C "$path" fetch --all --prune --quiet 2>/dev/null; then
    echo -e "  ${RED}Fetch failed${NC}"
    return
  fi

  local branch
  branch=$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")

  local upstream
  if upstream=$(git -C "$path" rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null); then
    :
  else
    upstream=""
  fi

  local ahead=0 behind=0
  if [ -n "$upstream" ]; then
    read -r ahead behind <<<"$(git -C "$path" rev-list --left-right --count HEAD..."$upstream" 2>/dev/null || echo "0 0")"
  fi

  local dirty_count
  dirty_count=$(git -C "$path" status --porcelain=v1 2>/dev/null | wc -l | tr -d ' ')

  local status_msg=""
  if [ -z "$upstream" ]; then
    status_msg="no upstream (set one to track remotes)"
  elif [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
    status_msg="up to date"
  else
    status_msg="ahead ${ahead}, behind ${behind}"
  fi

  if [ "$branch" != "$expected_branch" ]; then
    status_msg="$status_msg | expected '$expected_branch', got '$branch'"
  fi

  if [ "$dirty_count" -gt 0 ]; then
    status_msg="$status_msg | local changes: ${dirty_count}"
  fi

  local color="$GREEN"
  if [ "$behind" -gt 0 ]; then
    color="$RED"
  elif [ "$ahead" -gt 0 ] || [ "$dirty_count" -gt 0 ]; then
    color="$YELLOW"
  fi

  echo -e "  ${color}${status_msg}${NC}"
  echo ""
}

main() {
  print_header

  for key in "${!REPOS[@]}"; do
    local repo="${REPOS[$key]}"
    local main_path="$DEV_DIR/$repo"
    local dev_path="$WORKTREES_DIR/${key}-work"

    check_branch "$main_path" "main" "${key^^} (main)"
    check_branch "$dev_path" "dev" "${key^^} (dev worktree)"
  done

  echo -e "${GREEN}✅ Preflight complete${NC}"
  echo ""
  echo "💡 If a branch is behind: git -C <path> pull --rebase"
}

main "$@"

