---
project: DoD Banner Library
schema-prefix: dodbl_
platform: Power Platform / Dataverse
cloud: GCC High (DoD IL4/IL5)
context-version: 1.3.0
last-updated: 2026-07-24
owner: Tech Lead
review-cadence: every-sprint
---

# DoD Banner Library — AI Context

> This is the primary bootstrap document. An AI assistant should read this file first before asking any questions or generating any code.

---

## What This Is

The **DoD Banner Library** is a managed Power Platform solution that provides reusable CUI classification marks and DoD system-use notification consent banners for Canvas Apps, Model-Driven Apps, and Power Pages. Built exclusively for GCC High / IL4/IL5. Zero external CDN dependencies. All assets packaged as solution web resources under publisher prefix `dodbl_`.

---

## Current State (v1.2.0)

### Web Resources
- ✅ `dodbl_bannercore` — shared CSS (classification marks + consent modal layout)
- ✅ `dodbl_dodconsentbanner` — DoD consent modal HTML/JS (vanilla JS, Power Pages use)
- ✅ `dodbl_cuiconsentbanner` — CUI classification mark HTML (CSS-only, Power Pages use)
- ✅ `dodbl_webtemplatesource` — Power Pages Web Template source (copy/paste Liquid page)
- ✅ `dodbl_dodbanner` — MDA form OnLoad JS script; reads **6** env vars via Xrm.WebApi. Uses `Xrm.App.addGlobalNotification` for consent (supported UCI API, no window.top). Uses `window.top.document` DOM injection for classification bar only (known anti-pattern — see Decision 006). Supports `Top`/`Bottom`/`Both` bar placement; shifts MDA nav header down when bar is at top.
- ✅ `dodbl_docs` — in-solution documentation (post-import checklist, all 7 web resources documented)
- ✅ `dodbl_release-notes` — version history (latest first, oldest last). v1.0.0, v1.1.0, v1.2.0 released. v1.3.0 planned at top.

### PCF Control
- ✅ `DodBannerControl` (namespace `DoDBannerLibrary`) — PCF field control for Canvas Apps and Custom Pages (MDA)
  - `bannerEnabled` (TwoOptions, bound) — show/hide the banner
  - `bannerType` (SingleLine.Text, input) — classification bar type; `DoD` = legacy consent alias; empty = no bar
  - `showConsent` (TwoOptions, input) — show the DoD consent modal independently of `bannerType` (v1.2+)
  - `consentExpiryDays` (Whole.None, input) — cookie lifetime
  - `consentText` (SingleLine.Text, input) — AO-approved text override
  - Bundle is **fully self-contained**: injects modal CSS into `document.head` at runtime (`<style data-dodbl-pcf-styles>`). `dodbl_bannercore.css` is not required in Canvas Apps.
  - Built: webpack bundle ~5.92 KiB (production, minified, no eval).
  - `pcfconfig.json` sets `"buildMode": "production"` — plain `npm run build` always produces a production build.
  - Source: `pcf/DodBannerControl/`

### Solution Components
- ✅ 6 Environment Variables: `dodbl_BannerEnabled`, `dodbl_BannerType`, `dodbl_ConsentExpiryDays`, `dodbl_DoDConsentText`, `dodbl_ShowConsentBanner`, `dodbl_BannerPosition`
- ✅ `dodbl_DoDBannerLibraryManagement` — MDA management app (docs, release notes, web template source, banner demo)
- ✅ `dodbl_banner_demo` — custom Dataverse table for MDA banner demo; Main form has `dodbl_dodbanner` library registered
- ✅ `dodbl_DoDBannerLibrary.DodBannerControl` — PCF registered as custom control (type 66) in solution
- ✅ Solution version: `1.2.0.0`

### Not Yet Built (v1.2 roadmap)
- 🔲 `dodbl_consent_record` — Dataverse consent audit table
- 🔲 Security role: `DoD Banner — Consent Write`
- 🔲 Managed solution export v1.1.0 + GitHub release tag

---

## Architecture Summary

Two banner types: (1) DoD system-use notification consent modal (JS + CSS, cookie-based), and (2) CUI/classification mark (CSS-only via `data-classification` attribute). Three delivery paths:

