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
| `dodbl_BannerType` | Environment Variable (String) | Banner type: `DoD`, `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET` |
| `dodbl_ConsentExpiryDays` | Environment Variable (Decimal) | Cookie lifetime in days. Default: 1 |
| `dodbl_DoDConsentText` | Environment Variable (String) | AO-approved consent text override |
| `dodbl_DoDBannerLibraryManagement` | Model-Driven App | Management app — docs, demo, release notes |
| `dodbl_DoDBannerLibraryManagement` | App Module Site Map | Navigation for management app |
| `dodbl_DoDBannerLibrary.DodBannerControl` | PCF Custom Control (type 66) | Canvas App classification bar + DoD modal |
| `dodbl_banner_demo` | Custom Table (type 1) | Demo entity for MDA banner testing |

---

## Environment Variables

| Schema Name | Display Name | Type | Default | Description |
|---|---|---|---|---|
| `dodbl_BannerEnabled` | Banner Enabled | TwoOptions | true | Master toggle. `false` = no banner shown at all. |
| `dodbl_BannerType` | Banner Type | String | `DoD` | Which banner to show. See domain.md for valid values. |
| `dodbl_ConsentExpiryDays` | Consent Expiry Days | Decimal | `1` | Days before `Accepted` cookie expires. Set to `365` for yearly consent. |
| `dodbl_DoDConsentText` | DoD Consent Text | String | _(default text in code)_ | Override text for the DoD system-use notification body. AO-approved. |

---

## Custom Tables

### `dodbl_banner_demo`

Demo entity used to show the MDA banner on a real form. Not intended for production data.

| Column | Schema Name | Type | Notes |
|---|---|---|---|
| Name | `dodbl_name` | Single Line Text | Primary name column |

**Forms:**
- Main form — has `dodbl_dodbanner` JS web resource as library + `DoDBannerLibrary.DodBanner.onFormLoad` OnLoad handler (pass execution context: yes)
- Card form, Quick View form — standard scaffolding

**Views:** 7 saved queries (All Banner Demos, Active, Inactive + standard system views)

---

### `dodbl_consent_record` _(PLANNED — v1.2)_

Dataverse audit table for consent acknowledgments. Not yet created.

| Column | Schema Name | Type | Notes |
|---|---|---|---|
| Name | `dodbl_name` | Auto Number | Audit record identifier |
| User | `dodbl_user` | Lookup → SystemUser | Who acknowledged consent |
| Banner Type | `dodbl_bannertype` | Choice | Which banner was shown |
| Acknowledged On | `dodbl_acknowledgedon` | DateTime | When acknowledged |
| Expiry Date | `dodbl_expirydate` | DateTime | When consent expires |

---

## PCF Control Properties

PCF control: `DoDBannerLibrary.DodBannerControl`

| Property Name | Type | Binding | Required | Description |
|---|---|---|---|---|
| `bannerEnabled` | TwoOptions | bound | false | Show/hide the banner. Null treated as "don't show." |
| `bannerType` | SingleLine.Text | input | — | `DoD` or classification value. See domain.md. |
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
  Entities/dodbl_banner_demo/           Entity source (forms, views, ribbon)
  AppModuleSiteMaps/...                 Management app site map

pcf/DodBannerControl/                   PCF TypeScript project
  DodBannerControl/
    index.ts                            PCF implementation
    ControlManifest.Input.xml           Manifest (properties, CSS resource)
    css/DodBannerControl.css            Bundled copy of banner-core.css

.ai/                                    AI context files (this directory)
.github/copilot-instructions            Copilot grounding instructions
```
