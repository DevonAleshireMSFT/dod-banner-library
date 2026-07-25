# DoD Banner Library

A managed Power Platform solution providing reusable banner assets for **Power Pages**, **Canvas Apps**, and **Model-Driven Apps** intended for GCC High / DoD IL4/IL5 deployment environments.

Zero external dependencies. No CDN calls. No jQuery.

---

## Project Knowledge: `.ai/` vs `.squad/`

| `.ai/` | `.squad/` |
|---|---|
| Answers: what the product is and why it is built this way | Answers: how the AI team is working and what it decided/did |
| Audience: anyone modifying the code, human or AI | Audience: the AI team and PM |
| Lifespan: durable product truth that outlives the team | Lifespan: session-oriented working memory and running log |
| Decisions = product ADRs in `.ai/adr/`; living facts in `context/domain/data-model/security/pipelines` | Decisions = team direction, scope, routing, and session outcomes in `.squad/decisions.md` |

Rule: `.squad/decisions.md` never restates a product decision — it links to the `.ai/` ADR or living-doc fact. New contributors should read `.ai/context.md` first to understand the product; `.squad/` is the AI team's operating state.

Public-repo note: do not add internal-only or confidential content to this repository. Keep requirements and contributor guidance generalized, public-safe, and linked to `.ai/security.md` when disclosure handling matters.

---

## What's Included

### Web Resources

| Schema Name | Type | Purpose |
|---|---|---|
| `dodbl_bannercore` | CSS | Shared stylesheet — responsive consent modal layout and classification mark color rules |
| `dodbl_dodconsentbanner` | HTML | DoD consent modal — vanilla JS cookie-based consent tracking with fade animation |
| `dodbl_cuiconsentbanner` | HTML | CUI classification mark fragment — CSS-only, no JavaScript required |
| `dodbl_dodbanner` | JS | Model-Driven App form `OnLoad` script — reads `dodbl_` environment variables and injects the classification bar |
| `dodbl_banner-launch-page` | HTML | Model-Driven App custom home page — single consent entry point with navigation tiles into the management app |
| `dodbl_webtemplatesource` | HTML | Power Pages Liquid Web Template source — copy/paste setup page |
| `dodbl_docs` | HTML | In-environment documentation page |
| `dodbl_release-notes` | HTML | Version history and changelog |

### Other Components

| Component | Type | Purpose |
|---|---|---|
| `dodbl_DoDBannerLibraryManagement` | Model-Driven App | In-environment access to docs, release notes, and web template source |
| `dodbl_BannerEnabled` | Environment Variable | Global on/off toggle (Boolean, default: `true`) |
| `dodbl_BannerType` | Environment Variable | Classification bar to render — `CUI`, `UNCLASSIFIED`, `SECRET`, etc. Empty = no bar. (String) |
| `dodbl_ConsentExpiryDays` | Environment Variable | Cookie lifetime in days (Number, default: `30`) |
| `dodbl_DoDConsentText` | Environment Variable | AO-approved consent text override (String, optional) |
| `dodbl_ShowConsentBanner` | Environment Variable | Legacy form-script consent notification toggle (Boolean); the v1.3 management app consent gate uses `dodbl_banner-launch-page` |
| `dodbl_BannerPosition` | Environment Variable | Classification bar placement — `Bottom` (default), `Top`, or `Both` (String) |

---

## Prerequisites

- Power Platform environment (GCC High, IL4/IL5, or commercial)
- System Administrator or System Customizer role to import the solution
- For Power Pages deployment: access to Portal Management app

---

## Quick Start

### 1 — Import the managed solution

```powershell
pac solution import --path DoDBannerLibrary_managed.zip --activate-plugins
```

Or import through the Power Apps maker portal: **Solutions → Import solution**.

### 2 — Verify the import

Open the **DoD Banner Library Management** app from the app switcher. Navigate to **Documentation** to confirm all components loaded correctly.

### 3 — Complete the post-import checklist

The in-solution documentation page (`dodbl_docs`) contains the full post-import checklist. The key steps are:

