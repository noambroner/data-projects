# 🎨 SAM Visual Architecture - ארכיטקטורה ויזואלית

**תאריך:** 2025-12-20
**גרסה:** 1.0

---

## 🌍 System Overview - מבט על

```
┌─────────────────────────────────────────────────────────────────┐
│                        OVU Ecosystem                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│                    ┌──────────────────┐                          │
│                    │       SAM        │ ← "מוח המפה"            │
│                    │  (System Map)    │                          │
│                    └────────┬─────────┘                          │
│                             │                                    │
│                    ┌────────▼─────────┐                          │
│                    │       ULM        │ ← Core Auth             │
│                    │  (Login/Auth)    │                          │
│                    └────────┬─────────┘                          │
│                             │                                    │
│      ┌──────────────────────┼────────────────────┐              │
│      │                      │                    │              │
│ ┌────▼─────┐         ┌─────▼────┐         ┌─────▼────┐         │
│ │   AAM    │         │   CRM    │         │  Other   │         │
│ │ (Admin)  │         │(Customers│         │   Apps   │         │
│ └──────────┘         └──────────┘         └──────────┘         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🏗️ SAM Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                         Layer 1: Frontend                        │
├─────────────────────────────────────────────────────────────────┤
│  React UI                                                        │
│  ├─ Dashboard (Overview)                                         │
│  ├─ Apps List & Detail Pages                                    │
│  ├─ Dependency Graph (Visual)                                   │
│  ├─ Search & Discovery                                          │
│  └─ Documentation Viewer                                        │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTPS/REST
┌───────────────────────────▼─────────────────────────────────────┐
│                         Layer 2: API Layer                       │
├─────────────────────────────────────────────────────────────────┤
│  FastAPI Backend                                                 │
│  ├─ /api/v1/apps/*           (CRUD for apps)                   │
│  ├─ /api/v1/dependencies/*   (Relationships)                   │
│  ├─ /api/v1/endpoints/*      (API catalog)                     │
│  ├─ /api/v1/discovery/*      (Service discovery)               │
│  └─ /api/v1/map/*            (System map data)                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
┌─────────────▼──┐  ┌───────▼───────┐  ┌▼────────────────┐
│   Layer 3a:    │  │  Layer 3b:    │  │   Layer 3c:     │
│   Business     │  │   Cache       │  │   External      │
│   Logic        │  │   (Redis)     │  │   Services      │
├────────────────┤  ├───────────────┤  ├─────────────────┤
│ • Validation   │  │ • App lists   │  │ • ULM (Auth)    │
│ • Authorization│  │ • Search      │  │ • GitHub API    │
│ • Graph calc   │  │ • Queries     │  │ • Webhooks      │
│ • Search algo  │  │ • Hot data    │  │                 │
└────────┬───────┘  └───────────────┘  └─────────────────┘
         │
┌────────▼──────────────────────────────────────────────────────┐
│                    Layer 4: Data Layer                         │
├────────────────────────────────────────────────────────────────┤
│  PostgreSQL Database (sam_db)                                  │
│  ├─ apps                  (Applications registry)              │
│  ├─ dependencies          (Relationships)                      │
│  ├─ endpoints             (API catalog)                        │
│  ├─ servers               (Infrastructure)                     │
│  └─ app_deployments       (Deployment info)                    │
└────────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow - זרימת מידע

### Scenario 1: User Views App List

```
1. User opens SAM UI
   │
   ▼
2. Frontend: GET /api/v1/apps
   │
   ▼
3. Backend checks Redis cache
   │
   ├─ HIT → Return cached data (< 10ms)
   │
   └─ MISS ↓
      │
      ▼
   4. Query PostgreSQL
      │
      ▼
   5. Cache result in Redis (1 hour TTL)
      │
      ▼
   6. Return to Frontend
      │
      ▼
7. Render apps grid
```

**Performance:**
- Cached: ~10-20ms
- Uncached: ~50-100ms
- Database query: ~30-50ms

---

### Scenario 2: App Registers Itself

```
1. New app starts up
   │
   ▼
2. App calls: POST /api/v1/apps/register
   │
   ├─ Headers: Authorization: Bearer {service_token}
   │
   ▼
3. SAM validates token with ULM
   │
   ├─ Valid → Continue
   │
   └─ Invalid → 401 Unauthorized
   │
   ▼
4. Check if app already exists
   │
   ├─ Exists → Update (PUT)
   │
   └─ New → Create (POST)
   │
   ▼
5. Insert/Update in PostgreSQL
   │
   ▼
6. Invalidate cache
   │
   ▼
7. Return success
   │
   ▼
8. App is now registered!
```

---

### Scenario 3: Developer Searches for API

```
1. Developer types "user authentication"
   │
   ▼
2. Frontend: GET /api/v1/apps?search=user+authentication
   │
   ▼
