# 🚀 OVU Worktrees Setup Guide

## מה זה ולמה זה טוב?

מערכת Worktrees מאפשרת לך לעבוד על מספר branches במקביל בלי להחליף ביניהם!

### המבנה שהוקם:

```
~/projects/dev/              # Repositories מקוריים (אל תגע!)
├── ovu-ulm/    (main)
├── ovu-aam/    (main)
└── ovu-shared/ (main)

~/projects/worktrees/        # תיקיות העבודה שלך ✨
├── ulm-work/               # ULM (dev branch)
├── aam-work/               # AAM (dev branch)
└── shared-work/            # SHARED (dev branch)
```

---

## 🎯 איך להשתמש?

### עבודה רגילה:

```bash
# עובד על ULM
cd ~/projects/worktrees/ulm-work
code .
npm run dev

# עובד על AAM (בטרמינל/חלון אחר!)
cd ~/projects/worktrees/aam-work
code .
npm run dev

# עובד על SHARED (בטרמינל/חלון שלישי!)
cd ~/projects/worktrees/shared-work
code .
```

**🎉 כל השינויים ב-shared-work נראים מיד ב-ulm-work ו-aam-work!**

---

## 🔗 איך ה-Symlinks עובדים?

### המצב הנוכחי:

```
ulm-work/shared/interface-resources → shared-work/interface-resources
ulm-work/shared/localization → shared-work/localization
ulm-work/shared/react-components → shared-work/react-components

aam-work/shared/interface-resources → shared-work/interface-resources
aam-work/shared/localization → shared-work/localization
aam-work/shared/react-components → shared-work/react-components
```

**כשאתה עורך קובץ ב-shared-work, הוא משתנה אוטומטית ב-ulm-work וב-aam-work!**

---

## 🪝 Git Hooks - מה קורה כש commit?

### לפני Commit (pre-commit hook):
1. 🔍 Git בודק אם יש symlinks ב-shared/
2. 📦 אם כן - מחליף אותם בקבצים אמיתיים
3. ✅ מוסיף אותם ל-commit
4. 💾 Commit מצליח!

### אחרי Commit (post-commit hook):
1. 🔁 Git מחזיר את ה-symlinks אוטומטית
2. ✅ אתה חוזר לעבוד עם live updates

**אתה לא צריך לעשות כלום! הכל אוטומטי! 🎉**

---

## 📜 הסקריפטים שיש לך:

### 1. link-shared.sh
```bash
cd ~/projects/worktrees/ulm-work
bash scripts/link-shared.sh
```
**מה זה עושה:** יוצר symlinks ל-shared-work (לפיתוח)

### 2. unlink-shared.sh
```bash
cd ~/projects/worktrees/ulm-work
bash scripts/unlink-shared.sh
```
**מה זה עושה:** מחליף symlinks בקבצים אמיתיים (לפני commit ידני)

### 3. restore-links.sh
```bash
cd ~/projects/worktrees/ulm-work
bash scripts/restore-links.sh
```
**מה זה עושה:** מחזיר symlinks אחרי commit

**💡 בדרך כלל לא תצטרך להריץ אותם ידנית - ה-hooks עושים את זה בשבילך!**

---

## 🆕 יצירת Worktree חדש

### ULM Worktree חדש:
```bash
cd ~/projects/dev/ovu-ulm
git worktree add ~/projects/worktrees/ulm-feature-auth feature/auth
cd ~/projects/worktrees/ulm-feature-auth
bash scripts/link-shared.sh  # קישור ל-shared
```

### AAM Worktree חדש:
```bash
cd ~/projects/dev/ovu-aam
git worktree add ~/projects/worktrees/aam-feature-roles feature/roles
cd ~/projects/worktrees/aam-feature-roles
bash scripts/link-shared.sh  # קישור ל-shared
```

### SHARED Worktree חדש:
```bash
cd ~/projects/dev/ovu-shared
git worktree add ~/projects/worktrees/shared-feature-table feature/new-table
```

---

## 🗑️ מחיקת Worktree

כשסיימת עם worktree:

```bash
# סגור את הפרויקט בCursor/VSCode
cd ~/projects/dev/ovu-ulm
git worktree remove ~/projects/worktrees/ulm-feature-auth
```

**Git ימחק את התיקייה אוטומטית!**

---

## 🔄 תהליך עבודה טיפוסי

### דוגמה: שינוי טבלה משותפת

```bash
# 1. עורך את הטבלה ב-shared
cd ~/projects/worktrees/shared-work
code react-components/Table.tsx
# עושה שינויים...

# 2. רואה את השינויים מיד ב-ULM (אוטומטי!)
cd ~/projects/worktrees/ulm-work
npm run dev  # הטבלה המעודכנת כבר שם!

# 3. רואה את השינויים מיד ב-AAM (אוטומטי!)
cd ~/projects/worktrees/aam-work
npm run dev  # הטבלה המעודכנת כבר שם!

# 4. Commit השינויים ב-shared
cd ~/projects/worktrees/shared-work
git add .
git commit -m "Improved Table component"
# 🪝 Git Hook אוטומטית מטפל בsymlinks!
git push origin dev

# 5. Commit השינויים ב-ULM
cd ~/projects/worktrees/ulm-work
git add .
git commit -m "Updated shared components"
# 🪝 Git Hook אוטומטית מטפל בsymlinks!
git push origin dev

# 6. Commit השינויים ב-AAM
cd ~/projects/worktrees/aam-work
git add .
git commit -m "Updated shared components"
# 🪝 Git Hook אוטומטית מטפל בsymlinks!
git push origin dev
```

---

## ❓ שאלות נפוצות

### Q: מה קורה אם אני עושה commit בטעות עם symlinks?
**A:** ה-pre-commit hook אוטומטית מחליף אותם לקבצים אמיתיים. אבל אם זה לא עבד, תריץ:
```bash
bash scripts/unlink-shared.sh
git add shared/
git commit --amend
```

### Q: איך אני יודע אם יש לי symlinks או קבצים אמיתיים?
**A:** תריץ:
```bash
ls -la shared/
```
אם יש חץ (→) זה symlink. אם אין - זה קובץ רגיל.

### Q: מה אם אני רוצה לעבוד offline בלי symlinks?
**A:** תריץ:
```bash
bash scripts/unlink-shared.sh
```
עכשיו יש לך עותק מלא של shared. לחזור לsymlinks:
```bash
bash scripts/link-shared.sh
```

### Q: איך אני מסנכרן את shared-work ל-main?
**A:**
```bash
cd ~/projects/worktrees/shared-work
git fetch origin
git merge origin/main
# אם יש conflicts, פתור אותם
git push origin dev
```

---

## 🎉 סיכום

✅ **3 Worktrees** - ulm-work, aam-work, shared-work  
✅ **Symlinks אוטומטיים** - שינויים ב-shared נראים מיד  
✅ **Git Hooks** - מטפלים ב-symlinks לפני/אחרי commit  
✅ **סקריפטים** - link/unlink/restore shared  
✅ **worktrees.json** - setup אוטומטי לworktrees חדשים  

**תהנה מעבודה מהירה וחכמה! 🚀**

---

## 📞 צריך עזרה?

אם משהו לא עובד או שיש שאלות:
1. בדוק את המדריך הזה
2. הרץ `git status` לראות מה המצב
3. הרץ `ls -la shared/` לראות את הsymlinks
4. הרץ את הסקריפטים ידנית אם צריך

**בהצלחה! 💪**


