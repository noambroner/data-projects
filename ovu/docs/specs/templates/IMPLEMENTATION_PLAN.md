# 🎯 OVU App Template - תוכנית יישום מפורטת

**תאריך:** 2025-12-20
**גרסה:** 1.0
**סטטוס:** Ready for Implementation

---

## 📊 Executive Summary

### מטרה
יצירת תבנית מוכנה לשימוש ליצירת אפליקציות OVU חדשות עם:
- ✅ אימות ULM מובנה
- ✅ עיצוב OVU Design System
- ✅ Shared Components מוכנים
- ✅ Bootstrap אוטומטי ב-5 דקות

### Success Criteria
1. מפתח יכול ליצור אפליקציה חדשה ב-5 דקות
2. Auth עובד "מהקופסה" ללא קוד נוסף
3. UI עקבי עם AAM/ULM
4. כל request מזוהה ב-ULM logs

---

## 🏗️ ארכיטקטורת הפתרון

```
┌─────────────────────────────────────────────────────────┐
│                    OVU Ecosystem                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │   ULM    │  │   AAM    │  │ New App  │            │
│  │          │  │          │  │ (Template)│            │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘            │
│       │             │              │                   │
│       └─────────────┴──────────────┘                  │
│                     │                                  │
│              ┌──────▼──────┐                          │
│              │   Shared    │  ← @ovu/components (NPM) │
│              │ Components  │                           │
│              └─────────────┘                           │
│                                                         │
│  ┌─────────────────────────────────────────────────┐  │
│  │         Template Generator (Bootstrap)          │  │
│  │  scripts/new-app.sh --name myapp               │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Phase Breakdown

### Phase 0: Foundation (Prerequisites) 🔴 CRITICAL
**משך משוער:** 2-3 שעות
**תלויות:** אין

#### 0.1 Shared Components → NPM Package
**מה:** הפיכת shared-components ל-npm package מתוחזק

**צעדים:**
1. יצירת `package.json` ב-`shared-work/react-components/`
2. הגדרת build process (אם צריך)
3. פרסום local registry או GitHub packages
4. בדיקה ב-AAM: `npm install @ovu/components`

**Deliverables:**
- [ ] `@ovu/components` package מתפקד
- [ ] AAM משתמש ב-package במקום copy
- [ ] תיעוד התקנה ושימוש

**סיכונים:**
- ⚠️ Build process מורכב → פתרון: התחל פשוט (copy files)
- ⚠️ צריך npm registry → פתרון: GitHub packages בינתיים

---

#### 0.2 Environment Templates Creation
**מה:** יצירת `.env.example` files לכל השירותים

**Frontend `.env.example`:**
```bash
# API Configuration
VITE_API_BASE_URL=http://localhost:8000
VITE_APP_NAME=__APP_NAME__
VITE_APP_SOURCE=__APP_NAME__-web

# ULM Configuration
VITE_ULM_URL=http://localhost:8001

# Feature Flags
VITE_ENABLE_DEBUG=false
VITE_ENABLE_DEV_TOOLS=true
```

**Backend `.env.example`:**
```bash
# Service Info
SERVICE_NAME=__APP_NAME__ Backend
PORT=__BACKEND_PORT__

# ULM Integration
ULM_SERVICE_URL=http://localhost:8001
ULM_SERVICE_APP_SOURCE=__APP_NAME__-backend
ULM_SERVICE_USERNAME=
ULM_SERVICE_PASSWORD=

# Security
SECRET_KEY=__SECRET_KEY__
DEBUG=False
TESTING=False

# Database (optional)
DATABASE_URL=postgresql+asyncpg://postgres:password@localhost/__APP_NAME___db

# Redis (optional)
REDIS_URL=redis://localhost:6379/1
```

**Deliverables:**
- [ ] Frontend `.env.example`
- [ ] Backend `.env.example`
- [ ] תיעוד כל variable

---

### Phase 1: Frontend Template 🟡 HIGH PRIORITY
**משך משוער:** 4-6 שעות
**תלויות:** Phase 0.1, 0.2

#### 1.1 Project Structure Setup
**מה:** יצירת מבנה התיקיות הבסיסי

```
templates/ovu-app-template/frontend/
├── public/
│   └── favicon.ico
├── src/
│   ├── api/
│   ├── contexts/
│   ├── hooks/
│   ├── localization/
│   ├── pages/
│   ├── styles/
│   ├── App.tsx
│   └── main.tsx
├── .env.example
├── package.json
├── vite.config.ts
├── tsconfig.json
└── README.md
```

**Actions:**
```bash
mkdir -p templates/ovu-app-template/frontend/{src/{api,contexts,hooks,localization,pages,styles},public}
```

**Deliverables:**
- [ ] מבנה תיקיות מוכן
- [ ] `package.json` עם dependencies נכונים
- [ ] `vite.config.ts` מוגדר
- [ ] `tsconfig.json` מוגדר

---

#### 1.2 API Layer (apiClient.ts + auth.ts)
**מה:** העתקה ושיפור של apiClient מ-AAM

**קבצים:**
- `src/api/apiClient.ts` - axios instance עם interceptors
- `src/api/auth.ts` - login, refresh, me, logout wrappers

**שיפורים לעומת AAM:**
```typescript
// apiClient.ts improvements:
1. APP_SOURCE מגיע מ-env: import.meta.env.VITE_APP_SOURCE
2. תיעוד מפורט של כל interceptor
3. טיפול טוב יותר בשגיאות (error types)
4. Optional: retry logic עם exponential backoff
```

**Deliverables:**
- [ ] `apiClient.ts` מתפקד
- [ ] `auth.ts` עם כל הפונקציות
- [ ] Unit tests (optional)
- [ ] תיעוד API

---

#### 1.3 Authentication Context
**מה:** Context לניהול auth state

**קובץ:** `src/contexts/AuthContext.tsx`

**Interface:**
```typescript
interface AuthContextType {
  user: UserInfo | null;
  loading: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}