1. Verify all eight web resources and the management app are present
2. **Power Pages** — create `banner-core.css` and `dod-consent-banner.js` web files on your site
3. **Power Pages** — create the `dod-consent-banner` Web Template using the source in `dodbl_webtemplatesource`

---

## Usage

### DoD Consent Modal

Add this markup to your page layout (Power Pages header Web Template, MDA form, or Canvas App HTML control):

```html
<div id="cookieConsent">
  <a id="closeCookieConsent">&#x2715;</a>
  <p>Your AO-approved system-use notification text here.</p>
  <a class="cookieConsentOK">I Acknowledge</a>
</div>
<div class="consentBackground"></div>
```

> **Note:** Do not rename `id="cookieConsent"`, `id="closeCookieConsent"`, `class="cookieConsentOK"`, or `class="consentBackground"`. The JavaScript references these by exact name.

For Power Pages, use the Liquid Web Template approach — open `dodbl_webtemplatesource` for step-by-step instructions.

### CUI Classification Mark

Add the `data-classification` attribute to any container element. No JavaScript required.

```html
<!-- Top banner -->
<div class="classification-banner" data-classification="CUI">
  <!-- page content -->
</div>

<!-- Bottom banner -->
<div class="classification-banner-bot" data-classification="S">
  <!-- page content -->
</div>

<!-- Custom label text -->
<div class="classification-banner"
     data-classification="CUI"
     data-banner-content="CONTROLLED UNCLASSIFIED INFORMATION">
</div>
```

#### Classification Levels

| `data-classification` value | Color | Hex |
|---|---|---|
| `CUI` (starts with `CU`) | Purple | `#5a04b0` |
| `U` (starts with `U`) | Green | `#5cb85c` |
| `CONFIDENTIAL` (starts with `CO`) | Blue | `#286090` |
| `SECRET` (starts with `S`) | Red | `#d9534f` |
| `TOP SECRET` (starts with `T`) | Orange | `#f0ad4e` |

