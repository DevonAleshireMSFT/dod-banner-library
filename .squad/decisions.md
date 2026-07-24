# Squad Decisions

## Active Decisions

### 2026-07-24 (revised): Optional consent modes; classification bar is the core
**By:** Devon Aleshire (with Mal — Lead, Zoe — Compliance)
**What:** Consent is optional, configurable tooling — NOT an enforced access control. Introduce a single `dodbl_ConsentMode` selector (`Off` | `HomePage` | `GlobalNotification`, default `Off`) so an admin enables the home-page overlay (`dodbl_banner-launch-page`) OR the shell global notification (`dodbl_dodbanner` / `Xrm.App.addGlobalNotification`) OR neither. The two consent surfaces can NEVER fire simultaneously — enforced by code path, not config. `dodbl_ShowConsentBanner` becomes a legacy fallback only. The data **classification marking bar** (CUI/U/CONFIDENTIAL/SECRET/TOP SECRET) is the solution's primary feature and focus. Consent-cookie consistency debt is fixed **atomically** across all three consent surfaces (`pcf/DodBannerControl` index.ts, `dodbl_dodbanner`, `dodbl_banner-launch-page`): #3 malformed-cookie `URIError`, #4 rename `Accepted` → `dodbl_Accepted`, #5 `Secure` flag, #6 PCF `_consentSetup` reset. PCF docs corrected: control-type is `standard`, not virtual.
**Why:** Authentication into the GCC High tenant is the real access boundary; AC-8 system-use notification is inherited at the tenant/workstation logon banner (pending AO/ISSO confirmation), so in-app consent is supplementary hardening, not the primary control. This avoids fragile, unsupported `window.top` DOM enforcement and stops repeated direction churn. Keeps the solution simple and centered on its most compliance-significant contribution (classification marking).
**Supersedes:** "Single consent entry point" (below) — consent is no longer one hardwired path; both surfaces are selectable options. Also reframes "Ship v1.3.0 with UX-only consent gate; defer hard enforcement."
**Issue disposition:** #13 reframed as optional advanced-enforcement guidance for adopters requiring enforced in-app consent (not a blocking defect). #7 and #14 reframed around optional consent tooling, not mandatory AC-8 enforcement.
**Verification action (open):** Confirm AC-8 inheritance posture with the AO/ISSO and document it in the compliance/ATO trail.

### 2026-07-24: Issue #7 closeout includes consent-cookie hardening regressions
**By:** Wash
**What:** Treat consent-cookie hardening regressions in the new `dodbl_banner-launch-page` landing page as blocking closeout findings, even though issue #7 acceptance criteria only explicitly call out split-before-decode and version bump.
**Why:** Issue #7 says the new page "already implements the correct pattern." Reusing the generic `Accepted` cookie name or omitting the `Secure` flag means the new page still shares known issues #4 and #5 with other hosts, so closing the branch as "validated" would be misleading.
**Routing impact:** Kaylee should handle implementation fixes; Zoe should review whether cookie naming/flags are required for the intended GCC High compliance posture.

### 2026-07-24: AC-8 gate requirements for MDA entry points
**By:** Zoe
**What:** Treat a home-page consent gate as AC-8-complete only if every alternative Model-Driven App entry path (deep links, search, direct subarea URLs) is covered by the same acknowledgement control, and require every consent surface to source AO-approved text from `dodbl_DoDConsentText`.
**Why:** Sitemap-first ordering improves the default path but is not a complete enforcement boundary by itself. Compliance posture depends on preventing bypass through alternate navigation and on keeping the displayed system-use notification aligned with the AO-approved override across all surfaces.

### 2026-07-24: Launch page consent text resolution
**By:** Kaylee
**What:** `dodbl_banner-launch-page` now resolves consent text by honoring query-string overrides first (`dodbl_DoDConsentText` / `consentText` / `data` payload), then falling back to the same `Xrm.WebApi` environment-variable lookup pattern used by `dodbl_dodbanner`.
**Why:** The current sitemap subarea does not pass a populated consent-text query parameter, so matching the existing `dodbl_dodbanner` env-var lookup keeps behavior consistent today while remaining compatible with future subarea query-string wiring.

### 2026-07-24: Single consent entry point  — ⚠️ SUPERSEDED
**Superseded by:** "Optional consent modes; classification bar is the core" (top of Active Decisions). Both consent surfaces are now selectable via `dodbl_ConsentMode`; they remain mutually exclusive by code path, so the duplicate-banner concern this decision addressed is still guaranteed — just via config rather than removal.
**By:** Devon Aleshire
**What:** The MDA consent gate is delivered only via the custom home page overlay (`dodbl_banner-launch-page`); the shell-level `Xrm.App.addGlobalNotification` path was removed.
**Why:** This is the simplest and most logical implementation path and avoids over-complicating the UX with duplicate entry points.

### 2026-07-24: Ship v1.3.0 with UX-only consent gate; defer hard enforcement
**By:** Devon Aleshire
**What:** Ship v1.3.0 with the UX-only consent gate while consciously accepting the known AC-8 deep-link/global-search bypass limitation, tracked in issue #13.
**Why:** The team accepted the limitation for v1.3.0 so UAT can proceed while hard enforcement is deferred and tracked explicitly.

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
