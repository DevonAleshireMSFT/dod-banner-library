# DoD Banner Library technical integration guide

Audience: Power Platform technical reviewers and makers who need to understand, independently review, import, and reuse the DoD Banner Library solution.

This public guide describes product capabilities and portable configuration patterns. It intentionally avoids environment-specific deployment details such as tenant names, org URLs, environment IDs, or authentication profiles.

## 1. Overview and scope

The DoD Banner Library is a managed Power Platform solution for reusable classification bars and optional system-use notification experiences across:

- Model-driven apps
- Canvas apps and custom pages
- Power Pages

Current public product line: **v1.5.0**.

Key constraints:

- Publisher prefix: `dodbl_`
- No external CDN calls, fonts, scripts, or jQuery
- Managed solution distribution for shared deployment
- Environment-variable driven Model-Driven App behavior
- Client-side consent UX is supplementary; it is not a hard authorization boundary

## 2. Component inventory

| Component | Source name | Purpose |
|---|---|---|
| Consent table | `dodbl_consentrecord` | Dataverse audit table for acknowledgement records. |
| Canvas app demo | `dodbl_canvasappdemo_bb4ae` | Demo app that hosts the PCF control. |
| Web resource | `dodbl_banner-config` | RBAC-gated admin configuration screen for banner environment variable values. |
| Web resource | `dodbl_banner-launch-page` | Model-driven app launch page, consent acknowledgement path, and management home. |
| Web resource | `dodbl_bannercore` | Shared CSS for classification marks and consent modal layout. |
| Web resource | `dodbl_cuiconsentbanner` | Power Pages classification fragment. |
| Web resource | `dodbl_docs` | In-solution setup documentation. |
| Web resource | `dodbl_dodbanner` | Model-driven app form script for shell classification bars and optional notification consent. |
| Web resource | `dodbl_dodconsentbanner` | Power Pages consent modal HTML. |
| Web resource | `dodbl_release-notes` | In-solution release notes. |
| Web resource | `dodbl_webtemplatesource` | Power Pages Liquid web template source. |
| PCF control | `DoDBannerLibrary.DodBannerControl` | Canvas app/custom page classification and consent control. |
| Security role | `DoD Banner - Config Admin` | Allows authorized admins to use the configuration screen. |
| Security role | `DoD Banner - Consent Write` | Supports consent-record creation for acknowledgement paths. |
| Security role | `DoD Banner - Consent Audit Reader` | Read-only access for reviewing consent audit records. |

## 3. Environment variables

The Model-Driven App banner path is configured with these six public banner settings:

| Schema name | Type | Default | Description |
|---|---|---|---|
| `dodbl_BannerEnabled` | Yes/No | `Yes` | Master switch. `No` suppresses banners for the MDA path. |
| `dodbl_BannerType` | String | empty | Classification value: `U`/`UNCLASSIFIED`, `CUI`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`, or legacy `DoD` alias. Empty means no classification bar. |
| `dodbl_BannerPosition` | String | `Bottom` | Classification bar placement: `Top`, `Bottom`, or `Both`. |
| `dodbl_ConsentExpiryDays` | Integer | `30` | Days before the `dodbl_Accepted` consent cookie expires. `0` re-prompts each browser session. |
| `dodbl_BannerColor` | String | empty | Optional hex color override such as `#5cb85c`. Empty uses the automatic classification color. Invalid values are ignored by runtime code. |
| `dodbl_BannerVersion` | String | `1.5.0.0` | Running-version stamp shown in the app. Release owners keep this in sync with `Solution.xml`. |

### Default classification label and color mapping

| Banner type prefix | Display label | Default color |
|---|---|---|
| `CU` | `CUI` | `#5a04b0` purple |
| `U` | `UNCLASSIFIED` | `#5cb85c` green |
| `CO` | `CONFIDENTIAL` | `#286090` blue |
| `S` | `SECRET` | `#d9534f` red |
| `T` | `TOP SECRET` | `#f0ad4e` orange |
| Other | Uppercased value | `#5e5e5e` grey |

The MDA bar renders the full display label. For example, a stored short code of `U` displays as `UNCLASSIFIED`.

## 4. Admin configuration screen

`dodbl_banner-config` provides an in-app admin screen for authorized users. It is intended for holders of `DoD Banner - Config Admin` or System Administrator.