3. Backend checks search cache
   │
   ├─ HIT → Return cached results
   │
   └─ MISS ↓
      │
      ▼
   4. Full-text search in PostgreSQL
      │
      ├─ Search in: display_name, description, purpose, tags
      │
      ▼
   5. Rank results by relevance
      │
      ▼
   6. Cache results (15 min TTL)
      │
      ▼
7. Return matched apps
   │
   ▼
8. Display results with highlights
```

---

## 🔄 Auto-Registration Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    App Startup Process                        │
└──────────────────────────────────────────────────────────────┘

[App Container Starts]
         │
         ▼
    Load Config
    (from .env)
         │
         ▼
┌────────────────────┐
│ Auto-Register with│
│       SAM?        │
└────────┬───────────┘
         │
    ┌────┴────┐
    │  YES    │
    └────┬────┘
         │
         ▼
Get Service Token
(from ULM or config)
         │
         ▼
 Prepare App Info:
 ├─ name: "my-app"
 ├─ frontend_url
 ├─ backend_url
 ├─ version
 └─ ports
         │
         ▼
POST /api/v1/apps/register
         │
    ┌────┴────┐
    │ Success?│
    └────┬────┘
         │
    ┌────┴────────┐
    │             │
  YES            NO
    │             │
    ▼             ▼
Log success   Log warning
    │         (non-blocking)
    │             │
    └──────┬──────┘
           │
           ▼
   App continues
   normal startup
```

**Benefits:**
- ✅ Zero manual registration
- ✅ Always up-to-date
- ✅ Self-documenting
- ✅ Version tracking

---

## 🗺️ Dependency Graph Visualization

### Example: OVU Core System

```
                    ┌────────────────┐
                    │   PostgreSQL   │
                    │   (Database)   │
                    └────────┬───────┘
                             │
                    ┌────────▼───────┐
                    │     Redis      │
                    │    (Cache)     │
                    └────────┬───────┘
                             │
                    ┌────────▼───────┐
                    │      ULM       │ ← Level 1: Core
                    │ (Auth Service) │
                    └────────┬───────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼────────┐  ┌────────▼───────┐  ┌────────▼───────┐
│      AAM       │  │      SAM       │  │      CRM       │
│ (Admin Mgmt)   │  │ (System Map)   │  │  (Customers)   │
└───────┬────────┘  └────────┬───────┘  └────────┬───────┘
        │                    │                    │
        │                    └─────────┬──────────┘
        │                              │
┌───────▼──────────────────────────────▼───────┐
│              Dashboard                        │
│        (Unified Admin Interface)              │
└───────────────────────────────────────────────┘

Legend:
━━━━  Critical dependency (app won't work without it)
┈┈┈┈  Optional dependency (app works but with reduced features)
```

### Dependency Types:

| Type | Symbol | Description | Example |
|------|--------|-------------|---------|
| **requires** | ━━━ | Must have | AAM requires ULM |
| **uses** | ─── | Can use | Dashboard uses CRM |
| **integrates_with** | ┈┈┈ | Optional | CRM integrates_with Email |
| **extends** | ═══ | Extends | Plugin extends Core |

---

## 🎯 Service Discovery Pattern

```
┌────────────────────────────────────────────────────────┐
│          App A needs to call App B                     │
└────────────────────────────────────────────────────────┘

Traditional (Hard-coded):
─────────────────────────
const ULM_URL = "https://ulm.ovu.co.il/api/v1"  // ❌ Hard-coded!

With SAM (Dynamic):
───────────────────
import { SAMClient } from '@ovu/sam-sdk'

const sam = new SAMClient(process.env.SAM_URL)
const ulm = await sam.findApp('ulm')
const ULM_URL = ulm.backend_url  // ✅ Dynamic!

// Now call ULM
const response = await fetch(`${ULM_URL}/users`)
```

**Benefits:**
- ✅ No hard-coded URLs
- ✅ Easy to change environments
- ✅ Centralized configuration
- ✅ Automatic failover (future)

---

## 🚀 Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Production Setup                         │
└─────────────────────────────────────────────────────────────┘

[Internet]
    │
    ▼
┌───────────────────┐
│  Cloudflare CDN   │ ← SSL, DDoS protection, Cache
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│  Nginx (Proxy)    │ ← Load balancing, Routing
│  64.176.173.105   │
└────────┬──────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌─────────┐ ┌─────────┐
│SAM Front│ │SAM Back │
│(Static) │ │(FastAPI)│
│Port 3005│ │Port 8005│
└─────────┘ └────┬────┘
                 │
         ┌───────┼───────┐
         │       │       │
         ▼       ▼       ▼
    ┌────────┐ ┌──────┐ ┌─────┐
    │Postgres│ │Redis │ │ ULM │
    │(sam_db)│ │(DB 2)│ │ API │
    └────────┘ └──────┘ └─────┘
```

---

## 📈 Scalability Strategy

### Phase 1: Single Server (Current)
```
One Server:
├─ Frontend (Static files)
├─ Backend (FastAPI)
├─ PostgreSQL
└─ Redis

