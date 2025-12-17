# ADR-004: Internationalization (i18n) Library Choice

**Status:** ✅ Accepted
**Date:** 2025-12-16
**Decision Makers:** Senior Software Engineer, UX Lead
**Consulted:** Frontend Team, Content Team

---

## Context

מערכת OVU תומכת ב-**3 שפות**: עברית, אנגלית, ערבית.
יש צורך להחליט על ספריית i18n לניהול תרגומים ותמיכה ב-RTL/LTR.

### הדרישות

- ✅ Support 3 languages: he (עברית), en (English), ar (العربية)
- ✅ **RTL support** - עברית וערבית RTL, אנגלית LTR
- ✅ **Dynamic language switching** - ללא טעינה מחדש
- ✅ **Type-safe translations** - TypeScript autocomplete
- ✅ **Lazy loading** - טען רק את השפה הנוכחית
- ✅ **Namespaces** - organize translations by feature
- ✅ **Pluralization** - "1 item" vs "2 items"
- ✅ **Interpolation** - "Hello, {{name}}"

### Constraints

- Must work with React + TypeScript
- Should work with Flutter (for mobile apps)
- Translations managed by non-technical content team
- Small bundle size

---

## Decision

### ✅ נאמץ: **react-i18next** (for Web) + **Flutter Intl** (for Mobile)

**Architecture:**

```
┌──────────────────────────────────────┐
│   Translation Files (JSON)           │
├──────────────────────────────────────┤
│                                       │
│  shared/localization/                │
│  ├── en/                             │
│  │   ├── common.json                │
│  │   ├── auth.json                  │
│  │   └── dashboard.json             │
│  ├── he/                             │
│  │   ├── common.json                │
│  │   ├── auth.json                  │
│  │   └── dashboard.json             │
│  └── ar/                             │
│      ├── common.json                │
│      ├── auth.json                  │
│      └── dashboard.json             │
│                                       │
└──────────────────────────────────────┘
         │
         ├──────────────────┐
         │                  │
         ▼                  ▼
   ┌─────────────┐    ┌──────────────┐
   │  React Web  │    │Flutter Mobile│
   │             │    │              │
   │ react-i18next│    │ flutter_intl │
   └─────────────┘    └──────────────┘
```

### Why react-i18next?

1. **Industry Standard** - Most popular i18n library for React
2. **Excellent TypeScript Support** - Full type safety
3. **Rich Features** - All we need (RTL, pluralization, interpolation)
4. **Small Bundle** - ~12KB gzipped
5. **Great DX** - Easy to use hooks

---

## Alternatives Considered

### ❌ Alternative 1: react-intl (FormatJS)

**Pros:**
- ✅ Backed by FormatJS team (Yahoo)
- ✅ ICU Message Format (industry standard)
- ✅ Excellent formatting (dates, numbers, currencies)

**Cons:**
- ❌ More complex API
- ❌ Larger bundle size (~40KB)
- ❌ More verbose syntax
- ❌ TypeScript support not as good

**Why Rejected:** More complex than we need, larger bundle.

---

### ❌ Alternative 2: lingui

**Pros:**
- ✅ Excellent TypeScript support
- ✅ Compile-time extraction
- ✅ Small bundle

**Cons:**
- ❌ Requires build step (compile translations)
- ❌ Smaller community
- ❌ More complex setup

**Why Rejected:** Build step adds complexity, smaller ecosystem.

---

### ❌ Alternative 3: Custom Solution

**Pros:**
- ✅ Exactly what we need
- ✅ Minimal bundle size

**Cons:**
- ❌ Need to implement pluralization, interpolation, etc.
- ❌ Maintenance burden
- ❌ Reinventing the wheel

**Why Rejected:** Not worth the effort, i18next is battle-tested.

---

## Consequences

### ✅ Positive

1. **Easy to use** - Simple hooks: `useTranslation()`
2. **Type-safe** - Full autocomplete for translation keys
3. **Performance** - Lazy load languages, namespace splitting
4. **RTL/LTR** - Built-in `dir` attribute handling
5. **Proven** - Used by thousands of production apps

### ⚠️ Negative

