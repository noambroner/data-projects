# 🚀 OVU Project - Start Here!

## ברוכים הבאים לפרויקט OVU!

זהו מדריך ההתחלה המהירה שלך לעבודה עם הפרויקט.

---

## 📍 איפה אני נמצא?

אתה נמצא בתיקיית השורש של כל הפרויקטים שלך: `~/projects`

```
~/projects/
├── .global-config/        ← הגדרות גלובליות ומדריכים
├── .global-scripts/       ← סקריפטים שימושיים
├── ovu/                   ← פרויקט OVU
│   ├── worktrees/         ← קוד בפועל (כאן אתה עובד!)
│   │   ├── ulm-work/      ← User Login Manager
│   │   ├── aam-work/      ← Admin Area Manager
│   │   └── shared-work/   ← Shared Components
│   └── docs/              ← תיעוד פרויקט
└── shared → ovu/worktrees/shared-work  ← symlink
```

---

## ⚡ הפקודות החשובות ביותר

### 🔄 סנכרון עם GitHub

```bash
# בתחילת יום עבודה (או כשפותח מחשב אחר)
sync-all pull

# בסוף יום עבודה (לפני כיבוי המחשב)
sync-all push "תיאור מה עשיתי היום"

# בדיקת מצב (בכל רגע)
sync-all status
```

### 🎨 פתיחת הפרויקט ב-Cursor

```bash
# פתיחת כל הפרויקט (מומלץ למבט כללי)
cursor ~/projects/ovu/ovu-workspace.code-workspace

# פתיחת ULM בלבד
cursor ~/projects/ovu/worktrees/ulm-work

# פתיחת AAM בלבד
cursor ~/projects/ovu/worktrees/aam-work
```

---

## 🏃 התחלה מהירה - 3 צעדים

### 1️⃣ משוך שינויים אחרונים
```bash
sync-all pull
```

### 2️⃣ פתח את הפרויקט
```bash
cursor ~/projects/ovu/ovu-workspace.code-workspace
```

### 3️⃣ התחל לעבוד!
עבוד על הקוד כרגיל...

---

## 💾 שמירת השינויים שלך

### כשגמרת לעבוד:

```bash
# בדוק מה השתנה
sync-all status

# שמור ושלח הכל
sync-all push "Feature: Added new login page"
```

---

## 🖥️ עבודה ממספר מחשבים

### במחשב הראשון (בית):
```bash
# עבדת על הקוד...
sync-all push "WIP: Working on dashboard"
```

### במחשב השני (עבודה):
```bash
# משוך את השינויים מאתמול
sync-all pull

# המשך לעבוד מאיפה שעצרת!
```

### חזרה למחשב הראשון:
```bash
# משוך את מה שעשית בעבודה
sync-all pull

# והמשך...
```

**זהו! Git מסנכרן הכל באופן אוטומטי! ✨**

---

## 🆕 התקנה במחשב חדש

אם אתה מגיע למחשב חדש (או רוצה להתקין הכל במחשב נוסף):

```bash
# הורד את סקריפט ההתקנה
curl -o setup.sh https://raw.githubusercontent.com/noambroner/global-config/main/NEW_MACHINE_SETUP.sh

# הרץ אותו
chmod +x setup.sh
./setup.sh
```

הסקריפט יתקין הכל אוטומטית:
- ✅ Git + GitHub CLI
- ✅ כל הrepositories
- ✅ Worktrees
- ✅ הפקודה `sync-all`

---

## 📚 מדריכים מלאים

| מדריך | תיאור | מיקום |
|-------|--------|-------|
| 🔄 Multi-Machine Workflow | מדריך מלא לעבודה מכמה מחשבים | `.global-config/MULTI_MACHINE_WORKFLOW.md` |
| ⚡ Quick Sync Guide | הסבר על `sync-all` | `.global-config/QUICK_SYNC_GUIDE.md` |
| 🏗️ Architecture Spec | אדריכלות הפרויקט | `.global-config/PROJECT_ARCHITECTURE_SPEC.md` |
| 🎯 Cursor Quick Start | התחלה עם Cursor | `.global-config/CURSOR_QUICK_START.md` |

---

## 🔗 קישורים חשובים

### Production Servers:
- **ULM Frontend**: https://ulm-rct.ovu.co.il
- **AAM Frontend**: https://aam-rct.ovu.co.il
- **Backend Server**: 64.176.171.223

### GitHub Repositories:
- **ULM**: https://github.com/noambroner/ovu-ulm
- **AAM**: https://github.com/noambroner/ovu-aam
- **Shared**: https://github.com/noambroner/ovu-shared

---

## 🆘 עזרה

### שכחתי איך משתמשים ב-sync-all?
```bash
sync-all
# יראה לך את כל האופציות
```

### רוצה לראות מה עשיתי לאחרונה?
```bash
cd ~/projects/ovu/worktrees/ulm-work
git log --oneline -10
```

### יש בעיה עם Cursor?
קרא את: `.global-config/CURSOR_QUICK_START.md`

### יש בעיה עם Git?
קרא את: `.global-config/MULTI_MACHINE_WORKFLOW.md` (סעיף "בעיות נפוצות")

---

## 🎯 כלל הזהב

```
לפני עבודה → sync-all pull
אחרי עבודה → sync-all push "..."
```

**זהו! פשוט כמו שמירת קובץ ב-Word, רק שזה שומר בענן!** ☁️

---

## ✅ Checklist יומי

### בוקר:
- [ ] `sync-all pull`
- [ ] `cursor ~/projects/ovu/ovu-workspace.code-workspace`

### ערב:
- [ ] `sync-all status` (בדיקה)
- [ ] `sync-all push "..."`  (שמירה)

---

**זהו! אתה מוכן להתחיל! 🚀**

*אם אתה תקוע, תמיד יש לך את המדריכים המפורטים בתיקייה `.global-config/`*

