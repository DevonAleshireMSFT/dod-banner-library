---
project: DoD Banner Library
schema-prefix: dodbl_
platform: Power Platform / Dataverse
cloud: GCC High (intended DoD IL4/IL5 deployment environments)
context-version: 2.0.0
last-updated: 2026-07-25
owner: Tech Lead
review-cadence: every-sprint
---

# DoD Banner Library — AI Context

> This is the primary bootstrap document. An AI assistant should read this file first before asking any questions or generating any code.

This `.ai/` framework grounds the Squad agents — see `.squad/team.md` → Domain Grounding for the role→file map and loading rules.`r`n`r`n## AI Knowledge Boundary

- `.ai/` = durable product knowledge and Product ADRs.
- `.squad/` = AI-team working state.
- Squad links to `.ai/adr/` and does not restate product decisions.

> Structural migration note: `.ai/decisions/` (3-digit ADR filenames) moved to `.ai/adr/` (4-digit ADR filenames) in the v2.0.0 slim AI Context Framework migration.

---

## What This Is

The **DoD Banner Library** is a managed Power Platform solution that provides reusable CUI classification marks and DoD system-use notification consent banners for Canvas Apps, Model-Driven Apps, and Power Pages. It is intended for GCC High / DoD IL4/IL5 deployment environments; this repository does not assert certification or compliance status. Zero external CDN dependencies. All assets packaged as solution web resources under publisher prefix `dodbl_`.

---

## Current State

> **Branch:** `main`
> **Released:** v1.5.0 admin config screen pending release
> **Environment (Dev):** v1.4.1 UAT pending
> **PCF control:** `DoDBannerLibrary.DodBannerControl` v1.2.1
> **License:** MIT License added (Copyright 2026 Devon Aleshire; personal; no patent grant)

### Web Resources
- ✅ `dodbl_bannercore` — shared CSS (classification marks + consent modal layout)
- ✅ `dodbl_dodconsentbanner` — DoD consent modal HTML/JS (vanilla JS, Power Pages use)
- ✅ `dodbl_cuiconsentbanner` — CUI classification mark HTML (CSS-only, Power Pages use)
- ✅ `dodbl_webtemplatesource` — Power Pages Web Template source (copy/paste Liquid page)
- ✅ `dodbl_dodbanner` — MDA form OnLoad JS script; reads env vars via Xrm.WebApi. Uses `Xrm.App.addGlobalNotification` for consent (supported UCI API, no window.top). Uses `window.top.document` DOM injection for classification bar only (known anti-pattern — see ADR 0006). Supports `Top`/`Bottom`/`Both` bar placement; shifts MDA nav header down when bar is at top.
- ✅ `dodbl_docs` — in-solution documentation (post-import checklist, all web resources documented). Contains sidebar link back to Home.
- ✅ `dodbl_release-notes` — version history (latest first, oldest last). v1.4.1 patch entry is latest. Contains back-link to Home.
- ✅ `dodbl_banner-config` — admin-only banner configuration screen (v1.5.0). Reads/writes the `environmentvariablevalue` records for `dodbl_BannerEnabled`, `dodbl_BannerType`, `dodbl_BannerPosition`, and `dodbl_ConsentExpiryDays` through `parent.Xrm.WebApi`. Gated to `DoD Banner - Config Admin` / `System Administrator`; classification changes require confirmation. See ADR 0011.
- ✅ `dodbl_banner-launch-page` — MDA consent gate landing page (shipped in v1.3.0). Full-page HTML; optional system-use notification surface on app entry. Sets `dodbl_Accepted` with `Secure; SameSite=Strict`, calls `parent.Xrm.App.addGlobalNotification` belt-and-suspenders, then fades overlay. Provides nav tiles to Documentation, Release Notes, Web Template Source, and Canvas App Demo. Implements split-before-decode `getCookie()` pattern (URIError fix). All `parent.Xrm` calls wrapped in try/catch.

