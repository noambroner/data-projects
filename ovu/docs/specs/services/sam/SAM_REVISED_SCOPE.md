# 🗺️ SAM (System Mapping Manager) - Revised Scope

**תאריך:** 2025-12-20
**גרסה:** 2.0 (Monitoring Removed)

---

## 🎯 Clear Separation of Concerns

### SAM = System MAPPING Manager 🗺️
**תפקיד:** מיפוי ותיעוד המערכת

**מה SAM עושה:**
- ✅ רישום אפליקציות (Registry)
- ✅ תיעוד אפליקציות (Documentation)
- ✅ מיפוי dependencies (Relationships)
- ✅ מידע סטטי (URLs, endpoints, purposes)
- ✅ Service Discovery (איפה נמצא מה)
- ✅ חיפוש ונווט במערכת

**מה SAM לא עושה:**
- ❌ בדיקות בריאות (Health Checks)
- ❌ מוניטורינג ביצועים
- ❌ Alerts
- ❌ Uptime tracking
- ❌ Real-time status

---

### SMM = System Monitoring Manager 📊
**תפקיד:** מוניטורינג ובריאות המערכת (יוקם בעתיד)

**מה SMM יעשה:**
- ✅ Health checks (ping apps)
- ✅ Performance metrics
- ✅ Uptime tracking
- ✅ Alerts & notifications
- ✅ System status dashboard
- ✅ Historical data & trends

---

## 🏗️ SAM Architecture (Revised)

```
┌─────────────────────────────────────┐
│         SAM (Mapping Only)          │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Apps Registry                │  │
│  │  ├─ Name, Description         │  │
│  │  ├─ URLs (Frontend/Backend)   │  │
│  │  ├─ Ports                     │  │
│  │  ├─ Owner/Team                │  │
│  │  ├─ Version                   │  │
│  │  ├─ Created/Updated dates     │  │
│  │  └─ Category                  │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Documentation Hub            │  │
│  │  ├─ Purpose & Goals           │  │
│  │  ├─ API Endpoints list        │  │
│  │  ├─ Integration guides        │  │
│  │  └─ Usage examples            │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Dependency Graph             │  │
│  │  ├─ Visual map                │  │
│  │  ├─ Relationships             │  │
│  │  └─ Integration points        │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Search & Discovery           │  │
│  │  ├─ Full-text search          │  │
│  │  ├─ Filters & categories      │  │
│  │  └─ Quick links               │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## ✅ Benefits of Separation

| Aspect | Benefit |
|--------|---------|
| **Focus** | כל אפליקציה מומחית במה שהיא עושה |
| **Performance** | SAM קל יותר, מהיר יותר |
| **Maintenance** | קל יותר לתחזק ולפתח |
| **Scalability** | כל אחת scale בנפרד |
| **Reliability** | אם SMM נופל, SAM ממשיך לעבוד |
| **Team Structure** | צוותים שונים יכולים לעבוד על כל אחת |

---

## 📊 Integration: SAM ↔ SMM

### איך הן עובדות ביחד:

```
┌──────────┐              ┌──────────┐
│   SAM    │◄────reads────┤   SMM    │
│ (Static) │              │ (Dynamic)│
└──────────┘              └──────────┘
     │                         │
     │                         │
     ▼                         ▼
  "What"                    "How"
  "Where"                   "Health"
  "Why"                     "Performance"