Max Load: ~1000 req/sec
```

### Phase 2: Separate Services (Future)
```
Frontend Server:
└─ Nginx + Static files

Backend Server:
└─ FastAPI (multiple workers)

Database Server:
├─ PostgreSQL (master)
└─ Redis

Max Load: ~10,000 req/sec
```

### Phase 3: Distributed (If Needed)
```
CDN:
└─ Static assets worldwide

Load Balancer:
└─ Multiple backend instances

Database Cluster:
├─ PostgreSQL (master + replicas)
└─ Redis Cluster

Max Load: 100,000+ req/sec
```

---

## 🔐 Security Layers

```
┌─────────────────────────────────────────────────────┐
│              Security Architecture                   │
└─────────────────────────────────────────────────────┘

Layer 1: Network
├─ Cloudflare DDoS protection
├─ Firewall rules
└─ Rate limiting

Layer 2: Application
├─ HTTPS only
├─ CORS policy
└─ Input validation

Layer 3: Authentication
├─ ULM token required
├─ Token expiration (15 min)
└─ Refresh token (7 days)

Layer 4: Authorization
├─ Public endpoints (read-only)
├─ User endpoints (authenticated)
└─ Admin endpoints (admin role)

Layer 5: Data
├─ Encrypted at rest
├─ Encrypted in transit
└─ Sensitive data masked
```

---

## 📊 Monitoring Points

```
┌─────────────────────────────────────────────────────┐
│            What to Monitor (Future SMM)              │
└─────────────────────────────────────────────────────┘

Frontend:
├─ Page load time
├─ API call latency
└─ Error rate

Backend:
├─ Request rate (req/sec)
├─ Response time (p50, p95, p99)
├─ Error rate
├─ Database query time
└─ Cache hit rate

Database:
├─ Connection pool usage
├─ Query performance
├─ Disk usage
└─ Replication lag

Redis:
├─ Memory usage
├─ Hit/miss ratio
├─ Eviction rate
└─ Connection count

Business Metrics:
├─ Total apps registered
├─ API calls per app
├─ Search queries
└─ User engagement
```

---

## 🎨 UI Component Hierarchy

```
App
├─ AuthProvider
│  └─ ThemeProvider
│     └─ Router
│        ├─ Sidebar (Navigation)
│        │  ├─ Dashboard Link
│        │  ├─ Apps Link
│        │  ├─ Map Link
│        │  └─ Dependencies Link
│        │
│        └─ Main Content
│           ├─ Route: /dashboard
│           │  ├─ StatsCards
│           │  ├─ SystemMap
│           │  ├─ PopularApps
│           │  └─ RecentUpdates
│           │
│           ├─ Route: /apps
│           │  ├─ SearchBar
│           │  ├─ FilterPanel
│           │  └─ AppsGrid
│           │     └─ AppCard[]
│           │
│           ├─ Route: /apps/:id
│           │  ├─ AppHeader
│           │  ├─ AppTabs
│           │  ├─ AppOverview
│           │  ├─ AppAPI
│           │  ├─ AppDependencies
│           │  └─ AppDocumentation
│           │
│           └─ Route: /map
│              ├─ GraphControls
│              └─ DependencyGraph
│                 ├─ Nodes (Apps)
│                 └─ Edges (Dependencies)
```

---

## 🔄 Real-Time Updates (Future)

```
┌─────────────────────────────────────────────────────┐
│          WebSocket Architecture (Optional)           │
└─────────────────────────────────────────────────────┘

Client (Browser)
    │
    │ WebSocket Connection
    │
    ▼
FastAPI Backend
    │
    │ Subscribe to events
    │
    ▼
Redis Pub/Sub
    │
    │ Events:
    │ ├─ app.created
    │ ├─ app.updated
    │ ├─ app.deleted
    │ └─ dependency.changed
    │
    ▼
All Connected Clients
(Real-time UI updates)
```

---

## 🎯 Success Visualization

```
Before SAM:
───────────
Developer: "Where is the ULM API?"
→ Ask in Slack
→ Wait for response
→ Get URL
→ Hard-code in app
→ URL changes → App breaks 💔

After SAM:
──────────
Developer: "Where is the ULM API?"
→ Open SAM
→ Search "ULM"
→ Copy API URL
→ Use SAM SDK (dynamic)
→ URL changes → Automatic update ✨
```

---

## 📝 Summary

**SAM is:**
- 🗺️ **Single Source of Truth** for all system info
- 🔍 **Service Discovery** tool
- 📚 **Documentation Hub**
- 🤖 **Auto-Updating** registry
- 🚀 **Developer-Friendly** with SDKs
- ⚡ **Fast** with multi-tier caching
- 🔒 **Secure** with ULM integration
- 📊 **Visual** with interactive graphs

---

**Ready to build the future of OVU! 🚀**

*Designed by: Cursor AI + Noam*
*Date: 2025-12-20*