### PCF Control
- ✅ `DodBannerControl` (namespace `DoDBannerLibrary`) — PCF field control for Canvas Apps and Custom Pages (MDA), version v1.2.1
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
- ✅ `dodbl_DoDBannerLibraryManagement` — MDA management app; sitemap: **Home** (dodbl_banner-launch-page, first) → Banner Configuration (dodbl_banner-config) → Consent Records → Resources (docs, release notes, web template source) → Canvas App Demo
- ✅ `dodbl_canvasappdemo_bb4ae` — Canvas App demo (PCF control)
- ✅ `dodbl_DoDBannerLibrary.DodBannerControl` — PCF registered as custom control (type 66) in solution
- ✅ Solution version: `1.5.0.0` (main)
- 🔲 v1.4.0 follow-ups tracked live in GitHub Project: #21 (Canvas consent persistence), #22 (technical docs + repo artifacts), #23 (IL/compliance wording)

> **Note:** `dodbl_banner_demo` entity was intentionally removed from the solution in v1.3.0. The demo is now the Canvas App (`dodbl_canvasappdemo_bb4ae`).

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
- **Public repo hygiene.** Do not commit internal-only or confidential content; generalize requirements and see `.ai/security.md` for disclosure guidance.
- **Publisher prefix is `dodbl_`.** Every new Dataverse component, web resource, table, column, environment variable, and PCF namespace must use this prefix.
- **Do not change consent banner element IDs/classes.** `#cookieConsent`, `.cookieConsentOK`, `.consentBackground` are referenced by exact name in `dodbl_dodconsentbanner` (Power Pages) and `DodBannerControl` (PCF). Renaming breaks everything. Note: `#closeCookieConsent` was intentionally removed from the PCF modal in v1.2 — do not restore it. It still exists in `dodbl_dodconsentbanner` (Power Pages path).
- **Release notes are reverse chronological.** `dodbl_release-notes` always lists the newest version (or Planned) at the top and oldest at the bottom. When adding a new version block, insert it above the previous latest, and move the Planned block above the new entry.
- **CSS/data-classification values are case-sensitive.** `data-classification` is matched by CSS attribute selectors — always use `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`. Not lowercase. The JS/environment-variable `dodbl_BannerType` path is case-insensitive.
- **Do not include a website record in the solution.** Power Pages web files need a `Website` FK that is environment-specific.
- **MDA consent uses `addGlobalNotification` — not DOM injection.** The classification bar uses inline `element.style.*` assignments (no `<style>` tag, no `<link>` tag). GCC High CSP blocks nonce-less `<style>` injection. `dodbl_bannercore` CSS is for Power Pages only; MDA sets all bar styles inline.
- **Consent cookie is `dodbl_Accepted`.** All cookie writes must include `Secure; SameSite=Strict` and remain consistent across PCF (`index.ts`), MDA JS (`dodbl_dodbanner`), and home page (`dodbl_banner-launch-page`). Orphaned legacy `Accepted` cookies may cause one re-prompt after upgrade.
- **Solution must be distributed as managed.** Never export unmanaged for shared deployment.
- **Banner configuration is admin-only.** `dodbl_BannerType` is a classification setting. Only `dodbl_banner-config` edits env var values in-app, only for holders of `DoD Banner - Config Admin` or `System Administrator`, and Dataverse privileges on `environmentvariablevalue` — not the client-side role check — are the enforcement boundary.

---

## Known Gotchas

