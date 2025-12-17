# 📐 מבנה פרויקטים - גרסה סופית 2.0

## תאריך אישור: 13/12/2025
## סטטוס: ✅ מאושר ליישום

---

## 🎯 עקרון מנחה

> **כל פרויקט הוא יחידה עצמאית ומלאה**

---

## 📁 מבנה סופי מאושר

```
~/projects/
│
├── .global-config/                      ← 🌐 הגדרות גלובליות
│   ├── .cursorrules-global              ← כללי AI גלובליים
│   ├── PROJECT_ARCHITECTURE_SPEC.md     ← מפרט הארכיטקטורה
│   ├── SESSION_HANDOFF_TEMPLATE.md      ← תבנית Handoff
│   ├── CURSOR_QUICK_START.md            ← מדריך התחלה מהירה
│   └── templates/                       ← תבניות
│       ├── gitignore-template
│       ├── cursorrules-template
│       └── workspace-template.code-workspace
│
├── .global-scripts/                     ← 🔧 סקריפטים גלובליים
│   ├── create-new-project.sh            ← יצירת פרויקט חדש
│   ├── validate-structure.sh            ← 🆕 בדיקת תקינות מבנה
│   ├── setup-worktrees.sh               ← הגדרת worktrees
│   └── open-project-workspace.sh        ← פתיחת workspace
│
└── [PROJECT]/                           ← 📦 תבנית פרויקט
    │
    ├── 📄 [project]-workspace.code-workspace  ← 🚀 נקודת כניסה
    ├── 📄 .[project]-cursorrules              ← כללי AI לפרויקט
    ├── 📄 .gitignore                          ← 🆕 התעלמות מקבצים
    ├── 📄 VERSION                             ← 🆕 גרסת מבנה
    ├── 📄 PROJECT_README.md                   ← תיאור הפרויקט
    │
    ├── docs/                            ← 📚 תיעוד
    │   ├── SESSION_HANDOFF.md           ← המשכיות סשנים
    │   ├── ARCHITECTURE.md              ← ארכיטקטורה
    │   └── sessions/                    ← היסטוריה
    │
    ├── scripts/                         ← 🔧 סקריפטים
    │   ├── dev.sh                       ← הרצת פיתוח
    │   ├── test.sh                      ← בדיקות
    │   ├── quality.sh                   ← איכות קוד
    │   ├── session-end.sh               ← סיום סשן
    │   └── validate.sh                  ← 🆕 בדיקת מבנה פרויקט
    │
    ├── tests/                           ← 🆕 🧪 בדיקות
    │   ├── e2e/                         ← End-to-End
    │   ├── integration/                 ← אינטגרציה
    │   └── visual/                      ← Visual regression
    │
    ├── dev/                             ← 📦 Git Repositories
    │   ├── [project]-service1/          ← Repo מקורי
    │   ├── [project]-service2/
    │   └── [project]-shared/
    │
    └── worktrees/                       ← 🌳 Git Worktrees
        ├── service1-work/               ← סביבת עבודה
        │   ├── backend/
        │   ├── frontend/
        │   └── .cursorrules
        ├── service2-work/
        └── shared-work/
            ├── interface-resources/
            ├── localization/
            ├── design-tokens/           ← 🆕 UI tokens
            │   ├── tokens.json          ← Source of truth
            │   ├── css-variables.css
            │   └── dart-theme.dart
            └── .cursorrules
```

---

## 📋 קבצי תבנית

### 1. `.gitignore` לפרויקט
```gitignore
# Worktrees - managed separately
worktrees/

# IDE
.idea/
*.iml
.vscode/
!.vscode/settings.json

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Dependencies
node_modules/
venv/
__pycache__/

# Build
dist/
build/
.next/
```

### 2. `VERSION` file
```
2.0.0
# Project structure version
# See: ~/.global-config/PROJECT_ARCHITECTURE_SPEC.md
```

### 3. `validate.sh` לפרויקט
```bash
#!/bin/bash
# Validate project structure

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
ERRORS=0

echo "🔍 Validating project structure: $PROJECT_NAME"
echo "================================================"

# Required files
REQUIRED_FILES=(
    "${PROJECT_NAME}-workspace.code-workspace"
    ".${PROJECT_NAME}-cursorrules"
    "PROJECT_README.md"
    "VERSION"
    ".gitignore"
    "docs/SESSION_HANDOFF.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$PROJECT_DIR/$file" ]; then
        echo "✅ $file"
    else
        echo "❌ Missing: $file"
        ((ERRORS++))
    fi
done

# Required directories
REQUIRED_DIRS=(
    "docs"
    "scripts"
    "dev"
    "worktrees"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$PROJECT_DIR/$dir" ]; then
        echo "✅ $dir/"
    else
        echo "❌ Missing directory: $dir/"
        ((ERRORS++))
    fi
done

echo "================================================"
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed!"
    exit 0
else
    echo "❌ $ERRORS errors found"
    exit 1
fi
```

---

## 🔄 Workspace Configuration מעודכן

```json
{
  "folders": [
    {
      "name": "📁 [PROJECT] — Root",
      "path": "."
    },
    {
      "name": "🔧 Service 1",
      "path": "worktrees/service1-work"
    },
    {
      "name": "🔧 Service 2",
      "path": "worktrees/service2-work"
    },
    {
      "name": "📦 Shared",
      "path": "worktrees/shared-work"
    },
    {
      "name": "🌐 Global Config",
      "path": "../.global-config"
    }
  ],
  "settings": {
    "files.exclude": {
      "dev/": true
    }
  }
}
```

**הערה**: `dev/` מוסתר כי לא עובדים עליו ישירות!

---

## 🛡️ מנגנוני שימור

| מנגנון | מה עושה | מתי רץ |
|--------|---------|--------|
| `create-new-project.sh` | יוצר מבנה נכון | פעם אחת |
| `validate.sh` | בודק תקינות | לפני commit |
| `VERSION` file | מזהה מבנה ישן | תמיד |
| `.cursorrules` | מלמד AI | כל סשן |
| `session-end.sh` | מתעד handoff | סוף סשן |

---

## ✅ אושר על ידי

- 👨‍💻 מהנדס תוכנה בכיר
- 🎨 ארכיטקט VIBE CODING

**גרסה**: 2.0.0
**תאריך**: 13/12/2025

