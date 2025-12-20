# 🗄️ OVU Database Architecture

**תאריך:** 2025-12-20
**גרסה:** 1.0

---

## 📊 Current State - Database per Service

### ✅ כרגע: כל אפליקציה = DB נפרד

```
┌─────────────────────────────────────────┐
│         PostgreSQL Server               │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │   ulm_db     │  │   aam_db     │   │
│  │              │  │              │   │
│  │ • users      │  │ • admins     │   │
│  │ • roles      │  │ • settings   │   │
│  │ • sessions   │  │ • logs       │   │
│  │ • tokens     │  │ • analytics  │   │
│  └──────────────┘  └──────────────┘   │
│                                         │
│  ┌──────────────┐                      │
│  │   sam_db     │  ← נוסיף עכשיו      │
│  │              │                      │
│  │ • apps       │                      │
│  │ • docs       │                      │
│  │ • deps       │                      │
│  └──────────────┘                      │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│            Redis Server                 │
├─────────────────────────────────────────┤
│  DB 0: ULM (sessions, cache)            │
│  DB 1: AAM (cache)                      │
│  DB 2: SAM (cache) ← נוסיף             │
└─────────────────────────────────────────┘
```

---

## 🏗️ Architecture Pattern: Database per Service

### ✅ מה שקיים עכשיו:

| Service | Database | Redis DB | Port |
|---------|----------|----------|------|
| **ULM** | `ulm_db` | `/0` | 8001 |
| **AAM** | `aam_db` | `/1` | 8002 |
| **SAM** | `sam_db` | `/2` | 8005 |
| **SMM** | `smm_db` | `/3` | 8006 (future) |

---

## 🎯 Why Database per Service?

### ✅ Advantages (Microservices Best Practice)

**1. Independence & Autonomy:**
```
ULM משתנה → רק ulm_db מושפע
AAM לא יודע, לא אכפת לו
```

**2. Technology Freedom:**
```
ULM: PostgreSQL
AAM: PostgreSQL
SAM: יכול להיות MongoDB אם רוצים
SMM: יכול להיות InfluxDB (time-series)
```

**3. Scalability:**
```
ULM צריך scale? → scale רק את ulm_db
AAM לא צריך scale? → לא נוגעים
```

**4. Fault Isolation:**
```
AAM DB קורס? → רק AAM נופל
ULM ממשיך לעבוד, SAM ממשיך לעבוד
```

**5. Security:**
```
AAM אסור לגשת ישירות ל-users של ULM
כל service רואה רק את המידע שלו
```

**6. Deployment:**
```
עדכון schema של ULM? → migration רק ב-ulm_db
אין dependency על אפליקציות אחרות
```

### ⚠️ Disadvantages

**1. Data Duplication:**
```
אם צריך user info ב-AAM → צריך לקרוא מ-ULM API
לא יכול לעשות JOIN ישירות
```

**2. Distributed Transactions:**
```
עדכון בשני DBs ביחד? → מורכב
צריך saga pattern או compensation
```

**3. More Resources:**
```
כל DB = connections, memory, disk
יותר overhead
```

**4. Management Complexity:**
```
יותר DBs = יותר backups, monitoring, migrations
```

---

## 🔄 Alternative: Shared Database

### ❌ למה לא עושים Shared DB:

```
┌─────────────────────────────────────────┐
│         ONE Big Database                │
├─────────────────────────────────────────┤
│  • users (ULM)                          │
│  • roles (ULM)                          │
│  • admins (AAM)                         │
│  • apps (SAM)                           │
│  • metrics (SMM)                        │
└─────────────────────────────────────────┘
          ↓
    ⚠️ PROBLEMS:
    • Tight coupling
    • Schema conflicts
    • No independence
    • Scale together (waste)
    • Security issues
```

**זו Anti-pattern למיקרו-שירותים!**

---

## 💾 Recommended Architecture for OVU

