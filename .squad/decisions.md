# Squad Decisions

## Active Decisions

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

### 2026-07-24: Single consent entry point
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
