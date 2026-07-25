# DoD Banner Library — Domain Terminology

> Use these definitions when discussing or generating code for this project.

---

## Banner Types

| Value (`bannerType`) | Display | Color | Description |
|---|---|---|---|
| `DoD` | Consent notification/modal | n/a | DoD system-use notification when enabled. Acknowledgement is supplementary tooling, not an access-control boundary. Cookie-based, one-time per browser session / expiry period where supported. |
| `CUI` | Classification bar | Purple `#5a04b0` | Controlled Unclassified Information |
| `U` | Classification bar | Green `#5cb85c` | Unclassified |
| `CONFIDENTIAL` / `CO` | Classification bar | Blue `#286090` | Confidential |
| `SECRET` / `S` | Classification bar | Red `#d9534f` | Secret |
| `TOP SECRET` / `T` | Classification bar | Orange `#f0ad4e` | Top Secret |

`bannerType` matching uses `startsWith` (case-insensitive in JS, case-sensitive in CSS). Canonical full values are used in CSS (`data-classification="CUI"`, `"CONFIDENTIAL"`, etc.).

---

## Solution Concepts

**Managed solution** — A Power Platform solution package where components are locked against downstream customization. This project is distributed managed only.

**Web resource** — A file stored in Dataverse and served by the platform. Types used: HTML (1), CSS (2), JS (3). Files exported by PAC CLI have no extension — extension is inferred from the `.data.xml` `WebResourceType` field.

**PCF (PowerApps Component Framework)** — A framework for building custom code controls embedded in Canvas Apps and Model-Driven Apps. Requires a Premium license or Managed Environment ("Enable code components" toggle). Two templates: `field` (single-value, this project) and `dataset`.

**Environment variable** — A Dataverse first-class setting scoped to an environment. Has a definition (schema, type, default) and an optional current-value override per environment. Accessed via `Xrm.WebApi` in MDA scripts.

**Publisher prefix** — The alphanumeric namespace prefix applied to all custom components. This project uses `dodbl_`. Prevents collisions with other solutions.

---

## Consent / Cookie Concepts

**Consent cookie** — MDA JS, the MDA launch page, and PCF use `dodbl_Accepted=Yes` with `Secure; SameSite=Strict`. Power Pages (`dodbl_dodconsentbanner`) may still use legacy `Accepted=Yes` until refreshed. Presence suppresses the consent surface until expiry where cookie persistence is supported.

**Consent expiry** — The number of days before the consent cookie expires. Controlled by `consentExpiryDays` / `dodbl_ConsentExpiryDays` env var. Default: 1 day.

**AO-approved text** — The Authorizing Official (AO) may require specific system-use notification wording. The `consentText` input / `dodbl_DoDConsentText` env var provides an override for the default text.

---

## Platform Terminology

**GCC High** — Microsoft Government Community Cloud High, the intended target environment for DoD IL4/IL5 deployments. Uses `*.microsoftdynamics.us` and `*.powerapps.us` URLs. Zero external CDN calls allowed.

**MDA (Model-Driven App)** — Power Apps canvas-like app driven by the Dataverse data model. Forms open inside an iframe; external stylesheets loaded via `<link>` are unreliable inside the iframe context.

**Canvas App** — Power Apps low-code app. PCF field controls are embedded as custom controls bound to a data property.

**Power Pages** — Microsoft's portal product (formerly Power Apps Portals). Serves web pages to anonymous or authenticated external users. Liquid templates, web files, web templates.

**Liquid** — Server-side templating language used by Power Pages. The `dodbl_webtemplatesource` web resource contains the Liquid fragment deployers copy to a Web Template record.

**Web Template** — A Power Pages record (not a Dataverse web resource) containing Liquid markup. Must be created manually post-import because it has an environment-specific `Website` FK.

**Web file** — A Power Pages record that serves a static file (CSS, JS, image) to the portal. Must be created manually post-import.

**AppModuleSiteMap** — The navigation definition for a Model-Driven App. This project's map has Home (`dodbl_banner-launch-page`), Resources (docs, notes, web template source), and Canvas App Demo (`dodbl_canvasappdemo_bb4ae`). The old `dodbl_banner_demo` entity was removed in v1.3.0.

---

## Code Architecture

**`DoDBannerLibrary.DodBanner`** — IIFE namespace in `dodbl_dodbanner.js`. Entry point: `DoDBannerLibrary.DodBanner.onFormLoad(executionContext)`.

**`DodBannerControl`** (PCF) — TypeScript class implementing `ComponentFramework.StandardControl<IInputs, IOutputs>`. Container is the bound `<div>` provided by the PCF runtime. `showConsent` controls the consent modal; `bannerType` controls the classification bar.

**PCF properties** — `bannerEnabled` toggles rendering; `bannerType` selects the classification bar; `showConsent` (TwoOptions, v1.2+) shows consent independently; `consentExpiryDays` and `consentText` configure the consent surface.

**MDA consent rendering** — `dodbl_dodbanner.js` uses `Xrm.App.addGlobalNotification`, not the removed `injectModal()` / `injectCSS()` stack. MDA classification bars use inline element styles because GCC High CSP blocks nonce-less `<style>` injection.

**`getClassificationColor(bannerType)`** — PCF helper. Returns hex color string based on startsWith match of the bannerType argument. Unknown types default to `#5e5e5e` (grey).

**`clearBar()`** — PCF helper. Resets all inline styles on `_container` and removes the `data-dodbl-bar` attribute. Called before every render to avoid leftover state.