### ✅ Database per Service + Smart Integration

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│   ULM    │         │   AAM    │         │   SAM    │
├──────────┤         ├──────────┤         ├──────────┤
│ ulm_db   │         │ aam_db   │         │ sam_db   │
│          │         │          │         │          │
│ • users  │◄────────│ calls    │         │ • apps   │
│ • roles  │  API    │ /me      │         │ • docs   │
│ • tokens │         │          │         │          │
└──────────┘         └──────────┘         └──────────┘
     │                    │                     │
     │                    │                     │
     ▼                    ▼                     ▼
  Redis/0             Redis/1              Redis/2
  (sessions)          (cache)              (cache)
```

**Integration via APIs, NOT direct DB access!**

---

## 🎯 SAM Database Design

### Recommended: PostgreSQL (like others)

**Why:**
- ✅ Consistency עם ULM/AAM
- ✅ Proven & reliable
- ✅ JSON support (documentation)
- ✅ Full-text search
- ✅ ACID transactions

### SAM Schema (Initial)

```sql
-- Apps table
CREATE TABLE apps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(200) NOT NULL,
    description TEXT,
    purpose TEXT,

    -- URLs
    frontend_url VARCHAR(500),
    backend_url VARCHAR(500),
    api_docs_url VARCHAR(500),
    repository_url VARCHAR(500),

    -- Organization
    category VARCHAR(50) NOT NULL,
    owner VARCHAR(100),
    team VARCHAR(100),

    -- Versioning
    version VARCHAR(50),

    -- Access
    required_roles TEXT[],
    is_public BOOLEAN DEFAULT true,

    -- Documentation (JSON)
    documentation JSONB,

    -- Metadata
    tags TEXT[],
    frontend_port INTEGER,
    backend_port INTEGER,

    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(100),
    last_modified_by VARCHAR(100),

    -- Indexes
    CONSTRAINT apps_name_check CHECK (name ~ '^[a-z0-9_-]+$')
);

-- Dependencies table (many-to-many)
CREATE TABLE dependencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    depends_on_id UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    dependency_type VARCHAR(50) DEFAULT 'required',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(app_id, depends_on_id)
);

-- API Endpoints table
CREATE TABLE api_endpoints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_id UUID NOT NULL REFERENCES apps(id) ON DELETE CASCADE,
    method VARCHAR(10) NOT NULL,
    path VARCHAR(500) NOT NULL,
    description TEXT,
    requires_auth BOOLEAN DEFAULT true,
    required_roles TEXT[],
    request_example JSONB,
    response_example JSONB,
    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(app_id, method, path)
);

-- Indexes for performance
CREATE INDEX idx_apps_category ON apps(category);
CREATE INDEX idx_apps_owner ON apps(owner);
CREATE INDEX idx_apps_tags ON apps USING GIN(tags);
CREATE INDEX idx_apps_search ON apps USING GIN(to_tsvector('english',
    display_name || ' ' || COALESCE(description, '')));
CREATE INDEX idx_dependencies_app ON dependencies(app_id);
CREATE INDEX idx_dependencies_depends ON dependencies(depends_on_id);
```

---

## 🔄 Data Flow Examples

### Example 1: User logs into AAM

```
1. User → AAM Frontend
2. AAM Frontend → AAM Backend /login
3. AAM Backend → ULM API /api/v1/auth/login
4. ULM queries ulm_db (users table)
5. ULM returns token
6. AAM stores token (not in aam_db, in memory/redis)
7. User authenticated!

✅ AAM never touches ulm_db directly
✅ Data ownership respected
```

### Example 2: SAM displays app info

```
1. Developer → SAM Frontend
2. SAM Frontend → SAM Backend /api/v1/apps
3. SAM Backend queries sam_db (apps table)
4. Returns list of apps
5. SAM Frontend displays

✅ SAM owns its data
✅ No cross-DB queries needed
```

### Example 3: SAM needs to show "Who can access this app?"

```
Option A (Recommended):
1. SAM stores required_roles in sam_db: ['admin', 'developer']
2. When user opens SAM, check their role (from ULM token)
3. Filter apps based on user's role
✅ No cross-service call needed

Option B (If need live data):
1. SAM → ULM API: "Get user info for user_id"
2. ULM returns user with roles
3. SAM filters apps
⚠️ Extra API call, but data is fresh
```

---

## 🛡️ Security Best Practices

### 1. No Direct DB Access Between Services
```bash
# ❌ NEVER do this
AAM → connects to ulm_db → SELECT * FROM users

