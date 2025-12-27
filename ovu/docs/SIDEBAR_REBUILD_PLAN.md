# OVU Sidebar V2 - Architecture & Rebuild Plan

## 1. Design Philosophy
The sidebar will be a self-contained, theme-aware, RTL-first component. It will **not** rely on the consuming application's CSS inheritance for layout or positioning.

### Key Principles:
1.  **Strict Isolation:** All CSS classes will be prefixed (e.g., `.ovu-sb-item`) to avoid collisions.
2.  **Layout Engine:** Pure Flexbox. No `position: absolute` for layout flow (like the expand button).
3.  **RTL Strategy:** The root sidebar component will accept a `language` prop and set a `dir="rtl"` or `dir="ltr"` attribute on its root container. All internal layout will use logical CSS properties (`margin-inline-start`) or explicit `[dir="rtl"]` selectors where logical properties fail in older contexts.
4.  **State Management:** Internal context for collapsed/expanded state, but fully controlled navigation props.

## 2. Component Structure

```
src/
├── components/
│   ├── SidebarItem.tsx       // Individual app item (row)
│   ├── SidebarMenu.tsx       // Sub-menu container
│   ├── SidebarHeader.tsx     // Logo & Brand
│   ├── SidebarFooter.tsx     // User profile & Settings
│   └── SearchBar.tsx         // Search input
├── context/
│   └── SidebarContext.tsx    // State management
├── styles/
│   ├── variables.css         // Theme definitions
│   └── main.css              // Core layout & styling
├── types/
│   └── index.ts              // Shared interfaces
└── index.ts                  // Public API
```

## 3. The "Expand Button" Solution
The previous failure was due to `position: absolute` fighting with `flex` containers and unknown `z-index` stacks.

**New Approach:**
The `SidebarItem` will be a Flex container:
```css
.ovu-sb-item {
  display: flex;
  align-items: center;
  width: 100%;
}

.ovu-sb-icon { flex-shrink: 0; }
.ovu-sb-info { flex-grow: 1; } /* Pushes content */
.ovu-sb-expand-btn {
  margin-inline-start: auto; /* Pushes button to the end (Left in RTL, Right in LTR) */
  flex-shrink: 0;
  z-index: 2; /* Explicitly above background */
}
```

## 4. Implementation Steps
1.  **Variables:** Define strict colors, sizes, and z-indices.
2.  **Types:** Define `MenuItem`, `Application`, `SidebarProps`.
3.  **Logic:** Implement the Context provider.
4.  **UI:** Build components bottom-up (Item -> Menu -> Sidebar).
5.  **Build:** Configure Vite to bundle correctly.

## 5. Usage Documentation
Clear instructions on how to import, required props, and how the `dir` attribute is handled.

