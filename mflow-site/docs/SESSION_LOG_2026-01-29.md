# תיעוד סשן פיתוח - 29 בינואר 2026

## סקירה כללית

סשן פיתוח להקמת דף נחיתה "Coming Soon" עבור mflow.co.il, כולל תיקון בעיות DNS, SSL, והגדרת שרת.

---

## שלב 1: אבחון בעיית התחברות לאתר

### בעיה

המשתמש לא הצליח להתחבר ל-mflow.co.il

### אבחון

```bash
curl -v https://mflow.co.il
# תוצאה: IPv6: 2606:4700:3037::6815:8e0, IPv4: (none)
# שגיאה: Network is unreachable
```

### ממצאים

1. הדומיין היה מוגדר רק עם רשומות AAAA (IPv6)
2. לא היו רשומות A (IPv4)
3. סביבת WSL2 לא תמכה ב-IPv6

---

## שלב 2: הגדרת DNS ב-Cloudflare

### פעולות

1. נכנסנו ל-Cloudflare Dashboard
2. הוספנו רשומת A עבור `mflow.co.il` → `35.209.4.189`
3. הפעלנו Proxy (ענן כתום) על הרשומה

### בעיה חדשה: ERR_TOO_MANY_REDIRECTS

לאחר הוספת רשומת A, הופיעה שגיאת redirect loop.

### אבחון

```bash
curl -v --max-redirs 5 https://mflow.co.il
# תוצאה: location: https://mflow.co.il/ (חוזר על עצמו)
```

### פתרון

שינוי הגדרת SSL ב-Cloudflare מ-"Flexible" ל-"Full":

- Cloudflare Dashboard → SSL/TLS → Overview → Full

**הסיבה:** השרת השתמש ב-Cloudflare Origin Certificate שעובד רק עם Full SSL mode.

---

## שלב 3: הגדרת SSH לשרת SiteGround

### פרטי התחברות

- **Hostname:** giowm1272.siteground.biz
- **Username:** u3024-8wzeneeacbvg
- **Port:** 18765
- **SSH Key:** ~/.ssh/mflow-siteground
- **Key Password:** 2$4n8vQwc,7e

### יצירת מפתח SSH

המשתמש יצר מפתח SSH ב-SiteGround Site Tools:

- Key Name: mflow-key-1
- סוג: ed25519

### שמירת המפתח

```bash
# שמירת המפתח הפרטי
echo "-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----" > ~/.ssh/mflow-siteground

chmod 600 ~/.ssh/mflow-siteground
```

---

## שלב 4: זיהוי מבנה התיקיות בשרת

### בעיה ראשונית

העלינו קבצים ל-`~/public_html/` אבל האתר לא השתנה.

### אבחון

```bash
ssh -p 18765 user@server "ls -la ~/"
# גילינו: תיקיית www/mflow.co.il/public_html/
```

### מבנה התיקיות הנכון (SiteGround)

```
~/
├── public_html/          # לא בשימוש לאתר הראשי
└── www/
    └── mflow.co.il/
        └── public_html/  # ← זו התיקייה הנכונה!
            ├── wp-config.php
            ├── wp-content/
            └── ...
```

---

## שלב 5: יצירת דף Coming Soon

### קבצים שנוצרו

1. `coming-soon.html` - דף HTML רספונסיבי
2. `mobile-coming-soon.png` - תמונת רקע למובייל
3. `desktop-coming-soon.png` - תמונת רקע לדסקטופ

### העלאה לשרת

```bash
scp -P 18765 coming-soon.html mobile-coming-soon.png desktop-coming-soon.png \
  u3024-8wzeneeacbvg@giowm1272.siteground.biz:~/www/mflow.co.il/public_html/
```

---

## שלב 6: הגדרת .htaccess להפניה

### קובץ .htaccess

```apache
# Coming Soon - No Cache Headers
<IfModule mod_headers.c>
    <FilesMatch "coming-soon\.html$">
        Header set Cache-Control "no-cache, no-store, must-revalidate"
        Header set Pragma "no-cache"
        Header set Expires "0"
    </FilesMatch>
</IfModule>

# Coming Soon Redirect
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{REQUEST_URI} !^/coming-soon\.html$
RewriteCond %{REQUEST_URI} !^/wp-admin
RewriteCond %{REQUEST_URI} !^/wp-login\.php
RewriteCond %{REQUEST_URI} !\.(png|jpg|jpeg|gif|css|js|ico|woff|woff2)$
RewriteRule ^(.*)$ /coming-soon.html [R=302,L]
</IfModule>

# WordPress rules below...
```

### חשוב

- `/wp-admin` ו-`/wp-login.php` לא מופנים - אפשר להיכנס לניהול
- קבצים סטטיים (תמונות, CSS, JS) לא מופנים

---

## שלב 7: פתרון בעיות Cache

### בעיה

דף Coming Soon לא הופיע למרות ההגדרות.

### גורמים

1. **Cloudflare Cache** - נפתר ע"י Purge Everything
2. **WordPress Cache** (SG Optimizer) - נפתר ע"י ניקוי cache מתוך WordPress

### פתרון סופי

ניקוי cache מתוך WordPress Admin → SG Optimizer → Purge Cache

---

## שלב 8: הוספת כפתורים לדף

### כפתורים שנוספו

| כפתור          | צבע  | קישור                              |
| -------------- | ---- | ---------------------------------- |
| התחברות למערכת | סגול | https://my.mflow.co.il/v1/login    |
| להרשמה למערכת  | זהב  | https://my.mflow.co.il/v1/register |

### עיצוב

- כפתור סגול: gradient מ-#6B4BA1 ל-#8B5DC9
- כפתור זהב: gradient מ-#C9A54D ל-#E5C56B
- border-radius: 30px
- hover effects עם transform ו-box-shadow

---

## שלב 9: תיקון רספונסיביות

### בעיה

במסכים רחבים עם חלון קטן, התמונה נחתכת למטה.

### פתרון

```css
.background-image {
  object-fit: contain; /* במקום cover */
  object-position: center center;
}

body {
  background: linear-gradient(to bottom, #d4c4b0 0%, #2d2255 50%, #1a1a2e 100%);
}

html,
body {
  height: 100dvh; /* dynamic viewport height */
}
```

---

## תוצאה סופית

### האתר פעיל ב:

- https://mflow.co.il ✅
- https://www.mflow.co.il ✅

### תכונות:

- דף נחיתה רספונסיבי (מובייל + דסקטופ)
- כפתורי התחברות והרשמה
- הפניה אוטומטית מכל דף
- גישה ל-wp-admin נשמרת

---

## פקודות שימושיות

### התחברות SSH

```bash
ssh -i ~/.ssh/mflow-siteground -p 18765 u3024-8wzeneeacbvg@giowm1272.siteground.biz
```

### העלאת קבצים

```bash
scp -i ~/.ssh/mflow-siteground -P 18765 <file> u3024-8wzeneeacbvg@giowm1272.siteground.biz:~/www/mflow.co.il/public_html/
```

### בדיקת DNS

```bash
curl -s "https://dns.google/resolve?name=mflow.co.il&type=A"
```

### בדיקת redirect

```bash
curl -sIL https://mflow.co.il | grep -E "(HTTP|Location)"
```