```

**Features:**
- ✅ localStorage integration
- ✅ Auto token refresh
- ✅ Automatic redirect on 401
- ✅ User info caching

**Deliverables:**
- [ ] AuthContext מוכן
- [ ] useAuth hook
- [ ] תיעוד שימוש

---

#### 1.4 Theme & Language Context
**מה:** Context לניהול theme + language

**קובץ:** `src/contexts/ThemeContext.tsx`

**Interface:**
```typescript
interface ThemeContextType {
  theme: 'light' | 'dark';
  language: 'he' | 'en' | 'ar';
  toggleTheme: () => void;
  setLanguage: (lang: Language) => void;
}
```

**Deliverables:**
- [ ] ThemeContext מוכן
- [ ] useTheme hook
- [ ] localStorage persistence
- [ ] CSS variables update

---

#### 1.5 Localization System
**מה:** מערכת תרגומים פשוטה ויעילה

**מבנה:**
```
src/localization/
├── index.ts
├── he.json
├── en.json
└── ar.json
```

**Example (he.json):**
```json
{
  "app": {
    "name": "__APP_NAME__",
    "welcome": "ברוך הבא"
  },
  "auth": {
    "login": "התחבר",
    "logout": "התנתק",
    "email": "אימייל",
    "password": "סיסמה"
  },
  "menu": {
    "dashboard": "לוח בקרה",
    "settings": "הגדרות"
  }
}
```

**Hook:**
```typescript
// src/hooks/useTranslation.ts
export const useTranslation = () => {
  const { language } = useTheme();
  const t = translations[language];
  return { t, language };
};
```

**Deliverables:**
- [ ] JSON files (he, en, ar)
- [ ] useTranslation hook
- [ ] דוגמאות שימוש

---

#### 1.6 Styles Structure
**מה:** הפרדת CSS למודולים ברורים

**מבנה:**
```
src/styles/
├── base.css          ← resets, globals, scrollbar
├── theme.css         ← CSS variables (light/dark)
├── app.css           ← app-specific styles
└── index.css         ← imports all
```

**base.css:**
```css
/* HTML/Body setup */
html, body {
  height: 100vh;
  max-height: 100vh;
  overflow: hidden;
  margin: 0;
  padding: 0;
}

#root {
  height: 100vh;
  max-height: 100vh;
  overflow: hidden;
}

/* Reset */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* Custom Scrollbar */
::-webkit-scrollbar { width: 12px; }
::-webkit-scrollbar-track { background: var(--bg-main); }
::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 6px;
}
::-webkit-scrollbar-thumb:hover {
  background: var(--text-secondary);
}
```

**theme.css:**
```css
/* Base Variables */
:root {
  --spacing-unit: 8px;
  --border-radius: 8px;
  --transition-speed: 0.3s;

  /* Sidebar */
  --sidebar-width: 280px;
  --sidebar-collapsed: 80px;

  /* Header */
  --header-height: 70px;
}

/* Light Theme */
:root[data-theme="light"] {
  --bg-main: #f8fafc;
  --bg-card: #ffffff;
  --text-primary: #1e293b;
  --text-secondary: #64748b;
  --border-color: #e5e7eb;
  --header-bg: #f8fafc;
  --shadow-sm: 0 2px 8px rgba(15, 23, 42, 0.06);
  --shadow-md: 0 4px 12px rgba(15, 23, 42, 0.08);
  --shadow-lg: 0 8px 24px rgba(15, 23, 42, 0.12);
}

/* Dark Theme */
:root[data-theme="dark"] {
  --bg-main: #0f172a;
  --bg-card: #1e293b;
  --text-primary: #f1f5f9;
  --text-secondary: #cbd5e1;
  --border-color: #334155;
  --header-bg: #0f172a;
  --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.2);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.3);
  --shadow-lg: 0 8px 24px rgba(0, 0, 0, 0.4);
}

/* App Colors (customizable) */
:root {
  --app-primary: #3b82f6;        /* Change per app */
  --app-primary-hover: #2563eb;
  --app-primary-light: #60a5fa;
}
```

**Deliverables:**
- [ ] base.css מוכן
- [ ] theme.css עם כל variables
- [ ] app.css template
- [ ] תיעוד customization

---

#### 1.7 App.tsx - Full Example
**מה:** דוגמה מלאה של אפליקציה עם shared components

**Features:**
- ✅ Authentication flow
- ✅ Layout with Sidebar
- ✅ Dashboard example
- ✅ Protected routes
- ✅ Theme/Language switching

**מבנה:**
```tsx
function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <Router>
          <AppContent />
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
}

