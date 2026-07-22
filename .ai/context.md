---
project: DoD Banner Library
schema-prefix: dodbl_
platform: Power Platform / Dataverse
cloud: GCC High (DoD IL4/IL5)
context-version: 1.0.0
last-updated: 2026-07-22
owner: Tech Lead
review-cadence: every-sprint
---

# DoD Banner Library — AI Context

> This is the primary bootstrap document. An AI assistant should read this file first before asking any questions or generating any code.

---

## What This Is

The **DoD Banner Library** is a managed Power Platform solution that provides reusable CUI classification marks and DoD system-use notification consent banners for deployment across Canvas Apps, Model-Driven Apps, and Power Pages. It is built exclusively for GCC High / IL4/IL5 environments and contains zero external CDN dependencies. All assets are packaged as solution web resources under publisher prefix `dodbl` so a single solution import covers all three platforms.

---

## Current State

- ✅ `dodbl_bannercore` — shared CSS web resource (banner-core.css)
- ✅ `dodbl_dodconsentbanner` — DoD consent modal HTML/JS web resource (vanilla JS, jQuery removed)
- ✅ `dodbl_cuiconsentbanner` — CUI classification mark HTML web resource (CSS-only)
- ✅ `dodbl_docs` — in-solution documentation web resource
- ✅ `dodbl_release-notes` — release notes web resource
- ✅ Solution created with publisher prefix `dodbl` in GCC High tenant
- ⏳ Power Pages Web Template (`dod-consent-banner` Liquid fragment)
- ⏳ Content Snippet (`DoDConsentText`)
- ⏳ Environment Variables (4): `BannerEnabled`, `BannerType`, `DoDConsentText`, `ConsentExpiryDays`
- 🔲 PCF Virtual Component (`DodBannerControl`) — Canvas Apps + Model-Driven Apps
- 🔲 JS web resource fallback (`dodbl_dodbanner.js`) — MDA form OnLoad, no-premium path
- 🔲 Dataverse consent audit table (`dodbl_consent_record`)
- 🔲 Security role: `DoD Banner — Consent Write`
- 🔲 Export as managed solution (`dod_banner_library_managed.zip`)

---

## Architecture Summary

The solution delivers two banner types: a DoD system-use notification consent modal (JS + CSS) and a CUI classification mark (CSS-only via `data-classification` attribute). All assets are self-contained web resources with no external dependencies. Power Pages consumes the assets by creating portal web files from the web resource content — there is no website record in the solution (see Gotchas). Canvas Apps and Model-Driven Apps will consume a PCF Virtual Component in v1.1; a JS web resource fallback covers environments without Premium licensing.

**Key components:**
| Component | Purpose | Technology |
|-----------|---------|-----------|
| `dodbl_bannercore` | Shared stylesheet for all banner types | CSS web resource |
| `dodbl_dodconsentbanner` | DoD consent modal — cookie tracking + fade animation | HTML/JS web resource |
| `dodbl_cuiconsentbanner` | CUI classification mark fragment | HTML web resource (CSS-only) |
| `dodbl_docs` | In-solution setup documentation | HTML web resource |
| `dodbl_release-notes` | Version history and changelog | HTML web resource |

---

## Key Rules

> These rules must be followed in every AI interaction with this codebase. No exceptions.

- **No external CDN calls.** GCC High blocks them. All JavaScript must be fully self-contained. Do not add jQuery, lodash, or any CDN-hosted library.
- **Publisher prefix is `dodbl_`.** Every new Dataverse component, web resource, table, column, and environment variable must use this prefix.
- **Do not change the consent banner element IDs or class names.** The JavaScript in `dodbl_dodconsentbanner` references `#cookieConsent`, `#closeCookieConsent`, `.cookieConsentOK`, and `.consentBackground` by exact name. Renaming them breaks the modal.
- **CSS classification values are case-sensitive.** The `data-classification` starts-with selector (`^=`) is case-sensitive. Always use `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET` — not lowercase.
- **Do not include a website record in the solution.** Power Pages web files require a `Website` foreign key that is environment-specific. Deliver CSS and JS as web resources only; deployers create web files manually post-import.
- **Solution must be distributed as managed.** Do not export as unmanaged for shared deployment — managed prevents downstream modification of consent logic.

---

## Known Gotchas

> Non-obvious constraints that will cause errors if ignored.

- **Power Pages web files cannot be pre-packaged** — the `Website` field on `adx_webfile` is required and environment-specific. Attempting to create web files without a website record in the solution will fail. Deployers must create them manually in the Portal Management app and copy content from the web resources.
- **Canvas Apps PCF requires environment opt-in** — "Enable code components" must be toggled on in the environment's Power Apps settings. This requires Power Apps Premium license or Managed Environment. The PCF component (`DodBannerControl`) is not yet built (planned v1.1).
- **jQuery was intentionally removed.** Do not re-add it. The consent banner fade animation uses `requestAnimationFrame`. Any future animation must follow the same pattern.
- **`trimStart()` in `getCookie` requires ES2019+** — verify against the portal's minimum supported browser if targeting legacy environments.
- **`data-classification` prefix match (`^=`) can cause unexpected color matches.** A value of `UNCLASSIFIED` will match the `U` (green) rule. `CUI` matches `CU` (purple) before `C` is checked. `CONFIDENTIAL` uses `CO` which is distinct from `CU`. The matching order in the CSS matters — understand the cascade before adding new classification levels.
- **Web resource files from PAC CLI have no `.html` or `.css` extension** — the extension is implied by `WebResourceType` in the accompanying `.data.xml` file (type `1` = HTML, type `2` = CSS). Do not rename or add extensions to the exported files.
- **`dodbl_docs` links to `dodbl_release-notes` by schema name** (`href="dodbl_release-notes"`). This only resolves correctly when the web resource is opened in the Power Platform web resource viewer context, not from the local filesystem.

---

## Active Priorities

1. Upload updated `dodbl_docs` and `dodbl_release-notes` web resource content to the solution (PAC CLI push or manual portal update)
2. Phase 3 — Power Pages: add Content Snippet, Web Template, and 4 environment variables to the solution
3. Phase 4 — PCF Virtual Component (`DodBannerControl`) and MDA JS fallback

---

## Where to Look

| Topic | File |
|-------|------|
| Shared CSS | [DoDBannerLibrary/WebResources/dodbl_bannercore](../DoDBannerLibrary/WebResources/dodbl_bannercore) |
| Consent modal JS | [DoDBannerLibrary/WebResources/dodbl_dodconsentbanner](../DoDBannerLibrary/WebResources/dodbl_dodconsentbanner) |
| CUI classification CSS | [DoDBannerLibrary/WebResources/dodbl_cuiconsentbanner](../DoDBannerLibrary/WebResources/dodbl_cuiconsentbanner) |
| Documentation | [DoDBannerLibrary/WebResources/dodbl_docs](../DoDBannerLibrary/WebResources/dodbl_docs) |
| Release notes | [DoDBannerLibrary/WebResources/dodbl_release-notes](../DoDBannerLibrary/WebResources/dodbl_release-notes) |
| Source banner files | [dod-consent-banner.html](../dod-consent-banner.html), [cui-consent-banner.html](../cui-consent-banner.html), [banner-core.css](../banner-core.css) |
| Security and access | [security.md](security.md) |
| Pipelines and ALM | [pipelines.md](pipelines.md) |
| Technical debt | [debt.md](debt.md) |
| Developer onboarding | [onboarding.md](onboarding.md) |
| Architecture decisions | [decisions/](decisions/) |
| AI session prompt | [bootstrap-prompt.md](bootstrap-prompt.md) |