| Platform | Asset | How |
|---|---|---|
| Power Pages | `dodbl_dodconsentbanner` + `dodbl_bannercore` | Deployer creates web files from web resource content; Liquid Web Template from `dodbl_webtemplatesource` |
| Model-Driven Apps | `dodbl_dodbanner` (JS web resource) | Add as form library; register `DoDBannerLibrary.DodBanner.onFormLoad` OnLoad handler |
| Canvas Apps | `DodBannerControl` (PCF) | Add to screen; bind `bannerEnabled` to formula; set `bannerType` |

The env vars (`dodbl_BannerEnabled`, `dodbl_BannerType`, `dodbl_ConsentExpiryDays`, `dodbl_DoDConsentText`, `dodbl_ShowConsentBanner`, `dodbl_BannerPosition`) control behavior for the MDA JS path. The PCF reads from its own bound/input properties (not env vars directly).

---

## Key Rules

> Follow without exception.

- **No external CDN calls.** GCC High blocks them. All JS and CSS must be fully self-contained. Never add jQuery, lodash, or any CDN-hosted library.
- **Publisher prefix is `dodbl_`.** Every new Dataverse component, web resource, table, column, environment variable, and PCF namespace must use this prefix.
- **Do not change consent banner element IDs/classes.** `#cookieConsent`, `.cookieConsentOK`, `.consentBackground` are referenced by exact name in `dodbl_dodconsentbanner` (Power Pages) and `DodBannerControl` (PCF). Renaming breaks everything. Note: `#closeCookieConsent` was intentionally removed from the PCF modal in v1.2 — do not restore it. It still exists in `dodbl_dodconsentbanner` (Power Pages path).
- **Release notes are reverse chronological.** `dodbl_release-notes` always lists the newest version (or Planned) at the top and oldest at the bottom. When adding a new version block, insert it above the previous latest, and move the Planned block above the new entry.
- **CSS classification values are case-sensitive.** `data-classification` startsWith match — always use `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`. Not lowercase.
- **Do not include a website record in the solution.** Power Pages web files need a `Website` FK that is environment-specific.
- **MDA consent uses `addGlobalNotification` — not DOM injection.** The classification bar uses inline `element.style.*` assignments (no `<style>` tag, no `<link>` tag). GCC High CSP blocks nonce-less `<style>` injection. `dodbl_bannercore` CSS is for Power Pages only; MDA sets all bar styles inline.
- **Cookie name "Accepted" is shared.** All three delivery paths (Power Pages, MDA JS, PCF) use `Accepted=Yes` as the consent cookie. Do not rename it.
- **Solution must be distributed as managed.** Never export unmanaged for shared deployment.

---

## Known Gotchas

