# 🗺️ SAM Implementation Plan - תוכנית מפורטת

**תאריך:** 2025-12-20
**גרסה:** 1.0
**סטטוס:** Design Phase

---

## 🎯 Executive Summary

**SAM (System Mapping Manager)** הוא מרכז המידע והתיעוד של מערכת OVU.
**מטרה:** כל אפליקציה ומשתמש יוכלו להבין את המערכת בקלות ובמהירות.

---

## 📊 Part 1: Database Schema

### 1.1 Apps Table - מידע בסיסי על אפליקציות

```sql
CREATE TABLE apps (
    -- Identity
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,  -- 'ulm', 'aam', 'sam'
    display_name VARCHAR(200) NOT NULL,  -- 'User Login Manager'
    description TEXT,
    purpose TEXT,  -- מטרת האפליקציה

    -- URLs & Endpoints
    frontend_url VARCHAR(500),  -- 'https://ulm.ovu.co.il'
    backend_url VARCHAR(500),   -- 'https://ulm.ovu.co.il/api/v1'
    api_docs_url VARCHAR(500),  -- '/docs' או '/api/swagger'
    repository_url VARCHAR(500), -- GitHub URL

    -- Technical Details
    frontend_port INTEGER,  -- 3001
    backend_port INTEGER,   -- 8001
    version VARCHAR(50),    -- '2.0.0'
    tech_stack JSONB,       -- {"frontend": "React", "backend": "FastAPI"}

    -- Organization
    category VARCHAR(50) NOT NULL,  -- 'core', 'feature', 'admin', 'utility'
    owner VARCHAR(100),             -- 'noam@datapc.co.il'
    team VARCHAR(100),              -- 'Core Team'

    -- Access Control
    required_roles TEXT[],  -- ['admin'] או [] לציבורי
    is_public BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,

    -- Documentation (Rich JSON)
    documentation JSONB,  -- Structure below

    -- Metadata
    tags TEXT[],          -- ['auth', 'core', 'users']
    icon VARCHAR(50),     -- '🔐' או URL לאייקון
    color VARCHAR(20),    -- '#3b82f6'
    priority INTEGER DEFAULT 0,  -- גבוה יותר = חשוב יותר

    -- Audit
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(100),
    last_modified_by VARCHAR(100),

    -- Constraints
    CONSTRAINT apps_name_check CHECK (name ~ '^[a-z0-9_-]+$'),
    CONSTRAINT apps_category_check CHECK (category IN ('core', 'feature', 'admin', 'utility', 'integration'))
);

-- Indexes for performance
CREATE INDEX idx_apps_category ON apps(category);
CREATE INDEX idx_apps_is_active ON apps(is_active);
CREATE INDEX idx_apps_tags ON apps USING GIN(tags);
CREATE INDEX idx_apps_search ON apps USING GIN(to_tsvector('english',
    coalesce(display_name, '') || ' ' || coalesce(description, '') || ' ' || coalesce(purpose, '')));
```

**Documentation JSON Structure:**
```json
{
  "overview": "Detailed description of what the app does",
  "features": [
    {"name": "Feature 1", "description": "..."},
    {"name": "Feature 2", "description": "..."}
  ],
  "getting_started": {
    "installation": "How to install/access",
    "quick_start": "Quick start guide",
    "prerequisites": ["ULM authentication", "Admin role"]
  },
  "api_reference": {
    "base_url": "https://ulm.ovu.co.il/api/v1",
    "authentication": "Bearer token from ULM",
    "rate_limiting": "100 req/min"
  },
  "integration_guide": {
    "how_to_integrate": "Step by step",
    "code_examples": {
      "python": "import example",
      "javascript": "const example = ..."
    }
  },
  "troubleshooting": [
    {"issue": "Can't login", "solution": "Check ULM token"}
  ],
  "faq": [
    {"q": "What is ULM?", "a": "User Login Manager"}
  ],
  "changelog": [
    {"version": "2.0.0", "date": "2025-01-01", "changes": ["Added feature X"]}
  ],
  "contact": {
    "email": "support@datapc.co.il",
    "slack": "#ulm-support"
  }
}
```

