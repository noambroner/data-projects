# Sequence Diagrams - OVU App Template

## מה זה Sequence Diagram?

**Sequence Diagram** הוא דיאגרמה שמראה **איך מערכות שונות מתקשרות זו עם זו לאורך זמן**.

### למה צריך Sequence Diagrams?

1. **הבנת הזרימה** - רואים את כל השלבים בתהליך
2. **זיהוי בעיות** - רואים איפה יכולות להיות race conditions או errors
3. **תקשורת צוות** - כולם מבינים את הזרימה באותו אופן
4. **תיעוד** - תיעוד חזותי של ההתנהגות

### הכלים

משתמשים ב-**Mermaid** - פורמט טקסט שהופך אוטומטית לדיאגרמה ב-GitHub/GitLab.

---

## Diagrams List

| Diagram | Description | Status |
|---------|-------------|--------|
| [001-login-flow](./001-login-flow.md) | Login flow (happy path) | ✅ Complete |
| [002-refresh-token-flow](./002-refresh-token-flow.md) | Refresh token with queue | ✅ Complete |
| [003-logout-flow](./003-logout-flow.md) | Logout and cleanup | ✅ Complete |
| [004-401-error-handling](./004-401-error-handling.md) | 401 error with concurrent requests | ✅ Complete |
| [005-registration-flow](./005-registration-flow.md) | User registration (future) | 📝 Planned |

---

## How to View

### Option 1: GitHub/GitLab (Automatic)
Just open the `.md` file and the diagram renders automatically.

### Option 2: Mermaid Live Editor
Copy the code and paste in [https://mermaid.live](https://mermaid.live)

### Option 3: VS Code
Install "Markdown Preview Mermaid Support" extension

---

## Diagram Conventions

### Actors
- 👤 **User** - End user interacting with app
- 🌐 **Frontend** - React/Flutter app
- 🔧 **Backend** - App's backend API
- 🔐 **ULM** - User Login Manager service
- 💾 **LocalStorage** - Browser local storage

### Colors
- 🟢 **Green** - Success path
- 🔴 **Red** - Error path
- 🟡 **Yellow** - Warning/retry

---

## Key Flows Summary

### 1. Login Flow
```
User → Frontend → ULM
      ← tokens ←
Frontend saves tokens
Frontend redirects to Dashboard
```

### 2. Refresh Token Flow
```
API call → 401
Frontend checks: already refreshing?
  No → Call ULM refresh endpoint
     → Get new access token
     → Retry original request
  Yes → Queue request
      → Wait for refresh
      → Retry with new token
```

### 3. 401 Error Handling
The most complex flow - handles **race conditions** when multiple API calls fail simultaneously.

---

## Related ADRs

- [ADR-001: Session Management Strategy](../decisions/001-session-management-strategy.md)
- [ADR-003: State Management (React)](../decisions/003-state-management-react.md)

