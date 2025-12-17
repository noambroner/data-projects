# 🏗️ Projects Architecture & Development Environment Specification
## Enterprise-Grade Multi-Project Development Environment

**Document Version:** 1.1.0  
**Last Updated:** December 13, 2025  
**Owner:** Senior Software Architect  
**Target Audience:** VIBE Coders, Full-Stack Developers, DevOps Engineers  

---

## 🚀 מתחילים? התחל כאן!

> **למשתמשים בלי רקע טכני או למי שרוצה להתחיל מהר:**

| מה אתה צריך | קרא את זה |
|-------------|-----------|
| **איך עובדים עם Cursor** | 📖 [CURSOR_QUICK_START.md](./CURSOR_QUICK_START.md) |
| **תבנית לסיום סשן** | 📝 [SESSION_HANDOFF_TEMPLATE.md](./SESSION_HANDOFF_TEMPLATE.md) |
| **הקמת פרויקט OVU** | ✅ [OVU_SETUP_CHECKLIST.md](./OVU_SETUP_CHECKLIST.md) |

**המסמך הזה הוא מקיף ומיועד לקריאה מעמיקה. אם אתה רוצה להתחיל לעבוד — התחל מהמדריכים למעלה.**

---

## 📚 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Philosophy](#architecture-philosophy)
3. [Directory Structure](#directory-structure)
4. [Project Lifecycle Management](#project-lifecycle-management)
5. [VIBE Coding Environment](#vibe-coding-environment)
6. [Multi-Platform Development](#multi-platform-development)
7. [Git Worktrees Strategy](#git-worktrees-strategy)
8. [AI-Assisted Development](#ai-assisted-development)
9. [DevOps & CI/CD Integration](#devops--cicd-integration)
10. [Security & Compliance](#security--compliance)
11. [Monitoring & Observability](#monitoring--observability)
12. [Team Collaboration](#team-collaboration)
13. [Appendix: Templates & Scripts](#appendix-templates--scripts)

---

## 🎯 Executive Summary

This document defines the **enterprise-grade development environment architecture** for managing multiple projects with a focus on:

- **VIBE Coding**: Visual, Interactive, and Behavior-driven Development
- **Full-Stack Development**: Backend (FastAPI, Node.js), Frontend (React, Flutter), Mobile (Flutter, React Native)
- **Multi-Project Management**: Scalable structure for 10+ concurrent projects
- **AI-First Development**: Cursor IDE, Cloud Agents, Context Management
- **DevOps Ready**: Docker, Kubernetes, CI/CD, Infrastructure as Code

### Key Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Time to onboard new developer | < 30 minutes | TBD |
| Time to create new project | < 5 minutes | TBD |
| AI Context Accuracy | > 95% | TBD |
| Build Time (average) | < 3 minutes | TBD |
| Deployment Frequency | Multiple per day | TBD |

---

## 🧠 Architecture Philosophy

### Core Principles

1. **Separation of Concerns**
   - Global configurations for cross-project standards
   - Project-level configurations for project-specific needs
   - Repository-level configurations for technical implementation

2. **Convention over Configuration**
   - Standardized naming conventions
   - Predictable directory structures
   - Automated scaffolding

3. **DRY (Don't Repeat Yourself)**
   - Shared templates and scripts
   - Reusable component libraries
   - Centralized documentation

4. **AI-First Development**
   - Every file is AI-readable
   - Context files for project understanding
   - Development journals for continuity

5. **DevOps as Code**
   - Infrastructure as Code (Terraform, Pulumi)
   - CI/CD as Code (GitHub Actions, GitLab CI)
   - Configuration as Code (Ansible, Docker Compose)

---

## ✅ Adoption Model (Must / Should / Nice)

This spec covers enterprise-scale practices. To keep it **simple to adopt** (and consistent across many projects), we define 3 adoption levels:

### Adoption Levels

- **Level 0 — Baseline (MUST for every project)**: low friction, enforced by scripts/hooks/CI.
- **Level 1 — VIBE Full (SHOULD for UI-heavy projects)**: Storybook + design tokens pipeline + visual regression.
- **Level 2 — Enterprise (NICE / as needed)**: DR/HA, advanced governance, SLOs, deep compliance.

### Level 0 — Baseline (MUST)

Every project must include:

- **Project root essentials**
  - `PROJECT_README.md` (how to run, env vars, key URLs, contribution rules)
  - `<project>-workspace.code-workspace` (Multi-root workspace)
  - `.project-cursorrules` (project rules extending global)
  - `scripts/` with:
    - `dev` (run local dev)
    - `quality` (lint + format + typecheck)
    - `test` (unit/integration baseline)
    - `session-end` (session handoff)
- **Repo/worktree essentials**
  - `.cursorrules` + `.cursorignore` + `AI_AGENT_README.md`
- **Guardrails (enforcement)**
  - pre-commit: run `scripts/quality` (or equivalent)
  - CI: block merges when `quality` fails

### Global Standards Versioning (MUST)

To prevent “standards drift” across projects:

- Treat `/home/noam/projects/.global-config` as the **source of truth** and version it (tags + changelog).
- Each project should record which global version it is aligned with (e.g., a `GLOBAL_STANDARDS_VERSION` file or a line in `PROJECT_README.md`).

### Why levels matter

Without a clear Baseline, teams will pick different subsets of rules → **process drift** and **UI inconsistency** across projects.

## 📁 Directory Structure

### Level 1: Global Workspace Root

```
/home/noam/projects/                              ← Root for all projects
│
├── 📁 .global-config/                            ← GLOBAL (Source of Truth: standards, configs, docs)
│   ├── PROJECT_ARCHITECTURE_SPEC.md              ← This document
│   ├── GLOBAL_README.md                          ← Quick start guide
│   ├── CHANGELOG.md                              ← Global changes
│   ├── .cursorrules-template                     ← Base AI rules
│   ├── .gitignore-templates/                     ← By tech stack
│   │   ├── node.gitignore
│   │   ├── python.gitignore
│   │   ├── flutter.gitignore
│   │   └── docker.gitignore
│   ├── cursor-settings-template.json             ← IDE settings
│   ├── workspace-template.code-workspace         ← Workspace template
│   ├── eslintrc-template.json                    ← Linting (JS/TS)
│   ├── prettierrc-template.json                  ← Formatting
│   ├── tsconfig-template.json                    ← TypeScript base
│   ├── pyproject-template.toml                   ← Python base
│   ├── docker-compose-template.yml               ← Docker template
│   └── dockerfile-templates/                     ← By language
│       ├── Dockerfile.node
│       ├── Dockerfile.python
│       └── Dockerfile.flutter
│
├── 📁 .global-scripts/                           ← Global automation
│   ├── create-new-project.sh                     ← Scaffold new project
│   ├── setup-worktrees.sh                        ← Initialize worktrees
│   ├── open-project-workspace.sh                 ← Open in Cursor
│   ├── sync-project-from-main.sh                 ← Sync all repos
│   ├── backup-all-projects.sh                    ← Backup utility
│   ├── generate-project-report.sh                ← Status reports
│   └── utils/                                    ← Utility functions
│       ├── git-helpers.sh
│       ├── docker-helpers.sh
│       └── ai-helpers.sh
│
├── 📁 .global-docs/                              ← Global documentation
│   ├── CODING_STANDARDS.md                       ← Code style guide
│   ├── GIT_WORKFLOW.md                           ← Git conventions
│   ├── CI_CD_GUIDE.md                            ← CI/CD practices
│   ├── SECURITY_GUIDELINES.md                    ← Security best practices
│   ├── DEPLOYMENT_PLAYBOOK.md                    ← Deployment procedures
│   ├── INCIDENT_RESPONSE.md                      ← Incident handling
│   ├── API_DESIGN_GUIDE.md                       ← API standards
│   └── MOBILE_DEV_GUIDE.md                       ← Mobile best practices
│
├── 📁 .global-templates/                         ← Code templates
│   ├── component-templates/                      ← UI components
│   │   ├── react/
│   │   │   ├── functional-component.tsx
│   │   │   ├── hook.ts
│   │   │   └── context.tsx
│   │   └── flutter/
│   │       ├── stateless-widget.dart
│   │       └── stateful-widget.dart
│   ├── api-templates/                            ← API endpoints
│   │   ├── fastapi-route.py
│   │   └── express-route.ts
│   ├── test-templates/                           ← Testing
│   │   ├── jest.test.ts
│   │   ├── pytest.py
│   │   └── flutter_test.dart
│   └── documentation-templates/
│       ├── README-template.md
│       ├── API-DOC-template.md
│       └── CHANGELOG-template.md
│
├── 📁 .global-shared/                            ← Shared resources
│   ├── design-system/                            ← Design tokens
│   │   ├── colors.json
│   │   ├── typography.json
│   │   ├── spacing.json
│   │   └── breakpoints.json
│   ├── icons/                                    ← Icon library
│   ├── assets/                                   ← Shared assets
│   └── utilities/                                ← Utility functions
│       ├── javascript/
│       ├── python/
│       └── dart/
│
└── 📁 .global-monitoring/                        ← Monitoring configs
    ├── prometheus/
    ├── grafana/
    └── elk/
```

---

### Level 2: Project Structure

```
/home/noam/projects/<project-name>/               ← Individual project root
│
├── 📄 <project>-workspace.code-workspace         ← Cursor workspace
├── 📄 PROJECT_README.md                          ← Project overview
├── 📄 ARCHITECTURE.md                            ← Architecture docs
├── 📄 CHANGELOG.md                               ← Project changes
├── 📄 .project-cursorrules                       ← Project AI rules
│
├── 📁 repositories/                              ← Git repos (main branch)
│   ├── <service-1>/
│   ├── <service-2>/
│   └── <shared>/
│
├── 📁 worktrees/                                 ← Active development (dev branch)
│   ├── <service-1>-work/
│   ├── <service-2>-work/
│   └── <shared>-work/
│
├── 📁 scripts/                                   ← Project scripts
│   ├── create-component.sh
│   ├── run-all-services.sh
│   ├── sync-all-repos.sh
│   ├── deploy-staging.sh
│   ├── deploy-production.sh
│   ├── backup-database.sh
│   └── run-tests-all.sh
│
├── 📁 docs/                                      ← Project documentation
│   ├── api/
│   │   ├── openapi.yaml
│   │   └── postman-collection.json
│   ├── architecture/
│   │   ├── system-design.md
│   │   ├── database-schema.md
│   │   └── diagrams/
│   ├── deployment/
│   │   ├── deployment-guide.md
│   │   └── infrastructure.md
│   └── development/
│       ├── setup-guide.md
│       ├── contribution-guide.md
│       └── troubleshooting.md
│
├── 📁 infrastructure/                            ← IaC & DevOps
│   ├── terraform/
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   ├── staging/
│   │   │   └── production/
│   │   └── modules/
│   ├── kubernetes/
│   │   ├── base/
│   │   └── overlays/
│   ├── docker/
│   │   ├── docker-compose.dev.yml
│   │   ├── docker-compose.staging.yml
│   │   └── docker-compose.prod.yml
│   ├── ansible/
│   └── scripts/
│
├── 📁 .storybook-shared/                         ← Storybook config
│   ├── main.ts
│   ├── preview.ts
│   └── manager.ts
│
├── 📁 tests/                                     ← Integration tests
│   ├── e2e/
│   ├── integration/
│   └── performance/
│
└── 📁 .monitoring/                               ← Monitoring & logs
    ├── logs/
    ├── metrics/
    └── dashboards/
```

---

### Level 3: Repository Structure (Service/App)

```
/home/noam/projects/<project>/worktrees/<service>-work/
│
├── 📄 .cursorrules                               ← Service-specific AI rules
├── 📄 .cursorignore                              ← Ignore patterns
├── 📄 AI_AGENT_README.md                         ← Quick AI reference
├── 📄 README.md                                  ← Service documentation
├── 📄 CHANGELOG.md                               ← Service changes
│
├── 📁 .vscode/                                   ← IDE settings
│   ├── settings.json
│   ├── launch.json
│   ├── tasks.json
│   └── extensions.json
│
├── 📁 .github/                                   ← CI/CD
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── cd-staging.yml
│   │   └── cd-production.yml
│   └── CODEOWNERS
│
├── 📁 backend/                                   ← Backend code
│   ├── app/
│   │   ├── api/                                  ← API routes
│   │   ├── core/                                 ← Core config
│   │   ├── models/                               ← Database models
│   │   ├── schemas/                              ← Pydantic/DTO schemas
│   │   ├── services/                             ← Business logic
│   │   ├── repositories/                         ← Data access
│   │   ├── middleware/                           ← Middleware
│   │   └── utils/                                ← Utilities
│   ├── tests/
│   ├── migrations/                               ← DB migrations
│   ├── requirements.txt / package.json
│   ├── Dockerfile
│   └── .env.example
│
├── 📁 frontend/                                  ← Frontend code
│   ├── react/                                    ← React Web App
│   │   ├── src/
│   │   │   ├── components/                       ← UI components
│   │   │   ├── pages/                            ← Page components
│   │   │   ├── hooks/                            ← Custom hooks
│   │   │   ├── contexts/                         ← React contexts
│   │   │   ├── services/                         ← API clients
│   │   │   ├── utils/                            ← Utilities
│   │   │   ├── types/                            ← TypeScript types
│   │   │   ├── assets/                           ← Static assets
│   │   │   └── styles/                           ← Global styles
│   │   ├── public/                               ← Public assets
│   │   ├── .storybook/                           ← Storybook config
│   │   ├── tests/
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   ├── vite.config.ts
│   │   └── Dockerfile
│   │
│   └── flutter/                                  ← Flutter App (Web/Mobile)
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app/                              ← App config
│       │   ├── features/                         ← Feature modules
│       │   ├── widgets/                          ← Reusable widgets
│       │   ├── services/                         ← API & services
│       │   ├── models/                           ← Data models
│       │   ├── utils/                            ← Utilities
│       │   └── theme/                            ← Theme config
│       ├── test/
│       ├── assets/
│       ├── pubspec.yaml
│       └── Dockerfile
│
└── 📁 shared/                                    ← Shared resources
    ├── interface-resources/                      ← UI components
    ├── localization/                             ← i18n files
    └── react-components/                         ← Shared React components
```

---

## 🔄 Project Lifecycle Management

### Phase 1: Project Initialization

```bash
# Create new project with full scaffolding
.global-scripts/create-new-project.sh "ProjectName" \
  --type="fullstack" \
  --backend="fastapi" \
  --frontend="react,flutter" \
  --database="postgresql" \
  --monitoring="prometheus,grafana"

# This creates:
# - Project directory structure
# - Git repositories
# - Worktrees
# - CI/CD pipelines
# - Docker configs
# - Documentation templates
```

### Phase 2: Development Setup

```bash
# Setup development environment
cd /home/noam/projects/projectname
./scripts/setup-dev-environment.sh

# This:
# - Installs dependencies
# - Sets up databases
# - Configures environment variables
# - Initializes Storybook
# - Sets up Git hooks
# - Configures AI contexts
```

### Phase 3: Active Development

```bash
# Open project workspace in Cursor
cursor projectname-workspace.code-workspace

# Run all services
./scripts/run-all-services.sh

# This starts:
# - Backend APIs (with hot reload)
# - Frontend apps (with hot reload)
# - Storybook (component preview)
# - Database (Docker)
# - Redis/Queue (if needed)
```

### Phase 4: Testing & QA

```bash
# Run all tests
./scripts/run-tests-all.sh

# This runs:
# - Unit tests (backend + frontend)
# - Integration tests
# - E2E tests
# - Performance tests
# - Security scans
```

### Phase 5: Deployment

```bash
# Deploy to staging
./scripts/deploy-staging.sh

# Deploy to production (after approval)
./scripts/deploy-production.sh
```

### Phase 6: Monitoring & Maintenance

```bash
# Check project health
./scripts/health-check.sh

# View logs
./scripts/view-logs.sh [service]

# Backup databases
./scripts/backup-database.sh
```

---

## 🎨 VIBE Coding Environment

### What is VIBE Coding?

**VIBE** = **V**isual **I**nteractive **B**ehavior-driven **E**ngineering

A modern development approach that emphasizes:
- **Visual Development**: See changes in real-time
- **Interactive Design**: Component playground (Storybook)
- **Behavior-Driven**: Test behaviors, not implementations
- **AI-Enhanced**: Context-aware AI assistance

### VIBE Stack Components

#### 1. Storybook - Component Playground

```bash
# Shared Components Storybook
cd worktrees/shared-work
npm run storybook  # Port 6006

# Service-specific Storybook
cd worktrees/service-work/frontend/react
npm run storybook  # Port 6007
```

**Benefits:**
- ✅ Isolated component development
- ✅ Visual regression testing
- ✅ Component documentation
- ✅ Design system enforcement
- ✅ Stakeholder demos

#### 2. Hot Reload Architecture

```yaml
# All services with hot reload
Backend:
  - FastAPI: uvicorn with --reload
  - Node.js: nodemon
  
Frontend:
  - React: Vite HMR
  - Flutter Web: flutter run -d chrome
  
Mobile:
  - Flutter: Hot reload on save
```

#### 3. Live Component Preview

```typescript
// Every component has:
ComponentName/
├── ComponentName.tsx           ← Implementation
├── ComponentName.css           ← Styles (CSS Variables only!)
├── ComponentName.stories.tsx   ← Storybook stories
├── ComponentName.test.tsx      ← Unit tests
└── README.md                   ← Documentation
```

#### 4. Design System Enforcement

```css
/* Global CSS Variables (defined once, used everywhere) */
:root {
  /* Colors */
  --primary-color: #3b82f6;
  --primary-hover: #2563eb;
  --bg-color: var(--bg-color-light);
  --surface-color: var(--surface-color-light);
  --text-color: var(--text-color-light);
  
  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  
  /* Typography */
  --font-size-sm: 12px;
  --font-size-base: 14px;
  --font-size-lg: 16px;
  --font-size-xl: 20px;
  --font-size-2xl: 24px;
  
  /* Borders */
  --border-radius: 8px;
  --border-color: rgba(0, 0, 0, 0.1);
}

/* RULE: Never use hardcoded colors! Always use CSS Variables! */
```

#### 4.1 UI Contract (MUST)

To keep UI consistent across pages, services, and projects, define a single “UI Contract”:

- **Source of truth**: `design-system/tokens.json` (or `colors.json`, `spacing.json`, `typography.json`)
- **Generated outputs** (do not hand-edit):
  - Web: `css-variables.css`
  - Flutter: `dart-theme.dart`
- **Allowed exception**: only the generated tokens file(s) may contain raw `#RRGGBB` / `rgb()` values.
- **Enforcement (Level 1 recommended, Level 0 optional)**:
  - stylelint/ESLint checks that block hardcoded colors/spacing in component CSS
  - Storybook for shared components
  - Visual regression for shared components (Storybook snapshots)

#### 5. Component Generator

```bash
# Create new component with all files
.global-scripts/create-component.sh \
  --name="UserCard" \
  --type="functional" \
  --project="ovu" \
  --service="ulm" \
  --path="components"

# Creates:
# - UserCard.tsx (with template)
# - UserCard.css (with CSS Variables)
# - UserCard.stories.tsx (with examples)
# - UserCard.test.tsx (with tests)
# - README.md (with documentation)
```

---

## 📱 Multi-Platform Development

### Supported Platforms

| Platform | Technology | Hot Reload | Storybook | Testing |
|----------|-----------|------------|-----------|---------|
| **Web** | React + Vite | ✅ | ✅ | Vitest + Testing Library |
| **Mobile (iOS)** | Flutter | ✅ | ⚠️ Flutter Preview | Flutter Test |
| **Mobile (Android)** | Flutter | ✅ | ⚠️ Flutter Preview | Flutter Test |
| **Web (Flutter)** | Flutter Web | ✅ | ⚠️ Flutter Preview | Flutter Test |
| **Desktop** | Flutter Desktop | ✅ | ⚠️ Flutter Preview | Flutter Test |

### Development Workflows

#### React Web Development

```bash
# Terminal 1: Backend
cd worktrees/service-work/backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8001

# Terminal 2: Frontend
cd worktrees/service-work/frontend/react
npm run dev  # Vite dev server on port 5173

# Terminal 3: Storybook
npm run storybook  # Component playground on port 6006
```

#### Flutter Mobile Development

```bash
# Terminal 1: Backend
cd worktrees/service-work/backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8001

# Terminal 2: Flutter (iOS Simulator)
cd worktrees/service-work/frontend/flutter
flutter run -d ios

# OR: Flutter (Android Emulator)
flutter run -d android

# OR: Flutter Web
flutter run -d chrome
```

### Shared Code Strategy

```
/worktrees/shared-work/
├── interface-resources/           ← Shared UI components
│   ├── react/                     ← React components
│   └── flutter/                   ← Flutter widgets
├── localization/                  ← i18n files (3 languages)
│   ├── en.json
│   ├── he.json
│   └── ar.json
├── api-clients/                   ← Generated API clients
│   ├── typescript/
│   ├── dart/
│   └── python/
└── design-system/                 ← Design tokens
    ├── tokens.json                ← Source of truth
    ├── css-variables.css          ← For web
    └── dart-theme.dart            ← For Flutter
```

### API Gateway / BFF Pattern (Recommended)

When building both Web and Mobile clients, avoid pushing “one-size-fits-all” APIs directly to clients. Prefer an API Gateway and/or BFF:

```
[Web]    → [Web BFF]    → [API Gateway] → [Services]
[Mobile] → [Mobile BFF] → [API Gateway] → [Services]
```

**Benefits:**
- Optimized payloads per client (Web vs Mobile)
- Centralized auth, rate limiting, API versioning
- Safer evolution of APIs over time (less breaking change risk)

**Start simple:** one Gateway is usually enough; introduce separate BFFs only when client needs diverge.

### Responsive Design

```typescript
// Breakpoints (consistent across all platforms)
const breakpoints = {
  mobile: '0-767px',
  tablet: '768-1023px',
  desktop: '1024-1439px',
  wide: '1440px+'
};

// Usage in React
import { useMediaQuery } from '@/hooks/useMediaQuery';

const isMobile = useMediaQuery('(max-width: 767px)');
```

```dart
// Usage in Flutter
import 'package:flutter/material.dart';

bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < 768;
}
```

---

## 🌲 Git Worktrees Strategy

### Why Worktrees?

**Problem:** Traditional Git workflow requires:
- Switching branches (losing context)
- Stashing changes
- Waiting for build/install after switch

**Solution:** Git Worktrees allow:
- ✅ Multiple branches checked out simultaneously
- ✅ Work on features in parallel
- ✅ No context switching
- ✅ Separate node_modules for each worktree

### Worktree Architecture

```
/repositories/service-name/     ← Main repo (main branch) - DON'T TOUCH!
/worktrees/service-work/        ← Dev branch - ACTIVE DEVELOPMENT
/worktrees/service-feature-A/   ← Feature branch A
/worktrees/service-feature-B/   ← Feature branch B
```

### Worktree Lifecycle

#### 1. Initial Setup

```bash
# Clone repos to repositories/
cd /home/noam/projects/projectname/repositories
git clone git@github.com:user/service-name.git

# Create dev worktree
cd /home/noam/projects/projectname
.global-scripts/setup-worktrees.sh service-name dev
```

#### 2. Create Feature Worktree

```bash
# Create new feature worktree
cd repositories/service-name
git worktree add ../../worktrees/service-feature-auth feature/authentication

# Setup links to shared resources
cd ../../worktrees/service-feature-auth
./scripts/link-shared.sh
```

#### 3. Work on Feature

```bash
# Open in Cursor (automatically in workspace)
cd /home/noam/projects/projectname
cursor projectname-workspace.code-workspace

# Make changes in worktrees/service-feature-auth/
# Git operates independently in each worktree
```

#### 4. Merge & Cleanup

```bash
# When feature is complete
cd worktrees/service-feature-auth
git push origin feature/authentication

# Create PR on GitHub
# After merge, remove worktree
cd repositories/service-name
git worktree remove ../../worktrees/service-feature-auth
```

### Worktree Git Hooks

```bash
# pre-commit hook (auto-installed in all worktrees)
#!/bin/bash
# Replace symlinks with actual files before commit
./scripts/unlink-shared.sh

# post-commit hook
#!/bin/bash
# Restore symlinks after commit
./scripts/restore-links.sh

# post-checkout hook
#!/bin/bash
# Setup symlinks when checking out worktree
./scripts/link-shared.sh
```

### Symlinks for Shared Resources

```bash
# In each worktree:
worktrees/service-work/shared/
├── interface-resources → ../../shared-work/interface-resources (symlink)
├── localization → ../../shared-work/localization (symlink)
└── react-components → ../../shared-work/react-components (symlink)

# Benefits:
# ✅ Edit shared component once
# ✅ Changes appear in all services immediately
# ✅ No manual copying
# ✅ Git hooks handle commit/push
```

---

## 🤖 AI-Assisted Development

### Cursor IDE Configuration

#### Global .cursorrules Template

```markdown
# Global Cursor Rules - All Projects

## Core Principles
1. **Read Before Code**: Always read documentation before making changes
2. **Test-Driven**: Write tests before implementation
3. **Document Changes**: Update docs with every feature
4. **Security First**: Never commit secrets, always validate input
5. **Performance Aware**: Consider performance implications

## File Patterns
- Always use TypeScript for new JavaScript code
- Always use type hints for Python code
- Never use `any` type in TypeScript
- Never use `var` in JavaScript

## Git Workflow
- Conventional Commits: feat:, fix:, docs:, refactor:, test:, chore:
- Branch naming: feature/*, bugfix/*, hotfix/*
- Always pull before push
- Never force push to main/master

## Code Style
- Use Prettier for formatting
- Use ESLint for linting (JavaScript/TypeScript)
- Use Black for Python formatting
- Use dart format for Flutter

## Testing
- Unit test coverage > 80%
- Integration tests for all API endpoints
- E2E tests for critical user flows

## Security
- Never log sensitive data
- Always validate and sanitize user input
- Use parameterized queries (no SQL injection)
- Keep dependencies updated
```

#### Project-Level .cursorrules

```markdown
# Project: OVU System
# Extends: /.global-config/.cursorrules-template

## Project-Specific Rules

### AI Onboarding (MANDATORY)
1. Read Development Guidelines:
   - GET http://backend:8001/api/v1/dev-journal/ai/project-context
2. Read Latest Session:
   - GET http://backend:8001/api/v1/dev-journal/ai/latest-session
3. Confirm understanding before starting

### Design System (CRITICAL)
- **NEVER use hardcoded colors** - Always use CSS Variables
- **NEVER use hardcoded spacing** - Use --spacing-* variables
- **NEVER use inline styles** - Use CSS classes

### API Response Format (MANDATORY)
All API responses must follow:
```json
{
  "success": true,
  "data": { ... },
  "message": "Success message"
}
```

### Deployment Process
- Frontend: Copy to public/ directory
- Backend: Restart systemd service
- Database: Use Alembic migrations only

### Session Handoff (MANDATORY)
After every session:
1. Update `docs/sessions/<YYYY-MM-DD>_<topic>.md` (or `docs/SESSION_HANDOFF.md`)
2. Capture: summary, decisions (ADRs), changed files, next steps, open risks
3. Run `./scripts/session-end` (or equivalent)

### Development Journal (MANDATORY when available)
After every session:
1. Create session record
2. Document all steps
3. Record system state changes
```

#### Service-Level .cursorrules

```markdown
# Service: ULM (User Login Manager)
# Extends: /ovu/.ovu-cursorrules

## Service-Specific Rules

### Tech Stack
- Backend: FastAPI + SQLAlchemy + PostgreSQL
- Frontend: React + Vite + TypeScript
- Mobile: Flutter

### Key Files
- Development Guidelines: frontend/react/src/components/DevelopmentGuidelines/
- API Routes: backend/app/api/
- Database Models: backend/app/models/

### Critical Rules
1. All user passwords must be hashed with bcrypt
2. JWT tokens expire in 24 hours
3. Multi-language support: Hebrew, English, Arabic
4. Full RTL support required

### Testing
- Run tests before every commit: npm test && pytest
```

### AI Context Files

```markdown
# AI_AGENT_README.md (in every worktree)

# Service: [SERVICE_NAME]

## Quick Context
- **What**: [Brief description]
- **Tech Stack**: [Technologies used]
- **Dependencies**: [Other services]

## Before You Start
1. ✅ Read `.cursorrules` in this directory
2. ✅ Read `../../.project-cursorrules`
3. ✅ Read `../../../.global-config/.cursorrules-template`
4. ✅ Check Development Guidelines: [URL]
5. ✅ Check Development Journal: [URL]

## Key Locations
- API Endpoints: `backend/app/api/`
- Database Models: `backend/app/models/`
- React Components: `frontend/react/src/components/`
- Shared Components: `shared/react-components/`

## Common Tasks
- Create Component: `../../scripts/create-component.sh [name]`
- Run Tests: `npm test` (frontend), `pytest` (backend)
- Deploy: `../../scripts/deploy-staging.sh`

## Critical Rules
[Service-specific critical rules]

## Emergency Contacts
- Project Lead: [Name]
- DevOps: [Name]
- On-Call: [Number]
```

### Cloud Agents Configuration

```json
// .cursor/agents.json
{
  "agents": [
    {
      "name": "Architecture Reviewer",
      "role": "Review system design decisions",
      "context": [
        ".global-docs/CODING_STANDARDS.md",
        "{project}/ARCHITECTURE.md"
      ],
      "triggers": ["architecture", "design", "structure"]
    },
    {
      "name": "Security Auditor",
      "role": "Review code for security issues",
      "context": [
        ".global-docs/SECURITY_GUIDELINES.md"
      ],
      "triggers": ["security", "authentication", "authorization", "encryption"]
    },
    {
      "name": "Performance Optimizer",
      "role": "Suggest performance improvements",
      "context": [
        ".global-docs/PERFORMANCE_GUIDE.md"
      ],
      "triggers": ["performance", "optimization", "slow", "cache"]
    },
    {
      "name": "DevOps Assistant",
      "role": "Help with deployment and infrastructure",
      "context": [
        ".global-docs/DEPLOYMENT_PLAYBOOK.md",
        "{project}/infrastructure/"
      ],
      "triggers": ["deploy", "docker", "kubernetes", "ci/cd"]
    }
  ]
}
```

---

## 🚀 DevOps & CI/CD Integration

### CI/CD Pipeline Architecture

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [dev, feature/*]
  pull_request:
    branches: [main, dev]

jobs:
  # 1. Code Quality
  lint-and-format:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run ESLint
        run: npm run lint
      - name: Run Prettier
        run: npm run format:check
      - name: Run Black (Python)
        run: black --check .

  # 2. Security Scan
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run npm audit
        run: npm audit --audit-level=high
      - name: Run Snyk
        run: snyk test
      - name: Run Trivy (Docker)
        run: trivy image app:latest

  # 3. Unit Tests
  test-backend:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
    steps:
      - uses: actions/checkout@v3
      - name: Run pytest
        run: pytest --cov=app --cov-report=xml

  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Vitest
        run: npm test -- --coverage

  # 4. Build
  build:
    runs-on: ubuntu-latest
    needs: [lint-and-format, security-scan, test-backend, test-frontend]
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker Images
        run: docker-compose build
      - name: Push to Registry
        run: docker-compose push

  # 5. Integration Tests
  integration-tests:
    runs-on: ubuntu-latest
    needs: [build]
    steps:
      - name: Run integration tests
        run: npm run test:integration

  # 6. E2E Tests
  e2e-tests:
    runs-on: ubuntu-latest
    needs: [build]
    steps:
      - name: Run Playwright tests
        run: npx playwright test
```

### Deployment Pipeline

```yaml
# .github/workflows/cd-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [dev]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Staging Server
        run: |
          ssh deploy@staging-server "
            cd /var/www/project
            git pull origin dev
            docker-compose -f docker-compose.staging.yml up -d --build
          "
      
      - name: Run Smoke Tests
        run: |
          curl -f https://staging.project.com/health || exit 1
      
      - name: Notify Team
        run: |
          curl -X POST $SLACK_WEBHOOK \
            -d '{"text":"Staging deployment successful!"}'
```

### Infrastructure as Code

```hcl
# infrastructure/terraform/environments/production/main.tf
terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket = "terraform-state"
    key    = "project/production/terraform.tfstate"
    region = "us-east-1"
  }
}

# VPC
module "vpc" {
  source = "../../modules/vpc"
  
  environment = "production"
  cidr_block  = "10.0.0.0/16"
}

# ECS Cluster
module "ecs" {
  source = "../../modules/ecs"
  
  cluster_name = "project-production"
  vpc_id       = module.vpc.vpc_id
  
  services = {
    backend = {
      image = "project/backend:latest"
      cpu   = 1024
      memory = 2048
      replicas = 3
    }
    frontend = {
      image = "project/frontend:latest"
      cpu   = 512
      memory = 1024
      replicas = 2
    }
  }
}

# RDS Database
module "database" {
  source = "../../modules/rds"
  
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.large"
  
  backup_retention_period = 30
  multi_az               = true
}

# CloudFront CDN
module "cdn" {
  source = "../../modules/cloudfront"
  
  origin_domain = module.ecs.alb_dns_name
  price_class   = "PriceClass_All"
}
```

### Docker Architecture

```yaml
# docker-compose.yml (Development)
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "8001:8001"
    volumes:
      - ./backend:/app
      - /app/venv
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/dbname
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    command: uvicorn app.main:app --reload --host 0.0.0.0 --port 8001

  frontend:
    build: ./frontend/react
    ports:
      - "5173:5173"
    volumes:
      - ./frontend/react:/app
      - /app/node_modules
    environment:
      - VITE_API_URL=http://localhost:8001
    command: npm run dev

  storybook:
    build: ./frontend/react
    ports:
      - "6006:6006"
    volumes:
      - ./frontend/react:/app
      - /app/node_modules
    command: npm run storybook

  db:
    image: postgres:15
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=dbname
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

---

## 🔒 Security & Compliance

### Security Checklist

#### Code Level
- [ ] No hardcoded secrets (use environment variables)
- [ ] All user input validated and sanitized
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (escape user content)
- [ ] CSRF tokens on all forms
- [ ] Rate limiting on all endpoints
- [ ] Authentication required for protected routes
- [ ] Authorization checks before data access

#### Infrastructure Level
- [ ] HTTPS enforced everywhere
- [ ] SSL certificates auto-renewed
- [ ] Database encryption at rest
- [ ] Secrets stored in vault (AWS Secrets Manager, HashiCorp Vault)
- [ ] VPC with private subnets
- [ ] Security groups properly configured
- [ ] WAF (Web Application Firewall) enabled
- [ ] DDoS protection (CloudFlare, AWS Shield)

#### Monitoring Level
- [ ] Failed login attempts tracked
- [ ] Suspicious activity alerts
- [ ] Security audit logs
- [ ] Dependency vulnerability scanning
- [ ] Container image scanning
- [ ] Penetration testing (quarterly)

### Threat Modeling (MUST for production systems)

Before exposing a new feature to production, create a lightweight threat model:

- **STRIDE**: Spoofing, Tampering, Repudiation, Information Disclosure, DoS, Elevation of Privilege
- **OWASP Top 10** mapping (at least a checklist-level mapping)

**Deliverable:** `docs/threat-model.md` (or ADRs) with:
- assets, entry points, trust boundaries
- mitigations + owners
- open risks + timeline

### Authentication & Authorization (MUST)

Define a reference architecture so every project/service follows the same baseline:

- **AuthN**: OIDC/OAuth2 where applicable; JWT access + refresh tokens (with rotation)
- **AuthZ**: RBAC/ABAC (choose and document), least privilege
- **MFA**: required for admin/prod access (at least TOTP for high-risk roles)
- **Service-to-service**: scoped API keys or mTLS (document one standard)
- **Audit logging**: authentication events, permission checks, sensitive actions

### Secrets Management

```bash
# Development: .env file (not committed)
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
JWT_SECRET=dev-secret-change-in-production
API_KEY=dev-api-key

# Staging/Production: Environment variables from vault
# Retrieved automatically by deployment scripts
```

```python
# backend/app/core/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    database_url: str
    jwt_secret: str
    api_key: str
    
    class Config:
        env_file = ".env"
        case_sensitive = False

@lru_cache()
def get_settings():
    return Settings()
```

---

## 📊 Monitoring & Observability

### Three Pillars of Observability

#### 1. Logs (ELK Stack)

```yaml
# filebeat.yml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/app/*.log
    fields:
      project: "ovu"
      environment: "production"

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
```

#### 2. Metrics (Prometheus + Grafana)

```python
# backend/app/middleware/metrics.py
from prometheus_client import Counter, Histogram
import time

REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

@app.middleware("http")
async def metrics_middleware(request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    
    REQUEST_DURATION.labels(
        method=request.method,
        endpoint=request.url.path
    ).observe(duration)
    
    return response
```

#### 3. Traces (OpenTelemetry)

```python
# backend/app/main.py
from opentelemetry import trace
from opentelemetry.exporter.jaeger import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Setup tracing
trace.set_tracer_provider(TracerProvider())
jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",
    agent_port=6831,
)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

tracer = trace.get_tracer(__name__)

@app.get("/api/users/{user_id}")
async def get_user(user_id: int):
    with tracer.start_as_current_span("get_user"):
        # Traced operation
        user = await user_service.get_user(user_id)
        return user
```

### Health Checks

```python
# backend/app/api/health.py
from fastapi import APIRouter
from app.core.database import database
from app.core.redis import redis_client

router = APIRouter()

@router.get("/health")
async def health_check():
    checks = {
        "database": False,
        "redis": False,
        "disk_space": False
    }
    
    # Database check
    try:
        await database.execute("SELECT 1")
        checks["database"] = True
    except:
        pass
    
    # Redis check
    try:
        await redis_client.ping()
        checks["redis"] = True
    except:
        pass
    
    # Disk space check
    import shutil
    stat = shutil.disk_usage("/")
    checks["disk_space"] = (stat.free / stat.total) > 0.1
    
    is_healthy = all(checks.values())
    status_code = 200 if is_healthy else 503
    
    return {
        "status": "healthy" if is_healthy else "unhealthy",
        "checks": checks
    }
```

### Alerting Rules

```yaml
# prometheus/alerts.yml
groups:
  - name: application
    interval: 30s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} per second"
      
      # High response time
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High response time"
          description: "95th percentile is {{ $value }}s"
      
      # Database connection issues
      - alert: DatabaseDown
        expr: up{job="database"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database is down"
```

---

## 👥 Team Collaboration

### Development Workflow

```
Developer
    │
    ├─► Feature Request → Create Branch (feature/name)
    │
    ├─► Development
    │   ├─► Work in worktree (worktrees/service-feature/)
    │   ├─► Write tests first (TDD)
    │   ├─► Implement feature
    │   ├─► Run local tests
    │   └─► Update documentation
    │
    ├─► Code Review
    │   ├─► Push to GitHub
    │   ├─► Create Pull Request
    │   ├─► CI runs automatically
    │   ├─► Request review from team
    │   └─► Address feedback
    │
    ├─► Merge
    │   ├─► PR approved
    │   ├─► Merge to dev
    │   └─► Auto-deploy to staging
    │
    └─► Production Release
        ├─► Test on staging
        ├─► Create release PR (dev → main)
        ├─► Final review
        ├─► Merge to main
        └─► Auto-deploy to production
```

### Code Review Guidelines

```markdown
# Code Review Checklist

## Functionality
- [ ] Code does what it's supposed to do
- [ ] Edge cases are handled
- [ ] Error handling is proper

## Code Quality
- [ ] Code is readable and self-documenting
- [ ] Functions are small and focused
- [ ] No code duplication
- [ ] Follows project conventions

## Tests
- [ ] Tests are included
- [ ] Tests cover edge cases
- [ ] Tests are readable

## Documentation
- [ ] README updated if needed
- [ ] API docs updated
- [ ] Comments explain "why", not "what"

## Security
- [ ] No secrets in code
- [ ] Input validation present
- [ ] Authorization checks present

## Performance
- [ ] No obvious performance issues
- [ ] Database queries optimized
- [ ] Caching used where appropriate
```

### Communication Channels

```markdown
# Team Communication

## Daily Standup (Async)
- **Where**: Slack #daily-standup
- **When**: By 10:00 AM
- **Format**:
  - Yesterday: What I completed
  - Today: What I'm working on
  - Blockers: Any issues

## Code Reviews
- **Where**: GitHub PR comments
- **SLA**: Review within 4 hours
- **Required Approvals**: 1 (2 for production)

## Architecture Decisions
- **Where**: GitHub Discussions
- **Process**: Propose → Discuss → Document (ADR)

## Incidents
- **Where**: Slack #incidents
- **Process**: Report → Assess → Resolve → Postmortem

## Documentation
- **Where**: Project /docs/ folder
- **Update**: With every significant change
```

---

## 📚 Appendix: Templates & Scripts

### Script: create-new-project.sh

```bash
#!/bin/bash
# Create new project with full scaffolding

PROJECT_NAME=$1
BACKEND=$2  # fastapi, express, etc.
FRONTEND=$3 # react, flutter, etc.

PROJECT_ROOT="/home/noam/projects/${PROJECT_NAME}"

echo "🚀 Creating project: ${PROJECT_NAME}"

# Create directory structure
mkdir -p "${PROJECT_ROOT}"/{repositories,worktrees,scripts,docs,infrastructure,.storybook-shared}

# Copy templates
cp .global-config/workspace-template.code-workspace "${PROJECT_ROOT}/${PROJECT_NAME}-workspace.code-workspace"
cp .global-config/.cursorrules-template "${PROJECT_ROOT}/.project-cursorrules"

# Create scripts
cat > "${PROJECT_ROOT}/scripts/run-all-services.sh" << 'EOF'
#!/bin/bash
# Start all services in development mode
docker-compose up -d
EOF

chmod +x "${PROJECT_ROOT}/scripts/"*.sh

# Initialize git repositories
# (Implementation details...)

echo "✅ Project created successfully!"
echo "   Next steps:"
echo "   1. cd ${PROJECT_ROOT}"
echo "   2. cursor ${PROJECT_NAME}-workspace.code-workspace"
```

### Template: Component Generator

```bash
#!/bin/bash
# .global-scripts/create-component.sh

COMPONENT_NAME=$1
PROJECT=$2
SERVICE=$3
PATH=$4

COMPONENT_PATH="/home/noam/projects/${PROJECT}/worktrees/${SERVICE}-work/frontend/react/src/${PATH}/${COMPONENT_NAME}"

mkdir -p "${COMPONENT_PATH}"

# Create component file
cat > "${COMPONENT_PATH}/${COMPONENT_NAME}.tsx" << EOF
import React from 'react';
import './${COMPONENT_NAME}.css';

interface ${COMPONENT_NAME}Props {
  // Define props here
}

export const ${COMPONENT_NAME}: React.FC<${COMPONENT_NAME}Props> = (props) => {
  return (
    <div className="${COMPONENT_NAME}">
      {/* Component content */}
    </div>
  );
};
EOF

# Create CSS file
cat > "${COMPONENT_PATH}/${COMPONENT_NAME}.css" << EOF
.${COMPONENT_NAME} {
  /* Use CSS Variables only! */
  background: var(--surface-color);
  color: var(--text-color);
  padding: var(--spacing-md);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius);
}
EOF

# Create Storybook file
cat > "${COMPONENT_PATH}/${COMPONENT_NAME}.stories.tsx" << EOF
import type { Meta, StoryObj } from '@storybook/react';
import { ${COMPONENT_NAME} } from './${COMPONENT_NAME}';

const meta: Meta<typeof ${COMPONENT_NAME}> = {
  title: 'Components/${COMPONENT_NAME}',
  component: ${COMPONENT_NAME},
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof ${COMPONENT_NAME}>;

export const Default: Story = {
  args: {
    // Default props
  },
};
EOF

# Create test file
cat > "${COMPONENT_PATH}/${COMPONENT_NAME}.test.tsx" << EOF
import { render, screen } from '@testing-library/react';
import { ${COMPONENT_NAME} } from './${COMPONENT_NAME}';

describe('${COMPONENT_NAME}', () => {
  it('renders without crashing', () => {
    render(<${COMPONENT_NAME} />);
    // Add assertions
  });
});
EOF

# Create README
cat > "${COMPONENT_PATH}/README.md" << EOF
# ${COMPONENT_NAME}

## Description
[Brief description of the component]

## Props
[Document props here]

## Usage
\`\`\`tsx
import { ${COMPONENT_NAME} } from '@/components/${COMPONENT_NAME}';

<${COMPONENT_NAME} />
\`\`\`

## Examples
[Show usage examples]
EOF

echo "✅ Component created: ${COMPONENT_PATH}"
echo "   Files created:"
echo "   - ${COMPONENT_NAME}.tsx"
echo "   - ${COMPONENT_NAME}.css"
echo "   - ${COMPONENT_NAME}.stories.tsx"
echo "   - ${COMPONENT_NAME}.test.tsx"
echo "   - README.md"
```

---

## 🎯 Success Metrics

### Developer Experience Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| New developer onboarding time | < 30 min | Time to first commit |
| Time to create new project | < 5 min | Time to running dev server |
| Context switch time | < 30 sec | Time to switch between projects |
| Build time | < 3 min | CI pipeline duration |
| Deploy time (staging) | < 5 min | Push to live |
| Deploy time (production) | < 10 min | Push to live |

### Code Quality Metrics

| Metric | Target |
|--------|--------|
| Test coverage | > 80% |
| Linting errors | 0 |
| Security vulnerabilities (high) | 0 |
| Code review turnaround | < 4 hours |
| Bug escape rate | < 5% |

### System Performance Metrics

| Metric | Target |
|--------|--------|
| API response time (p95) | < 200ms |
| Frontend load time | < 2s |
| Uptime | > 99.9% |
| Error rate | < 0.1% |

---

## 📝 Document Change Log

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | 2025-12-12 | Initial specification | Senior Architect |

---

## ✅ Review & Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Senior Architect** | [Name] | __________ | _____ |
| **Lead Developer** | [Name] | __________ | _____ |
| **DevOps Lead** | [Name] | __________ | _____ |
| **Security Officer** | [Name] | __________ | _____ |
| **CTO** | [Name] | __________ | _____ |

---

**Document End**

*This is a living document. It should be reviewed and updated quarterly or when significant architecture changes are made.*

