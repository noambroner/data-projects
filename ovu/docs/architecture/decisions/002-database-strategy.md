# ADR-002: Database Strategy (Per-App vs Shared)

**Status:** ✅ Accepted
**Date:** 2025-12-16
**Decision Makers:** Software Architect, DevOps Manager
**Consulted:** Database Administrator, Security Team

---

## Context

כל אפליקציה חדשה שנבנית על תבנית OVU צריכה לאחסן נתונים עסקיים. יש צורך להחליט:

1. **האם כל אפליקציה מקבלת DB משלה?** (Database per Service)
2. **האם משתפים DB אחד עם schemas נפרדים?** (Logical Separation)
3. **איך מתנהלים עם ULM?** (ULM אחראי רק על users/auth)
4. **מה קורה עם migrations?** (מי מריץ, איך מנהלים versions)

### הדרישות

- ✅ Isolation: אפליקציה אחת לא תשפיע על אחרת
- ✅ Security: הפרדת הרשאות ברמת DB
- ✅ Scalability: יכולת לגדול בנפרד
- ✅ Cost Effective: לא לבזבז משאבים מיותרים
- ✅ Easy Development: מפתח יכול לעבוד local בקלות

### Constraints

- ULM כבר קיים עם PostgreSQL 15
- חלק מהאפליקציות פשוטות (read-only מול ULM)
- חלק מהאפליקציות מורכבות (CRUD מלא + business logic)
- אנחנו משתמשים ב-Alembic (Python) או Prisma (TypeScript) ל-migrations

---

## Decision

### ✅ נאמץ: **Database Per App + Shared ULM**

**Architecture:**

```
┌─────────────────────────────────────────────────┐
│             Database Server (PostgreSQL 15)      │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌────────┐│
│  │  ulm_db      │  │  app1_db     │  │ app2_db││
│  │              │  │              │  │        ││
│  │ - users      │  │ - products   │  │ - ...  ││
│  │ - roles      │  │ - orders     │  │        ││
│  │ - sessions   │  │ - ...        │  │        ││
│  │ - api_logs   │  │              │  │        ││
│  └──────────────┘  └──────────────┘  └────────┘│
│                                                  │
│  User: ulm_user    User: app1_user  User: app2 │
│  (grants on ulm)   (grants on app1) (grants...)│
│                                                  │
└─────────────────────────────────────────────────┘
```

### Database Naming Convention

```
<app_name>_db

Examples:
- ulm_db
- inventory_db
- crm_db
- reports_db
```

### User & Permissions Strategy

```sql
-- For each app, create dedicated DB user
CREATE DATABASE inventory_db;
CREATE USER inventory_user WITH PASSWORD '<secure-password>';

-- Grant only to own database
GRANT ALL PRIVILEGES ON DATABASE inventory_db TO inventory_user;
GRANT ALL ON SCHEMA public TO inventory_user;

-- No cross-database access!
-- If app needs ULM data → go through ULM API
```

### When App Needs ULM Data

**❌ Don't do this:** Direct DB queries across databases

```python
# BAD: Direct cross-database query
SELECT u.email, o.total
FROM ulm_db.users u
JOIN inventory_db.orders o ON o.user_id = u.id
```

**✅ Do this:** API calls to ULM

```python
# GOOD: API call to ULM
user = await ulm_client.get_user(user_id)
orders = await db.query(Order).filter_by(user_id=user_id).all()
return {
    'user': user,
    'orders': orders
}
```

### Migration Strategy

```
Each app has its own migrations/

app1/
├── backend/
│   ├── alembic/
│   │   ├── versions/
│   │   │   ├── 001_initial.py
│   │   │   └── 002_add_products.py
│   │   └── env.py
│   └── ...

app2/
├── backend/
│   ├── alembic/
│   │   ├── versions/
│   │   │   └── 001_initial.py
│   │   └── env.py
│   └── ...
```

