# ADR-001: Session Management Strategy

**Status:** ✅ Accepted
**Date:** 2025-12-16
**Decision Makers:** Software Architect, Senior Engineer
**Consulted:** DevOps Manager, Security Team

---

## Context

אפליקציות OVU חדשות צריכות לבצע authentication מול ULM (User Login Manager). יש צורך להחליט:

1. **איפה מאוחסן Session State?** (Client vs Server vs Hybrid)
2. **מי אחראי על Refresh Token rotation?** (ULM vs App Backend)
3. **מה קורה כש-ULM down?** (Fallback strategy)
4. **איך מטפלים ב-concurrent 401s?** (Race conditions)

### הדרישות

- ✅ Support access token (15 min TTL) + refresh token (7 days)
- ✅ Seamless refresh ללא הפרעה למשתמש
- ✅ Handle multiple concurrent API calls with expired token
- ✅ Security: tokens לא נגישים ל-XSS attacks (אידיאלי)
- ✅ Work offline (אם אפשר) למשך זמן מוגבל

### Constraints

- ULM כבר קיים ומחזיר JWT tokens (access + refresh)
- Frontend יכול להיות React Web או Flutter Mobile
- חלק מהאפליקציות צריכות לעבוד גם בלי Backend (static hosting)

---

## Decision

### ✅ נאמץ: **Hybrid Client-Side Session with Refresh Queue**

**Architecture:**

```
┌─────────────────┐
│   Frontend      │
│  (React/Flutter)│
├─────────────────┤
│ - Access Token  │ ← localStorage (or secure storage on mobile)
│ - Refresh Token │ ← localStorage (future: HttpOnly cookie if backend exists)
│ - User Info     │ ← minimal (id, email, role)
└────────┬────────┘
         │
         ├──────────────────┐
         │                  │
         ▼                  ▼
  ┌─────────────┐    ┌─────────────┐
  │  ULM API    │    │  App Backend│
  │             │    │  (Optional) │
  │ - Auth      │    │ - Business  │
  │ - Refresh   │    │ - Proxy to  │
  │ - Validate  │    │   ULM       │
  └─────────────┘    └─────────────┘
```

### Refresh Strategy: **Client-Side with Queue**

```typescript
// Pseudo-code
let isRefreshing = false;
let refreshQueue: Array<(token: string) => void> = [];

interceptor.on401 = async (request) => {
  if (!isRefreshing) {
    isRefreshing = true;

    try {
      const newToken = await refreshTokenWithULM();
      refreshQueue.forEach(cb => cb(newToken));
      refreshQueue = [];
      return retryRequest(request, newToken);
    } finally {
      isRefreshing = false;
    }
  } else {
    // Wait for refresh to complete
    return new Promise(resolve => {
      refreshQueue.push((token) => {
        resolve(retryRequest(request, token));
      });
    });
  }
};
```

### Token Storage Strategy

| Scenario | Access Token | Refresh Token | Rationale |
|----------|-------------|---------------|-----------|
| **Web (no backend)** | localStorage | localStorage | Simple, works with static hosting. XSS risk mitigated by CSP |
| **Web (with backend)** | localStorage | HttpOnly Cookie | Best security: refresh token not accessible to JS |
| **Mobile (Flutter)** | Secure Storage | Secure Storage | Use flutter_secure_storage (iOS Keychain / Android Keystore) |

### Fallback Strategy (ULM Down)

**Option 1 (Recommended for MVP):** Fail Fast
- כש-ULM down → show error "Authentication service unavailable"
- Don't cache credentials client-side for offline auth (security risk)

**Option 2 (Future Enhancement):** Circuit Breaker + Redis Cache
- App Backend caches last N successful auth validations (5 min TTL)
- If ULM down → serve from cache
- Show banner "Running in degraded mode"

**For MVP: Choose Option 1 (Fail Fast)**

---

## Alternatives Considered

### ❌ Alternative 1: Pure Server-Side Sessions

**Approach:**
- Backend creates session cookie
- Frontend sends session ID only
- Backend validates against ULM on every request

**Pros:**
- ✅ More secure (tokens never touch client)
- ✅ Easy to revoke sessions