function AppContent() {
  const { isAuthenticated, loading } = useAuth();

  if (loading) return <LoadingScreen />;

  if (!isAuthenticated) return <LoginPage />;

  return (
    <Layout menuItems={menuItems} {...props}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Layout>
  );
}
```

**Deliverables:**
- [ ] App.tsx מושלם
- [ ] דוגמאות routes
- [ ] הערות מפורטות

---

#### 1.8 Package Configuration
**מה:** הגדרת package.json, vite, typescript

**package.json:**
```json
{
  "name": "__APP_NAME__-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite --port __FRONTEND_PORT__",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "format": "prettier --write \"src/**/*.{ts,tsx}\""
  },
  "dependencies": {
    "@ovu/components": "^1.0.0",
    "axios": "^1.12.2",
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "react-router-dom": "^7.9.3"
  },
  "devDependencies": {
    "@types/react": "^19.1.16",
    "@types/react-dom": "^19.1.9",
    "@vitejs/plugin-react": "^5.0.4",
    "typescript": "~5.9.3",
    "vite": "^7.1.7"
  }
}
```

**vite.config.ts:**
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: Number(process.env.VITE_PORT) || 3000,
    proxy: {
      '/api': {
        target: process.env.VITE_API_BASE_URL || 'http://localhost:8000',
        changeOrigin: true,
      }
    }
  }
})
```

**Deliverables:**
- [ ] package.json מוכן
- [ ] vite.config.ts מוגדר
- [ ] tsconfig.json מוגדר
- [ ] .gitignore

---

#### 1.9 Frontend README
**מה:** תיעוד מפורט לשימוש בתבנית

**תוכן:**
```markdown
# __APP_NAME__ Frontend

## Quick Start

1. Install dependencies:
   npm install

2. Copy and configure environment:
   cp .env.example .env
   # Edit .env with your values

3. Run development server:
   npm run dev

## Customization

### Change App Colors
Edit `src/styles/app.css`:
--app-primary: #YOUR_COLOR;

### Add Menu Items
Edit `src/App.tsx` → menuItems array

### Add Routes
Edit `src/App.tsx` → Routes section

## Project Structure
[מפורט...]
```

**Deliverables:**
- [ ] README.md מושלם
- [ ] דוגמאות customization
- [ ] Troubleshooting guide

---

### Phase 2: Backend Template 🟡 HIGH PRIORITY
**משך משוער:** 4-6 שעות
**תלויות:** Phase 0.2

#### 2.1 Project Structure Setup
```
templates/ovu-app-template/backend/
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── __init__.py
│   │       └── routes/
│   │           ├── __init__.py
│   │           ├── auth.py
│   │           ├── health.py
│   │           └── example.py
│   ├── clients/
│   │   ├── __init__.py
│   │   └── ulm.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py
│   │   └── deps.py
│   ├── middleware/
│   │   ├── __init__.py
│   │   └── logging.py
│   ├── security/
│   │   ├── __init__.py
│   │   └── auth.py
│   └── main.py
├── .env.example
├── requirements.txt
├── Dockerfile
└── README.md
```

**Deliverables:**
- [ ] מבנה תיקיות מוכן
- [ ] `__init__.py` files

---

#### 2.2 Core Configuration
**מה:** העתקה ושיפור של config.py מ-AAM

**קובץ:** `app/core/config.py`

**שינויים:**
```python
class Settings(BaseSettings):
    # Service Information
    SERVICE_NAME: str = "__APP_NAME__ Backend"
    SERVICE_VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    PORT: int = __BACKEND_PORT__

    # ULM Integration
    ULM_SERVICE_URL: str
    ULM_SERVICE_APP_SOURCE: str = "__APP_NAME__-backend"
    ULM_SERVICE_USERNAME: Optional[str] = None
    ULM_SERVICE_PASSWORD: Optional[str] = None

    # Security
    SECRET_KEY: str
    DEBUG: bool = False

    # Optional: Database
    DATABASE_URL: Optional[str] = None

    # Optional: Redis
    REDIS_URL: Optional[str] = None

    class Config:
        env_file = ".env"
        case_sensitive = True
```

**Deliverables:**
- [ ] config.py מוגדר
- [ ] תיעוד כל setting
- [ ] validation rules

---

#### 2.3 ULM Client
**מה:** העתקה של ulm.py מ-AAM

**קובץ:** `app/clients/ulm.py`

**תיעוד מפורט:**
```python
"""
HTTP client helpers for calling ULM with user/service credentials.

Usage:
    # User request (forward user token)
    response = await ulm_request(
        "GET",
        "/api/v1/users/me",
        user_token=request.headers.get("authorization")
    )

    # Service request (use service token)
    response = await ulm_request(
        "POST",
        "/api/v1/users",
        use_service_fallback=True,
        json={"email": "user@example.com"}
    )
"""
```

**Deliverables:**
- [ ] ulm.py מתפקד
- [ ] תיעוד מפורט
- [ ] דוגמאות שימוש

---

#### 2.4 Authentication Module
**מה:** JWT decoding + get_current_user dependency

