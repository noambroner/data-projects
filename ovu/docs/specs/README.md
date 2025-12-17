# OVU Specifications

This directory is the canonical place for written specs and design docs. Keep specs **separate from code templates** so each stays focused.

## Structure

- `docs/specs/templates/` — spec templates and reusable patterns (e.g., app template spec).
- `docs/specs/platform/` — cross-cutting platform specs (auth, security, observability, logging).
- `docs/specs/services/<app>/` — specs per service/app when needed.

## Code Templates (not stored here)

- Keep code skeletons/boilerplates in a top-level `templates/` directory (e.g., `templates/ovu-app-template/frontend`, `templates/ovu-app-template/backend`).
- Specs in `docs/specs/` should reference those templates but not contain the code.

## How to add a new spec

1. Choose the right folder (platform / templates / services/<app>).
2. Add a concise markdown doc with scope, flows, and requirements.
3. Link to any code templates or sample env files if relevant.
4. Prefer short checklists for implementation and verification.
