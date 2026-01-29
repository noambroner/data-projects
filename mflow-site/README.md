# Mflow Website

אתר השיווק והנחיתה של מערכת **Mflow ERP**.

## 🌐 כתובות

| שירות           | כתובת                              |
| --------------- | ---------------------------------- |
| אתר שיווקי      | https://mflow.co.il                |
| אפליקציית ERP   | https://my.mflow.co.il             |
| התחברות         | https://my.mflow.co.il/v1/login    |
| הרשמה           | https://my.mflow.co.il/v1/register |
| ניהול WordPress | https://mflow.co.il/wp-admin       |

## 📁 מבנה הפרויקט

```
mflow-site/
├── README.md                 # קובץ זה
├── HANDOFF.md               # מסמך העברה לסשן הבא
├── coming-soon.html         # דף הנחיתה הנוכחי
├── mobile-coming-soon.png   # רקע מובייל
├── desktop-coming-soon.png  # רקע דסקטופ
│
├── .cursor/
│   └── rules/
│       └── siteground-ssh.mdc  # פרטי SSH והגדרות שרת
│
└── docs/
    └── SESSION_LOG_*.md     # תיעוד סשנים
```

## 🏗️ ארכיטקטורה

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────────┐
│   משתמש     │ ──→ │ Cloudflare  │ ──→ │    SiteGround       │
│             │     │ (DNS + CDN) │     │ (WordPress + PHP)   │
└─────────────┘     └─────────────┘     └─────────────────────┘
                          │
                    SSL/TLS (Full)
                          │
                    Proxy (כתום)
```

### רכיבים:

- **Cloudflare** - DNS, CDN, SSL, DDoS protection
- **SiteGround** - Shared hosting, WordPress, MySQL
- **WordPress** - CMS עם WooCommerce

## 🔧 הגדרות חשובות

### Cloudflare

- **SSL Mode:** Full (לא Flexible!)
- **DNS Records:**
  - `mflow.co.il` → A → 35.209.4.189 (Proxied)
  - `www` → A → 35.209.4.189 (Proxied)
  - `*` → A → 35.209.4.189 (Proxied)

### SiteGround

- **Web Root:** `~/www/mflow.co.il/public_html/`
- **SSH Port:** 18765
- **PHP Version:** (managed by SiteGround)

## 🚀 פיתוח

### התחברות לשרת

```bash
# קרא את הפרטים המלאים מ:
# .cursor/rules/siteground-ssh.mdc

ssh -i ~/.ssh/mflow-siteground -p 18765 u3024-8wzeneeacbvg@giowm1272.siteground.biz
```

### העלאת שינויים

```bash
# העלאת קובץ בודד
scp -P 18765 coming-soon.html user@server:~/www/mflow.co.il/public_html/

# העלאת כל הקבצים
scp -P 18765 *.html *.png user@server:~/www/mflow.co.il/public_html/
```

### ניקוי Cache

לאחר כל שינוי:

1. **WordPress:** Admin → SG Optimizer → Purge Cache
2. **Cloudflare:** Caching → Configuration → Purge Everything

## 📋 Cursor Rules

הפרויקט כולל Cursor Rules שמספקים הקשר ל-AI:

| קובץ                               | תיאור                    |
| ---------------------------------- | ------------------------ |
| `.cursor/rules/siteground-ssh.mdc` | פרטי SSH, נתיבים, פקודות |

### שימוש

ה-AI יקרא אוטומטית את ה-rules ויקבל:

- פרטי התחברות SSH
- מבנה התיקיות בשרת
- פקודות נפוצות

## 📄 תיעוד

| קובץ                    | תיאור                   |
| ----------------------- | ----------------------- |
| `HANDOFF.md`            | מסמך העברה - קרא ראשון! |
| `docs/SESSION_LOG_*.md` | תיעוד מפורט של כל סשן   |

## 🔄 מצב נוכחי: Coming Soon

האתר כרגע מציג דף "Coming Soon" עם:

- לוגו Mflow
- טקסט "משהו טוב קורה לנו. יש למה לחכות! צפו להפתעות."
- כפתור "התחברות למערכת"
- כפתור "להרשמה למערכת"
- טקסט "האתר בבנייה. בקרוב נשוב"

### להסרת מצב Coming Soon:

1. התחבר לשרת ב-SSH
2. ערוך את `.htaccess`:
   ```bash
   nano ~/www/mflow.co.il/public_html/.htaccess
   ```
3. מחק או הערה את הסקשן "Coming Soon Redirect"
4. נקה cache

## 🎯 שלבים הבאים

- [ ] בניית האתר המלא ב-WordPress
- [ ] הגדרת WooCommerce לחנות
- [ ] SEO בעברית
- [ ] טפסי יצירת קשר
- [ ] אינטגרציה עם מערכת ה-ERP
- [ ] הסרת Coming Soon והשקה

## 📞 תמיכה

- **Cloudflare Dashboard:** https://dash.cloudflare.com
- **SiteGround Site Tools:** https://tools.siteground.com
- **WordPress Admin:** https://mflow.co.il/wp-admin

---

**עדכון אחרון:** 29 בינואר 2026
