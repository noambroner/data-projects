# OVU App Template Specification

## Purpose

Create a reusable starter for new OVU applications with built‑in integration to ULM (auth, logging, headers), so teams can bootstrap faster with consistent security and observability.

## Location & Structure

- Directory: `docs/specs/` (this document)
- Code templates (proposed): `templates/ovu-app-template/`
  - `frontend/` (React+Vite) template
  - `backend/` (FastAPI) template
  - `README.md` + `.env.example` for each

## Scope

- Included: Auth integration with ULM, app source identification, basic logging, health/ready endpoints, minimal UI login page, token handling, sample proxy call to ULM.
- Excluded: Business domain features, DB schemas beyond minimal health/status, CI/CD specifics (can be added per project).

## Requirements

### App Source & Headers

- Every request from new apps to ULM **must** send `X-App-Source=<app-name>`.
- Keep optional `X-Service=<app-name>` for backward compatibility.
- Target ULM URL is configurable via env (`ULM_SERVICE_URL`).

### Authentication

- Support login/refresh via ULM endpoints:
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/refresh`
  - `GET /api/v1/auth/me`
- Default token policy: access 15m, refresh 7d (ULM standard).
- Frontend: token storage helper (localStorage for now), with background refresh and 401 handling. (Future: switchable to HttpOnly cookies.)
- Backend: helper client to forward user tokens or service tokens when acting on behalf of system jobs.

### Logging & Observability

- On the app side: minimal middleware/logger to record endpoint, status, duration, app_source, origin/referer, user (if available).
- ULM integration: ensure headers reach ULM so its `api_logs_backend` records `app_source`.
- Health endpoints: `/health`, `/ready`.

### Security

- Send only bearer tokens over HTTPS.
- Redact sensitive headers in logs (authorization/cookie/x-api-key).
- Provide CSP default `'self'` in frontend index if possible.
- Option to disable localStorage and use cookies in the future (toggle in config).

### Configuration (proposed defaults)

- Frontend: `.env.example`
  - `VITE_API_BASE_URL` (points to backend gateway for the new app)
  - `VITE_APP_SOURCE=<app-name>-web`
- Backend: `.env.example`
  - `PORT=8000` (example)
  - `ULM_SERVICE_URL=https://ulm-rct.ovu.co.il` (or internal URL)
  - `ULM_SERVICE_APP_SOURCE=<app-name>-backend`
  - `ULM_SERVICE_USERNAME` / `ULM_SERVICE_PASSWORD` (optional service account)

### Template Contents

- Frontend:
  - `apiClient.ts` with axios instance, interceptors (auth, refresh, X-App-Source), error handling.
  - Auth hook + context, login form, ProtectedRoute example.
  - Simple UI with i18n scaffold (he/en) and RTL support.
- Backend:
  - `clients/ulm.py` httpx client with X-App-Source and optional service token.
  - Minimal FastAPI app with AuthContext-like middleware (optional) and logging middleware.
  - Sample proxy endpoint to ULM (`/me`), plus `/health` and `/ready`.

### Process to Create a New App (intended)

1. Copy template: `cp -r templates/ovu-app-template my-new-app/`
2. Set unique `app_source` values in env (web/backend).
3. Install deps and run.
4. Verify `/auth/me` flow through ULM succeeds.

### Open Points / Next Steps

- Decide where to host `templates/ovu-app-template/` (root-level `templates/` is proposed).
- Decide token storage mode default (keep localStorage, allow cookie mode flag).
- Add a small bootstrap script to instantiate a new app and replace placeholders (`<app-name>`, app_source).
- Wire CI/CD guidance later.

---

Author: AI assistant
Date: 2025-12-15