- **MDA consent uses `addGlobalNotification`, not a DOM modal.** `dodbl_dodbanner.js` calls `Xrm.App.addGlobalNotification` (type 2, level 3 — Warning) for the consent banner. The old `injectModal()` / `injectCSS()` stack was removed. Do not restore it — the modal approach required window.top DOM injection and GCC High CSP blocked the `<style>` tag.
- **MDA classification bar uses `window.top.document` (known anti-pattern).** No supported UCI API exists for injecting a persistent visible DOM element into the outer shell page. The window.top path is explicitly flagged by MS Solution Checker (Impact: High, Category: Supportability) and accepted as a known risk. See ADR 0006.
- **MDA iframes block external stylesheets.** The classification bar uses inline element styles (not `<style>` or `<link>`). GCC High CSP blocks nonce-less `<style>` injection.
- **PCF `bannerEnabled` defaults to `null` in test harness.** The test harness resets `TwoOptions` to no value on reload. Always explicitly set it to `True` before testing. In Canvas Apps, bind to `true` or a toggle variable.
- **Canvas App / Custom Page bundle baking.** When a Canvas App or Custom Page is published, the PCF bundle is snapshotted into the app package at that moment. `pac pcf push` updates the bundle in the environment, but the app will not pick it up until the Canvas App/Custom Page is republished in Power Apps Studio (Save → Publish → Publish this version). In some cases, if the page was already published with a prior bundle version, a full remove/re-add of the PCF control on the page is required — republish alone is insufficient. See ADR 0008.
- **Canvas consent persistence limitation.** PCF sandbox cookie writes do not surface to the Canvas host origin, so Canvas consent is session-scoped today; MDA path persists normally. Tracked in [#21](https://github.com/DevonAleshireMSFT/dod-banner-library/issues/21) for v1.4.0.
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

## GitHub Project Management

**Project:** https://github.com/users/DevonAleshireMSFT/projects/3
**Repo:** `DevonAleshireMSFT/dod-banner-library`
**gh CLI:** `gh issue`, `gh pr`, `gh project item-add 3 --owner DevonAleshireMSFT --url <url>`

### Backlog

Backlog is tracked live in GitHub, not mirrored here. Use the GitHub Project for current status; static issue tables drift.

Known follow-ups: #21 (Canvas consent persistence), #22 (technical docs + repo artifacts), #23 (IL/compliance wording), plus the v1.5 ALM story tracked in the project.

### Project Management Rules

> Follow these when implementing any issue.

- **Reference the issue in every commit** that implements it: `git commit -m "Fix: getCookie URIError (#3)"`
- **Close the issue on merge** — use `gh issue close #N --comment "Resolved in <PR link>"` after the PR merges, or add `Closes #N` to the PR description.
- **Use GitHub Project as source of truth** — do not mirror per-issue rows in this file.
- **Update the Key Rule** that corresponds to the fix when behavior changes.
- **Add new issues to project** — after creating any new issue: `gh project item-add 3 --owner DevonAleshireMSFT --url <issue-url>`
- **Bump solution version** in `DoDBannerLibrary/Other/Solution.xml` for every release that changes solution components.
- **Update `dodbl_release-notes`** (reverse chronological) with each release.

---

## Active Priorities

1. **v1.4.0 — Canvas consent persistence** — PCF sandbox cookie limitation; design host-persisted output property / Dataverse-backed path ([#21](https://github.com/DevonAleshireMSFT/dod-banner-library/issues/21)).
2. **v1.4.0 — Documentation and compliance wording** — technical docs + repo artifacts ([#22](https://github.com/DevonAleshireMSFT/dod-banner-library/issues/22)); reword IL/compliance language as intended environment, not certification ([#23](https://github.com/DevonAleshireMSFT/dod-banner-library/issues/23)).
3. **v1.5.0 — ALM story** — track live in GitHub Project; do not mirror status here.

---

## Where to Look

| Topic | File |
|---|---|
| Shared CSS (source of truth) | `banner-core.css` (repo root) |
| PCF TypeScript source | `pcf/DodBannerControl/DodBannerControl/index.ts` |
| PCF manifest | `pcf/DodBannerControl/DodBannerControl/ControlManifest.Input.xml` |
| MDA consent gate home page | `DoDBannerLibrary/WebResources/dodbl_banner-launch-page` |
| MDA admin config screen | `DoDBannerLibrary/WebResources/dodbl_banner-config` |
| MDA form script | `DoDBannerLibrary/WebResources/dodbl_dodbanner` |
| Solution manifest | `DoDBannerLibrary/Other/Solution.xml` |
| Documentation web resource | `DoDBannerLibrary/WebResources/dodbl_docs` |
| Release notes | `DoDBannerLibrary/WebResources/dodbl_release-notes` |
| Power Pages web template source | `DoDBannerLibrary/WebResources/dodbl_webtemplatesource` |
| Canvas App demo | `dodbl_canvasappdemo_bb4ae` solution component |
| Domain terminology | `.ai/domain.md` |
| Data model | `.ai/data-model.md` |
| Security | `.ai/security.md` |
| Pipelines / deployment | `.ai/pipelines.md` |
| Product ADRs | `.ai/adr/` |
| Release notes | [DoDBannerLibrary/WebResources/dodbl_release-notes](../DoDBannerLibrary/WebResources/dodbl_release-notes) |
| Source banner files | [dod-consent-banner.html](../dod-consent-banner.html), [cui-consent-banner.html](../cui-consent-banner.html), [banner-core.css](../banner-core.css) |
| Security and access | [security.md](security.md) |
| Pipelines and ALM | [pipelines.md](pipelines.md) |
| Architecture decisions | [adr/](adr/) |
