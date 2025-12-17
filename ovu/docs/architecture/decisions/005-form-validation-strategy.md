# ADR-005: Form & Validation Strategy

**Status:** ✅ Accepted
**Date:** 2025-12-16
**Decision Makers:** Senior Software Engineer
**Consulted:** Frontend Team, UX Lead

---

## Context

אפליקציות צריכות טפסים מורכבים: login, registration, create/edit entities.
יש צורך להחליט על ספרייה לניהול טפסים ו-validation.

### הדרישות

- ✅ **Type-safe validation** - schema-based, TypeScript first
- ✅ **Performance** - minimal re-renders
- ✅ **UX** - show errors at right time (onBlur, onSubmit)
- ✅ **Complex validation** - async, conditional, cross-field
- ✅ **i18n support** - error messages in 3 languages
- ✅ **Accessibility** - proper ARIA attributes

### Constraints

- Must work with React + TypeScript
- Should integrate with react-i18next (ADR-004)
- Small bundle size
- Easy for junior developers

---

## Decision

### ✅ נאמץ: **React Hook Form + Zod**

**Why?**

```
React Hook Form → Performance (uncontrolled inputs)
      +
Zod → Type-safe validation schemas
```

**Architecture:**

```typescript
// Define schema with Zod
const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

type LoginFormData = z.infer<typeof loginSchema>;

// Use with React Hook Form
const { register, handleSubmit, formState: { errors } } = useForm<LoginFormData>({
  resolver: zodResolver(loginSchema),
});
```

---

## Alternatives Considered

### ❌ Alternative 1: Formik + Yup

**Pros:**
- ✅ Popular, mature
- ✅ Good documentation

**Cons:**
- ❌ Slower (controlled inputs)
- ❌ More re-renders
- ❌ Yup TypeScript support not as good

**Why Rejected:** React Hook Form is more performant.

---

### ❌ Alternative 2: React Hook Form + Joi

**Cons:**
- ❌ Joi designed for Node.js, larger bundle
- ❌ Zod is TypeScript-first

**Why Rejected:** Zod is better for frontend.

---

### ❌ Alternative 3: Controlled Forms (useState)

**Cons:**
- ❌ Too much boilerplate
- ❌ Performance issues with many fields
- ❌ Manual validation logic

**Why Rejected:** Not scalable.

---

## Implementation

### Installation

```bash
npm install react-hook-form zod @hookform/resolvers
```

### Login Form Example

```typescript
// components/LoginForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useTranslation } from 'react-i18next';

const loginSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

const LoginForm = () => {
  const { t } = useTranslation('auth');
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    await login(data.email, data.password);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="email">{t('login.email')}</label>
        <input
          id="email"
          type="email"
          {...register('email')}
          aria-invalid={!!errors.email}
          aria-describedby={errors.email ? 'email-error' : undefined}
        />
        {errors.email && (
          <span id="email-error" role="alert">
            {errors.email.message}
          </span>
        )}
      </div>

      <div>
        <label htmlFor="password">{t('login.password')}</label>
        <input
          id="password"
          type="password"
          {...register('password')}
          aria-invalid={!!errors.password}
        />
        {errors.password && <span role="alert">{errors.password.message}</span>}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? t('common.loading') : t('login.submit')}
      </button>
    </form>
  );
};
```

### i18n Error Messages

```typescript
// schemas/loginSchema.ts
import { z } from 'zod';
import i18n from '@/i18n/config';

export const createLoginSchema = () =>
  z.object({
    email: z.string().email(i18n.t('validation.email')),
    password: z.string().min(8, i18n.t('validation.password_min', { min: 8 })),
  });
```

```json
// localization/en/validation.json
{
  "email": "Invalid email address",
  "password_min": "Password must be at least {{min}} characters",
  "required": "This field is required"
}
```

### Complex Validation

```typescript
// Async validation (check email availability)
const registerSchema = z.object({
  email: z.string().email().refine(
    async (email) => {
      const response = await api.get('/api/v1/check-email', {
        params: { email },
      });
      return !response.data.exists;
    },
    {
      message: 'Email already taken',
    }
  ),
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
});
```

---

## Testing

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import LoginForm from './LoginForm';

describe('LoginForm', () => {
  it('shows validation errors', async () => {
    render(<LoginForm />);

    const submitButton = screen.getByRole('button', { name: /sign in/i });
    await userEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
    });
  });

  it('submits valid form', async () => {
    const mockLogin = jest.fn();
    render(<LoginForm onSubmit={mockLogin} />);

    await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
    await userEvent.type(screen.getByLabelText(/password/i), 'password123');
    await userEvent.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });
});
```

---

## Status History

- **2025-12-16:** ✅ **Accepted**

