# ADR-003: React State Management Choice

**Status:** ✅ Accepted
**Date:** 2025-12-16
**Decision Makers:** Senior Software Engineer (VIBE Specialist)
**Consulted:** Frontend Team, UX Lead

---

## Context

אפליקציות React צריכות לנהל state מורכב:

1. **User state** - מידע על המשתמש המחובר
2. **UI state** - loading, errors, modals, toasts
3. **Server state** - data from API (cached, fresh, stale)
4. **Form state** - form values, validation, touched fields

יש צורך להחליט על **State Management Strategy** לתבנית.

### הדרישות

- ✅ **Simple for beginners** - easy to understand and use
- ✅ **Type-safe** - full TypeScript support
- ✅ **Performant** - no unnecessary re-renders
- ✅ **Devtools** - debugging support
- ✅ **SSR-ready** - works with Next.js (future)
- ✅ **Small bundle** - minimal impact on load time

### Constraints

- Template should work for small apps (5-10 components) and large apps (100+ components)
- Must integrate well with React 18+ (Suspense, Concurrent Mode)
- Team has varying skill levels (junior to senior)

---

## Decision

### ✅ נאמץ: **React Context + Hooks (Baseline) + TanStack Query (Server State)**

**Architecture:**

```
┌─────────────────────────────────────┐
│         Application State            │
├─────────────────────────────────────┤
│                                      │
│  UI/Client State                    │
│  └─→ React Context API              │
│      - AuthContext (user, login,    │
│        logout)                       │
│      - ThemeContext (theme, toggle) │
│      - ToastContext (show, hide)    │
│                                      │
│  Server State                        │
│  └─→ TanStack Query (React Query)   │
│      - Caching                       │
│      - Automatic refetching          │
│      - Optimistic updates            │
│      - Pagination, infinite scroll   │
│                                      │
│  Form State                          │
│  └─→ React Hook Form + Zod          │
│      (See ADR-005)                   │
│                                      │
└─────────────────────────────────────┘
```

### State Categories

| State Type | Solution | Example | Why |
|------------|----------|---------|-----|
| **Authentication** | React Context | user, isAuthenticated | Rarely changes, accessed everywhere |
| **Theme** | React Context | theme, colorMode | Rarely changes, accessed everywhere |
| **Notifications** | React Context | toasts, alerts | Simple queue management |
| **Server Data** | TanStack Query | users, products, orders | Caching, refetching, background updates |
| **Form Data** | React Hook Form | login form, create product | Complex validation, performance |
| **Local UI** | useState | modal open/close | Component-local, doesn't need sharing |

### Example: AuthContext

```typescript
// contexts/AuthContext.tsx
import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import api from '@/api/apiClient';

interface User {
  id: number;
  email: string;
  role: string;
  full_name: string;
}

interface AuthContextValue {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // On mount, check if user is logged in
    const token = localStorage.getItem('access_token');
    if (token) {
      refreshUser();
    } else {
      setIsLoading(false);
    }
  }, []);

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    try {
      const response = await api.post('/api/v1/auth/login', {
        email,
        password,
      });

      const { access_token, refresh_token, user: userData } = response.data.data;

      localStorage.setItem('access_token', access_token);
      localStorage.setItem('refresh_token', refresh_token);

      setUser(userData);
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    localStorage.clear();
    setUser(null);
  };

  const refreshUser = async () => {
    setIsLoading(true);
    try {
      const response = await api.get('/api/v1/auth/me');
      setUser(response.data.data);
    } catch (error) {
      // Token invalid, logout
      logout();
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        isLoading,
        login,
        logout,
        refreshUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### Example: TanStack Query for Server State

```typescript
// App.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        {/* Your app */}
      </AuthProvider>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