> **The `data-classification` HTML attribute is case-sensitive** (it's matched by CSS attribute selectors) — use the canonical uppercase forms (`CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`). Note: this applies only to the static HTML/CSS usage above — the environment-variable–driven banner below is case-insensitive.

---

## Environment Variables

These variables are available for Canvas App and Model-Driven App integrations (Phase 4). For Power Pages, use the equivalent [site settings](https://learn.microsoft.com/en-us/power-pages/configure/configure-site-settings) instead.

| Schema Name | Type | Default | Description |
|---|---|---|---|
| `dodbl_BannerEnabled` | Boolean | `true` | Set to `false` to disable banners environment-wide |
| `dodbl_BannerType` | String | *(empty)* | Classification bar to render: `CUI`, `UNCLASSIFIED`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`. Empty = no bar |
| `dodbl_ConsentExpiryDays` | Number | `30` | Days before the consent cookie expires |
| `dodbl_DoDConsentText` | String | *(empty)* | AO-approved consent text; used by the MDA home-page consent gate after query-string overrides and before the built-in default |
| `dodbl_ShowConsentBanner` | Boolean | `false` | Legacy form-script consent notification toggle; the v1.3 management app consent gate uses the custom home page instead of a global notification |
| `dodbl_BannerPosition` | String | `Bottom` | Classification bar placement: `Bottom`, `Top`, or `Both`. `Top` shifts the MDA nav header down 28 px |

Environment-variable values for the JS-driven banner are case-insensitive: `dodbl_BannerType` is normalized and prefix-matched (`secret`, `SECRET`, and `Secret` all render the red `SECRET` bar, and bar text is always uppercase); `dodbl_BannerEnabled` and `dodbl_BannerPosition` are also compared case-insensitively.

---

## Known Limitations

- Consent acknowledgment does not persist across sessions when `DodBannerControl` is used inside a Canvas app; the consent modal reappears each session. This is a Power Apps canvas code-component sandbox limitation. The modal still functions per session, persistent Canvas consent is planned for v1.4.0 (tracked in issue #21), and the Model-Driven App consent gate (`dodbl_banner-launch-page`) persists consent normally.

## Security Notes

- **GCC High / IL4/IL5 safe** — no external CDN calls, no third-party scripts
- Consent is tracked **client-side only** via browser cookie in v1.3, including the new Model-Driven App home-page consent gate — no server-side audit log yet
- The Model-Driven App home-page consent gate is a UX-level entry pattern, not hard security enforcement; deep links, global search, pinned items, and recent items can bypass it (tracked in issue #13)
- The jQuery dependency present in prior versions was **removed in v1.0**
- Review all scripts before deploying to a production environment
- Replace placeholder consent text with your organization's AO-approved language

---

## Compliance & AC-8 Posture

This library helps present system-use notification text and classification markings, but it does **not** define or guarantee an adopter's accreditation boundary.

For AC-8 (System Use Notification), the expected posture for GCC High / DoD tenants is that AC-8 is normally inherited at the tenant, workstation, or network logon boundary — for example, the Entra ID / Microsoft 365 sign-in banner or Windows logon banner. Once a user is authenticated into the government tenant, that authenticated tenant access is the real boundary. **Each adopting organization must confirm this inheritance assumption with its own Authorizing Official (AO), ISSM, or security personnel.**

In-app consent in this library is optional, supplementary hardening. The agreed consent configuration model is `dodbl_ConsentMode`:

| Value | Meaning |
|---|---|
| `Off` | No in-app consent prompt; this is the default posture |
| `HomePage` | Show the `dodbl_banner-launch-page` consent experience |
| `GlobalNotification` | Show the Model-Driven App shell notification through `dodbl_dodbanner` / `Xrm.App.addGlobalNotification` |

These modes are informational/UX controls, not technical access-control boundaries. Client-side consent can be bypassed through deep links, browser developer tools, disabled JavaScript, or direct API/OData access. Organizations that require enforced acknowledgement beyond authenticated tenant access should use platform-level controls such as Entra Conditional Access Terms-of-Use, security-role gating, or a gated entry app. GitHub issue #13 tracks this as optional advanced-enforcement guidance, not as a guarantee provided by this library.

The library's primary compliance-significant contribution is the data classification marking bar (`CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`), which supports visible marking/handling expectations such as CUI handling. Do not assume a precise control mapping without review; consult your ISSM or security personnel for the controls and data-handling requirements that apply to your environment.

Adopters are responsible for:

1. Confirming with their AO / ISSM how AC-8 is satisfied or inherited within their authorization boundary.
2. Supplying AO-approved system-use-notification language in `dodbl_DoDConsentText` if in-app consent is enabled.
3. Determining the classification, CUI, and data-handling requirements for their own environment.

---

## Roadmap

**v1.3 (Released 2026-07-24)**

- Model-Driven App consent gate custom home page (`dodbl_banner-launch-page`) with blocking overlay before the management app home content is shown
- Custom home page is the single MDA consent entry point; the duplicate shell-level global notification banner was removed
- `dodbl_DoDConsentText` now drives the home-page consent copy after query-string overrides and before the built-in warning fallback
- Consent cookie `dodbl_Accepted` uses `Secure; SameSite=Strict`, and the acknowledge path consistently reveals the home content
- Known limitation: the sitemap/home-page gate is UX-level only, not hard enforcement; issue #13 tracks deep-link/search/pinned/recent bypasses

**v1.4 (Planned)**

- Dataverse consent audit table (`dodbl_consent_record`)
- Security role `DoD Banner — Consent Write`
- PCF acknowledge action writes consent records (#10)
- Model-Driven App JS acknowledge action writes consent records (#11)
- Power Pages server-side consent record write (#12)

---

## AI Disclosure

Assets, scripts, and documentation in this solution were developed with the assistance of **GitHub Copilot** (Claude Sonnet 4.6). All output was reviewed by a human before inclusion. Apply the same due diligence you would to any third-party code.

---

## Publisher

**Prefix:** `dodbl_` | **Solution:** `DoDBannerLibrary`