**Cons:**
- ❌ Requires Backend for every app (can't use static hosting)
- ❌ More complex infrastructure
- ❌ Doesn't work well with mobile apps
- ❌ Scalability: session store needed (Redis)

**Why Rejected:** Overkill for most OVU apps. Adds complexity without enough benefit.

---

### ❌ Alternative 2: ULM Centralized Session Store

**Approach:**
- ULM maintains session DB
- Frontend gets session ID from ULM
- Every app validates session ID with ULM

**Pros:**
- ✅ Single source of truth
- ✅ Easy global logout

**Cons:**
- ❌ ULM becomes bottleneck (every request needs validation)
- ❌ ULM downtime kills all apps
- ❌ High load on ULM

**Why Rejected:** Creates single point of failure and scales poorly.

---

### ❌ Alternative 3: Long-Lived Tokens (No Refresh)

**Approach:**
- Single token with 7-day TTL
- No refresh mechanism

**Pros:**
- ✅ Simplest implementation

**Cons:**
- ❌ Security risk: if token leaked, valid for 7 days
- ❌ Can't revoke without blacklist
- ❌ Industry best practice is short-lived access tokens

**Why Rejected:** Poor security posture.

---

## Consequences

### ✅ Positive

1. **Simple to implement** - Client-side refresh is straightforward
2. **Works without backend** - Can host frontend as static site
3. **Good developer experience** - Transparent refresh, no user interruption
4. **Mobile-friendly** - Same pattern works for Flutter
5. **Standard approach** - OAuth2 refresh token pattern is well-known

### ⚠️ Negative

1. **XSS risk** - If localStorage compromised, tokens stolen
   - **Mitigation:** Strict CSP headers, sanitize all user input
2. **Refresh token exposed** - In localStorage (web) or device storage (mobile)
   - **Mitigation:** Use HttpOnly cookies when backend available
3. **Client complexity** - Refresh queue logic is non-trivial
   - **Mitigation:** Provide battle-tested template code

### 🚨 Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Race condition in refresh** | Medium | High | Extensive unit tests + E2E tests |
| **XSS attack steals tokens** | Low | Critical | CSP headers, input sanitization, security audits |
| **Token not cleared on logout** | Medium | Medium | Explicit cleanup in logout flow + tests |
| **Refresh token expired** | High | Low | Redirect to login, clear message to user |

---

## Implementation Notes

### Frontend (React)

```typescript
// api/apiClient.ts
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'X-App-Source': import.meta.env.VITE_APP_SOURCE,
  },
});

// Request interceptor: inject token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor: handle 401 with refresh queue
let isRefreshing = false;
let refreshSubscribers: Array<(token: string) => void> = [];

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        return new Promise((resolve) => {
          refreshSubscribers.push((token: string) => {
            originalRequest.headers.Authorization = `Bearer ${token}`;
            resolve(api(originalRequest));
          });
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const refreshToken = localStorage.getItem('refresh_token');
        const { data } = await axios.post(
          `${import.meta.env.VITE_ULM_URL}/api/v1/auth/refresh`,
          { refresh_token: refreshToken },
          {
            headers: {
              'X-App-Source': import.meta.env.VITE_APP_SOURCE,
            },
          }
        );

        localStorage.setItem('access_token', data.data.access_token);

        // Notify all waiting requests
        refreshSubscribers.forEach((cb) => cb(data.data.access_token));
        refreshSubscribers = [];
        isRefreshing = false;

        originalRequest.headers.Authorization = `Bearer ${data.data.access_token}`;
        return api(originalRequest);
      } catch (refreshError) {
        isRefreshing = false;
        refreshSubscribers = [];

        // Refresh failed → logout
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

### Backend (FastAPI - Optional Proxy)

```python
# backend/app/clients/ulm.py
import httpx
from app.core.config import settings

class ULMClient:
    def __init__(self):
        self.base_url = settings.ULM_SERVICE_URL
        self.app_source = settings.ULM_SERVICE_APP_SOURCE
        self.client = httpx.AsyncClient(timeout=10.0)

    async def validate_token(self, access_token: str) -> dict:
        """Validate access token with ULM."""
        headers = {
            'Authorization': f'Bearer {access_token}',
            'X-App-Source': self.app_source,
        }

        response = await self.client.get(
            f'{self.base_url}/api/v1/auth/me',
            headers=headers
        )
        response.raise_for_status()
        return response.json()

    async def close(self):
        await self.client.aclose()
```

### Mobile (Flutter)

```dart
// lib/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
```

---

## Testing Strategy

### Unit Tests

```typescript
describe('apiClient refresh logic', () => {
  it('should refresh token on 401', async () => {
    // Mock 401 response
    // Mock successful refresh
    // Verify original request retried with new token
  });

  it('should queue concurrent requests during refresh', async () => {
    // Make 5 concurrent requests that all get 401
    // Verify only 1 refresh call made
    // Verify all 5 requests retried with new token
  });

  it('should logout on refresh failure', async () => {
    // Mock 401 response
    // Mock refresh failure
    // Verify localStorage cleared
    // Verify redirect to /login
  });
});
```

### Integration Tests

- Test full login → make API call → token expires → auto-refresh → continue
- Test refresh token expiration → redirect to login
- Test logout clears all tokens

---

## References

- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [JWT Best Practices (RFC 8725)](https://tools.ietf.org/html/rfc8725)
- ULM API Documentation (internal)

---

## Status History

- **2025-12-16:** Proposed by Software Architect
- **2025-12-16:** Reviewed by Security Team
- **2025-12-16:** ✅ **Accepted**

---

**Next ADRs to write:**
- ADR-002: Database Strategy (per-app or shared)
- ADR-003: State Management (React Context vs Redux vs Zustand)

