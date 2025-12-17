# 📝 Changelog — שינויים בסטנדרטים הגלובליים

כל השינויים המשמעותיים בסטנדרטים מתועדים כאן.

הפורמט מבוסס על [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
והגרסאות לפי [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2025-12-13

### ✨ נוסף
- מסמך ארכיטקטורה ראשי: `PROJECT_ARCHITECTURE_SPEC.md`
- מדריך מהיר: `CURSOR_QUICK_START.md`
- תבנית Handoff: `SESSION_HANDOFF_TEMPLATE.md`
- כללי Cursor גלובליים: `.cursorrules-global`
- תבנית Cursor לפרויקטים: `.cursorrules-template`
- תבניות הגדרות:
  - `workspace-template.code-workspace`
  - `eslintrc-template.json`
  - `prettierrc-template.json`
  - `tsconfig-template.json`
  - `pyproject-template.toml`
- תבניות Docker:
  - `docker-compose-template.yml`
  - `dockerfile-templates/` (Node, Python, Flutter)
- תבניות .gitignore:
  - `.gitignore-templates/` (Node, Python, Flutter, Docker)
- מדריך גלובלי: `GLOBAL_README.md`
- קובץ שינויים: `CHANGELOG.md` (הקובץ הזה)

### 📋 3 סבבי ביקורת מומחים
- `ARCHITECTURE_SPEC_REVIEW.md` (סבב 1)
- `ARCHITECTURE_SPEC_REVIEW_R2.md` (סבב 2)
- `EXPERT_REVIEW_ROUND_3.md` (סבב 3 — פישוט למשתמש לא-טכני)

### 🎯 עקרונות מפתח שנקבעו
1. **Adoption Model**: Level 0 (MUST), Level 1 (SHOULD), Level 2 (NICE)
2. **Session Handoff**: חובה לתעד בסוף כל סשן
3. **UI Contract**: Design Tokens כמקור אמת יחיד
4. **Global Standards Versioning**: כל פרויקט מציין גרסה

---

## [Unreleased]

### 🔜 מתוכנן
- סקריפטים גלובליים (`.global-scripts/`)
- אינטגרציה עם CI/CD
- Visual Regression Testing templates

---

## 📌 איך לעדכן את הקובץ הזה

כשמוסיפים שינוי לסטנדרטים:

1. **הוסף תחת `[Unreleased]`:**
```markdown
### ✨ נוסף
- תיאור השינוי

### 🔄 שונה
- תיאור השינוי

### 🗑️ הוסר
- תיאור השינוי

### 🐛 תוקן
- תיאור השינוי
```

2. **כשמשחררים גרסה חדשה:**
   - העבר מ־`[Unreleased]` לגרסה חדשה
   - הוסף תאריך
   - עדכן את `GLOBAL_README.md` עם הגרסה החדשה