**Deployment:**
```bash
# Each app runs own migrations
docker exec app1-backend alembic upgrade head
docker exec app2-backend alembic upgrade head
```

---

## Alternatives Considered

### ❌ Alternative 1: Single Shared Database with Schemas

**Approach:**
```
┌──────────────────────────────────┐
│   Single Database: ovu_db        │
├──────────────────────────────────┤
│  schema: ulm                     │
│    - users, roles, ...           │
│                                  │
│  schema: app1                    │
│    - products, orders, ...       │
│                                  │
│  schema: app2                    │
│    - ...                         │
└──────────────────────────────────┘
```

**Pros:**
- ✅ Single connection pool
- ✅ Easier cross-schema queries (if needed)
- ✅ Single backup process

**Cons:**
- ❌ Coupling: all apps share DB instance
- ❌ Single point of failure
- ❌ Can't scale apps independently
- ❌ Permissions harder to manage (schema-level grants)
- ❌ Migration conflicts (multiple teams working on same DB)

**Why Rejected:** Too much coupling, limits scalability and isolation.

---

### ❌ Alternative 2: Completely Separate Database Servers

**Approach:**
```
ULM App         → PostgreSQL Server 1 (ulm_db)
Inventory App   → PostgreSQL Server 2 (inventory_db)
CRM App         → PostgreSQL Server 3 (crm_db)
```

**Pros:**
- ✅ Complete isolation
- ✅ Can use different DB versions
- ✅ Maximum scalability

**Cons:**
- ❌ Very high infrastructure cost
- ❌ Complex backup strategy
- ❌ Overkill for small/medium apps
- ❌ Harder for local development

**Why Rejected:** Overkill for most OVU apps. Not cost-effective.

---

### ❌ Alternative 3: ULM as Shared User Store + App DBs

**Approach:**
- All apps query ULM database directly for user data
- Each app has own DB for business data

**Pros:**
- ✅ No duplicate user data

**Cons:**
- ❌ Tight coupling to ULM DB schema
- ❌ Breaking changes in ULM affect all apps
- ❌ Security risk: apps have direct DB access to ULM
- ❌ Violates service boundaries

**Why Rejected:** Violates microservices principles, creates tight coupling.

---

## Consequences

### ✅ Positive

1. **Strong Isolation** - Each app independent, can't break others
2. **Security** - DB-level permission boundaries
3. **Scalability** - Each DB can scale independently (read replicas, sharding)
4. **Easy Backups** - Backup per app, restore per app
5. **Clear Ownership** - App team owns their DB
6. **Flexible Technology** - Future apps can use different DB engines (MySQL, MongoDB)

### ⚠️ Negative

1. **No Cross-DB Queries** - Can't JOIN across databases
   - **Mitigation:** Use API calls between services
2. **More Migration Management** - Each app has own migration history
   - **Mitigation:** Standard template makes it easy
3. **Connection Pooling** - More DB connections overall
   - **Mitigation:** Use PgBouncer if needed

### 🚨 Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **DB server overload** | Low | Medium | Monitor connections, use PgBouncer |
| **Inconsistent data** | Medium | Medium | Event-driven sync (future), eventual consistency |
| **Orphaned data** | Low | Low | Proper foreign key handling through API |

---

## Implementation Notes

### Backend Configuration (.env)

```bash
# For app backend
DATABASE_URL=postgresql://inventory_user:password@postgres:5432/inventory_db

# Connection pool settings
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=10
DB_POOL_TIMEOUT=30
```

### SQLAlchemy Setup (Python/FastAPI)

```python
# backend/app/core/database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_timeout=settings.DB_POOL_TIMEOUT,
)

AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
```

### Alembic Configuration

```python
# backend/alembic/env.py
from app.models import Base  # Import all models
from app.core.config import settings

config.set_main_option('sqlalchemy.url', settings.DATABASE_URL)

def run_migrations_online():
    connectable = create_async_engine(
        config.get_main_option('sqlalchemy.url')
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
```