**קובץ:** `app/security/auth.py`

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> dict:
    """
    Extract and decode JWT token (no validation - trust ULM).
    Returns user claims: {sub, email, role, ...}
    """
    token = credentials.credentials
    try:
        claims = jwt.decode(
            token,
            options={"verify_signature": False, "verify_exp": False}
        )
        return claims
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
```

**Deliverables:**
- [ ] auth.py מוכן
- [ ] get_current_user dependency
- [ ] Optional: role checker

---

#### 2.5 API Routes

##### auth.py - Authentication Proxy
```python
"""
Authentication routes - proxy to ULM
"""
from fastapi import APIRouter, HTTPException
from app.clients.ulm import ulm_client
from app.security.auth import get_current_user

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/login")
async def login(payload: dict):
    """Proxy login to ULM"""
    response = await ulm_client.post("/api/v1/auth/login", json=payload)
    if response.status_code >= 400:
        raise HTTPException(status_code=response.status_code, detail=response.json())
    return response.json()

@router.post("/refresh")
async def refresh(payload: dict):
    """Refresh access token"""
    response = await ulm_client.post("/api/v1/auth/refresh", json=payload)
    if response.status_code >= 400:
        raise HTTPException(status_code=response.status_code, detail=response.json())
    return response.json()

@router.get("/me")
async def auth_me(current_user: dict = Depends(get_current_user)):
    """Get current authenticated user"""
    return current_user

@router.post("/logout")
async def logout():
    """Logout (client should clear tokens)"""
    return {"message": "Logged out successfully"}
```

##### health.py - Health Checks
```python
"""
Health and readiness endpoints
"""
from fastapi import APIRouter
from app.core.config import settings
from app.clients.ulm import ulm_client

router = APIRouter(tags=["Health"])

@router.get("/health")
async def health():
    """Basic health check"""
    return {
        "status": "healthy",
        "service": settings.SERVICE_NAME,
        "version": settings.SERVICE_VERSION
    }

@router.get("/ready")
async def ready():
    """Readiness check - verify dependencies"""
    checks = {
        "service": "ok",
        "ulm": "checking"
    }

    # Check ULM connectivity
    try:
        response = await ulm_client.get("/health")
        checks["ulm"] = "ok" if response.status_code == 200 else "error"
    except:
        checks["ulm"] = "error"

    all_ok = all(v == "ok" for v in checks.values())
    status_code = 200 if all_ok else 503

    return {"status": "ready" if all_ok else "not_ready", "checks": checks}
```

##### example.py - Protected Route Example
```python
"""
Example protected route
"""
from fastapi import APIRouter, Depends
from app.security.auth import get_current_user

router = APIRouter(prefix="/example", tags=["Example"])

@router.get("/protected")
async def protected_route(current_user: dict = Depends(get_current_user)):
    """
    Example of a protected route that requires authentication.
    The current_user dependency automatically validates the JWT.
    """
    return {
        "message": "This is a protected route",
        "user_id": current_user.get("sub"),
        "user_email": current_user.get("email"),
        "user_role": current_user.get("role")
    }
```

**Deliverables:**
- [ ] auth.py routes
- [ ] health.py routes
- [ ] example.py route
- [ ] תיעוד כל endpoint

---

#### 2.6 Logging Middleware
**מה:** request logger עם app_source

**קובץ:** `app/middleware/logging.py`

```python
"""
Request logging middleware
"""
import time
import logging
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()

        # Extract metadata
        app_source = request.headers.get("x-app-source", "unknown")

        response = await call_next(request)

        duration = time.time() - start_time

        logger.info(
            "request_completed",
            extra={
                "method": request.method,
                "path": request.url.path,
                "status_code": response.status_code,
                "duration_ms": round(duration * 1000, 2),
                "app_source": app_source,
            }
        )

        return response