---

### 1.2 Dependencies Table - קשרים בין אפליקציות

```sql
CREATE TABLE dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationship
    source_app_id UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    target_app_id UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,

    -- Dependency Details
    dependency_type VARCHAR(50) NOT NULL,  -- 'requires', 'uses', 'integrates_with', 'extends'
    description TEXT,  -- למה צריך את התלות הזאת
    is_critical BOOLEAN DEFAULT true,  -- האם האפליקציה לא יכולה לעבוד בלי זה

    -- Integration Details
    integration_method VARCHAR(50),  -- 'api', 'sdk', 'webhook', 'shared_db', 'message_queue'
    integration_details JSONB,  -- פרטים ספציפיים

    -- Audit
    created_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(100),

    -- Constraints
    CONSTRAINT dependency_unique UNIQUE(source_app_id, target_app_id, dependency_type),
    CONSTRAINT no_self_dependency CHECK (source_app_id != target_app_id),
    CONSTRAINT valid_dependency_type CHECK (
        dependency_type IN ('requires', 'uses', 'integrates_with', 'extends', 'optional')
    )
);

CREATE INDEX idx_dependencies_source ON dependencies(source_app_id);
CREATE INDEX idx_dependencies_target ON dependencies(target_app_id);
CREATE INDEX idx_dependencies_critical ON dependencies(is_critical);
```

**Example Dependencies:**
```
SAM → requires → ULM (for authentication)
AAM → requires → ULM (for authentication)
CRM → uses → ULM (for user data)
Notifications → integrates_with → Email Service
Dashboard → extends → Analytics
```

---

### 1.3 Endpoints Table - רשימת API endpoints

```sql
CREATE TABLE endpoints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,

    -- Endpoint Details
    path VARCHAR(500) NOT NULL,  -- '/api/v1/users'
    method VARCHAR(10) NOT NULL,  -- 'GET', 'POST', 'PUT', 'DELETE'
    summary TEXT,  -- תיאור קצר
    description TEXT,  -- תיאור מפורט

    -- Access
    is_public BOOLEAN DEFAULT false,
    required_roles TEXT[],  -- ['admin', 'user']

    -- Request/Response
    request_schema JSONB,   -- JSON Schema
    response_schema JSONB,  -- JSON Schema
    example_request JSONB,
    example_response JSONB,

    -- Metadata
    tags TEXT[],
    rate_limit INTEGER,  -- requests per minute
    is_deprecated BOOLEAN DEFAULT false,
    deprecation_message TEXT,

    -- Audit
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT endpoint_method_check CHECK (
        method IN ('GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS', 'HEAD')
    )
);

CREATE INDEX idx_endpoints_app ON endpoints(app_id);
CREATE INDEX idx_endpoints_public ON endpoints(is_public);
CREATE INDEX idx_endpoints_tags ON endpoints USING GIN(tags);
CREATE UNIQUE INDEX idx_endpoints_unique ON endpoints(app_id, path, method);
```

---

### 1.4 Servers Table - שרתים במערכת

```sql
CREATE TABLE servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Server Details
    name VARCHAR(100) UNIQUE NOT NULL,  -- 'dataflow-dev1'
    hostname VARCHAR(255) NOT NULL,     -- 'dataflow-dev1.datapc.co.il'
    ip_address INET,                    -- '64.176.171.223'

    -- Purpose
    purpose VARCHAR(50) NOT NULL,  -- 'backend', 'frontend', 'database', 'redis'
    environment VARCHAR(50) NOT NULL,  -- 'production', 'staging', 'development'

    -- Provider
    provider VARCHAR(50),  -- 'Vultr', 'AWS', 'Azure'
    region VARCHAR(50),    -- 'Amsterdam', 'US-East'

    -- Specs
    specs JSONB,  -- {"cpu": "4 cores", "ram": "8GB", "disk": "160GB"}

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Audit
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT server_purpose_check CHECK (
        purpose IN ('backend', 'frontend', 'database', 'redis', 'proxy', 'other')
    ),
    CONSTRAINT server_env_check CHECK (
        environment IN ('production', 'staging', 'development', 'test')
    )
);

CREATE INDEX idx_servers_purpose ON servers(purpose);
CREATE INDEX idx_servers_environment ON servers(environment);
CREATE INDEX idx_servers_active ON servers(is_active);
```

