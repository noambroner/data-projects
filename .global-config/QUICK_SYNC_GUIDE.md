# ⚡ Quick Sync Guide - מדריך מהיר

## 🎯 הפקודות שאתה צריך לדעת

### בתחילת יום (או כשמחליפים מחשב):
```bash
sync-all pull
```
זה מוריד את כל השינויים האחרונים מ-GitHub לכל 3 הrepositories.

---

### בסוף יום (או לפני שעוזבים את המחשב):
```bash
sync-all push "מה שעשיתי היום"
```
זה שומר ושולח את כל השינויים ל-GitHub.

דוגמאות:
```bash
sync-all push "Feature: Added login page"
sync-all push "Fix: Resolved authentication bug"
sync-all push "Update: Improved dashboard UI"
```

---

### לבדוק מצב (בכל עת):
```bash
sync-all status
```
זה מראה לך מה השתנה ואם יש שינויים שלא נשמרו.

---

## 🔧 התקנת הקיצור

הוסף לקובץ `~/.bashrc` או `~/.zshrc`:

```bash
alias sync-all='/home/noam/projects/.global-scripts/sync-all.sh'
```

ואז הרץ:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

עכשיו אפשר להריץ `sync-all` מכל מקום!

---

## 📋 Workflow פשוט

### כשמתחיל לעבוד:
```bash
# 1. פתח את הפרויקט
cursor ~/projects/ovu/ovu-workspace.code-workspace

# 2. משוך שינויים אחרונים
sync-all pull
```

### כשגומר לעבוד:
```bash
# 1. בדוק מה השתנה
sync-all status

# 2. שמור ושלח
sync-all push "תיאור השינויים"
```

---

## 🚨 מה לעשות אם...

### יש לי שינויים שלא נשמרו ורוצה למשוך עדכונים?
```bash
sync-all pull
```
הסקריפט יעשה stash אוטומטי לשינויים שלך, ימשוך את העדכונים, ויחזיר את השינויים שלך.

### שכחתי מה שיניתי?
```bash
sync-all status
```

### רוצה לראות את ההיסטוריה?
```bash
cd ~/projects/ovu/worktrees/ulm-work
git log --oneline -10  # 10 הcommits האחרונים
```

---

## 🎓 טיפים

1. **תמיד עשה pull לפני שמתחיל לעבוד** - זה חוסך conflicts
2. **תמיד עשה push בסוף היום** - גיבוי אוטומטי!
3. **כתוב הודעות commit ברורות** - תודה לעצמך בעתיד
4. **עשה status לפעמים** - תדע תמיד מה המצב

---

## 📱 תזכורת חזותית

```
🏠 מחשב בית                              💼 מחשב עבודה
     │                                         │
     │  sync-all pull  ◄─────┐      ┌────────►│  sync-all pull
     │                        │      │         │
     ▼                        │      │         ▼
  עובד על                    │      │      עובד על
  הקוד...                    │      │      הקוד...
     │                        │      │         │
     ▼                        │      │         ▼
     │  sync-all push ───────►│ GitHub │◄──────│  sync-all push
                               └──────┘
```

---

*זהו! 3 פקודות פשוטות וכל הסנכרון עובד!* ✨

