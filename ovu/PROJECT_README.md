# 🚀 OVU — User & Admin Management System

**Created:** 2025-12-13  
**Global Standards Version:** 1.0.0  
**Status:** Production Ready 🟢

---

## 📋 Quick Start

### 1. פתיחת הפרויקט
```bash
# פתח את ה-Workspace ב-Cursor:
File → Open Workspace from File → ovu-workspace.code-workspace
```

### 2. קריאת הסשן האחרון
```
📖 קרא: docs/SESSION_HANDOFF.md
```

### 3. התחל לעבוד!
```
🤖 אמור ל-Cursor: "אני מתחיל סשן חדש. המטרה שלי היום היא: [המטרה שלך]"
```

---

## 🏗️ ארכיטקטורה

```
OVU System
├── 🔐 ULM (User Login Manager)
│   ├── Backend: FastAPI + PostgreSQL
│   ├── Frontend: React + TypeScript
│   └── Mobile: Flutter
│
├── 👤 AAM (Admin Area Manager)
│   ├── Base Server: FastAPI
│   ├── Admin Dashboard: FastAPI
│   └── Role Installer: FastAPI
│
└── 📦 Shared Resources
    ├── UI Components (React + Flutter)
    ├── Localization (HE, EN, AR)
    └── Themes & Design Tokens
```

---

## 📁 מבנה הפרויקט

```
/home/noam/projects/
├── .global-config/              ← סטנדרטים גלובליים
├── .global-scripts/             ← סקריפטים גלובליים
│
├── ovu/                         ← אתה כאן!
│   ├── ovu-workspace.code-workspace  ← פתח את זה!
│   ├── PROJECT_README.md             ← המסמך הזה
│   ├── .ovu-cursorrules              ← כללי Cursor לפרויקט
│   ├── scripts/                      ← סקריפטים
│   └── docs/                         ← תיעוד
│       ├── SESSION_HANDOFF.md        ← סטטוס נוכחי
│       └── sessions/                 ← היסטוריה
│
├── dev/                         ← Repositories מקוריים
│   ├── ovu-ulm/
│   ├── ovu-aam/
│   ├── ovu-shared/
│   └── ovu-deployment/
│
└── worktrees/                   ← סביבות עבודה פעילות
    ├── ulm-work/
    ├── aam-work/
    └── shared-work/
```

---

## 🌐 URLs — Production

| Service | URL |
|---------|-----|
| **ULM Frontend** | https://ulm-rct.ovu.co.il |
| **ULM Backend** | http://64.176.171.223:8001 |
| **Dev Guidelines** | https://ulm-rct.ovu.co.il/dev-guidelines |
| **Dev Journal** | https://ulm-rct.ovu.co.il/dev-journal |
| **AAM Base** | https://base.aam.bflow.co.il |
| **AAM Admin** | https://aam.bflow.co.il |
| **AAM Installer** | https://approleinstaller.aam.bflow.co.il |

---

## 🔧 סקריפטים

| סקריפט | מטרה |
|--------|------|
| `./scripts/dev.sh` | הרצת סביבת פיתוח |
| `./scripts/quality.sh` | בדיקות איכות (lint, format) |
| `./scripts/test.sh` | הרצת טסטים |
| `./scripts/session-end.sh` | סיום סשן ועדכון handoff |

---

## 🌍 תמיכה רב-לשונית

המערכת תומכת ב-3 שפות:
- 🇮🇱 עברית (Hebrew) — RTL
- 🇺🇸 English
- 🇸🇦 العربية (Arabic) — RTL

---

## 🎨 Design System

**חשוב!** השתמש תמיד ב-CSS Variables:

```css
/* ✅ נכון */
color: var(--primary-color);
background: var(--surface-color);

/* ❌ לא נכון */
color: #3498db;
background: white;
```

---

## 📝 תיעוד נוסף

- [מדריך מהיר](../.global-config/CURSOR_QUICK_START.md)
- [מפרט ארכיטקטורה](../.global-config/PROJECT_ARCHITECTURE_SPEC.md)
- [תבנית Handoff](../.global-config/SESSION_HANDOFF_TEMPLATE.md)

---

## 👥 צוות

- **Project Owner:** Noam Broner
- **GitHub:** github.com/noambroner

---

**בהצלחה! 🚀**