---

### 1.5 App_Deployments Table - איפה כל אפליקציה deployed

```sql
CREATE TABLE app_deployments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    app_id UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    server_id UUID NOT NULL REFERENCES servers(id) ON DELETE CASCADE,

    -- Deployment Details
    component VARCHAR(50) NOT NULL,  -- 'frontend', 'backend', 'database'
    deployment_url VARCHAR(500),     -- 'https://ulm.ovu.co.il'
    port INTEGER,

    -- Configuration
    config JSONB,  -- Environment variables, settings

    -- Status
    is_active BOOLEAN DEFAULT true,
    deployed_at TIMESTAMP DEFAULT NOW(),
    deployed_by VARCHAR(100),

    CONSTRAINT deployment_component_check CHECK (
        component IN ('frontend', 'backend', 'database', 'worker', 'other')
    ),
    CONSTRAINT deployment_unique UNIQUE(app_id, server_id, component)
);

CREATE INDEX idx_deployments_app ON app_deployments(app_id);
CREATE INDEX idx_deployments_server ON app_deployments(server_id);
CREATE INDEX idx_deployments_active ON app_deployments(is_active);
```

---

## 🔌 Part 2: REST API Design

### 2.1 Apps API

#### **GET /api/v1/apps** - רשימת כל האפליקציות
```json
{
  "query_params": {
    "category": "core|feature|admin|utility",
    "is_active": "true|false",
    "is_public": "true|false",
    "tags": "auth,users",
    "search": "user management",
    "limit": 50,
    "offset": 0,
    "sort_by": "name|created_at|priority",
    "order": "asc|desc"
  },
  "response": {
    "total": 10,
    "items": [
      {
        "id": "uuid",
        "name": "ulm",
        "display_name": "User Login Manager",
        "description": "Central authentication service",
        "category": "core",
        "frontend_url": "https://ulm.ovu.co.il",
        "backend_url": "https://ulm.ovu.co.il/api/v1",
        "version": "2.0.0",
        "icon": "🔐",
        "color": "#3b82f6",
        "tags": ["auth", "core", "users"],
        "is_active": true,
        "created_at": "2025-01-01T00:00:00Z"
      }
    ]
  }
}
```

#### **GET /api/v1/apps/:id** - פרטי אפליקציה מלאים
```json
{
  "response": {
    "id": "uuid",
    "name": "ulm",
    "display_name": "User Login Manager",
    "description": "...",
    "purpose": "Provides centralized authentication...",
    "frontend_url": "https://ulm.ovu.co.il",
    "backend_url": "https://ulm.ovu.co.il/api/v1",
    "api_docs_url": "https://ulm.ovu.co.il/docs",
    "repository_url": "https://github.com/noambroner/ovu-ulm",
    "frontend_port": 3001,
    "backend_port": 8001,
    "version": "2.0.0",
    "tech_stack": {
      "frontend": "React 18 + TypeScript + Vite",
      "backend": "FastAPI + Python 3.11",
      "database": "PostgreSQL 15",
      "cache": "Redis 7"
    },
    "category": "core",
    "owner": "noam@datapc.co.il",
    "team": "Core Team",
    "required_roles": [],
    "is_public": true,
    "is_active": true,
    "documentation": { /* full docs */ },
    "tags": ["auth", "core", "users"],
    "icon": "🔐",
    "color": "#3b82f6",
    "priority": 100,
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-15T10:30:00Z",
    "created_by": "admin",
    "last_modified_by": "admin",

    // Related data (expanded)
    "dependencies": [
      {
        "target_app": {
          "id": "uuid",
          "name": "postgres",
          "display_name": "PostgreSQL Database"
        },
        "dependency_type": "requires",
        "is_critical": true
      }
    ],
    "dependents": [
      {
        "source_app": {
          "id": "uuid",
          "name": "aam",
          "display_name": "Admin Area Manager"
        },
        "dependency_type": "requires",
        "is_critical": true
      }
    ],
    "endpoints_count": 25,
    "deployments": [
      {
        "component": "backend",
        "server": {
          "name": "dataflow-dev1",
          "hostname": "dataflow-dev1.datapc.co.il"
        },
        "deployment_url": "https://ulm.ovu.co.il/api/v1",
        "port": 8001,
        "is_active": true
      }
    ]
  }
}
```