The screen:

- Edits Environment Variable **Value** records, not definitions.
- Lets admins change banner enablement, type, position, consent expiry, and optional color override without redeploying the solution.
- Displays `dodbl_BannerVersion` read-only as the running product stamp.
- Shows `modifiedby` and `modifiedon` for the current value record so changes are attributable in the UI.
- Refreshes the visible shell classification bar in place when the renderer is available; otherwise changes appear on each user's next page navigation or refresh.
- Includes a self-service **Reset My Consent** action that clears only the current user's `dodbl_Accepted` cookie for retesting.

Dataverse privileges remain the enforcement boundary. Client-side role checks are usability gates, not a substitute for Dataverse security.

## 5. Consent and audit behavior

The Model-Driven App launch page writes a `dodbl_consentrecord` when a user acknowledges the system-use notification. The record captures:

- User
- Banner type
- Acknowledged-on timestamp
- Expiry timestamp
- Consent text snapshot

The acknowledgement cookie is:

- Name: `dodbl_Accepted`
- Value: `Yes`
- Flags: `Secure; SameSite=Strict`
- Path: `/`
- Expiry: controlled by `dodbl_ConsentExpiryDays`

### Consent audit roles

- `DoD Banner - Consent Write` supports creation of acknowledgement records.
- `DoD Banner - Consent Audit Reader` provides read-only access for reviewing consent audit records.

### Canvas limitation

Canvas-hosted PCF consent is useful for in-app user experience, but it does not provide the supported Dataverse audit-write path described above. In Canvas, the PCF sandbox can limit cookie persistence and `context.webAPI` availability. Use the Model-Driven App launch page when a persisted Dataverse consent audit record is required.

## 6. Hosting patterns

| Host | Recommended pattern | Notes |
|---|---|---|
| Model-driven app | Use `dodbl_banner-launch-page` as the first sitemap subarea for app-load consent and shell classification display. | Best supported product path for audited acknowledgement records. |
| Model-driven forms | Register `DoDBannerLibrary.DodBanner.onFormLoad` from `dodbl_dodbanner`. | Provides shell classification bar rendering on form load. |
| Canvas apps/custom pages | Add `DoDBannerLibrary.DodBannerControl`. | Uses PCF properties; does not read MDA environment variables directly. Republish apps after PCF updates. |
| Power Pages | Create site-specific web files from shipped web resources and template source. | Website records are not packaged because website IDs are environment-specific. |

## 7. Classification bar implementation notes

For Model-Driven Apps, the shell classification bar uses `window.top.document` so it appears in the visible UCI shell rather than only inside a form or web-resource iframe. This is limited to classification-bar DOM placement and uses cleanup markers (`data-dodbl-bar`) to avoid duplicate bars during navigation.

`dodbl_BannerColor` is validated with a hex-color allow-list (`#RGB` or `#RRGGBB`). Malformed values fall back to the classification-type default, preventing arbitrary CSS injection.

## 8. Import and verification checklist

1. Import the managed solution.
2. Publish all customizations.
3. Open the DoD Banner Library Management app.
4. Confirm Home, Banner Configuration, Consent Records, Documentation, Release Notes, Web Template Source, and Canvas App Demo are available as expected for the imported solution.
5. Assign `DoD Banner - Config Admin` only to users authorized to change banner settings.
6. Assign consent audit roles according to least-privilege review needs.
7. Open Banner Configuration and verify the current version, banner settings, and value attribution display.
8. Test the launch page acknowledgement path and confirm a consent audit record is created where the user has the required privileges.
9. Use Reset My Consent to clear the current user's cookie and retest the prompt.

## 9. Recent release highlights

| Version | Highlights |
|---|---|
| v1.5.0 | Admin configuration screen, optional banner color override, reset-my-consent action, runtime version stamp, full label rendering for short classification codes, and in-place shell bar refresh when available. |
| v1.4.1 | Consent Audit Reader role and Active Consent Records view correction. |
| v1.4.0 | Consent audit table and model-driven landing-page consent-record creation on acknowledgement. |

## 10. Public documentation boundary

This repository and GitHub Pages site are public. Keep adopter-specific operational data out of public artifacts, including tenant names, environment URLs, environment IDs, authentication profiles, and internal deployment procedures. Describe product capabilities and generic configuration only.