- **MDA consent uses `addGlobalNotification`, not a DOM modal.** `dodbl_dodbanner.js` calls `Xrm.App.addGlobalNotification` (type 2, level 3 — Warning) for the consent banner. The old `injectModal()` / `injectCSS()` stack was removed. Do not restore it — the modal approach required window.top DOM injection and GCC High CSP blocked the `<style>` tag.
- **MDA classification bar uses `window.top.document` (known anti-pattern).** No supported UCI API exists for injecting a persistent visible DOM element into the outer shell page. The window.top path is explicitly flagged by MS Solution Checker (Impact: High, Category: Supportability) and accepted as a known risk. See Decision 006.
- **MDA iframes block external stylesheets.** The classification bar uses inline element styles (not `<style>` or `<link>`). GCC High CSP blocks nonce-less `<style>` injection.
- **PCF `bannerEnabled` defaults to `null` in test harness.** The test harness resets `TwoOptions` to no value on reload. Always explicitly set it to `True` before testing. In Canvas Apps, bind to `true` or a toggle variable.
- **Canvas App / Custom Page bundle baking.** When a Canvas App or Custom Page is published, the PCF bundle is snapshotted into the app package at that moment. `pac pcf push` updates the bundle in the environment, but the app will not pick it up until the Canvas App/Custom Page is republished in Power Apps Studio (Save → Publish → Publish this version). In some cases, if the page was already published with a prior bundle version, a full remove/re-add of the PCF control on the page is required — republish alone is insufficient. See Decision 008.
- **Power Pages web files cannot be pre-packaged** — `adx_webfile` requires `Website` FK. Deployers create manually post-import.
- **jQuery was intentionally removed.** Do not re-add. Fade animation uses `requestAnimationFrame`.
- **PCF classification bar styles `_container` directly** (not a child div). Uses individual `style.*` property assignments, not `cssText` (which breaks when font-family contains quoted strings in some browsers).
- **`pcfconfig.json` sets `buildMode: production`.** Plain `npm run build` always produces a minified production bundle with no eval. Use `npm start` or `npm run start:watch` for development. Do not remove this setting — it resolves the Solution Checker `eval` critical violation.
- **`dodbl_BannerType` default is now empty string, not `"DoD"`.** No classification bar renders without an explicit `dodbl_BannerType` env var value. Consent is now driven by `dodbl_ShowConsentBanner` (Boolean) independently of the bar.
- **`shiftMdaHeader()` relies on `<header>` / `[role='banner']` selector.** When `dodbl_BannerPosition` is `Top` or `Both`, the MDA global nav header is shifted down by 28px via `style.top`. If the selector doesn't match the current MDA version's header element, the bar silently overlays the header with no other breakage.
- **PAC CLI v2.6.4 (.NET Framework 4.8)** — some flags differ from newer versions (e.g. `--force-overwrite` not `--overwrite-unmanaged-customizations`).
- **`trimStart()` requires ES2019+** — verify against portal's minimum browser if targeting legacy environments.
- **`data-classification` prefix cascade** — `UNCLASSIFIED` matches `U` (green). `CUI` matches `CU` (purple). `CONFIDENTIAL` uses `CO` (distinct from `CU`). Order matters.
- **Web resource files from PAC CLI have no extension** — extension implied by `WebResourceType` in `.data.xml` (type 1=HTML, type 2=CSS, type 3=JS). Do not add extensions.
- **Auto-generated solution export folders are gitignored** — `DoDBannerLibrary/Controls/`, `DoDBannerLibrary/dvtablesearchs/`, `DoDBannerLibrary/Other/Relationships*` are excluded. Do not commit them.

---

## Active Priorities

1. **v1.2.0 release** — pack managed solution, push git tag `v1.2.0`, create GitHub release
2. **Known bugs (v1.3.0)** — `getCookie` URIError on malformed cookie values; cookie name `Accepted` collision risk; missing `Secure` flag on `setCookie`; `_consentSetup` not reset when `showConsent` cycles without destroy/init
3. **Phase 5** — `dodbl_consent_record` Dataverse table, `DoD Banner — Consent Write` security role
4. **Canvas App demo** — `DoD Banner Preview` canvas app with PCF + property controls (planned for solution)

---

## Where to Look

| Topic | File |
|---|---|
| Shared CSS (source of truth) | `banner-core.css` (repo root) |
| PCF TypeScript source | `pcf/DodBannerControl/DodBannerControl/index.ts` |
| PCF manifest | `pcf/DodBannerControl/DodBannerControl/ControlManifest.Input.xml` |
| MDA form script | `DoDBannerLibrary/WebResources/dodbl_dodbanner` |
| Solution manifest | `DoDBannerLibrary/Other/Solution.xml` |
| Documentation web resource | `DoDBannerLibrary/WebResources/dodbl_docs` |
| Release notes | `DoDBannerLibrary/WebResources/dodbl_release-notes` |
| Power Pages web template source | `DoDBannerLibrary/WebResources/dodbl_webtemplatesource` |
| Banner Demo entity forms | `DoDBannerLibrary/Entities/dodbl_banner_demo/FormXml/` |
| Domain terminology | `.ai/domain.md` |
| Data model | `.ai/data-model.md` |
| Security | `.ai/security.md` |
| Pipelines / deployment | `.ai/pipelines.md` |
| Past decisions | `.ai/decisions/` |
| Release notes | [DoDBannerLibrary/WebResources/dodbl_release-notes](../DoDBannerLibrary/WebResources/dodbl_release-notes) |
| Source banner files | [dod-consent-banner.html](../dod-consent-banner.html), [cui-consent-banner.html](../cui-consent-banner.html), [banner-core.css](../banner-core.css) |
| Security and access | [security.md](security.md) |
| Pipelines and ALM | [pipelines.md](pipelines.md) |
| Technical debt | [debt.md](debt.md) |
| Developer onboarding | [onboarding.md](onboarding.md) |
| Architecture decisions | [decisions/](decisions/) |
| AI session prompt | [bootstrap-prompt.md](bootstrap-prompt.md) |