#### **POST /api/v1/apps** - רישום אפליקציה חדשה
```json
{
  "request": {
    "name": "crm",
    "display_name": "Customer Relationship Manager",
    "description": "Manage customer relationships",
    "purpose": "Track customers, deals, and interactions",
    "frontend_url": "https://crm.ovu.co.il",
    "backend_url": "https://crm.ovu.co.il/api/v1",
    "frontend_port": 3010,
    "backend_port": 8010,
    "version": "1.0.0",
    "category": "feature",
    "owner": "sales@datapc.co.il",
    "tags": ["sales", "customers"],
    "icon": "💼",
    "color": "#10b981"
  },
  "response": {
    "id": "new-uuid",
    "message": "App registered successfully"
  }
}
```

#### **PUT /api/v1/apps/:id** - עדכון אפליקציה
#### **DELETE /api/v1/apps/:id** - מחיקת אפליקציה

---

### 2.2 Dependencies API

#### **GET /api/v1/dependencies** - כל התלויות
```json
{
  "query_params": {
    "source_app_id": "uuid",
    "target_app_id": "uuid",
    "dependency_type": "requires|uses|integrates_with",
    "is_critical": "true|false"
  },
  "response": {
    "total": 15,
    "items": [
      {
        "id": "uuid",
        "source_app": {
          "id": "uuid",
          "name": "aam",
          "display_name": "Admin Area Manager"
        },
        "target_app": {
          "id": "uuid",
          "name": "ulm",
          "display_name": "User Login Manager"
        },
        "dependency_type": "requires",
        "description": "AAM requires ULM for authentication",
        "is_critical": true,
        "integration_method": "api",
        "created_at": "2025-01-01T00:00:00Z"
      }
    ]
  }
}
```

#### **GET /api/v1/apps/:id/dependencies** - תלויות של אפליקציה ספציפית
```json
{
  "response": {
    "app": {
      "id": "uuid",
      "name": "aam",
      "display_name": "Admin Area Manager"
    },
    "requires": [
      {
        "app": { "name": "ulm", "display_name": "User Login Manager" },
        "is_critical": true
      }
    ],
    "used_by": [
      {
        "app": { "name": "dashboard", "display_name": "Admin Dashboard" },
        "is_critical": false
      }
    ]
  }
}
```

#### **POST /api/v1/dependencies** - הוספת תלות
```json
{
  "request": {
    "source_app_id": "uuid",
    "target_app_id": "uuid",
    "dependency_type": "requires",
    "description": "CRM needs ULM for user authentication",
    "is_critical": true,
    "integration_method": "api"
  }
}
```

---

### 2.3 Service Discovery API

#### **GET /api/v1/discovery/find/:app_name** - מצא אפליקציה
```json
{
  "response": {
    "found": true,
    "app": {
      "name": "ulm",
      "frontend_url": "https://ulm.ovu.co.il",
      "backend_url": "https://ulm.ovu.co.il/api/v1",
      "api_docs_url": "https://ulm.ovu.co.il/docs",
      "is_active": true
    }
  }
}
```

#### **GET /api/v1/discovery/endpoints/:app_name** - כל ה-endpoints של אפליקציה
```json
{
  "response": {
    "app": "ulm",
    "base_url": "https://ulm.ovu.co.il/api/v1",
    "endpoints": [
      {
        "path": "/auth/login",
        "method": "POST",
        "summary": "User login",
        "is_public": true
      },
      {
        "path": "/users",
        "method": "GET",
        "summary": "List users",
        "required_roles": ["admin"]
      }
    ]
  }
}
```

---

### 2.4 System Map API