### Docker Compose (Development)

```yaml
# docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql

  app1-backend:
    build: ./app1/backend
    environment:
      DATABASE_URL: postgresql://app1_user:app1_pass@postgres:5432/app1_db
    depends_on:
      - postgres

  app2-backend:
    build: ./app2/backend
    environment:
      DATABASE_URL: postgresql://app2_user:app2_pass@postgres:5432/app2_db
    depends_on:
      - postgres

volumes:
  postgres_data:
```

### Init Script (init-db.sql)

```sql
-- Create databases
CREATE DATABASE ulm_db;
CREATE DATABASE inventory_db;

-- Create users
CREATE USER ulm_user WITH PASSWORD 'ulm_pass';
CREATE USER inventory_user WITH PASSWORD 'inventory_pass';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE ulm_db TO ulm_user;
GRANT ALL PRIVILEGES ON DATABASE inventory_db TO inventory_user;

-- Connect to each DB and grant schema permissions
\c ulm_db
GRANT ALL ON SCHEMA public TO ulm_user;

\c inventory_db
GRANT ALL ON SCHEMA public TO inventory_user;
```

### Migration Workflow

```bash
# Create new migration
cd backend
alembic revision --autogenerate -m "add products table"

# Review generated migration
cat alembic/versions/xxx_add_products_table.py

# Apply migration
alembic upgrade head

# Rollback if needed
alembic downgrade -1
```

---

## Cross-Service Data Access Pattern

When App1 needs user data from ULM:

```python
# backend/app/api/orders.py
from fastapi import APIRouter, Depends
from app.clients.ulm import ULMClient
from app.models import Order

router = APIRouter()

@router.get("/orders/{order_id}")
async def get_order_with_user(
    order_id: int,
    ulm: ULMClient = Depends(),
    db: AsyncSession = Depends(get_db)
):
    # Get order from own DB
    order = await db.get(Order, order_id)
    if not order:
        raise HTTPException(404)

    # Get user from ULM via API
    user = await ulm.get_user(order.user_id)

    return {
        'order': order,
        'user': user
    }
```

---

## Testing Strategy

### Unit Tests

```python
# Use in-memory SQLite for fast tests
@pytest.fixture
async def db_session():
    engine = create_async_engine('sqlite+aiosqlite:///:memory:')
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async_session = sessionmaker(engine, class_=AsyncSession)
    async with async_session() as session:
        yield session
```

### Integration Tests

```python
# Use testcontainers for real PostgreSQL
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope="session")
def postgres():
    with PostgresContainer("postgres:15") as postgres:
        yield postgres

def test_order_creation(postgres):
    # Test against real PostgreSQL
    pass
```

---

## Production Considerations

### Backup Strategy

```bash
# Daily full backup per database
0 2 * * * pg_dump -U postgres -d inventory_db > backup_$(date +%Y%m%d).sql

# Upload to S3
aws s3 cp backup_*.sql s3://ovu-backups/inventory/
```

### Monitoring

```yaml
# Grafana dashboard metrics per database:
- Connection count
- Query duration (p50, p95, p99)
- Slow queries (> 100ms)
- Table sizes
- Index usage
```

### Scaling

When app grows:
```
Option 1: Vertical Scaling
- Increase DB instance size (more CPU, RAM)

Option 2: Read Replicas
- Create read replica for heavy read queries

Option 3: Sharding (if really needed)
- Shard by tenant_id or region
```

---

## References

- [Database per Service Pattern](https://microservices.io/patterns/data/database-per-service.html)
- [PostgreSQL Multi-Database Management](https://www.postgresql.org/docs/15/managing-databases.html)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)

---

## Status History

- **2025-12-16:** Proposed by Software Architect
- **2025-12-16:** Reviewed by DevOps & DBA
- **2025-12-16:** ✅ **Accepted**

---

**Related ADRs:**
- ADR-001: Session Management Strategy
- ADR-006: (Future) Event-Driven Data Sync