```

**Example User Journey:**

1. **User opens SAM:**
   - רואה רשימת אפליקציות
   - רואה תיעוד של כל אפליקציה
   - רואה dependency graph

2. **User clicks "View Health" on an app:**
   - SAM redirects/embeds → SMM
   - SMM מציג status, metrics, alerts

3. **Integration:**
   - SAM יכול להציג status badge מ-SMM (via API)
   - אבל ה-logic של checking נמצא ב-SMM

---

## 🎯 SAM Revised Features

### Phase 1: MVP (Focus on Mapping)

**Core Features:**
1. ✅ **App Registry (CRUD)**
   - Add/edit/delete apps
   - Name, description, URLs
   - Owner, version, category

2. ✅ **System Map View**
   - List of all apps
   - Grid/List toggle
   - App cards with basic info

3. ✅ **App Detail Page**
   - Full description
   - URLs & ports
   - API endpoints list (static)
   - Dependencies list

4. ✅ **Search & Filter**
   - Search by name
   - Filter by category
   - Filter by owner/team

5. ✅ **Dependency Graph**
   - Visual representation
   - Interactive (click to navigate)
   - Shows relationships

6. ✅ **Documentation Section**
   - Markdown support
   - Code examples
   - Integration guides

---

### Phase 2: Enhanced Documentation

**Enhanced Features:**
1. ✅ **API Documentation Viewer**
   - OpenAPI/Swagger integration
   - Interactive API explorer
   - Request/response examples

2. ✅ **Version History**
   - Track app versions
   - Changelog per version
   - Migration guides

3. ✅ **Integration Templates**
   - "How to integrate with X"
   - Code snippets
   - Best practices

4. ✅ **Tags & Categories**
   - Custom tags
   - Multi-category support
   - Tag-based search

5. ✅ **Favorites & Recents**
   - Personal favorites
   - Recently viewed
   - Quick access

---

### Phase 3: Advanced Features

**Advanced Features:**
1. ✅ **Auto-Discovery**
   - Apps register themselves on startup
   - Auto-update metadata
   - Self-documenting

2. ✅ **API Contract Validation**
   - Compare expected vs actual APIs
   - Breaking changes detection
   - Version compatibility check

3. ✅ **Collaborative Documentation**
   - Comments on apps
   - Q&A section
   - Community contributions

4. ✅ **Export & Reports**
   - System architecture diagram
   - PDF reports
   - API for external tools

---

## 💾 SAM Data Model (Revised)

```typescript
// Core model - NO health/status fields
interface OVUApp {
  // Identity
  id: string;
  name: string;              // "sam"
  displayName: string;       // "System Mapping Manager"
  description: string;
  purpose: string;           // "Maps and documents OVU ecosystem"

  // URLs & Endpoints
  frontendUrl: string;       // "http://localhost:3005"
  backendUrl: string;        // "http://localhost:8005"
  apiDocsUrl?: string;       // "http://localhost:8005/docs"
  repositoryUrl?: string;    // GitHub URL

  // Organization
  category: 'core' | 'utility' | 'feature' | 'service';
  owner: string;             // "Team Name" or person
  team?: string;

  // Versioning
  version: string;           // "1.0.0"
  versionHistory?: Version[];

  // Dependencies (mapping only)
  dependencies: string[];    // App IDs this app depends on
  dependents?: string[];     // Apps that depend on this

  // Access Control
  requiredRoles: string[];   // ['admin', 'developer']
  isPublic: boolean;         // visible to all?

  // Documentation
  documentation?: {
    readme: string;          // Markdown
    changelog: string;
    guides: Guide[];
    apiEndpoints: APIEndpoint[];
  };

  // Metadata
  tags: string[];
  ports: {
    frontend?: number;
    backend?: number;
  };

  // Timestamps
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
  lastModifiedBy: string;

  // ❌ REMOVED - These go to SMM:
  // status, health, uptime, lastChecked, metrics, alerts
}

interface Version {
  version: string;
  releaseDate: Date;
  changelog: string;
  breaking: boolean;
}

interface APIEndpoint {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  path: string;
  description: string;
  requiresAuth: boolean;
  roles?: string[];
  requestSchema?: object;
  responseSchema?: object;
  examples?: {
    request: string;
    response: string;
  };
}