#### **GET /api/v1/map/overview** - מבט על כל המערכת
```json
{
  "response": {
    "total_apps": 10,
    "categories": {
      "core": 3,
      "feature": 5,
      "admin": 2
    },
    "total_dependencies": 25,
    "critical_dependencies": 8,
    "total_endpoints": 150,
    "total_servers": 4
  }
}
```

#### **GET /api/v1/map/graph** - גרף תלויות
```json
{
  "response": {
    "nodes": [
      {
        "id": "ulm",
        "label": "User Login Manager",
        "type": "core",
        "color": "#3b82f6"
      },
      {
        "id": "aam",
        "label": "Admin Area Manager",
        "type": "admin",
        "color": "#8b5cf6"
      }
    ],
    "edges": [
      {
        "source": "aam",
        "target": "ulm",
        "type": "requires",
        "is_critical": true
      }
    ]
  }
}
```

---

## 🎨 Part 3: UI/UX Design

### 3.1 Dashboard (Homepage)

```
┌─────────────────────────────────────────────────────┐
│  SAM - System Mapping Manager        🔍 חיפוש...   │
├─────────────────────────────────────────────────────┤
│                                                      │
│  📊 System Overview                                  │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌────────┐│
│  │ 10 Apps │  │ 25 APIs │  │ 4 Srv  │  │ 3 DBs  ││
│  └─────────┘  └─────────┘  └─────────┘  └────────┘│
│                                                      │
│  🗺️ System Map                        [Graph View]  │
│  ┌────────────────────────────────────────────────┐ │
│  │           ULM (Core)                           │ │
│  │             ↓                                  │ │
│  │      ┌──────┴──────┬──────────┐              │ │
│  │      ↓             ↓          ↓              │ │
│  │     AAM           SAM        CRM             │ │
│  │      ↓                        ↓              │ │
│  │  Dashboard              Notifications        │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  🔥 Popular Apps                                     │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  │
│  │ 🔐 ULM │  │ 👤 AAM │  │ 🗺️ SAM │  │ 💼 CRM │  │
│  │ Active │  │ Active │  │ Active │  │ Active │  │
│  └────────┘  └────────┘  └────────┘  └────────┘  │
│                                                      │
│  📝 Recent Updates                                   │
│  • CRM v1.2.0 deployed (2 hours ago)                │
│  • ULM documentation updated (1 day ago)            │
│  • New app registered: Analytics (3 days ago)       │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

### 3.2 Apps List Page

```
┌─────────────────────────────────────────────────────┐
│  📦 Applications                                     │
│                                                      │
│  Filter: [All ▼] [Category ▼] [Active ▼] 🔍 Search │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │ 🔐 User Login Manager (ULM)           v2.0.0   │ │
│  │ Core • Active                                   │ │
│  │ Central authentication service for all OVU apps │ │
│  │ 🌐 https://ulm.ovu.co.il  📡 API: 25 endpoints │ │
│  │ Tags: auth, core, users                         │ │
│  │ [View Details] [API Docs] [Dependencies]       │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │ 👤 Admin Area Manager (AAM)           v1.5.0   │ │
│  │ Admin • Active                                  │ │
│  │ Manage system administrators and permissions   │ │
│  │ 🌐 https://aam.ovu.co.il  📡 API: 15 endpoints │ │
│  │ Tags: admin, roles, permissions                 │ │
│  │ [View Details] [API Docs] [Dependencies]       │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  ... more apps ...                                   │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

### 3.3 App Detail Page

