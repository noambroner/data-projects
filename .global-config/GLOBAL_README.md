# 🌐 Global Configuration — מדריך מהיר

**גרסה:** 1.0.0  
**עודכן:** 2025-12-13  

---

## 📌 מה זו התיקייה הזו?

`.global-config/` היא **מקור האמת** (Source of Truth) עבור כל הפרויקטים.  
כל הסטנדרטים, התבניות, וההגדרות הגלובליות נמצאים כאן.

---

## 🚀 התחלה מהירה

### אם אתה משתמש חדש:
```
📖 קרא: CURSOR_QUICK_START.md
```

### אם אתה מקים פרויקט חדש:
```bash
# הרץ את הסקריפט ליצירת פרויקט
../.global-scripts/create-new-project.sh <project-name>
```

### אם אתה ממשיך עבודה קיימת:
```
📝 קרא: docs/SESSION_HANDOFF.md בתיקיית הפרויקט
```

---

## 📁 מבנה התיקייה

```
.global-config/
│
├── 📚 מסמכים ראשיים
│   ├── PROJECT_ARCHITECTURE_SPEC.md  ← מפרט ארכיטקטורה מלא
│   ├── CURSOR_QUICK_START.md         ← מדריך למשתמש Cursor
│   ├── SESSION_HANDOFF_TEMPLATE.md   ← תבנית לסיום סשן
│   └── GLOBAL_README.md              ← אתה כאן!
│
├── 📋 כללי Cursor
│   ├── .cursorrules-global           ← כללים גלובליים
│   └── .cursorrules-template         ← תבנית לפרויקט חדש
│
├── 📝 תבניות הגדרות
│   ├── workspace-template.code-workspace
│   ├── eslintrc-template.json
│   ├── prettierrc-template.json
│   ├── tsconfig-template.json
│   └── pyproject-template.toml
│
├── 🐳 תבניות Docker
│   ├── docker-compose-template.yml
│   └── dockerfile-templates/
│       ├── Dockerfile.node
│       ├── Dockerfile.python
│       └── Dockerfile.flutter
│
└── 🚫 תבניות .gitignore
    └── .gitignore-templates/
        ├── node.gitignore
        ├── python.gitignore
        ├── flutter.gitignore
        └── docker.gitignore
```

---

## 🔢 גרסת הסטנדרטים

**גרסה נוכחית:** `1.0.0`

כל פרויקט צריך לציין באיזו גרסה הוא משתמש:
```markdown
# בקובץ PROJECT_README.md של הפרויקט:
**Global Standards Version:** 1.0.0
```

---

## 📋 מה נמצא בכל קובץ

| קובץ | מטרה | מתי לקרוא |
|------|------|-----------|
| `PROJECT_ARCHITECTURE_SPEC.md` | מפרט ארכיטקטורה מלא | לקריאה מעמיקה |
| `CURSOR_QUICK_START.md` | מדריך פשוט לעבודה יומיומית | **תמיד בהתחלה** |
| `SESSION_HANDOFF_TEMPLATE.md` | תבנית לסיכום סשן | בסוף כל סשן |
| `.cursorrules-global` | כללים שכל פרויקט יורש | אוטומטי |
| `CHANGELOG.md` | שינויים בסטנדרטים | כשמעדכנים |

---

## ✅ צ'קליסט לפרויקט חדש

- [ ] קראתי את `CURSOR_QUICK_START.md`
- [ ] יצרתי את הפרויקט עם `create-new-project.sh`
- [ ] הגדרתי את הגרסה ב־`PROJECT_README.md`
- [ ] יצרתי `.cursorrules` לפרויקט
- [ ] יצרתי `docs/SESSION_HANDOFF.md`

---

## 🔗 קישורים שימושיים

- [מדריך מהיר](./CURSOR_QUICK_START.md)
- [מפרט מלא](./PROJECT_ARCHITECTURE_SPEC.md)
- [תבנית Handoff](./SESSION_HANDOFF_TEMPLATE.md)
- [סקריפטים גלובליים](../.global-scripts/)

---

## ❓ שאלות נפוצות

### "איך מעדכנים סטנדרט גלובלי?"
1. ערוך את הקובץ ב־`.global-config/`
2. עדכן את `CHANGELOG.md`
3. עלה את הגרסה

### "איך יודעים שפרויקט מעודכן?"
בדוק את `GLOBAL_STANDARDS_VERSION` ב־`PROJECT_README.md` של הפרויקט.

### "מה קורה אם פרויקט לא תואם לגרסה החדשה?"
הרץ: `../.global-scripts/sync-project-from-main.sh <project>`

---

**בהצלחה! 🚀**