1. **Learning curve** - Team needs to learn i18next API
   - **Mitigation:** Good documentation, examples in template
2. **Duplication** - Need separate Flutter implementation
   - **Mitigation:** Share JSON files, same structure

---

## Implementation Notes

### Installation

```bash
npm install react-i18next i18next i18next-browser-languagedetector
npm install -D @types/i18next
```

### Setup

```typescript
// src/i18n/config.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// Import translations
import enCommon from '@/localization/en/common.json';
import enAuth from '@/localization/en/auth.json';
import heCommon from '@/localization/he/common.json';
import heAuth from '@/localization/he/auth.json';
import arCommon from '@/localization/ar/common.json';
import arAuth from '@/localization/ar/auth.json';

const resources = {
  en: {
    common: enCommon,
    auth: enAuth,
  },
  he: {
    common: heCommon,
    auth: heAuth,
  },
  ar: {
    common: arCommon,
    auth: arAuth,
  },
};

i18n
  .use(LanguageDetector) // Detect user language
  .use(initReactI18next) // Pass i18n to React
  .init({
    resources,
    fallbackLng: 'he', // Default to Hebrew
    defaultNS: 'common',
    interpolation: {
      escapeValue: false, // React already escapes
    },
    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage'],
    },
  });

export default i18n;
```

### TypeScript Types

```typescript
// src/i18n/types.ts
import 'react-i18next';
import common from '@/localization/en/common.json';
import auth from '@/localization/en/auth.json';

declare module 'react-i18next' {
  interface CustomTypeOptions {
    defaultNS: 'common';
    resources: {
      common: typeof common;
      auth: typeof auth;
    };
  }
}
```

### Translation Files Structure

```json
// localization/en/common.json
{
  "app_name": "My App",
  "welcome": "Welcome",
  "loading": "Loading...",
  "error": "An error occurred",
  "save": "Save",
  "cancel": "Cancel",
  "delete": "Delete",
  "edit": "Edit",
  "search": "Search",
  "no_results": "No results found"
}
```

```json
// localization/en/auth.json
{
  "login": {
    "title": "Login",
    "email": "Email",
    "password": "Password",
    "submit": "Sign In",
    "forgot_password": "Forgot password?",
    "no_account": "Don't have an account?",
    "register": "Register"
  },
  "logout": "Logout",
  "profile": "Profile"
}
```

```json
// localization/he/common.json
{
  "app_name": "האפליקציה שלי",
  "welcome": "ברוכים הבאים",
  "loading": "טוען...",
  "error": "אירעה שגיאה",
  "save": "שמור",
  "cancel": "ביטול",
  "delete": "מחק",
  "edit": "ערוך",
  "search": "חיפוש",
  "no_results": "לא נמצאו תוצאות"
}
```

### Usage in Components

```typescript
// components/Login.tsx
import { useTranslation } from 'react-i18next';

const Login = () => {
  const { t } = useTranslation('auth');

  return (
    <div>
      <h1>{t('login.title')}</h1>
      <input placeholder={t('login.email')} />
      <input type="password" placeholder={t('login.password')} />
      <button>{t('login.submit')}</button>
    </div>
  );
};
```

### RTL/LTR Support

```typescript
// App.tsx
import { useTranslation } from 'react-i18next';
import { useEffect } from 'react';

const App = () => {
  const { i18n } = useTranslation();

  useEffect(() => {
    // Set document direction based on language
    const dir = i18n.dir();
    document.documentElement.dir = dir;
    document.documentElement.lang = i18n.language;
  }, [i18n.language]);

  return <div>{/* App content */}</div>;
};
```

```css
/* Global RTL styles */
[dir='rtl'] {
  text-align: right;
}

[dir='ltr'] {
  text-align: left;
}

/* Margin/padding that needs to flip */
.card {
  margin-inline-start: 16px; /* Auto-flips in RTL */
  padding-inline-end: 8px;
}
```

### Language Switcher Component