```
┌─────────────────────────────────────────────────────┐
│  ← Back to Apps                                      │
│                                                      │
│  🔐 User Login Manager (ULM)                         │
│  Core Application • v2.0.0 • Active                  │
│                                                      │
│  [Overview] [API] [Dependencies] [Documentation]    │
│                                                      │
│  📋 Overview                                         │
│  ├─ Description: Central authentication service...  │
│  ├─ Purpose: Provides centralized authentication... │
│  ├─ Owner: Core Team (noam@datapc.co.il)           │
│  ├─ Created: 2025-01-01 by admin                   │
│  └─ Updated: 2025-01-15 by admin                   │
│                                                      │
│  🔗 Quick Links                                      │
│  ├─ 🌐 Frontend: https://ulm.ovu.co.il             │
│  ├─ 📡 Backend API: /api/v1                        │
│  ├─ 📚 API Docs: /docs                             │
│  └─ 💻 GitHub: github.com/noambroner/ovu-ulm      │
│                                                      │
│  🛠️ Technical Stack                                  │
│  ├─ Frontend: React 18 + TypeScript + Vite         │
│  ├─ Backend: FastAPI + Python 3.11                 │
│  ├─ Database: PostgreSQL 15                        │
│  └─ Cache: Redis 7                                 │
│                                                      │
│  📊 Dependencies                                     │
│  Requires (3):                                       │
│  ├─ PostgreSQL Database (critical)                 │
│  ├─ Redis Cache (critical)                         │
│  └─ Email Service (optional)                       │
│                                                      │
│  Used By (5):                                        │
│  ├─ AAM - Admin Area Manager (critical)            │
│  ├─ SAM - System Mapping Manager (critical)        │
│  ├─ CRM - Customer Relations (critical)            │
│  ├─ Dashboard - Main Dashboard (critical)          │
│  └─ Analytics - Analytics Platform (optional)      │
│                                                      │
│  🌍 Deployments                                      │
│  ├─ Backend: dataflow-dev1 (port 8001)            │
│  └─ Frontend: dataflow-dev2 (port 3001)           │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

### 3.4 Dependency Graph View

```
┌─────────────────────────────────────────────────────┐
│  🗺️ System Dependency Map                           │
│                                                      │
│  [Tree View] [Graph View] [Matrix View]             │
│                                                      │
│  Interactive Graph:                                  │
│                                                      │
│              ┌─────────────┐                         │
│              │  PostgreSQL │                         │
│              └──────┬──────┘                         │
│                     │                                │
│              ┌──────┴──────┐                         │
│              │     ULM     │ ← Core                  │
│              └──────┬──────┘                         │
│                     │                                │
│       ┌─────────────┼─────────────┬────────┐        │
│       │             │             │        │        │
│  ┌────▼────┐  ┌────▼────┐  ┌────▼────┐  ┌▼──┐     │
│  │   AAM   │  │   SAM   │  │   CRM   │  │...│     │
│  └────┬────┘  └─────────┘  └────┬────┘  └───┘     │
│       │                          │                  │
│  ┌────▼────────┐           ┌────▼─────────┐        │
│  │  Dashboard  │           │ Notifications │        │
│  └─────────────┘           └──────────────┘        │
│                                                      │
│  Legend:                                             │
│  ● Core Apps  ● Feature Apps  ● Admin Apps          │
│  ─ Requires (critical)  ┈ Uses (optional)           │
│                                                      │
│  Click on any app to see details                    │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 Part 4: Advanced Features

### 4.1 Auto-Registration

**כל אפליקציה יכולה לרשום את עצמה אוטומטית:**

```python
# In any app's startup:
import httpx
from app.core.config import settings

async def register_with_sam():
    """Auto-register this app with SAM on startup"""
    sam_url = "https://sam.ovu.co.il/api/v1/apps/register"

    app_info = {
        "name": settings.SERVICE_NAME.lower().replace(" ", "-"),
        "display_name": settings.SERVICE_NAME,
        "description": "Auto-generated description",
        "frontend_url": settings.FRONTEND_URL,
        "backend_url": settings.BACKEND_URL,
        "frontend_port": settings.FRONTEND_PORT,
        "backend_port": settings.BACKEND_PORT,
        "version": settings.SERVICE_VERSION,
        "category": "feature",  # Or auto-detect
    }

    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(
                sam_url,
                json=app_info,
                headers={"Authorization": f"Bearer {get_service_token()}"}
            )
            if response.status_code == 200:
                logger.info(f"✅ Registered with SAM: {app_info['name']}")
            elif response.status_code == 409:
                # Already registered - update instead
                await client.put(f"{sam_url}/{app_info['name']}", json=app_info)
        except Exception as e:
            logger.warning(f"Failed to register with SAM: {e}")
```

---

### 4.2 Client SDK

**Python SDK לשימוש קל:**