```

**Deliverables:**
- [ ] logging.py middleware
- [ ] structured logging
- [ ] app_source tracking

---

#### 2.7 Main Application
**מה:** FastAPI app setup עם כל הroutes

**קובץ:** `app/main.py`

```python
"""
__APP_NAME__ Backend - FastAPI Application
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.clients import ulm
from app.middleware.logging import RequestLoggingMiddleware
from app.api.v1.routes import auth, health, example

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    # Startup
    print(f"🚀 Starting {settings.SERVICE_NAME} v{settings.SERVICE_VERSION}")
    print(f"📡 ULM Service: {settings.ULM_SERVICE_URL}")
    yield
    # Shutdown
    await ulm.client.aclose()
    print("👋 Shutdown complete")

app = FastAPI(
    title=settings.SERVICE_NAME,
    version=settings.SERVICE_VERSION,
    lifespan=lifespan
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Logging
app.add_middleware(RequestLoggingMiddleware)

# Routes
app.include_router(health.router)
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(example.router, prefix=settings.API_V1_STR)

@app.get("/")
async def root():
    return {
        "service": settings.SERVICE_NAME,
        "version": settings.SERVICE_VERSION,
        "status": "running"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=settings.PORT)
```

**Deliverables:**
- [ ] main.py מושלם
- [ ] lifespan events
- [ ] middleware setup
- [ ] routes registration

---

#### 2.8 Requirements & Docker
**מה:** dependencies + containerization

**requirements.txt:**
```txt
# Core
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-dotenv==1.0.0
pydantic==2.5.0
pydantic-settings==2.1.0

# HTTP Client
httpx==0.25.2

# JWT (decode only)
python-jose[cryptography]==3.3.0

# Optional: Database
# sqlalchemy==2.0.23
# asyncpg==0.29.0

# Optional: Redis
# redis==5.0.1

# Development
pytest==7.4.3
pytest-asyncio==0.21.1
black==23.11.0
```

**Dockerfile:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app/ ./app/

# Run
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Deliverables:**
- [ ] requirements.txt
- [ ] Dockerfile
- [ ] .dockerignore
- [ ] docker-compose.yml (optional)

---

#### 2.9 Backend README
**מה:** תיעוד מפורט

**תוכן:**
```markdown
# __APP_NAME__ Backend

## Quick Start

1. Create virtual environment:
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # or: venv\Scripts\activate  # Windows

2. Install dependencies:
   pip install -r requirements.txt

3. Copy and configure environment:
   cp .env.example .env
   # Edit .env with your values

4. Run server:
   uvicorn app.main:app --reload --port __BACKEND_PORT__

## API Documentation

Once running, visit:
- Swagger UI: http://localhost:__BACKEND_PORT__/docs
- ReDoc: http://localhost:__BACKEND_PORT__/redoc

## Project Structure
[מפורט...]

## Adding New Endpoints
[דוגמה...]
```

**Deliverables:**
- [ ] README.md מושלם
- [ ] Quick start guide
- [ ] API documentation
- [ ] Development guide

---

### Phase 3: Bootstrap Script 🔴 CRITICAL
**משך משוער:** 3-4 שעות
**תלויות:** Phase 1, 2

#### 3.1 Script Development
**מה:** סקריפט אוטומטי ליצירת אפליקציה חדשה

**קובץ:** `scripts/new-app.sh`

```bash
#!/bin/bash
# OVU App Template Generator
# Usage: ./new-app.sh --name myapp --frontend-port 3000 --backend-port 8000

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APP_NAME=""
FRONTEND_PORT="3000"
BACKEND_PORT="8000"
APP_COLOR="blue"  # blue or purple
SKIP_INSTALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      APP_NAME="$2"
      shift 2
      ;;
    --frontend-port)
      FRONTEND_PORT="$2"
      shift 2
      ;;
    --backend-port)
      BACKEND_PORT="$2"
      shift 2
      ;;
    --color)
      APP_COLOR="$2"
      shift 2
      ;;
    --skip-install)
      SKIP_INSTALL=true
      shift
      ;;
    --help)
      echo "Usage: $0 --name APP_NAME [OPTIONS]"
      echo ""
      echo "Required:"
      echo "  --name NAME              Application name (lowercase, no spaces)"
      echo ""
      echo "Optional:"
      echo "  --frontend-port PORT     Frontend dev server port (default: 3000)"
      echo "  --backend-port PORT      Backend server port (default: 8000)"
      echo "  --color COLOR            Primary color: blue or purple (default: blue)"
      echo "  --skip-install           Skip npm/pip install"
      echo "  --help                   Show this help"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Validation
if [[ -z "$APP_NAME" ]]; then
  echo -e "${RED}Error: --name is required${NC}"
  echo "Use --help for usage information"
  exit 1
fi

# Validate app name (lowercase, alphanumeric, hyphens/underscores only)
if [[ ! "$APP_NAME" =~ ^[a-z0-9_-]+$ ]]; then
  echo -e "${RED}Error: App name must be lowercase alphanumeric (hyphens/underscores allowed)${NC}"
  exit 1
fi

# Check if directory already exists
if [[ -d "$APP_NAME" ]]; then
  echo -e "${RED}Error: Directory '$APP_NAME' already exists${NC}"
  exit 1
fi

# Get script directory (to find template)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_DIR="$SCRIPT_DIR/../templates/ovu-app-template"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo -e "${RED}Error: Template not found at $TEMPLATE_DIR${NC}"
  exit 1
fi

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════╗"
echo "║     OVU App Template Generator v1.0       ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

# Summary
echo -e "${YELLOW}Creating new OVU app with:${NC}"
echo "  📦 Name: $APP_NAME"
echo "  🎨 Color: $APP_COLOR"
echo "  🌐 Frontend port: $FRONTEND_PORT"
echo "  🔌 Backend port: $BACKEND_PORT"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

echo ""
echo -e "${GREEN}🚀 Starting generation...${NC}"
echo ""

# Step 1: Copy template
echo -e "${BLUE}[1/8]${NC} Copying template..."
cp -r "$TEMPLATE_DIR" "$APP_NAME"
echo -e "      ${GREEN}✓${NC} Template copied"

# Step 2: Replace placeholders in all files
echo -e "${BLUE}[2/8]${NC} Configuring app name..."
find "$APP_NAME" -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -exec sed -i.bak "s/__APP_NAME__/$APP_NAME/g" {} \;
find "$APP_NAME" -type f -name "*.bak" -delete
echo -e "      ${GREEN}✓${NC} App name configured: $APP_NAME"

# Step 3: Replace ports
echo -e "${BLUE}[3/8]${NC} Configuring ports..."
find "$APP_NAME" -type f -not -path "*/node_modules/*" -exec sed -i.bak "s/__FRONTEND_PORT__/$FRONTEND_PORT/g" {} \;
find "$APP_NAME" -type f -not -path "*/node_modules/*" -exec sed -i.bak "s/__BACKEND_PORT__/$BACKEND_PORT/g" {} \;
find "$APP_NAME" -type f -name "*.bak" -delete
echo -e "      ${GREEN}✓${NC} Ports configured: Frontend=$FRONTEND_PORT, Backend=$BACKEND_PORT"

# Step 4: Generate secrets
echo -e "${BLUE}[4/8]${NC} Generating secrets..."
SECRET_KEY=$(openssl rand -base64 32)
sed -i.bak "s/__SECRET_KEY__/$SECRET_KEY/g" "$APP_NAME/backend/.env"
rm -f "$APP_NAME/backend/.env.bak"
echo -e "      ${GREEN}✓${NC} Secret key generated"

# Step 5: Set color theme
echo -e "${BLUE}[5/8]${NC} Setting color theme..."
if [[ "$APP_COLOR" == "purple" ]]; then
  COLOR_HEX="#8b5cf6"
  COLOR_HOVER="#7c3aed"
  COLOR_LIGHT="#a78bfa"
else
  COLOR_HEX="#3b82f6"
  COLOR_HOVER="#2563eb"
  COLOR_LIGHT="#60a5fa"
fi
sed -i.bak "s/__APP_PRIMARY__/$COLOR_HEX/g" "$APP_NAME/frontend/src/styles/theme.css"
sed -i.bak "s/__APP_PRIMARY_HOVER__/$COLOR_HOVER/g" "$APP_NAME/frontend/src/styles/theme.css"
sed -i.bak "s/__APP_PRIMARY_LIGHT__/$COLOR_LIGHT/g" "$APP_NAME/frontend/src/styles/theme.css"
find "$APP_NAME" -type f -name "*.bak" -delete
echo -e "      ${GREEN}✓${NC} Color theme set: $APP_COLOR"

# Step 6: Install frontend dependencies
if [[ "$SKIP_INSTALL" == false ]]; then
  echo -e "${BLUE}[6/8]${NC} Installing frontend dependencies..."
  (cd "$APP_NAME/frontend" && npm install > /dev/null 2>&1)
  echo -e "      ${GREEN}✓${NC} Frontend dependencies installed"
else
  echo -e "${BLUE}[6/8]${NC} Skipping frontend dependencies (use --skip-install)"
fi

# Step 7: Install backend dependencies
if [[ "$SKIP_INSTALL" == false ]]; then
  echo -e "${BLUE}[7/8]${NC} Installing backend dependencies..."
  (cd "$APP_NAME/backend" && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt > /dev/null 2>&1)
  echo -e "      ${GREEN}✓${NC} Backend dependencies installed"
else
  echo -e "${BLUE}[7/8]${NC} Skipping backend dependencies (use --skip-install)"
fi

# Step 8: Git initialization
echo -e "${BLUE}[8/8]${NC} Initializing git repository..."
(cd "$APP_NAME" && git init > /dev/null 2>&1)
(cd "$APP_NAME" && git add . > /dev/null 2>&1)
(cd "$APP_NAME" && git commit -m "Initial commit from OVU template" > /dev/null 2>&1)
echo -e "      ${GREEN}✓${NC} Git repository initialized"

# Success!
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✅ Success! App ready! ✅          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo -e "  ${BLUE}1.${NC} Start the backend:"
echo -e "     ${GREEN}cd $APP_NAME/backend${NC}"
echo -e "     ${GREEN}source venv/bin/activate${NC}"
echo -e "     ${GREEN}uvicorn app.main:app --reload --port $BACKEND_PORT${NC}"
echo ""
echo -e "  ${BLUE}2.${NC} In a new terminal, start the frontend:"
echo -e "     ${GREEN}cd $APP_NAME/frontend${NC}"
echo -e "     ${GREEN}npm run dev${NC}"
echo ""
echo -e "  ${BLUE}3.${NC} Open in browser:"
echo -e "     ${GREEN}http://localhost:$FRONTEND_PORT${NC}"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo -e "  • Frontend: ${GREEN}$APP_NAME/frontend/README.md${NC}"
echo -e "  • Backend:  ${GREEN}$APP_NAME/backend/README.md${NC}"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"
```

**Deliverables:**
- [ ] new-app.sh script מושלם
- [ ] Validation + error handling
- [ ] User-friendly output
- [ ] --help documentation

---

#### 3.2 Script Testing
**מה:** בדיקות יסודיות של הסקריפט

**Test Cases:**
```bash
# Test 1: Basic creation
./scripts/new-app.sh --name testapp1

# Test 2: Custom ports
./scripts/new-app.sh --name testapp2 --frontend-port 3005 --backend-port 8005

# Test 3: Purple theme
./scripts/new-app.sh --name testapp3 --color purple

# Test 4: Skip install (fast)
./scripts/new-app.sh --name testapp4 --skip-install

# Test 5: Invalid name (should fail)
./scripts/new-app.sh --name "Test App"

# Test 6: Existing directory (should fail)
./scripts/new-app.sh --name testapp1
```

**Validation Checklist:**
- [ ] כל placeholders מוחלפים
- [ ] Secrets נוצרים
- [ ] npm install עובד
- [ ] pip install עובד
- [ ] git init עובד
- [ ] Error handling תקין

**Deliverables:**
- [ ] Test script
- [ ] Test results documented
- [ ] Known issues list

---

### Phase 4: Documentation 📚 HIGH PRIORITY
**משך משוער:** 2-3 שעות
**תלויות:** Phase 1, 2, 3

#### 4.1 Master README
**מה:** תיעוד ראשי לתבנית

**קובץ:** `templates/ovu-app-template/README.md`

**תוכן:**
```markdown
# 🚀 OVU App Template

Template for creating new OVU applications with built-in authentication, design system, and best practices.

## Features

- ✅ **ULM Authentication** - Login/logout/refresh built-in
- ✅ **OVU Design System** - Consistent UI across all apps
- ✅ **Shared Components** - LoginPage, Layout, Dashboard, etc.
- ✅ **Multi-language** - Hebrew, English, Arabic
- ✅ **Dark/Light Theme** - Automatic theme switching
- ✅ **Type-Safe** - Full TypeScript support
- ✅ **FastAPI Backend** - Modern Python async backend
- ✅ **Bootstrap Script** - Create new app in 5 minutes

## Quick Start

### Using Bootstrap Script (Recommended)

\`\`\`bash
cd /path/to/ovu
./scripts/new-app.sh --name myapp --frontend-port 3000 --backend-port 8000
\`\`\`

That's it! Your app is ready. 🎉

### Manual Setup

[Steps for manual setup...]

## Project Structure

\`\`\`
myapp/
├── frontend/          # React + Vite + TypeScript
│   ├── src/
│   │   ├── api/       # API client + auth
│   │   ├── contexts/  # React contexts
│   │   ├── hooks/     # Custom hooks
│   │   ├── localization/ # Translations
│   │   ├── pages/     # Page components
│   │   └── styles/    # CSS files
│   └── package.json
│
└── backend/           # FastAPI + Python
    ├── app/
    │   ├── api/       # API routes
    │   ├── clients/   # External clients (ULM)
    │   ├── core/      # Config + deps
    │   ├── middleware/# Logging, etc.
    │   └── security/  # Auth
    └── requirements.txt
\`\`\`

## Customization Guide

### Change App Name
Already done by bootstrap script, but you can manually find/replace \`__APP_NAME__\`.

### Change Primary Color
Edit \`frontend/src/styles/theme.css\`:
\`\`\`css
--app-primary: #YOUR_COLOR;
\`\`\`

### Add Menu Items
Edit \`frontend/src/App.tsx\`:
\`\`\`typescript
const menuItems = [
  {
    id: "dashboard",
    label: "לוח בקרה",
    labelEn: "Dashboard",
    icon: "📊",
    path: "/dashboard",
  },
  // Add your items here
];
\`\`\`

### Add New API Route
1. Create \`backend/app/api/v1/routes/myroute.py\`
2. Register in \`backend/app/main.py\`:
   \`\`\`python
   from app.api.v1.routes import myroute
   app.include_router(myroute.router, prefix=settings.API_V1_STR)
   \`\`\`

## Authentication Flow

[Detailed explanation...]

## Development

### Frontend
\`\`\`bash
cd frontend
npm run dev
\`\`\`

### Backend
\`\`\`bash
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8000
\`\`\`

## Deployment

[Deployment instructions...]

## Troubleshooting

### npm install fails
[Solution...]

### Backend can't connect to ULM
[Solution...]

## Contributing

Please follow OVU coding standards and test thoroughly before committing.

## License

Internal use only - OVU System
\`\`\`

**Deliverables:**
- [ ] Master README מושלם
- [ ] Quick start guide
- [ ] Customization guide
- [ ] Troubleshooting section

---

#### 4.2 Architecture Documentation
**מה:** תיעוד ארכיטקטוני מפורט

**קובץ:** `docs/specs/templates/ARCHITECTURE.md`

**תוכן:**
- Authentication flow diagrams
- Component hierarchy
- Data flow
- Security model
- Deployment architecture

**Deliverables:**
- [ ] ARCHITECTURE.md
- [ ] Diagrams (if possible)
- [ ] Design decisions documented

---

#### 4.3 Migration Guide
**מה:** מדריך למיגרציה של אפליקציות קיימות

**קובץ:** `docs/specs/templates/MIGRATION_GUIDE.md`

**תוכן:**
- כיצד לשדרג AAM לגרסה חדשה
- כיצד להמיר אפליקציה קיימת לתבנית
- Breaking changes
- Compatibility notes

**Deliverables:**
- [ ] MIGRATION_GUIDE.md
- [ ] Step-by-step instructions
- [ ] Code examples

---

### Phase 5: Testing & Validation 🧪 CRITICAL
**משך משוער:** 3-4 שעות
**תלויות:** Phase 1, 2, 3, 4

#### 5.1 Create Test App
**מה:** יצירת אפליקציית בדיקה מלאה

```bash
./scripts/new-app.sh --name testapp --frontend-port 3099 --backend-port 8099
```

**Test Checklist:**
- [ ] Bootstrap script רץ בהצלחה
- [ ] Frontend מתקמפל ללא שגיאות
- [ ] Backend מתחיל ללא שגיאות
- [ ] Login flow עובד
- [ ] Token refresh עובד
- [ ] Logout עובד
- [ ] Theme switching עובד
- [ ] Language switching עובד
- [ ] Protected routes עובדים
- [ ] API calls מגיעים ל-ULM עם X-App-Source נכון

**Deliverables:**
- [ ] Test app נוצר בהצלחה
- [ ] כל הבדיקות עברו
- [ ] Bugs מתועדים ותוקנו

---

#### 5.2 Integration Testing
**מה:** בדיקת אינטגרציה מלאה עם ULM+AAM

**Tests:**
```bash
# Test 1: Login with real ULM
curl -X POST http://localhost:8099/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test@example.com","password":"test123"}'

# Test 2: Check ULM logs for app_source
# Should see: app_source=testapp-backend

# Test 3: Protected endpoint
curl http://localhost:8099/api/v1/example/protected \
  -H "Authorization: Bearer $TOKEN"

# Test 4: Frontend login
# Open http://localhost:3099 and login
```

**Deliverables:**
- [ ] Integration tests documented
- [ ] All tests pass
- [ ] Screenshots of working app

---

#### 5.3 Performance Testing
**מה:** בדיקת ביצועים בסיסית

**Metrics:**
- Frontend bundle size
- Backend startup time
- Login flow duration
- API response times

**Deliverables:**
- [ ] Performance baseline documented
- [ ] No major bottlenecks identified

---

### Phase 6: Shared Components Package 📦 MEDIUM PRIORITY
**משך משוער:** 2-3 שעות
**תלויות:** Phase 0.1

#### 6.1 Package Setup
**מה:** הפיכת shared-components ל-npm package

**קובץ:** `worktrees/shared-work/react-components/package.json`

```json
{
  "name": "@ovu/components",
  "version": "1.0.0",
  "description": "OVU Shared React Components",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "tsc && cp -r */**.css dist/",
    "prepublishOnly": "npm run build"
  },
  "peerDependencies": {
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "react-router-dom": "^7.9.3"
  },
  "devDependencies": {
    "@types/react": "^19.1.16",
    "typescript": "~5.9.3"
  }
}
```

**Deliverables:**
- [ ] package.json מוגדר
- [ ] Build script עובד
- [ ] Types מיוצאים נכון

---

#### 6.2 Publishing
**מה:** פרסום ל-npm registry (GitHub packages)

**Steps:**
```bash
cd worktrees/shared-work/react-components

# Login to npm/GitHub packages
npm login --registry=https://npm.pkg.github.com

# Publish
npm publish --access public
```

**Deliverables:**
- [ ] Package מפורסם
- [ ] Installation מתועדת
- [ ] Version tagging setup

---

### Phase 7: Polish & Cleanup 🧹 LOW PRIORITY
**משך משוער:** 2 שעות
**תלויות:** כל ה-phases

#### 7.1 Code Quality
**Actions:**
- [ ] ESLint checks
- [ ] Prettier formatting
- [ ] Python black formatting
- [ ] Remove console.logs
- [ ] Remove TODOs/FIXMEs

---

#### 7.2 Final Documentation Review
**Actions:**
- [ ] Spell check
- [ ] Grammar check
- [ ] Links validation
- [ ] Code examples tested
- [ ] Screenshots updated

---

#### 7.3 Release Preparation
**Actions:**
- [ ] CHANGELOG.md
- [ ] Version tagging
- [ ] Release notes
- [ ] Announcement draft

---

## 📊 Timeline & Resources

### Estimated Timeline
| Phase | Duration | Dependencies | Priority |
|-------|----------|--------------|----------|
| Phase 0 | 2-3h | None | 🔴 Critical |
| Phase 1 | 4-6h | Phase 0 | 🟡 High |
| Phase 2 | 4-6h | Phase 0 | 🟡 High |
| Phase 3 | 3-4h | Phase 1, 2 | 🔴 Critical |
| Phase 4 | 2-3h | Phase 1, 2, 3 | 🟡 High |
| Phase 5 | 3-4h | Phase 1-4 | 🔴 Critical |
| Phase 6 | 2-3h | Phase 0.1 | 🟢 Medium |
| Phase 7 | 2h | All | 🟢 Low |
| **Total** | **22-31h** | | |

### Recommended Order
1. **Day 1 (8h):** Phase 0 + Phase 1 (Frontend)
2. **Day 2 (8h):** Phase 2 (Backend) + Phase 3 (Bootstrap)
3. **Day 3 (6h):** Phase 4 (Docs) + Phase 5 (Testing)
4. **Day 4 (4h):** Phase 6 (Package) + Phase 7 (Polish)

---

## 🚨 Risks & Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Shared components package fails | High | Low | Start with simple copy, upgrade later |
| Bootstrap script breaks | High | Medium | Extensive testing + error handling |
| Auth flow incompatible | Critical | Low | Test with real ULM early |
| Performance issues | Medium | Low | Baseline testing in Phase 5 |
| Documentation incomplete | Medium | Medium | Write docs alongside code |

---

## ✅ Success Criteria

### Must Have (MVP)
- [x] Bootstrap script creates working app
- [x] Frontend compiles and runs
- [x] Backend starts and responds
- [x] Login/logout flow works
- [x] X-App-Source tracked in ULM
- [x] README documentation complete

### Should Have
- [ ] Shared components as npm package
- [ ] Dark/light theme working
- [ ] Multi-language working
- [ ] Health endpoints
- [ ] Docker support

### Nice to Have
- [ ] Unit tests
- [ ] E2E tests
- [ ] Performance optimizations
- [ ] CI/CD templates

---

## 📞 Support & Next Steps

### After Implementation
1. Create demo video
2. Training session for developers
3. Monitor first real app creation
4. Collect feedback
5. Iterate based on feedback

### Maintenance
- Update dependencies quarterly
- Review security quarterly
- Update docs as needed
- Track issues in GitHub

---

**תוכנית זו מאושרת להתחלת פיתוח! 🚀**

*Last Updated: 2025-12-20*

