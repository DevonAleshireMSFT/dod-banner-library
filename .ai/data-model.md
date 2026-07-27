# DoD Banner Library — Data Model

> Tables, columns, environment variables, and solution components defined in this project.

---

## Solution Components

| Unique Name | Type | Description |
|---|---|---|
| `dodbl_bannercore` | Web Resource (CSS, type 2) | Shared stylesheet — classification marks + consent modal layout |
| `dodbl_dodconsentbanner` | Web Resource (HTML, type 1) | DoD consent modal (Power Pages use) |
| `dodbl_cuiconsentbanner` | Web Resource (HTML, type 1) | CUI classification mark fragment (Power Pages use) |
| `dodbl_webtemplatesource` | Web Resource (HTML, type 1) | Power Pages Liquid Web Template source (copy/paste) |
| `dodbl_dodbanner` | Web Resource (JS, type 3) | MDA form OnLoad script |
| `dodbl_docs` | Web Resource (HTML, type 1) | In-solution setup documentation |
| `dodbl_release-notes` | Web Resource (HTML, type 1) | Version history and changelog |
| `dodbl_BannerEnabled` | Environment Variable (TwoOptions) | Master on/off switch for the banner |
| `dodbl_BannerType` | Environment Variable (String) | Classification bar type: empty, `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`; `DoD` legacy alias |
| `dodbl_ConsentExpiryDays` | Environment Variable (Decimal) | Cookie lifetime in days. Default: 1 |
| `dodbl_DoDConsentText` | Environment Variable (String) | AO-approved consent text override |
| `dodbl_ShowConsentBanner` | Environment Variable (TwoOptions) | MDA consent notification toggle |
| `dodbl_BannerPosition` | Environment Variable (String) | MDA classification bar position: `Top`, `Bottom`, `Both` |
| `dodbl_DoDBannerLibraryManagement` | Model-Driven App | Management app — docs, demo, release notes |
| `dodbl_DoDBannerLibraryManagement` | App Module Site Map | Navigation for management app |
| `dodbl_DoDBannerLibrary.DodBannerControl` | PCF Custom Control (type 66) | Canvas App classification bar + DoD modal |
| `dodbl_banner_demo` | Removed custom table | Removed in v1.3.0; demo is now Canvas App `dodbl_canvasappdemo_bb4ae` |

---

## Environment Variables

| Schema Name | Display Name | Type | Default | Description |
|---|---|---|---|---|
| `dodbl_BannerEnabled` | Banner Enabled | TwoOptions | true | Master toggle. `false` = no banner shown at all. |
| `dodbl_BannerType` | Banner Type | String | _(empty)_ | Classification bar type. Empty = no bar. See domain.md for valid values. |
| `dodbl_ConsentExpiryDays` | Consent Expiry Days | Decimal | `1` | Days before `dodbl_Accepted` cookie expires. Set to `365` for yearly consent. |
| `dodbl_DoDConsentText` | DoD Consent Text | String | _(default text in code)_ | Override text for the DoD system-use notification body. AO-approved. |
| `dodbl_ShowConsentBanner` | Show Consent Banner | TwoOptions | false | Shows MDA consent notification independently of classification bar. |
| `dodbl_BannerPosition` | Banner Position | String | `Bottom` | MDA classification bar placement: `Top`, `Bottom`, or `Both`. |

---

## Custom Tables

No live custom tables ship in v1.3.0. `dodbl_banner_demo` was removed; the demo is now the Canvas App `dodbl_canvasappdemo_bb4ae`.

---

### `dodbl_consentrecord` _(PLANNED — v1.4.0, #8)_

Dataverse audit table for consent acknowledgments. Not yet created. This is the authoritative schema for v1.4.0 planning.

**Table settings:** User/Team owned; table-level auditing enabled; add to the `DoDBannerLibrary` solution.

