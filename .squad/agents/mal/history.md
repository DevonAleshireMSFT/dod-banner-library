# Mal — History

**Project:** DoD Banner Library — a managed Power Platform solution providing GCC High–safe consent and classification banner assets for Power Pages, Canvas Apps, and Model-Driven Apps in DoD environments (IL4/IL5). Zero external dependencies, no CDN calls, no jQuery.

**Stack:** Dataverse solution (managed/unmanaged export), HTML/CSS/vanilla JS web resources, TypeScript PCF virtual component, Power Pages Liquid web templates, Dataverse environment variables.

**Current state (as of team setup):** v1.1 released (2026-07-23) — added PCF Virtual Component, JS web resource for MDA `OnLoad`, `dodbl_ShowConsentBanner`, `dodbl_BannerPosition`. v1.2 planned: Dataverse consent audit table + security role.

**Requested by:** Devon Aleshire.

**2026-07-24:** Team stood up (Squad init). No decisions recorded yet — starting fresh.

**2026-07-24:** Authored the Power Platform Squad skill and started v1.3.0 documentation updates across release notes, `dodbl_docs`, and README.
Flagged that the PCF manifest uses `control-type="standard"`, not `virtual`.

📌 Team update (2026-07-24T23:20:00-07:00): Scribe merged Mal's governance boundary decision: .ai/ is product truth, .squad/ is team/routing/session memory, and agents should link rather than restate .ai/ product decisions while using tiered .ai/ loading. — decided by Mal


📌 Team update (2026-07-24T23:36:08-07:00): Public-repository hygiene is now a working agreement in team context and points to .ai/security.md as authoritative. — decided by Mal/Zoe

💬 PM kudos (2026-07-24T23:48:08-07:00): DevonAleshireMSFT said, "I always know I can count on the team to come together for a quality decision."
📌 2026-07-25T16:03:36-07:00: Owns .ai reconciliation; performed slim .ai migration from .ai_old/ to adr/context-version convention (commit ea87b4a).
📌 Team update (2026-07-25T23:54:22-07:00): `dodbl_consent_record` schema defined for v1.4.0 issue #8; Devon chose the Power Apps maker path for manual table creation. — decided by Mal
