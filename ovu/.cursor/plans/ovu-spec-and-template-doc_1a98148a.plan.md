---
name: ovu-spec-and-template-doc
overview: Prepare a full specification document for the OVU app template and decide the templates directory location/structure
todos: []
---

# OVU App Template Specification Plan

## Scope

- Produce a comprehensive specification document for the OVU app template (frontend + backend) with built-in ULM auth integration.
- Decide and document the directory location and structure for code templates (skeletons) and keep specifications separate.

## Deliverables

- New spec file under `docs/specs/templates/app-template.md` detailing goals, architecture, flows, requirements, and bootstrap steps.
- README note in `docs/specs/README.md` (or update) explaining where specs live and how to use them.
- Clear recommendation for code templates location/structure (e.g., `templates/ovu-app-template/`), but **no code templates created now**.

## Steps

1. **Review existing guidance**

- Confirm current conventions for logging/app_source and ULM integration from `ulm` guidelines and middleware notes (already referenced in analysis).

2. **Define locations & structure**

- Propose and document: 
- Specs in `docs/specs/` with subfolders `templates/`, `platform/`, `services/<app>/`.
- Code templates in a separate top-level `templates/` directory (e.g., `templates/ovu-app-template/` with `frontend/`, `backend/`, `README`).

3. **Author spec document** (`docs/specs/templates/app-template.md`)

- Sections: goals/scope, positioning, architecture overview (frontend+backend), ULM auth & headers (X-App-Source), logging/monitoring, env samples, bootstrap steps for a new app, security notes, naming conventions for app_source, checklist for adoption.

4. **Update specs README**

- Briefly describe how to add/read specs and where code templates will live.

5. **Review**

- Self-review for clarity and completeness; no code/template files created at this stage.

## Out-of-Scope

- Creating actual code templates or modifying existing app code.
- Deployment or runtime changes.

## Notes

- Keep the plan lightweight; implement as docs only. Code template creation can be a follow-up task.