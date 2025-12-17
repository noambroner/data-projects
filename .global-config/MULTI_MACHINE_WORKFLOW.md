# 🔄 Multi-Machine Workflow Guide

## Overview

מדריך מקיף לעבודה עם פרויקט OVU ממספר מחשבים (בית, עבודה, וכו').

---

## 🎯 העיקרון הבסיסי

**Git + GitHub = המקור האמת היחיד!**

```
┌─────────────────────────────────────────────────────┐
│               GitHub (Cloud Storage)                 │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │   ovu-ulm    │  │   ovu-aam    │  │ ovu-shared│ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
└──────────┬─────────────────────┬────────────────────┘
           │                     │
     git pull/push          git pull/push
           │                     │
    ┌──────┴────────┐     ┌─────┴────────┐
    │ Computer 1    │     │ Computer 2   │
    │  (Home)       │     │  (Work)      │
    └───────────────┘     └──────────────┘
```

---

## 📦 סט-אפ ראשוני במחשב חדש

### שלב 1: התקנת כלים בסיסיים

```bash
# Git (אם לא מותקן)
sudo apt update
sudo apt install git

# GitHub CLI (מומלץ מאוד!)
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# התחברות ל-GitHub
gh auth login
```

### שלב 2: הגדרת Git

```bash
git config --global user.name "Noam Broner"
git config --global user.email "noambroner@gmail.com"

# אופציונלי: שינוי editor ברירת מחדל
git config --global core.editor "nano"

# מומלץ: autocrlf (חשוב ל-Windows/Linux)
git config --global core.autocrlf input
```

### שלב 3: שיבוט המאגרים

```bash
# יצירת תיקיית פרויקטים
mkdir -p ~/projects/ovu

# Clone repositories עם worktrees
cd ~/projects/ovu

# 1. Clone ULM
git clone --bare https://github.com/noambroner/ovu-ulm.git dev/ulm
mkdir -p worktrees
git -C dev/ulm worktree add ../../worktrees/ulm-work dev

# 2. Clone AAM
git clone --bare https://github.com/noambroner/ovu-aam.git dev/aam
git -C dev/aam worktree add ../../worktrees/aam-work dev

# 3. Clone Shared
git clone --bare https://github.com/noambroner/ovu-shared.git dev/shared
git -C dev/shared worktree add ../../worktrees/shared-work dev
```

### שלב 4: העתקת קבצי הגדרות גלובליים

```bash
# אם יש לך את ה-global-config ב-Git (מומלץ!)
cd ~/projects
git clone https://github.com/noambroner/global-config.git .global-config

# אם לא, העתק ידנית מהמחשב הקודם:
# scp -r user@home-computer:~/projects/.global-config ~/projects/
```

### שלב 5: התקנת תלויות

```bash
# Python (Backend)
cd ~/projects/ovu/worktrees/ulm-work/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Repeat for AAM
cd ~/projects/ovu/worktrees/aam-work/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Node.js (Frontend)
cd ~/projects/ovu/worktrees/ulm-work/frontend/react
npm install

# Repeat for AAM
cd ~/projects/ovu/worktrees/aam-work/frontend/react
npm install
```

---

## 🔄 Workflow היומיומי

### 🏠 בסוף יום עבודה במחשב 1 (בית):

```bash
cd ~/projects/ovu/worktrees/ulm-work

# 1. בדוק מה השתנה
git status

# 2. הוסף שינויים
git add .

# 3. Commit עם הודעה ברורה
git commit -m "Feature: Added user authentication API"

# 4. דחוף ל-GitHub
git push origin dev

# חזור על זה לכל repository שהשתנה (AAM, Shared)
```

### 💼 בתחילת יום עבודה במחשב 2 (עבודה):

```bash
cd ~/projects/ovu/worktrees/ulm-work

# 1. משוך את השינויים האחרונים
git pull origin dev

# 2. עכשיו יש לך את כל השינויים מאתמול!

# חזור על זה לכל repository
```

### ⚡ כלל הזהב:

```bash
# לפני שמתחילים לעבוד - תמיד:
git pull

# לפני שעוזבים את המחשב - תמיד:
git add .
git commit -m "..."
git push
```

---

## 🔐 ניהול SSH Keys לשרתי Production

SSH Keys הם **ספציפיים למחשב**. כל מחשב צריך את המפתחות שלו.

### אופציה 1: שיתוף המפתחות (פחות בטוח)

```bash
# מהמחשב הישן
scp ~/.ssh/ovu_backend_server user@new-computer:~/.ssh/
scp ~/.ssh/ovu_frontend_server user@new-computer:~/.ssh/

# במחשב החדש
chmod 600 ~/.ssh/ovu_backend_server
chmod 600 ~/.ssh/ovu_frontend_server
```

### אופציה 2: יצירת מפתחות חדשים (מומלץ!)

```bash
# במחשב החדש
ssh-keygen -t ed25519 -f ~/.ssh/ovu_backend_server_work -C "work-computer"
ssh-keygen -t ed25519 -f ~/.ssh/ovu_frontend_server_work -C "work-computer"

# העלה את המפתח הציבורי לשרתים
ssh-copy-id -i ~/.ssh/ovu_backend_server_work.pub ploi@64.176.171.223
ssh-copy-id -i ~/.ssh/ovu_frontend_server_work.pub ploi@64.176.173.105
```

---

## 🎨 סנכרון הגדרות Cursor

### אופציה 1: Cursor Settings Sync (מובנה)

Cursor תומך ב-Settings Sync דרך חשבון GitHub/Microsoft:

1. פתח Cursor
2. `Ctrl+Shift+P` → "Settings Sync: Turn On"
3. התחבר עם GitHub
4. במחשב השני: עשה את אותו הדבר

זה יסנכרן:
- Extensions
- User Settings
- Keybindings
- Snippets

### אופציה 2: שמירה ידנית ב-Git

```bash
# שמור את ההגדרות שלך ב-repository נפרד
mkdir ~/cursor-config
cp -r ~/.config/Cursor/User/settings.json ~/cursor-config/
cp -r ~/.config/Cursor/User/keybindings.json ~/cursor-config/
cd ~/cursor-config
git init
git add .
git commit -m "Cursor settings"
git remote add origin https://github.com/noambroner/cursor-config.git
git push -u origin main

# במחשב אחר
git clone https://github.com/noambroner/cursor-config.git ~/cursor-config
cp ~/cursor-config/* ~/.config/Cursor/User/
```

---

## 📋 Checklist למחשב חדש

### ✅ Software:
- [ ] Git מותקן
- [ ] GitHub CLI מותקן והמשתמש מחובר (`gh auth login`)
- [ ] Python 3.x
- [ ] Node.js + npm
- [ ] Flutter SDK (אם עובדים עם Flutter)
- [ ] Cursor IDE

### ✅ Repositories:
- [ ] ovu-ulm cloned עם worktree
- [ ] ovu-aam cloned עם worktree
- [ ] ovu-shared cloned עם worktree
- [ ] .global-config cloned

### ✅ Dependencies:
- [ ] Python venv created והתקנת requirements.txt (ULM)
- [ ] Python venv created והתקנת requirements.txt (AAM)
- [ ] npm install (ULM Frontend)
- [ ] npm install (AAM Frontend)

### ✅ SSH Keys:
- [ ] ovu_backend_server key מוגדר
- [ ] ovu_frontend_server key מוגדר
- [ ] Permissions 600 על כל המפתחות

### ✅ Configuration:
- [ ] Git user.name ו-user.email מוגדרים
- [ ] Cursor settings synced
- [ ] .env files created (אם נחוץ)

---

## 🚨 בעיות נפוצות ופתרונות

### "Permission denied" בעת git push

```bash
# וודא שאתה מחובר ל-GitHub
gh auth status

# או הגדר SSH key ל-GitHub
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# העתק את המפתח ל-GitHub Settings > SSH Keys
```

### Merge Conflicts

```bash
# אם יש קונפליקטים
git status  # ראה איזה קבצים בעייתיים

# פתח את הקבצים וערוך ידנית
# חפש את הסימנים:
# <<<<<<< HEAD
# שינויים שלך
# =======
# שינויים מהשרת
# >>>>>>> origin/dev

# לאחר עריכה:
git add .
git commit -m "Resolved merge conflicts"
git push
```

### שכחתי לעשות pull לפני שעבדתי

```bash
# שמור את השינויים שלך
git stash

# משוך את השינויים מהשרת
git pull

# החזר את השינויים שלך
git stash pop

# אם יש conflicts - פתור אותם
```

---

## 🎯 Best Practices

### 1. **Commit לעתים קרובות**
```bash
# לא טוב:
git commit -m "Fixed stuff" (אחרי 3 ימים)

# טוב:
git commit -m "Fixed login bug in auth.py"  (אחרי כל תיקון קטן)
```

### 2. **הודעות Commit ברורות**
```bash
# פורמט מומלץ:
# <type>: <description>
#
# Types: Feature, Fix, Update, Refactor, Docs, Style, Test

git commit -m "Feature: Added user role management API"
git commit -m "Fix: Resolved JWT token expiration issue"
git commit -m "Docs: Updated API documentation"
```

### 3. **Branches לפיצ'רים גדולים**
```bash
# עבודה על פיצ'ר חדש
git checkout -b feature/user-notifications
# ... עבוד על הפיצ'ר
git push origin feature/user-notifications

# במחשב אחר
git fetch origin
git checkout feature/user-notifications
```

### 4. **Pull לפני Push**
```bash
# תמיד:
git pull --rebase origin dev
git push origin dev
```

### 5. **לא לשמור סודות ב-Git!**
```bash
# הוסף ל-.gitignore:
.env
*.key
secrets.json
id_rsa*

# אם בטעות שמרת סוד:
git rm --cached .env
git commit -m "Remove .env from tracking"
```

---

## 🔗 Quick Commands Cheatsheet

```bash
# Setup (once per computer)
gh auth login
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Daily workflow
git pull                          # בתחילת יום
git status                        # בדוק מה השתנה
git add .                         # הוסף שינויים
git commit -m "Description"       # שמור שינויים
git push                          # שלח לענן

# Check status
git status                        # מצב נוכחי
git log --oneline                 # היסטוריית commits
git remote -v                     # רשימת remotes

# Undo changes
git checkout -- <file>            # בטל שינויים לקובץ
git reset --soft HEAD~1           # בטל commit אחרון (שמור שינויים)
git reset --hard HEAD~1           # בטל commit אחרון (מחק שינויים!)

# Branches
git branch                        # רשימת branches
git checkout -b new-branch        # צור branch חדש
git checkout dev                  # החלף ל-branch אחר
git merge feature-branch          # מזג branch

# Sync with remote
git fetch origin                  # הורד מידע על שינויים
git pull origin dev               # משוך שינויים
git push origin dev               # דחוף שינויים
```

---

## 📚 תרחישים נפוצים

### תרחיש 1: עבדתי במשרד, רוצה להמשיך בבית

```bash
# במשרד (סוף יום):
cd ~/projects/ovu/worktrees/ulm-work
git add .
git commit -m "WIP: Working on login page"
git push

# בבית (ערב):
cd ~/projects/ovu/worktrees/ulm-work
git pull
# עכשיו אפשר להמשיך מאיפה שעצרת!
```

### תרחיש 2: שני מחשבים עובדים במקביל (רצוי להימנע!)

```bash
# אם זה קרה, Git יזהה conflicts
git pull
# Auto-merging file.py
# CONFLICT (content): Merge conflict in file.py

# פתור ידנית ואז:
git add file.py
git commit -m "Resolved conflict"
git push
```

### תרחיש 3: רוצה לנסות משהו בלי לקלקל

```bash
# צור branch נפרד לניסויים
git checkout -b experiment
# עשה מה שאתה רוצה...

# אם הצליח:
git checkout dev
git merge experiment

# אם לא הצליח:
git checkout dev
git branch -D experiment  # מחק את ה-branch
```

---

## 🎓 למידה נוספת

- **Git Basics:** https://git-scm.com/book/en/v2
- **GitHub CLI:** https://cli.github.com/manual/
- **Interactive Git Tutorial:** https://learngitbranching.js.org/

---

*Last updated: December 2025*

