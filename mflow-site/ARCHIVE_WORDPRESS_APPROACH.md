# Mflow Site - Archive: WordPress Approach (January 2026)

## Overview

This document archives the WordPress/Elementor approach we initially took for the Mflow marketing website. We later switched to a Next.js approach using Vercel v0.

**Decision Date:** January 29-30, 2026  
**New Approach:** Next.js + Vercel (v0.dev generated)

---

## What Was Built (WordPress)

### Infrastructure
- **Hosting:** SiteGround (giowm1272.siteground.biz)
- **CMS:** WordPress with WooCommerce
- **Page Builder:** Elementor (AI Site Planner)
- **CDN/DNS:** Cloudflare (proxied)
- **Domain:** mflow.co.il

### Coming Soon Page
A responsive "Coming Soon" landing page was deployed with:
- Mobile and desktop background images
- Login button → https://my.mflow.co.il/v1/login
- Register button → https://my.mflow.co.il/v1/register
- Redirect via .htaccess (preserving /wp-admin access)

### Pages Created (Later Deleted)
- Home
- About Us
- Features
- Pricing
- Contact
- Blog and Resource Center

---

## Technical Details

### SSH Access (Still Valid)
```
Host: giowm1272.siteground.biz
User: u3024-8wzeneeacbvg
Port: 18765
Key: ~/.ssh/mflow-siteground
Key Password: 2$4n8vQwc,7e
```

**See:** `.cursor/rules/siteground-ssh.mdc` for full details.

### Server Paths
```
Web Root: ~/www/mflow.co.il/public_html/
WordPress: ~/www/mflow.co.il/public_html/wp-config.php
htaccess: ~/www/mflow.co.il/public_html/.htaccess
```

### .htaccess Configuration (Coming Soon Mode)
```apache
# Coming Soon Redirect
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /

# Route wp-json to WordPress
RewriteRule ^wp-json(/.*)?$ index.php [L]

# Allow WordPress admin, login, Elementor, and static files
RewriteCond %{REQUEST_URI} ^/coming-soon\.html$ [OR]
RewriteCond %{REQUEST_URI} ^/wp-admin [OR]
RewriteCond %{REQUEST_URI} ^/wp-login\.php [OR]
RewriteCond %{REQUEST_URI} ^/index\.php [OR]
RewriteCond %{QUERY_STRING} rest_route [OR]
RewriteCond %{QUERY_STRING} elementor [OR]
RewriteCond %{QUERY_STRING} preview [OR]
RewriteCond %{QUERY_STRING} action=elementor [OR]
RewriteCond %{HTTP_COOKIE} wordpress_logged_in [OR]
RewriteCond %{REQUEST_URI} \.(png|jpg|jpeg|gif|css|js|ico|woff|woff2|php|svg|webp)$
RewriteRule ^ - [L]

# Redirect everything else to coming soon
RewriteRule ^(.*)$ /coming-soon.html [R=302,L]
</IfModule>
```

---

## Issues Encountered

1. **DNS/SSL Issues** - Fixed by adding A record and setting Cloudflare SSL to "Full"
2. **REST API blocked** - Fixed by adding wp-json exception to .htaccess
3. **Elementor preview not loading** - Fixed by adding exceptions for logged-in users
4. **Cache issues** - Required clearing both WordPress (SG Optimizer) and Cloudflare cache

---

## Original Planning (Brief)

### Business Info
- **Client:** Mflow (part of DataFlow group)
- **Product:** POS system with inventory management + eCommerce sync
- **Target:** Small business owners, retail, eCommerce (ages 23-60)

### Brand Style
- **Primary Color:** #4800B3 (purple)
- **Secondary Color:** #FF9A3C (orange)
- **Background:** White (#FFFFFF)
- **Secondary BG:** Off-white (#F8F7F5)
- **Style:** Minimalistic, clean lines, gentle curves
- **Reference:** matat.co.il

### Site Structure
- Home
- Pricing
- About
- Contact

### Features Planned
- Bilingual (English + Hebrew with RTL)
- WPML for translations
- Contact forms
- Live chat widget
- Knowledge base

---

## Why We Switched

1. **Complexity** - WordPress + Elementor required many workarounds for Coming Soon mode
2. **Performance** - Next.js is faster and more optimized
3. **Development Speed** - v0.dev generated a complete site in minutes
4. **Modern Stack** - Next.js + Tailwind is easier to maintain and customize
5. **Bilingual Support** - next-intl is cleaner than WPML

---

## Current Status

### WordPress on SiteGround
- **Still running** with Coming Soon page
- **Accessible** at https://mflow.co.il/wp-admin
- **Can be used** for WooCommerce/store if needed later

### New Approach
- **Stack:** Next.js + Tailwind CSS + shadcn/ui
- **Generated with:** Vercel v0.dev
- **Deployment:** Vercel
- **i18n:** Built-in RTL support for Hebrew

---

## Files Deleted from This Repo

- `coming-soon.html` - Landing page HTML
- `mobile-coming-soon.png` - Mobile background image
- `desktop-coming-soon.png` - Desktop background image
- `HANDOFF.md` - Session handoff document
- `README.md` - Project readme
- `docs/SESSION_LOG_2026-01-29.md` - Development session log

---

## Useful Commands (For Reference)

### SSH to Server
```bash
ssh -i ~/.ssh/mflow-siteground -p 18765 u3024-8wzeneeacbvg@giowm1272.siteground.biz
```

### Upload Files
```bash
scp -i ~/.ssh/mflow-siteground -P 18765 <file> u3024-8wzeneeacbvg@giowm1272.siteground.biz:~/www/mflow.co.il/public_html/
```

### WP-CLI (on server)
```bash
cd ~/www/mflow.co.il/public_html
wp plugin list
wp post list --post_type=page
wp cache flush
```

### Clear Cache (After Changes)
1. WordPress Admin → SG Optimizer → Purge Cache
2. Cloudflare Dashboard → Caching → Purge Everything

---

## Contact URLs

| Service | URL |
|---------|-----|
| Marketing Site | https://mflow.co.il |
| App Login | https://my.mflow.co.il/v1/login |
| App Register | https://my.mflow.co.il/v1/register |
| WordPress Admin | https://mflow.co.il/wp-admin |
| Cloudflare | https://dash.cloudflare.com |
| SiteGround | https://tools.siteground.com |

---

*Archived: January 30, 2026*