```typescript
// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '@/api/apiClient';

export const useUsers = () => {
  return useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const response = await api.get('/api/v1/users');
      return response.data.data;
    },
  });
};

export const useCreateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (userData: CreateUserDTO) => {
      const response = await api.post('/api/v1/users', userData);
      return response.data.data;
    },
    onSuccess: () => {
      // Invalidate and refetch users list
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
};

// Usage in component:
const UsersList = () => {
  const { data: users, isLoading, error } = useUsers();
  const createUser = useCreateUser();

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      {users.map(user => <UserCard key={user.id} user={user} />)}
      <button onClick={() => createUser.mutate({ name: 'New User' })}>
        Add User
      </button>
    </div>
  );
};
```

---

## Alternatives Considered

### ❌ Alternative 1: Redux + Redux Toolkit

**Approach:**
```typescript
// Redux store with slices
const store = configureStore({
  reducer: {
    auth: authReducer,
    users: usersReducer,
    products: productsReducer,
  },
});
```

**Pros:**
- ✅ Industry standard, widely known
- ✅ Excellent devtools
- ✅ Predictable state updates
- ✅ Middleware ecosystem (redux-saga, redux-thunk)

**Cons:**
- ❌ Boilerplate-heavy (even with Redux Toolkit)
- ❌ Steeper learning curve for beginners
- ❌ Overkill for simple apps
- ❌ Larger bundle size (~10KB gzipped)
- ❌ Async logic still complex (thunks/sagas)

**Why Rejected:** Too complex for template. Adds unnecessary cognitive load for simple use cases.

---

### ❌ Alternative 2: Zustand

**Approach:**
```typescript
// Simple store with Zustand
const useAuthStore = create((set) => ({
  user: null,
  login: async (email, password) => {
    const user = await api.login(email, password);
    set({ user });
  },
  logout: () => set({ user: null }),
}));
```

**Pros:**
- ✅ Very simple API
- ✅ Small bundle (1KB)
- ✅ No boilerplate
- ✅ Good TypeScript support
- ✅ Familiar to Redux users

**Cons:**
- ❌ Less ecosystem/community than Redux
- ❌ Still mixes client state with server state
- ❌ Devtools not as mature
- ❌ Less familiar to React beginners

**Why Rejected:** While excellent, React Context is more "standard React" and easier for beginners. Zustand is great for complex apps but adds dependency.

---

### ❌ Alternative 3: MobX

**Approach:**
```typescript
class AuthStore {
  @observable user = null;

  @action
  async login(email, password) {
    this.user = await api.login(email, password);
  }
}
```

**Pros:**
- ✅ Very intuitive (mutable-like API)
- ✅ Excellent performance
- ✅ Less boilerplate than Redux

**Cons:**
- ❌ Requires decorators (experimental)
- ❌ Less popular than Redux
- ❌ OOP style less common in modern React
- ❌ Harder to debug (magic reactivity)

**Why Rejected:** Decorators add complexity. Less aligned with modern React (hooks, functional).

---

### ❌ Alternative 4: Jotai / Recoil (Atomic State)

**Approach:**
```typescript
// Atoms
const userAtom = atom(null);
const themeAtom = atom('light');

// Component
const user = useAtom(userAtom);
```

**Pros:**
- ✅ Modern approach
- ✅ Great TypeScript support
- ✅ Small bundle
- ✅ Fine-grained reactivity

**Cons:**
- ❌ Newer, less battle-tested
- ❌ Different mental model
- ❌ Smaller community
- ❌ Recoil still experimental

**Why Rejected:** Too new, smaller ecosystem. Context API is proven and simpler for beginners.

---

## Consequences

### ✅ Positive

1. **Zero Dependencies (for client state)** - Context API is built-in
2. **Easy to Learn** - Standard React patterns
3. **Type-Safe** - Full TypeScript support
4. **Performant** - TanStack Query handles caching brilliantly
5. **Separation of Concerns** - Client state vs Server state clearly separated
6. **Great DX** - React Query Devtools are amazing

### ⚠️ Negative

1. **Context Re-render Risk** - Need careful value memoization
   - **Mitigation:** Split contexts, use `useMemo` for values
2. **Prop Drilling** - For deeply nested components
   - **Mitigation:** Use Context, keep component tree shallow
3. **No Time-Travel Debugging** - Unlike Redux
   - **Mitigation:** React Devtools + Query Devtools cover most cases

