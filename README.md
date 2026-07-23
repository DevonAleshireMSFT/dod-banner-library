# DoD Banner Library

A managed Power Platform solution providing reusable, GCC High–safe banner assets for **Power Pages**, **Canvas Apps**, and **Model-Driven Apps** deployed in DoD environments (IL4/IL5).

Zero external dependencies. No CDN calls. No jQuery.

---

## What's Included

### Web Resources

| Schema Name | Type | Purpose |
|---|---|---|
| `dodbl_bannercore` | CSS | Shared stylesheet — responsive consent modal layout and classification mark color rules |
| `dodbl_dodconsentbanner` | HTML | DoD consent modal — vanilla JS cookie-based consent tracking with fade animation |
| `dodbl_cuiconsentbanner` | HTML | CUI classification mark fragment — CSS-only, no JavaScript required |
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
| `dodbl_ShowConsentBanner` | Environment Variable | Set to `yes`/`true` to show the DoD system-use notification (Boolean) |
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

1. Verify all six web resources and the management app are present
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

> **Values are case-sensitive.** `cui` will not match CUI purple — use `CUI`.

---

## Environment Variables

These variables are available for Canvas App and Model-Driven App integrations (Phase 4). For Power Pages, use the equivalent [site settings](https://learn.microsoft.com/en-us/power-pages/configure/configure-site-settings) instead.

| Schema Name | Type | Default | Description |
|---|---|---|---|
| `dodbl_BannerEnabled` | Boolean | `true` | Set to `false` to disable banners environment-wide |
| `dodbl_BannerType` | String | *(empty)* | Classification bar to render: `CUI`, `UNCLASSIFIED`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`. Empty = no bar |
| `dodbl_ConsentExpiryDays` | Number | `30` | Days before the consent cookie expires |
| `dodbl_DoDConsentText` | String | *(empty)* | AO-approved consent text; overrides the built-in default when set |
| `dodbl_ShowConsentBanner` | Boolean | `false` | Set to `yes`/`true` to show the DoD system-use notification via `Xrm.App.addGlobalNotification` |
| `dodbl_BannerPosition` | String | `Bottom` | Classification bar placement: `Bottom`, `Top`, or `Both`. `Top` shifts the MDA nav header down 28 px |

---

## Security Notes

- **GCC High / IL4/IL5 safe** — no external CDN calls, no third-party scripts
- Consent is tracked **client-side only** via browser cookie in v1.0 — no server-side audit log
- The jQuery dependency present in prior versions was **removed in v1.0**
- Review all scripts before deploying to a production environment
- Replace placeholder consent text with your organization's AO-approved language

---

## Roadmap

**v1.1 (Released 2026-07-23)**

- PCF Virtual Component (`DodBannerControl`) for Canvas Apps
- JavaScript web resource (`dodbl_dodbanner`) for Model-Driven App form `OnLoad` — consent via `Xrm.App.addGlobalNotification`, classification bar via `window.top` DOM injection
- `dodbl_ShowConsentBanner` — decouples consent notification from classification bar
- `dodbl_BannerPosition` — `Top`, `Bottom`, or `Both` classification bar placement

**v1.2 (Planned)**

- Dataverse consent audit table (`dodbl_consent_record`)
- Security role `DoD Banner — Consent Write`

---

## AI Disclosure

Assets, scripts, and documentation in this solution were developed with the assistance of **GitHub Copilot** (Claude Sonnet 4.6). All output was reviewed by a human before inclusion. Apply the same due diligence you would to any third-party code.

---

## Publisher

**Prefix:** `dodbl_` | **Solution:** `DoDBannerLibrary`
