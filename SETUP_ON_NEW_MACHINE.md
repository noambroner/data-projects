# 🚀 Setup on New Machine - Instructions

## 📋 What to Do on Your Work Computer

### Step 1: Clone this repository

```bash
git clone https://github.com/noambroner/data-projects.git ~/projects
```

### Step 2: Open in Cursor

```bash
cd ~/projects
cursor .
```

### Step 3: Tell the AI (in Hebrew or English):

```
התקן את הכל
```

או:

```
Setup everything
```

או:

```
Run the setup script and install all tools
```

---

## 🤖 What the AI Will Do Automatically

The AI will:
1. ✅ Read the `.cursorrules` file
2. ✅ Run `NEW_MACHINE_SETUP.sh`
3. ✅ Install Git + GitHub CLI
4. ✅ Configure Git with your info
5. ✅ Clone all projects (ovu-ulm, ovu-aam, ovu-shared)
6. ✅ Setup worktrees
7. ✅ Install `sync-all` and `session-save` commands
8. ✅ Verify everything works

---

## 📝 After Setup is Complete

### Daily Morning Routine:

Tell the AI:
```
משוך עדכונים
```

Or:
```
Pull updates and show me yesterday's session
```

The AI will:
```bash
cd ~/projects && git pull
sync-all pull
cat ~/projects/ovu/docs/SESSION_HANDOFF.md
```

### Daily Evening Routine:

Tell the AI:
```
שמור סשן וקוד
```

Or:
```
Save session and push code
```

The AI will:
```bash
session-save ~/projects/ovu
sync-all push "Your description"
cd ~/projects && git push  # if needed
```

---

## 🎯 Simple Commands to Tell the AI

| What You Want | What to Say |
|---------------|-------------|
| Setup everything | "התקן את הכל" |
| Pull updates | "משוך עדכונים" |
| Push code | "שמור הכל" |
| Check status | "בדוק מצב" |
| Save session | "שמור סשן" |
| Show yesterday's work | "מה עשיתי אתמול" |

---

## ✅ Verification

Tell the AI:
```
בדוק שהכל מוכן
```

It will check:
- ✅ Git installed
- ✅ GitHub CLI installed
- ✅ sync-all command
- ✅ session-save command
- ✅ All repositories cloned
- ✅ All worktrees setup

---

## 📚 Important Files

- **`.cursorrules`** - Instructions for the AI
- **`START_HERE.md`** - Quick start guide
- **`MULTI_MACHINE_WORKFLOW.md`** - Full documentation
- **`SESSION_HANDOFF.md`** - Yesterday's work (in ovu/docs/)

---

## 🆘 If Something Goes Wrong

Tell the AI:
```
הצג לי את השגיאות
```

Or:
```
Show me the errors and help me fix them
```

The AI will debug and fix the issues.

---

## 🎉 That's It!

The AI on the work computer will handle everything automatically.

Just:
1. Clone the repository
2. Open in Cursor
3. Tell the AI: "התקן את הכל"
4. Wait for it to finish
5. Start working!

---

*The AI will read `.cursorrules` and know exactly what to do!*

