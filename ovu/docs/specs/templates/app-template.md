# OVU App Template Specification

## Goals

- Provide a ready-to-use skeleton (frontend + backend) for new OVU apps with built-in ULM authentication, logging, and headers.
- Standardize headers (`X-App-Source`) so ULM logs every app correctly.
- Keep specs here; keep code templates separately under `templates/`.

## Placement & Structure

- Specs live in `docs/specs/` (this file is under `docs/specs/templates/`).
- Code templates should live at repo root: `templates/ovu-app-template/`
  - `templates/ovu-app-template/frontend/` — React/Vite skeleton with ULM client + auth.
  - `templates/ovu-app-template/backend/` — FastAPI skeleton with ULM client + logging.
  - `templates/ovu-app-template/README.md` — how to bootstrap a new app.

## Naming / App Source

- Each app must have a unique `app_source` used in headers:
  - Frontend: `X-App-Source: <app-name>-web`
  - Backend: `X-App-Source: <app-name>-backend` (also can set `X-Service` if desired)
- This value is logged by ULM (see ULM `api_logger` middleware).

## Frontend Template Requirements (React/Vite)

- Axios client preconfigured with:
  - `baseURL` from env (`VITE_API_BASE_URL`)
  - Headers: `Content-Type: application/json`, `X-App-Source=<app-name>-web`
  - Request interceptor: inject `Authorization` if token present; optional proactive refresh.
  - Response interceptor: handle 401 → refresh → retry; on failure clear tokens + logout event.
- Auth module:
  - `/auth/login`, `/auth/refresh`, `/auth/me` wrappers.
  - Local storage (or future HttpOnly cookies) for tokens; store minimal user info (id/email/role).
  - Optional background validation of `/auth/me`.
- Minimal UI:
  - Login screen, protected route example, basic error display.
- Logging hook (optional): batch/emit client logs including `app_source`.
- Env sample: `.env.example` with `VITE_API_BASE_URL`, `VITE_APP_SOURCE`.

## Backend Template Requirements (FastAPI)

- httpx AsyncClient for ULM with defaults:
  - `base_url` from env (`ULM_SERVICE_URL`)
  - Headers: `X-App-Source=<app-name>-backend`, `X-Service=<app-name>-backend`
  - `ulm_request(method, path, user_token=None, use_service_fallback=False, **kwargs)`
  - Optional service token retrieval if `ULM_SERVICE_USERNAME/PASSWORD` provided.
- Middleware / logging:
  - Basic request logger (duration, status, path, method).
  - Include origin/referer/app_source in logs.
- Health/readiness:
  - `/health`, `/ready` endpoints; ready checks DB/ULM reachability if applicable.
- Sample proxy route:
  - e.g., `/me` that forwards `Authorization` to ULM and returns the claims.
- Env sample: `.env.example` with `ULM_SERVICE_URL`, `ULM_SERVICE_APP_SOURCE`, `PORT`, optional service credentials.

## Security Notes

- Prefer short-lived access tokens; refresh token stored securely (future: HttpOnly cookies).
- Always send `X-App-Source` so ULM can attribute requests.
- Validate JWT expiry; handle refresh failures by clearing tokens.
- Avoid storing sensitive data in localStorage; limit to tokens + minimal user info.

## Bootstrap Steps for a New App

1. Copy template: `cp -r templates/ovu-app-template my-new-app/`
2. Set `app_source` values in env and headers (frontend + backend).
3. Install deps and run locally.
4. Verify flow:
   - `/auth/login` returns tokens
   - `/auth/me` works via proxy
   - ULM logs show `app_source` = your app’s name
5. Initialize git, add README with app name + app_source.

## Checklist (implementation)

- [ ] Frontend axios client sends `X-App-Source=<app-name>-web`
- [ ] Backend client sends `X-App-Source=<app-name>-backend`
- [ ] Auth flow: login → store tokens → `/auth/me` succeeds
- [ ] Error/401 handling clears tokens and logs out
- [ ] Health endpoints present
- [ ] Env examples added

## Future Enhancements

- HttpOnly cookie mode for tokens.
- Shared logging helper to standardize client logs.
- CLI bootstrap script (e.g., `scripts/new-app.sh --name myapp` to set app_source automatically).
