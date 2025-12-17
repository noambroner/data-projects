# 🚀 Data Projects - Global Repository

This repository contains the **global configuration, scripts, and documentation** for all data projects.

---

## 📁 What's Inside?

```
projects/
├── .global-config/         Global configuration files
├── .global-scripts/        Utility scripts (sync-all, etc.)
├── START_HERE.md          Quick start guide
├── ANSWER_TO_YOUR_QUESTION.md
└── ovu/                   OVU project structure
    ├── docs/              Project documentation
    ├── scripts/           Project-specific scripts
    └── *.md               Project files
```

---

## 🎯 Quick Start

### First Time Setup (New Machine)

#### Option 1: Let AI Do Everything (Recommended!) 🤖

```bash
# 1. Clone this repository
git clone https://github.com/noambroner/data-projects.git ~/projects

# 2. Open in Cursor
cd ~/projects
cursor .

# 3. Tell the AI:
"התקן את הכל" (Hebrew)
# or
"Setup everything" (English)

# ✨ AI will read .cursorrules and run everything automatically!
```

**See:** `SETUP_ON_NEW_MACHINE.md` for detailed instructions.

---

#### Option 2: Manual Setup

```bash
# Clone this repository
git clone https://github.com/noambroner/data-projects.git ~/projects
cd ~/projects

# Run setup script
cd .global-config
./NEW_MACHINE_SETUP.sh

# This will install everything:
# - Git + GitHub CLI
# - All repositories (ovu-ulm, ovu-aam, ovu-shared)
# - Worktrees
# - sync-all & session-save commands
```

### Daily Workflow

```bash
# Start of day - pull latest changes
sync-all pull

# End of day - push your changes
sync-all push "Description of what you did"
```

---

## 📚 Documentation

| File | Description |
|------|-------------|
| [START_HERE.md](START_HERE.md) | Quick start guide (3 minutes) |
| [ANSWER_TO_YOUR_QUESTION.md](ANSWER_TO_YOUR_QUESTION.md) | Multi-machine workflow explanation |
| [.global-config/MULTI_MACHINE_WORKFLOW.md](.global-config/MULTI_MACHINE_WORKFLOW.md) | Complete multi-machine guide |
| [.global-config/QUICK_SYNC_GUIDE.md](.global-config/QUICK_SYNC_GUIDE.md) | sync-all command reference |
| [.global-config/CURSOR_QUICK_START.md](.global-config/CURSOR_QUICK_START.md) | Cursor IDE setup |

---

## 🔧 Available Tools

### sync-all
Automatic synchronization tool for all OVU repositories.

```bash
sync-all pull          # Pull latest changes from GitHub
sync-all push "msg"    # Push your changes to GitHub
sync-all status        # Check status of all repos
```

### NEW_MACHINE_SETUP.sh
Automatic setup script for new machines.

```bash
cd .global-config
./NEW_MACHINE_SETUP.sh
```

---

## 📦 Projects

This repository manages global files only. Individual projects are in separate repositories:

### OVU Project:
- **ovu-ulm** (User Login Manager): https://github.com/noambroner/ovu-ulm
- **ovu-aam** (Admin Area Manager): https://github.com/noambroner/ovu-aam
- **ovu-shared** (Shared Resources): https://github.com/noambroner/ovu-shared

These are managed separately using Git worktrees and the `sync-all` tool.

### Future Projects:
More projects will be added here over time...

---

## 🏗️ Architecture

```
projects/                    ← This repository (global files)
│
├── .global-config/         ← Global configuration
├── .global-scripts/        ← Utility scripts
│
└── ovu/                    ← OVU project
    ├── dev/                ← Bare repositories (ignored by this repo)
    │   ├── ovu-ulm/
    │   ├── ovu-aam/
    │   └── ovu-shared/
    │
    ├── worktrees/          ← Working directories (ignored by this repo)
    │   ├── ulm-work/
    │   ├── aam-work/
    │   └── shared-work/
    │
    ├── docs/               ← Project documentation (in this repo)
    └── scripts/            ← Project scripts (in this repo)
```

---

## 🔄 Multi-Machine Workflow

### On Computer 1 (Home):
```bash
# Work on code...
sync-all push "Feature: Added login page"
```

### On Computer 2 (Work):
```bash
# Pull yesterday's changes
sync-all pull

# Everything is synced! ✨
# Continue working...
```

---

## 🆘 Help

- **Forgot how to use sync-all?** → `sync-all` (without arguments)
- **Need full documentation?** → Read [MULTI_MACHINE_WORKFLOW.md](.global-config/MULTI_MACHINE_WORKFLOW.md)
- **Setting up new machine?** → Run `.global-config/NEW_MACHINE_SETUP.sh`

---

## 📝 Notes

- This repository contains **configuration and documentation** only
- Actual project code (ulm, aam, shared) is in **separate repositories**
- The `sync-all` tool manages all repositories together
- Use `.gitignore` to prevent committing `ovu/dev/` and `ovu/worktrees/`

---

## 🔗 Links

| Resource | URL |
|----------|-----|
| ULM Frontend | https://ulm-rct.ovu.co.il |
| AAM Frontend | https://aam-rct.ovu.co.il |
| Backend Server | 64.176.171.223 |

---

**Last Updated:** December 2024
**Maintained By:** Noam Broner

