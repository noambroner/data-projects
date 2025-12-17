# ✅ תשובה לשאלתך: עבודה עם הפרויקט ממספר מחשבים

---

## ❓ השאלה שלך:

> איך אני עובד על אותו פרוייקט כל פעם על מחשב אחר?  
> ואיך הנתונים מסונכרנים בין המחשבים?

---

## 💡 התשובה הקצרה:

**Git + GitHub = הפתרון!**

```
Git שומר את כל ההיסטוריה של הפרויקט
GitHub שומר את הכל בענן
כל מחשב מושך (pull) ודוחף (push) שינויים
```

---

## 🎯 איך זה עובד בפועל?

### תסריט טיפוסי:

#### 🏠 יום ראשון - בבית:
```bash
# 1. פתחת את Cursor
cursor ~/projects/ovu/ovu-workspace.code-workspace

# 2. עבדת על תכונה חדשה...
#    (שינית קבצים, הוספת קוד, וכו')

# 3. בסוף היום - שמרת הכל ב-GitHub
sync-all push "Feature: Added login validation"
```

**מה קרה מאחורי הקלעים:**
- ✅ Git שמר את כל השינויים שלך
- ✅ GitHub קיבל את השינויים
- ✅ עכשיו השינויים נמצאים בענן!

---

#### 💼 יום שני - בעבודה:
```bash
# 1. הגעת למחשב בעבודה
# 2. משכת את השינויים מאתמול
sync-all pull

# 3. פתחת את Cursor
cursor ~/projects/ovu/ovu-workspace.code-workspace

# 4. הקוד מאתמול כבר כאן! ✨
#    אפשר להמשיך מאיפה שעצרת!

# 5. עבדת על המשך התכונה...

# 6. בסוף היום
sync-all push "Feature: Completed login validation"
```

**מה קרה:**
- ✅ משכת את השינויים מהענן
- ✅ עבדת על הקוד
- ✅ שלחת את השינויים החדשים לענן

---

#### 🏠 יום שלישי - חזרה לבית:
```bash
# 1. משכת את מה שעשית בעבודה
sync-all pull

# 2. כל השינויים מאתמול כבר כאן!
# 3. ממשיך לעבוד...
```

---

## 🔄 הדיאגרמה המלאה:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   🏠 מחשב בית                 ☁️ GitHub                💼 מחשב עבודה   │
│                                                             │
│      ▼                                                      │
│   עובד על                                                   │
│   הקוד                                                      │
│      │                                                      │
│      │ sync-all push                                        │
│      └──────────────► שומר בענן ◄────────┐                  │
│                           │              │                  │
│                           │              │ sync-all pull    │
│                           ▼              │                  │
│                      הקוד מסונכרן        │                  │
│                           │              │                  │
│      ┌───────────────────►│              │                  │
│      │ sync-all pull      ▼              │                  │
│      │                                   └─────────────┐    │
│   הקוד מאתמול                                        עובד על│
│   כבר כאן!                                           הקוד │
│                                                        ▼   │
│                          sync-all push ◄───────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ איך מתקינים במחשב חדש?

### אופציה 1: סקריפט אוטומטי (מומלץ!)

```bash
cd ~/projects/.global-config
./NEW_MACHINE_SETUP.sh
```

הסקריפט יעשה **הכל** בשבילך:
- ✅ יתקין Git + GitHub CLI
- ✅ יגדיר את Git עם שם ואימייל שלך
- ✅ יתחבר ל-GitHub
- ✅ ישכפל את כל ה-repositories
- ✅ יתקין את הפקודה `sync-all`
- ✅ (אופציונלי) יתקין תלויות Python/Node.js

**זמן: ~5 דקות** ⏱️

---

### אופציה 2: ידני (אם אתה אוהב שליטה מלאה)

```bash
# 1. התקן כלים
sudo apt install git gh

# 2. התחבר ל-GitHub
gh auth login

# 3. שכפל repositories
cd ~/projects/ovu
git clone --bare https://github.com/noambroner/ovu-ulm.git dev/ulm
git clone --bare https://github.com/noambroner/ovu-aam.git dev/aam
git clone --bare https://github.com/noambroner/ovu-shared.git dev/shared

# 4. צור worktrees
mkdir -p worktrees
git -C dev/ulm worktree add ../../worktrees/ulm-work dev
git -C dev/aam worktree add ../../worktrees/aam-work dev
git -C dev/shared worktree add ../../worktrees/shared-work dev

# 5. התקן sync-all
echo 'alias sync-all="/home/noam/projects/.global-scripts/sync-all.sh"' >> ~/.zshrc
source ~/.zshrc
```

