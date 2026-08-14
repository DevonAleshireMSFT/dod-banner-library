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
📌 Team update (2026-07-25T23:54:22-07:00): AC-8 audit table designed as `dodbl_consent_record`; expiry-processing ownership for `dodbl_isactive` remains open for #10-#12. — decided by Mal

📌 Team update (2026-08-03T15:42:23-07:00): DoD Banner - Consent Write role passed live least-privilege testing; consent PRs #28, #29, #30, and #31 are merged; issue #9 is closed. — decided by Serenity

📌 Team update (2026-08-03T19:59:53-07:00): Issue #32 consent deployment docs shipped via squash-merged PR #33 after disclosure-safe review; role wording was corrected to the exact `DoD Banner - Consent Write` name. — decided by Zoe and Serenity

📌 Team update (2026-08-03T20:28:54-07:00): v1.4.0 consent-write shipped for #10/#11 via merged PRs #36/#37; ADR 0010 set the authenticated-only Power Pages approach for #12; `Unspecified=703870007` was added for empty/unknown bannerType audit rows. — decided by Mal and Zoe

📌 Team update (2026-08-04T14:16:27-07:00): Public GitHub Pages docs review for PR #39 was green after placeholder compliance copy was removed; avoid certification/accreditation claims and keep GCC High/IL4-IL5 wording scoped to intended environments. — decided by Zoe

📌 Team update (2026-08-06T22:38:59-07:00): Consent audit table remains User/Team-owned; Zoe added DoD Banner - Consent Audit Reader for Organization-scope Read-only auditor access, with v1.4 release-note/version follow-up. — decided by Zoe, approved by Devon


📌 Team update (2026-08-11T23:50:59.790-07:00): Completed least-privilege review of the DoD Banner - Consent Audit Reader role in merged PR #41; role remains read-only for consent audit reporting.
