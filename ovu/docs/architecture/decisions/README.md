# Architecture Decision Records (ADRs)

## מה זה ADR?

**Architecture Decision Record (ADR)** הוא מסמך קצר שמתעד החלטה ארכיטקטונית משמעותית יחד עם ההקשר שלה וההשלכות.

### למה צריך ADRs?

1. **תיעוד החלטות** - מתעד למה בחרנו בפתרון מסוים
2. **העברת ידע** - מפתחים חדשים מבינים מהר יותר את הרציונל
3. **למידה מהעבר** - נמנע מלחזור על אותן טעויות
4. **שקיפות** - כל הצוות מבין את ההחלטות

### מבנה ADR

כל ADR מכיל:

```markdown
# ADR-XXX: [Title]

**Status:** [Proposed | Accepted | Rejected | Deprecated | Superseded]
**Date:** YYYY-MM-DD
**Decision Makers:** [Who made this decision]
**Consulted:** [Who was consulted]

## Context

מה הבעיה? מה הרקע?

## Decision

מה החלטנו לעשות?

## Alternatives Considered

אילו אופציות אחרות שקלנו?

## Consequences

### Positive
- מה הטוב בהחלטה?

### Negative
- מה החסרונות?

### Risks
- אילו סיכונים?

## Implementation Notes

פרטים טכניים להטמעה
```

## ADRs במערכת OVU App Template

| # | Title | Status | Date |
|---|-------|--------|------|
| [001](./001-session-management-strategy.md) | Session Management Strategy | Accepted | 2025-12-16 |
| [002](./002-database-strategy.md) | Database Strategy (Per-App vs Shared) | Accepted | 2025-12-16 |
| [003](./003-state-management-react.md) | React State Management Choice | Accepted | 2025-12-16 |
| [004](./004-i18n-library-choice.md) | Internationalization Library | Accepted | 2025-12-16 |
| [005](./005-form-validation-strategy.md) | Form & Validation Strategy | Accepted | 2025-12-16 |

## תהליך יצירת ADR חדש

1. העתק את `template.md`
2. מספר את ה-ADR (XXX רץ לפי סדר)
3. מלא את כל הסעיפים
4. שלח ל-review לצוות
5. עדכן סטטוס ל-Accepted/Rejected
6. עדכן טבלה זו

## כללים

- **אחד ADR לכל החלטה** - אל תשלב החלטות
- **תמיד תעד alternatives** - מה עוד שקלת?
- **היה ספציפי** - לא "נשתמש בDB" אלא "PostgreSQL 15"
- **תעד מה, לא איך** - ADR זה לא implementation guide