# ✅ ALWAYS do this
AAM → ULM API → /api/v1/users/me
```

### 2. Database Credentials Isolation
```bash
# Each service has its own DB user
ulm_backend: user=ulm_user, password=ulm_pass, db=ulm_db
aam_backend: user=aam_user, password=aam_pass, db=aam_db
sam_backend: user=sam_user, password=sam_pass, db=sam_db

# ulm_user CANNOT access aam_db or sam_db
```

### 3. Connection String per Service
```python
# ULM config
DATABASE_URL = "postgresql+asyncpg://ulm_user:pass@localhost/ulm_db"

# AAM config
DATABASE_URL = "postgresql+asyncpg://aam_user:pass@localhost/aam_db"

# SAM config
DATABASE_URL = "postgresql+asyncpg://sam_user:pass@localhost/sam_db"
```

---

## 📋 Setup Checklist for SAM

### Database Setup

```bash
# 1. Create SAM database
psql -U postgres
CREATE DATABASE sam_db;
CREATE USER sam_user WITH PASSWORD 'sam_password';
GRANT ALL PRIVILEGES ON DATABASE sam_db TO sam_user;

# 2. Run migrations (Alembic)
cd sam/backend
alembic upgrade head

# 3. Verify
psql -U sam_user -d sam_db
\dt  # should show: apps, dependencies, api_endpoints
```

### Redis Setup
```bash
# SAM will use Redis DB 2
# No special setup needed, just configure in .env
REDIS_URL=redis://localhost:6379/2
```

---

## 🎯 Decision Matrix: When to Use What

| Scenario | Solution | Example |
|----------|----------|---------|
| **Store app metadata** | SAM DB | App name, URLs, description |
| **Check user permissions** | Call ULM API | Is user admin? |
| **Cache frequently accessed data** | Redis | App list, search results |
| **Log events** | Service's own DB | SAM logs who edited what |
| **Cross-service data** | API calls | AAM needs user info → call ULM |

---

## 🚀 Recommended for SAM

### ✅ Use Separate Database: `sam_db`

**Reasoning:**
1. **Independence:** SAM can evolve without affecting ULM/AAM
2. **Performance:** Optimized schema for mapping/docs
3. **Security:** SAM doesn't need access to user passwords
4. **Scalability:** Can scale SAM independently
5. **Consistency:** Same pattern as other OVU services

### Configuration

```python
# sam/backend/app/core/config.py
class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://sam_user:password@localhost/sam_db"
    DATABASE_POOL_SIZE: int = 10  # SAM needs less than ULM
    DATABASE_MAX_OVERFLOW: int = 20

    # Redis
    REDIS_URL: str = "redis://localhost:6379/2"  # DB 2 for SAM
```

---

## 📊 Resource Planning

### Current Setup (Estimated)

```
PostgreSQL Server (Shared):
├─ ulm_db: ~500MB (users, sessions, etc.)
├─ aam_db: ~100MB (admins, settings)
└─ sam_db: ~50MB (apps, docs) ← Small!

Redis Server (Shared):
├─ DB 0 (ULM): ~100MB (sessions)
├─ DB 1 (AAM): ~10MB (cache)
└─ DB 2 (SAM): ~5MB (cache) ← Very small!

Total: ~765MB
```

**זה ממש לא הרבה! שרת אחד יכול להכיל הכל.**

---

## 💡 Summary & Recommendation

### ✅ Final Answer: **Database per Service**

**For SAM:**
- PostgreSQL: `sam_db`
- Redis: `/2`
- DB User: `sam_user`
- Port: 8005

**Benefits:**
- 🎯 Microservices best practice
- 🔒 Security isolation
- ⚡ Independent scaling
- 🛠️ Easy maintenance
- 📈 Future-proof

**Minimal overhead, maximum flexibility!**

---

**Ready to create SAM with its own database?** 🚀

---

*Architecture designed by: Cursor AI + Noam*
*Date: 2025-12-20*