| Display Name | Schema Name | Type | Required | Notes |
|---|---|---|---|---|
| Consent Record | `dodbl_consentrecordid` | Primary Key (GUID) | System required | System-generated row ID. |
| Name | `dodbl_name` | Auto Number primary name | Required | Audit identifier, e.g. `CONSENT-{SEQNUM:8}`. Dataverse requires a primary name column; Auto Number keeps audit rows human-readable without user input. |
| User | `dodbl_userid` | Lookup → SystemUser | Required | Who acknowledged consent. Use `dodbl_userid` to follow lookup naming convention. Audit enabled. |
| Banner Type | `dodbl_bannertype` | Choice | Required | Snapshot of the banner/classification value at acknowledgement time. Options should align to `dodbl_BannerType`: `None`, `DoD`, `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`. Use publisher option-value prefix `70387`. Audit enabled. |
| Acknowledged On | `dodbl_acknowledgedon` | Date and Time (UTC / time-zone independent) | Required | When the user acknowledged. Audit enabled. |
| Expiry Date | `dodbl_expirydate` | Date and Time (UTC / time-zone independent) | Required | When the acknowledgement expires, computed from `dodbl_ConsentExpiryDays`. Audit enabled. |
| Consent Text | `dodbl_consenttext` | Multiple lines of text | Required | Snapshot of the exact AO-approved text shown to the user. Audit enabled. |
| Is Active | `dodbl_isactive` | Yes/No | Required | Defaults to Yes; set No on expiry or revocation. Audit enabled. |

> **Deployment prerequisite / gotcha:** Dataverse auditing is a two-level setting. Table-level auditing ("Audit changes to its data" on the table plus per-column "Enable auditing") only records data when environment-level auditing is also enabled in Power Platform admin center → Environment → Settings → Audit and logs → Audit settings → **Start Auditing** ON, with **Log record access** / read logs enabled if required. If environment auditing is OFF, table auditing captures nothing. After configuring auditing, publish all customizations and verify `dodbl_consentrecord` appears as a component in the `DoDBannerLibrary` solution.

**Required saved view:** `Active Consent Records` — filter `dodbl_isactive = true` OR `dodbl_expirydate` is in the future; sort by `dodbl_acknowledgedon` descending.

---

## PCF Control Properties

PCF control: `DoDBannerLibrary.DodBannerControl`

| Property Name | Type | Binding | Required | Description |
|---|---|---|---|---|
| `bannerEnabled` | TwoOptions | bound | false | Show/hide the banner. Null treated as "don't show." |
| `bannerType` | SingleLine.Text | input | — | Classification value; `DoD` legacy consent alias. See domain.md. |
| `showConsent` | TwoOptions | input | — | Show the DoD consent modal independently of `bannerType` (v1.2+). |
| `consentExpiryDays` | Whole.None | input | — | Cookie lifetime in days. |
| `consentText` | SingleLine.Text | input | — | AO-approved text override for DoD modal body. |

---

## File Layout (repo root)

```
banner-core.css                         Source of truth CSS (shared stylesheet)
dod-consent-banner.html                 Source DoD consent modal
cui-consent-banner.html                 Source CUI classification mark

DoDBannerLibrary/                       PAC CLI solution source
  Other/Solution.xml                    Solution manifest (version, publisher, components)
  WebResources/
    dodbl_bannercore                    CSS web resource
    dodbl_dodconsentbanner              DoD consent modal HTML
    dodbl_cuiconsentbanner              CUI HTML
    dodbl_webtemplatesource             Liquid Web Template source HTML
    dodbl_dodbanner                     MDA form JS
    dodbl_docs                          Documentation HTML
    dodbl_release-notes                 Release notes HTML
  Entities/dodbl_banner_demo/           Removed in v1.3.0 (do not restore)
  AppModuleSiteMaps/...                 Management app site map

pcf/DodBannerControl/                   PCF TypeScript project
  DodBannerControl/
    index.ts                            PCF implementation
    ControlManifest.Input.xml           Manifest (properties, CSS resource)
    css/DodBannerControl.css            Bundled copy of banner-core.css

.ai/                                    AI context files (this directory)
.github/copilot-instructions            Copilot grounding instructions
```