### 🚨 Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Performance issues from Context** | Low | Medium | Split contexts, optimize with useMemo |
| **Developer confusion (2 state solutions)** | Medium | Low | Clear documentation, examples |
| **Missing Redux features** | Low | Low | Add Redux only if really needed |

---

## Implementation Notes

### Project Structure

```
src/
├── contexts/
│   ├── AuthContext.tsx
│   ├── ThemeContext.tsx
│   └── ToastContext.tsx
├── hooks/
│   ├── useAuth.ts          (re-export from context)
│   ├── useUsers.ts         (TanStack Query)
│   ├── useProducts.ts      (TanStack Query)
│   └── useLocalStorage.ts  (utility)
├── api/
│   ├── apiClient.ts
│   └── queryClient.ts
└── App.tsx
```

### Performance Optimization

```typescript
// ❌ Bad: Context value recreated every render
const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);

  return (
    <AuthContext.Provider value={{ user, setUser }}>
      {children}
    </AuthContext.Provider>
  );
};

// ✅ Good: Memoized value
const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);

  const value = useMemo(
    () => ({
      user,
      isAuthenticated: !!user,
      login: async (email, password) => { /* ... */ },
      logout: () => setUser(null),
    }),
    [user]
  );

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
```

### Context Splitting

```typescript
// ❌ Bad: One big context
const AppContext = {
  user,
  theme,
  language,
  notifications,
  settings,
  // ... 20 more things
};

// ✅ Good: Split by concern
<AuthProvider>
  <ThemeProvider>
    <I18nProvider>
      <ToastProvider>
        <App />
      </ToastProvider>
    </I18nProvider>
  </ThemeProvider>
</AuthProvider>
```

### When to Upgrade to Redux?

Consider Redux if:
- ✅ App has >50 components
- ✅ Complex state logic (wizards, multi-step forms)
- ✅ Need time-travel debugging
- ✅ Multiple developers need predictable patterns
- ✅ Need middleware (logging, analytics)

But start with Context + React Query first!

---

## Testing Strategy

### Context Testing

```typescript
// __tests__/AuthContext.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { AuthProvider, useAuth } from '@/contexts/AuthContext';

const TestComponent = () => {
  const { login, user, isLoading } = useAuth();

  return (
    <div>
      {isLoading && <div>Loading...</div>}
      {user && <div>Welcome {user.email}</div>}
      <button onClick={() => login('test@example.com', 'password')}>
        Login
      </button>
    </div>
  );
};

describe('AuthContext', () => {
  it('should login user', async () => {
    render(
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    );

    const button = screen.getByText('Login');
    button.click();

    await waitFor(() => {
      expect(screen.getByText(/Welcome test@example.com/)).toBeInTheDocument();
    });
  });
});
```

### TanStack Query Testing

```typescript
// __tests__/useUsers.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useUsers } from '@/hooks/useUsers';

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  return ({ children }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
};

describe('useUsers', () => {
  it('should fetch users', async () => {
    const { result } = renderHook(() => useUsers(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data).toHaveLength(3);
  });
});
```

---

## Migration Path

### From Context to Redux (if needed)

```typescript
// Step 1: Keep Context as-is
// Step 2: Add Redux store alongside
// Step 3: Gradually move state to Redux
// Step 4: Remove Context when done

// Both can coexist:
<Provider store={store}>
  <AuthProvider>
    <App />
  </AuthProvider>
</Provider>
```

---

## References

- [React Context API](https://react.dev/reference/react/createContext)
- [TanStack Query](https://tanstack.com/query/latest)
- [Redux vs Context](https://blog.isquaredsoftware.com/2021/01/context-redux-differences/)
- [When to use Context vs Redux](https://kentcdodds.com/blog/application-state-management-with-react)

---

## Status History

- **2025-12-16:** Proposed by Senior Engineer
- **2025-12-16:** Reviewed by Frontend Team
- **2025-12-16:** ✅ **Accepted**

---

**Related ADRs:**
- ADR-001: Session Management Strategy
- ADR-005: Form & Validation Strategy