```python
# sam_client.py
from sam_sdk import SAMClient

sam = SAMClient("https://sam.ovu.co.il")

# Find an app
ulm = await sam.find_app("ulm")
print(ulm.backend_url)  # https://ulm.ovu.co.il/api/v1

# Get all apps in category
core_apps = await sam.get_apps(category="core")

# Get dependencies
deps = await sam.get_dependencies("aam")
print(deps.requires)  # [ulm, postgres]

# Search
results = await sam.search("authentication")
```

**JavaScript SDK:**

```javascript
import { SAMClient } from '@ovu/sam-sdk';

const sam = new SAMClient('https://sam.ovu.co.il');

// Find app
const ulm = await sam.findApp('ulm');
console.log(ulm.backendUrl);

// Get all apps
const apps = await sam.getApps({ category: 'core' });

// Search
const results = await sam.search('user management');
```

---

### 4.3 Caching Strategy

```
┌──────────────────────────────────────────┐
│         Multi-Tier Caching                │
├──────────────────────────────────────────┤
│                                           │
│  Browser Cache                            │
│  └─ Static data: 5 min                   │
│                                           │
│  Redis Cache (DB 2)                      │
│  ├─ App list: 1 hour                     │
│  ├─ App details: 30 min                  │
│  ├─ Dependencies: 1 hour                 │
│  └─ Search results: 15 min               │
│                                           │
│  PostgreSQL Database                      │
│  └─ Source of truth                      │
│                                           │
└──────────────────────────────────────────┘

Cache Keys:
- sam:apps:all → Full list
- sam:apps:{id} → Single app
- sam:apps:{name} → By name
- sam:deps:{app_id} → Dependencies
- sam:search:{query} → Search results
```

---

## 🔒 Part 5: Security & Access Control

### 5.1 Authentication

```
All SAM API calls require ULM token:
Authorization: Bearer {ulm_token}
```

### 5.2 Authorization

```python
# Public endpoints (no auth):
- GET /api/v1/apps (basic list)
- GET /api/v1/apps/:id (public apps only)
- GET /api/v1/discovery/*

# User endpoints (authenticated):
- GET /api/v1/apps/:id (full details if has access)
- GET /api/v1/endpoints/*

# Admin endpoints (admin role required):
- POST /api/v1/apps
- PUT /api/v1/apps/:id
- DELETE /api/v1/apps/:id
- POST /api/v1/dependencies
- PUT /api/v1/dependencies/:id
- DELETE /api/v1/dependencies/:id
```

---

## 📈 Part 6: Implementation Phases

### Phase 1: MVP (Week 1-2)
- ✅ Database schema
- ✅ Basic CRUD APIs for apps
- ✅ Simple UI: list + detail pages
- ✅ Manual app registration
- ✅ Basic search

### Phase 2: Dependencies (Week 3)
- ✅ Dependencies table & APIs
- ✅ Dependency graph visualization
- ✅ Service discovery API

### Phase 3: Documentation (Week 4)
- ✅ Rich documentation support
- ✅ API endpoints catalog
- ✅ Integration guides

### Phase 4: Automation (Week 5)
- ✅ Auto-registration
- ✅ SDKs (Python, JS)
- ✅ Caching layer

### Phase 5: Advanced (Week 6+)
- ✅ Search optimization
- ✅ Export/Import
- ✅ Webhooks
- ✅ Analytics

---

## 🎯 Success Metrics

| Metric | Target |
|--------|--------|
| **All apps registered** | 100% |
| **API response time** | < 100ms (cached) |
| **Search accuracy** | > 90% |
| **Daily active users** | All developers |
| **Documentation completeness** | > 80% apps |
| **Zero manual lookups** | Developers use SAM, not Slack |

---

## 📝 Next Steps

1. ✅ **Review & Approve** this plan
2. ⏳ **Create Database** (sam_db in PostgreSQL)
3. ⏳ **Implement Phase 1** APIs
4. ⏳ **Build Phase 1** UI
5. ⏳ **Register existing apps** (ULM, AAM, SAM)
6. ⏳ **Test & Iterate**

---

**המערכת תהיה מושלמת! 🚀**

*Plan created by: Cursor AI + Noam*
*Date: 2025-12-20*

