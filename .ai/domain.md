# DoD Banner Library — Domain Terminology

> Use these definitions when discussing or generating code for this project.

---

## Banner Types

| Value (`bannerType`) | Display | Color | Description |
|---|---|---|---|
| `DoD` | Full-page consent modal | n/a (overlay) | DoD system-use notification. Must be acknowledged before use. Cookie-based, one-time per browser session / expiry period. |
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

**Consent cookie** — A browser cookie named `Accepted` with value `Yes`. Presence of this cookie suppresses the DoD banner on subsequent page loads until the cookie expires. The cookie name must be identical across all three delivery paths (Power Pages, MDA JS, PCF).

**Consent expiry** — The number of days before the `Accepted` cookie expires. Controlled by `consentExpiryDays` / `dodbl_ConsentExpiryDays` env var. Default: 1 day.

**AO-approved text** — The Authorizing Official (AO) may require specific system-use notification wording. The `consentText` input / `dodbl_DoDConsentText` env var provides an override for the default text.

---

## Platform Terminology

**GCC High** — Microsoft Government Community Cloud High. Isolated sovereign cloud for DoD IL4/IL5 workloads. Uses `*.microsoftdynamics.us` and `*.powerapps.us` URLs. Zero external CDN calls allowed.

**MDA (Model-Driven App)** — Power Apps canvas-like app driven by the Dataverse data model. Forms open inside an iframe; external stylesheets loaded via `<link>` are unreliable inside the iframe context.

**Canvas App** — Power Apps low-code app. PCF field controls are embedded as custom controls bound to a data property.

**Power Pages** — Microsoft's portal product (formerly Power Apps Portals). Serves web pages to anonymous or authenticated external users. Liquid templates, web files, web templates.

**Liquid** — Server-side templating language used by Power Pages. The `dodbl_webtemplatesource` web resource contains the Liquid fragment deployers copy to a Web Template record.

**Web Template** — A Power Pages record (not a Dataverse web resource) containing Liquid markup. Must be created manually post-import because it has an environment-specific `Website` FK.

**Web file** — A Power Pages record that serves a static file (CSS, JS, image) to the portal. Must be created manually post-import.

**AppModuleSiteMap** — The navigation definition for a Model-Driven App. This project's map has "Resources" (docs, notes, web template source) and "Demo" (dodbl_banner_demo) groups.

---

## Code Architecture

**`DoDBannerLibrary.DodBanner`** — IIFE namespace in `dodbl_dodbanner.js`. Entry point: `DoDBannerLibrary.DodBanner.onFormLoad(executionContext)`.

**`DodBannerControl`** (PCF) — TypeScript class implementing `ComponentFramework.StandardControl<IInputs, IOutputs>`. Container is the bound `<div>` provided by the PCF runtime. `bannerType = "DoD"` hides the container and shows a full-page modal; any other value renders a color bar inside the container.

**`injectCSS()`** — Function in `dodbl_dodbanner.js` that creates a `<style data-dodbl-core>` element with the full consent modal CSS embedded as a template literal. Idempotent (skips if tag already present). CSS uses `position: fixed` for MDA chrome layering.

**`getClassificationColor(bannerType)`** — PCF helper. Returns hex color string based on startsWith match of the bannerType argument. Unknown types default to `#5e5e5e` (grey).

**`clearBar()`** — PCF helper. Resets all inline styles on `_container` and removes the `data-dodbl-bar` attribute. Called before every render to avoid leftover state.
