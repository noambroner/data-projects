# Mflow Site - Session Handoff

## Quick Start for AI Agent

### 1. Project Context

This is the marketing/landing site for **Mflow** - an ERP system at https://mflow.co.il

### 2. Current State

- **Live URL:** https://mflow.co.il
- **Status:** Coming Soon page with login/register buttons
- **Backend:** WordPress on SiteGround hosting
- **CDN/DNS:** Cloudflare (Proxied)

### 3. Important Files Location

```
Local (this repo):
├── coming-soon.html          # Landing page HTML
├── mobile-coming-soon.png    # Mobile background
├── desktop-coming-soon.png   # Desktop background
├── .cursor/rules/            # Cursor rules for AI
│   └── siteground-ssh.mdc    # SSH credentials & paths
└── docs/
    └── SESSION_LOG_*.md      # Development logs

Server (SiteGround):
~/www/mflow.co.il/public_html/
├── coming-soon.html
├── mobile-coming-soon.png
├── desktop-coming-soon.png
├── .htaccess
└── [WordPress files]
```

### 4. SSH Access

**Read `.cursor/rules/siteground-ssh.mdc` for full credentials.**

Quick connect:

```bash
ssh -i ~/.ssh/mflow-siteground -p 18765 u3024-8wzeneeacbvg@giowm1272.siteground.biz
```

### 5. Key URLs

| Service         | URL                                |
| --------------- | ---------------------------------- |
| Marketing Site  | https://mflow.co.il                |
| App Login       | https://my.mflow.co.il/v1/login    |
| App Register    | https://my.mflow.co.il/v1/register |
| WordPress Admin | https://mflow.co.il/wp-admin       |
| Cloudflare      | Dashboard for mflow.co.il          |

### 6. Common Tasks

#### Deploy changes to landing page:

```bash
scp -P 18765 coming-soon.html u3024-8wzeneeacbvg@giowm1272.siteground.biz:~/www/mflow.co.il/public_html/
```

#### Clear cache after changes:

1. WordPress Admin → SG Optimizer → Purge Cache
2. Cloudflare → Caching → Purge Everything

#### Remove Coming Soon mode:

Edit `.htaccess` on server and remove/comment the "Coming Soon Redirect" section.

### 7. Known Issues & Solutions

| Issue                      | Solution                               |
| -------------------------- | -------------------------------------- |
| Changes not visible        | Clear WordPress + Cloudflare cache     |
| SSL errors                 | Ensure Cloudflare SSL is set to "Full" |
| Redirect loop              | Check SSL mode in Cloudflare           |
| Page extends below taskbar | Use `100dvh` instead of `100vh`        |

### 8. Architecture Notes

```
User Request
     ↓
Cloudflare (DNS + CDN + SSL)
     ↓
SiteGround Server (35.209.4.189)
     ↓
.htaccess redirect
     ↓
coming-soon.html (static) OR WordPress (dynamic)
```

### 9. Next Steps / TODO

- [ ] Build full WordPress site
- [ ] Configure WooCommerce
- [ ] Add Hebrew SEO
- [ ] Set up contact forms
- [ ] Remove Coming Soon redirect when ready

---

**Last Updated:** 2026-01-29
**Last Session:** DNS fix, SSL fix, Coming Soon page deployment
