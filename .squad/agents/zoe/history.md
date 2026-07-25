# Zoe — History

**Project:** DoD Banner Library — a managed Power Platform solution providing GCC High–safe consent and classification banner assets for Power Pages, Canvas Apps, and Model-Driven Apps in DoD environments (IL4/IL5). Zero external dependencies, no CDN calls, no jQuery.

**Compliance surface:** Classification banner levels (CUI, U, CONFIDENTIAL, SECRET, TOP SECRET) with case-sensitive `data-classification` matching and fixed color mappings; client-side-only consent tracking via cookie (no server-side audit log yet — planned for v1.2); AO-approved consent text is configurable via `dodbl_DoDConsentText`.

**Requested by:** Devon Aleshire.

**2026-07-24:** Team stood up (Squad init). No decisions recorded yet — starting fresh.

**2026-07-24:** Reviewed v1.3.0 consent gate for compliance posture and identified the AC-8 hard-enforcement gap now tracked in issue #13.
Confirmed AO-approved consent text must come from `dodbl_DoDConsentText`; noted Secure cookie flag gap for remediation.

**2026-07-24:** Documented AC-8 posture for adopters in README and in-app docs (dodbl_docs): AC-8 is inherited at tenant/workstation logon pending adopter AO/ISSM confirmation, in-app consent is optional supplementary hardening, and the classification bar is the library's primary compliance contribution. Commit: 09734b5.


📌 Team update (2026-07-24T19:53:00-07:00): Clarified compliance docs so banner env-var values are case-insensitive while data-classification HTML/CSS matching remains case-sensitive; commit 25450a1.

📌 Team update (2026-07-24T22:50:00-07:00): v1.3.0 is release-ready on the Model-Driven App path after documentation reconciliation for `dodbl_Accepted`, `Secure; SameSite=Strict`, malformed-cookie `getCookie` hardening, PCF re-arm behavior, and PCF v1.2.1. Canvas consent persistence is documented as a sandbox limitation and tracked for v1.4.0 in #21; technical docs/repo artifacts are tracked in #22 — decided by Zoe and Serenity.

📌 Team update (2026-07-24T23:20:00-07:00): Scribe merged Zoe's AI security guardrail: .ai/security.md should state implemented controls factually and avoid unsupported certification, ATO, AC-8, or compliance overclaims. — decided by Zoe


📌 Team update (2026-07-24T23:36:08-07:00): Public-repository disclosure hygiene guardrail added to product docs; keep internal-to-Microsoft material out of committed/public artifacts. — decided by Zoe/Mal

💬 PM kudos (2026-07-24T23:48:08-07:00): DevonAleshireMSFT said, "I always know I can count on the team to come together for a quality decision."
📌 2026-07-25T16:03:36-07:00: Co-reviewed migrated .ai/security.md for compliance; verdict 🟢 Green, no changes.