```typescript
// components/LanguageSwitcher.tsx
import { useTranslation } from 'react-i18next';

const languages = {
  en: { name: 'English', flag: '🇬🇧' },
  he: { name: 'עברית', flag: '🇮🇱' },
  ar: { name: 'العربية', flag: '🇸🇦' },
};

const LanguageSwitcher = () => {
  const { i18n } = useTranslation();

  return (
    <select
      value={i18n.language}
      onChange={(e) => i18n.changeLanguage(e.target.value)}
    >
      {Object.entries(languages).map(([code, { name, flag }]) => (
        <option key={code} value={code}>
          {flag} {name}
        </option>
      ))}
    </select>
  );
};
```

### Pluralization

```json
// localization/en/common.json
{
  "items_count": "{{count}} item",
  "items_count_plural": "{{count}} items"
}
```

```json
// localization/he/common.json
{
  "items_count": "פריט אחד",
  "items_count_plural": "{{count}} פריטים"
}
```

```typescript
// Usage
const { t } = useTranslation();

t('items_count', { count: 1 }); // "1 item" / "פריט אחד"
t('items_count', { count: 5 }); // "5 items" / "5 פריטים"
```

### Interpolation

```json
{
  "welcome_user": "Welcome, {{name}}!",
  "items_found": "Found {{count}} items in {{category}}"
}
```

```typescript
t('welcome_user', { name: 'John' }); // "Welcome, John!"
t('items_found', { count: 5, category: 'Electronics' });
// "Found 5 items in Electronics"
```

---

## Testing Strategy

### Mock i18next in Tests

```typescript
// __mocks__/react-i18next.ts
export const useTranslation = () => ({
  t: (key: string) => key,
  i18n: {
    language: 'en',
    changeLanguage: jest.fn(),
    dir: () => 'ltr',
  },
});
```

### Test Translations

```typescript
// __tests__/Login.test.tsx
import { render, screen } from '@testing-library/react';
import { I18nextProvider } from 'react-i18next';
import i18n from '@/i18n/config';
import Login from '@/components/Login';

describe('Login', () => {
  it('should render in English', () => {
    i18n.changeLanguage('en');
    render(
      <I18nextProvider i18n={i18n}>
        <Login />
      </I18nextProvider>
    );
    expect(screen.getByText('Login')).toBeInTheDocument();
  });

  it('should render in Hebrew', () => {
    i18n.changeLanguage('he');
    render(
      <I18nextProvider i18n={i18n}>
        <Login />
      </I18nextProvider>
    );
    expect(screen.getByText('התחברות')).toBeInTheDocument();
  });
});
```

---

## Content Management

### Translation Workflow

1. **Developer:** Add English translation key
2. **Content Team:** Add Hebrew & Arabic translations
3. **Review:** Check RTL layout
4. **Commit:** All languages committed together

### Translation Files Validation

```typescript
// scripts/validate-translations.ts
import enCommon from '../localization/en/common.json';
import heCommon from '../localization/he/common.json';
import arCommon from '../localization/ar/common.json';

const enKeys = new Set(Object.keys(enCommon));
const heKeys = new Set(Object.keys(heCommon));
const arKeys = new Set(Object.keys(arCommon));

// Find missing keys
const missingInHe = [...enKeys].filter((k) => !heKeys.has(k));
const missingInAr = [...enKeys].filter((k) => !arKeys.has(k));

if (missingInHe.length > 0) {
  console.error('Missing Hebrew translations:', missingInHe);
  process.exit(1);
}

if (missingInAr.length > 0) {
  console.error('Missing Arabic translations:', missingInAr);
  process.exit(1);
}

console.log('✅ All translations present');
```

---

## Flutter Implementation (for Mobile)

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0

flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

```json
// lib/l10n/app_en.arb
{
  "appName": "My App",
  "welcome": "Welcome",
  "@welcome": {
    "description": "Welcome message"
  }
}
```

---

## References

- [react-i18next Documentation](https://react.i18next.com/)
- [i18next Best Practices](https://www.i18next.com/principles/best-practices)
- [RTL Styling Guide](https://rtlstyling.com/)
- [Flutter Intl](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

---

## Status History

- **2025-12-16:** Proposed by Senior Engineer
- **2025-12-16:** Reviewed by UX & Content Team
- **2025-12-16:** ✅ **Accepted**

---

**Related ADRs:**
- ADR-003: State Management (React)