---

## 📋 כללי הזהב

### ✅ תמיד לפני עבודה:
```bash
sync-all pull
```

### ✅ תמיד בסוף עבודה:
```bash
sync-all push "תיאור מה עשיתי"
```

### ✅ אם לא בטוח במצב:
```bash
sync-all status
```

---

## 🔐 מה עם SSH Keys לשרתי Production?

SSH Keys הם **ספציפיים למחשב**.

### אופציה 1: העתק מפתחות קיימים
```bash
# מהמחשב הישן
scp ~/.ssh/ovu_backend_server user@new-computer:~/.ssh/

# במחשב החדש
chmod 600 ~/.ssh/ovu_backend_server
```

### אופציה 2: צור מפתחות חדשים (יותר בטוח)
```bash
# במחשב החדש
ssh-keygen -t ed25519 -f ~/.ssh/ovu_backend_server_work

# העלה לשרת
ssh-copy-id -i ~/.ssh/ovu_backend_server_work.pub ploi@64.176.171.223
```

---

## 🎨 מה עם הגדרות Cursor?

Cursor תומך ב-**Settings Sync** מובנה!

### הפעלה:
1. פתח Cursor
2. `Ctrl+Shift+P`
3. חפש "Settings Sync: Turn On"
4. התחבר עם GitHub
5. במחשב השני - עשה את אותו הדבר

זה יסנכרן אוטומטית:
- ✅ Extensions
- ✅ Settings
- ✅ Keybindings
- ✅ Snippets

---

## 📊 סיכום הפקודות

| פעולה | פקודה | מתי |
|-------|-------|-----|
| משוך שינויים | `sync-all pull` | תחילת יום / החלפת מחשב |
| שלח שינויים | `sync-all push "..."` | סוף יום / לפני כיבוי |
| בדוק מצב | `sync-all status` | בכל עת |
| פתח פרויקט | `cursor ~/projects/ovu/ovu-workspace.code-workspace` | - |

---

## 🎓 למידה נוספת

| נושא | מיקום |
|------|-------|
| מדריך מהיר | `~/projects/START_HERE.md` |
| מדריך מלא | `~/projects/.global-config/MULTI_MACHINE_WORKFLOW.md` |
| הסבר sync-all | `~/projects/.global-config/QUICK_SYNC_GUIDE.md` |
| אדריכלות | `~/projects/.global-config/PROJECT_ARCHITECTURE_SPEC.md` |

---

## 💬 שאלות נפוצות

### Q: מה קורה אם אשכח לעשות push במחשב אחד?
**A:** לא נורא! כשתחזור למחשב הזה, פשוט תעשה `sync-all pull` קודם. Git ינסה למזג את השינויים. אם יש conflicts, הוא יגיד לך ותצטרך לפתור אותם ידנית.

### Q: האם אני יכול לעבוד על שני מחשבים במקביל?
**A:** טכנית כן, אבל לא מומלץ. זה עלול ליצור conflicts. עדיף לעבוד על מחשב אחד בכל פעם.

### Q: מה קורה אם יש לי שינויים שלא שמרתי ואני רוצה למשוך עדכונים?
**A:** `sync-all pull` יעשה stash אוטומטי לשינויים שלך, ימשוך את העדכונים, ויחזיר את השינויים שלך.

### Q: כמה מחשבים אני יכול להתקין?
**A:** בלי הגבלה! כל מחשב עם גישה ל-GitHub שלך.

---

## ✨ סיכום

**אתה שואל:** איך אני עובד על הפרויקט ממספר מחשבים?

**התשובה:** 

1. **Git שומר את כל השינויים**
2. **GitHub מסנכרן בין המחשבים**
3. **הפקודות `sync-all pull/push` עושות את הקסם**
4. **במחשב חדש: הרץ `NEW_MACHINE_SETUP.sh`**

**זהו! פשוט כמו Dropbox, אבל הרבה יותר חכם!** 🚀

---

*קרא את `~/projects/START_HERE.md` למדריך התחלה מהירה!*