interface Guide {
  title: string;
  content: string;  // Markdown
  category: 'integration' | 'setup' | 'tutorial';
}
```

---

## 🎨 SAM UI (Revised)

### Homepage - Focus on Discovery

```
┌────────────────────────────────────────────┐
│  🗺️ SAM - System Map       🔍 [Search...]  │
├────────────────────────────────────────────┤
│                                            │
│  📊 Quick Stats                            │
│  ┌──────────────────────────────────────┐  │
│  │  4 Apps • 2 Core • 1 Utility • 1 Feature│
│  │  Last Updated: 5 min ago             │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  🎯 My Favorites                 [View All]│
│  ┌─────────┐  ┌─────────┐  ┌─────────┐   │
│  │ 🔐 ULM  │  │ 👤 AAM  │  │ 🗺️ SAM  │   │
│  │ Core    │  │ Core    │  │ Utility │   │
│  │ v2.0.0  │  │ v1.5.0  │  │ v1.0.0  │   │
│  │         │  │         │  │         │   │
│  │ [Docs]  │  │ [Docs]  │  │ [Docs]  │   │
│  └─────────┘  └─────────┘  └─────────┘   │
│                                            │
│  🔗 Dependency Graph              [Expand] │
│  ┌──────────────────────────────────────┐  │
│  │            ULM                       │  │
│  │             ↓                        │  │
│  │      ┌──────┴──────┐                │  │
│  │      ↓             ↓                │  │
│  │     AAM           SAM               │  │
│  │                    ↓                │  │
│  │                  [SMM]              │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  📚 Categories                             │
│  [Core Systems] [Utilities] [Features]    │
│                                            │
└────────────────────────────────────────────┘
```

### App Detail Page

```
┌────────────────────────────────────────────┐
│  ← Back to Map        🗺️ SAM v1.0.0        │
├────────────────────────────────────────────┤
│                                            │
│  System Mapping Manager                    │
│  📝 Maps and documents the OVU ecosystem   │
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │ 📍 Quick Info                        │  │
│  │ • Frontend: http://localhost:3005    │  │
│  │ • Backend:  http://localhost:8005    │  │
│  │ • Owner:    Core Team                │  │
│  │ • Category: Utility                  │  │
│  │ • Tags:     documentation, mapping   │  │
│  └──────────────────────────────────────┘  │
│                                            │
│  [Overview] [API Docs] [Dependencies]     │
│  [Guides] [Changelog]                     │
│                                            │
│  📖 Overview                               │
│  SAM provides a centralized view of all   │
│  OVU applications, their relationships... │
│                                            │
│  🔗 Dependencies                           │
│  Depends on:                              │
│  • ULM (Authentication)                   │
│                                            │
│  Used by:                                 │
│  • All OVU developers                     │
│                                            │
│  📡 API Endpoints                          │
│  GET  /api/v1/apps      List all apps     │
│  POST /api/v1/apps      Register new app  │
│  GET  /api/v1/graph     Dependency graph  │
│                                            │
│  [View Full API Docs →]                   │
│                                            │
│  💡 Quick Actions                          │
│  [Open Frontend] [Open Backend]           │
│  [View API Docs] [Edit Info]              │
│                                            │
│  ℹ️  Want to see this app's health?       │
│     → [Open in SMM (Monitoring)] ←        │
│                                            │
└────────────────────────────────────────────┘
```

---

## 🔗 SAM ↔ SMM Integration Points

### 1. Link from SAM to SMM
```typescript
// In SAM app detail page
<button onClick={() => window.open(`${SMM_URL}/apps/${appId}`)}>
  View Health & Monitoring →
</button>
```

### 2. Optional Status Badge (Light Integration)
```typescript
// SAM can fetch basic status from SMM (optional)
// But doesn't do the health checking itself

const { data: status } = useQuery(
  ['app-status', appId],
  () => smmAPI.getAppStatus(appId),
  { refetchInterval: 60000 } // every minute
);

// Display simple badge
{status === 'healthy' && <Badge color="green">🟢</Badge>}
```

### 3. Cross-Navigation
```typescript
// In SMM, link back to SAM for docs
<Link to={`${SAM_URL}/apps/${appId}`}>
  📖 View Documentation in SAM
</Link>
```

---

## 📋 Updated Implementation Checklist

### SAM MVP (Week 1)
- [ ] Create SAM from template
- [ ] Backend: Apps CRUD API (no health fields)
- [ ] Frontend: App registry UI
- [ ] Frontend: System map view
- [ ] Frontend: Search functionality
- [ ] Frontend: Dependency graph visualization
- [ ] Integration: ULM authentication
- [ ] Documentation: Markdown editor
- [ ] Testing: Unit + integration

### Register Initial Apps
- [ ] Register ULM
- [ ] Register AAM
- [ ] Register SAM (self-registration)
- [ ] Document dependencies

### Documentation
- [ ] User guide
- [ ] API documentation
- [ ] Integration guide for new apps
- [ ] How to auto-register guide

---

## 🎯 Success Metrics (Revised)

**Documentation Coverage:**
- % of apps with complete documentation
- % of APIs documented
- % of dependencies mapped

**Usage Metrics:**
- Time to find app info (< 30 seconds)
- Search success rate
- Developer satisfaction

**System Metrics:**
- Apps registered
- Documentation pages created
- API endpoints documented

---

## 💡 Key Takeaways

### SAM is now...
✅ **Lighter** - no real-time monitoring overhead
✅ **Focused** - pure documentation & mapping
✅ **Faster** - no health checks slowing it down
✅ **Simpler** - easier to build & maintain
✅ **Scalable** - can handle 100s of apps easily

### Future: SAM + SMM Together
```
SAM answers: "What is it? Where is it? How to use it?"
SMM answers: "Is it up? Is it fast? Any problems?"
```

**Perfect separation! 🎯**

---

## 🚀 Ready to Build?

```bash
cd /home/noam/projects/ovu
./scripts/new-app.sh --name sam \
  --color blue \
  --frontend-port 3005 \
  --backend-port 8005
```

**זה הכל! SAM מוכן להיבנות.** 🗺️✨

---

*Updated: 2025-12-20*
*Monitoring features moved to future SMM app*

