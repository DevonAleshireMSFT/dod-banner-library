# DoD Banner Library technical integration guide

Audience: Power Platform technical reviewers and makers who need to understand, independently review, import, and reuse the DoD Banner Library solution.

This guide is grounded in the repository source, solution package metadata, and product ADRs. It intentionally avoids internal-only deployment details because this repository is public. For security wording boundaries, see `.ai/security.md`.

## 1. Overview and scope

The DoD Banner Library is a Power Platform solution that ships reusable banner assets for:

- Model-driven apps
- Canvas apps and custom pages
- Power Pages

The solution publisher prefix is `dodbl` / `dodbl_`, verified in `DoDBannerLibrary/Other/Solution.xml` and the managed package `solution.xml`. The checked-in unpacked solution source is unmanaged (`<Managed>0</Managed>`), while `DoDBannerLibrary_managed.zip` is the deployment artifact and contains `<Managed>1</Managed>`.

The project rule is to distribute the managed solution for shared deployment. The source also verifies zero runtime external dependencies:

- No CDN dependencies and no external requests are allowed by `.ai/context.md` and `.ai/security.md`.
- jQuery was removed and must not be reintroduced. ADR 0001 says all future web resource JavaScript must be vanilla JavaScript.
- The PCF package has no runtime dependencies in `pcf/DodBannerControl/package.json`.

Primary sources: `.ai/context.md`, `.ai/security.md`, `.ai/adr/0001-remove-jquery.md`, `DoDBannerLibrary/Other/Solution.xml`, `DoDBannerLibrary_managed.zip`.

## 2. Component inventory

Root components were verified from `DoDBannerLibrary/Other/Solution.xml`. The managed package adds the security role root component as type `20`, verified from `DoDBannerLibrary_managed.zip` `solution.xml` and `customizations.xml`.

| Component | Root type | Source name | Purpose |
|---|---:|---|---|
| Consent table | 1 | `dodbl_consentrecord` | Dataverse audit table metadata for planned consent records. Runtime writes are not wired yet. |
| System user dependency | 1 | `systemuser` | Required related component for the consent record user lookup. |
| Canvas app demo | 300 | `dodbl_canvasappdemo_bb4ae` | Demo app that hosts the PCF control. |
| Web resource | 61 | `dodbl_banner-config` | Admin-only banner configuration screen. Reads and writes the `environmentvariablevalue` records for the four banner environment variables. |
| Web resource | 61 | `dodbl_banner-launch-page` | Model-driven app launch page and primary app-load consent/banner entry point. |
| Web resource | 61 | `dodbl_bannercore` | Shared CSS for classification marks and consent modal layout. |
| Web resource | 61 | `dodbl_cuiconsentbanner` | Power Pages CUI classification fragment. |
| Web resource | 61 | `dodbl_docs` | In-solution setup documentation. |
| Web resource | 61 | `dodbl_dodbanner` | Model-driven app form script for classification bar and optional global notification consent. |
| Web resource | 61 | `dodbl_dodconsentbanner` | Power Pages DoD consent modal HTML. |
| Web resource | 61 | `dodbl_release-notes` | In-solution release notes. |
| Web resource | 61 | `dodbl_webtemplatesource` | Power Pages Liquid web template source for manual copy. |
| App module site map | 62 | `dodbl_DoDBannerLibraryManagement` | Navigation for the management app. |
| PCF control | 66 | `dodbl_DoDBannerLibrary.DodBannerControl` | Code component for Canvas apps, custom pages, and field-control hosting. |
| Model-driven app | 80 | `dodbl_DoDBannerLibraryManagement` | Management app that exposes Home, docs, release notes, web template source, and demo. |
| Global option set | 9 | `dodbl_bannertype` | Banner type choices with publisher option-value prefix `70387`. |
| Security role | 20 | `DoD Banner - Config Admin` | Role required to open and use the banner configuration screen. Read on `environmentvariabledefinition`; read, write, and create on `environmentvariablevalue`. |
| Security role | 20 | `DoD Banner - Consent Write` | Managed package role intended for consent record create/read access. Not present in checked-in `DoDBannerLibrary/Other/Solution.xml`, but present in `DoDBannerLibrary_managed.zip`. |

`DoDBannerLibrary/WebResources/` currently contains nine web resources: `dodbl_banner-config`, `dodbl_banner-launch-page`, `dodbl_bannercore`, `dodbl_cuiconsentbanner`, `dodbl_docs`, `dodbl_dodbanner`, `dodbl_dodconsentbanner`, `dodbl_release-notes`, and `dodbl_webtemplatesource`.

## 3. The PCF control: `DodBannerControl`

The PCF control is declared in `pcf/DodBannerControl/DodBannerControl/ControlManifest.Input.xml`:

- Namespace: `DoDBannerLibrary`
- Constructor: `DodBannerControl`
- Version: `1.2.1`
- `control-type`: `standard`
- External service usage: `false`

ADR 0003 records why this is a field-template PCF, not a dataset control: `bannerEnabled` is a single `TwoOptions` bound property.

| Property | Manifest type | Usage | Behavior |
|---|---|---|---|
| `bannerEnabled` | `TwoOptions` | `bound` | Anchor property. Shows or hides the control. Null is treated as not shown. |
| `bannerType` | `SingleLine.Text` | `input` | Classification value. Canonical values are `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, and `TOP SECRET`; `UNCLASSIFIED` also maps through the `U` prefix in code. `DoD` is a legacy consent alias and does not render a classification bar. |
| `showConsent` | `TwoOptions` | `input` | Shows the DoD consent modal independently of `bannerType`. |
| `consentExpiryDays` | `Whole.None` | `input` | Cookie lifetime in days. The manifest comment and `index.ts` default are `30`. |
| `consentText` | `SingleLine.Text` | `input` | Consent text override. Empty uses the built-in default text. |

Build and runtime notes:

- `pcf/DodBannerControl/pcfconfig.json` sets `"buildMode": "production"`. ADR 0007 records that `npm run build` produces a minified production bundle with no eval-based source maps.
- Canvas apps and custom pages bake the PCF bundle at publish time. After updating the PCF bundle, save and publish the app or custom page again. If republish does not pick up the bundle, remove and re-add the PCF control, then publish. See ADR 0008.
- Canvas PCF consent persistence is limited by sandboxed iframe behavior. The modal can show and dismiss in-session, but cookie persistence across sessions is not reliable in Canvas today. See ADR 0009.

## 4. Banner hosting methods

The solution supports three hosting patterns. The primary design goal is app-load rendering through a first sitemap subarea, not form-load rendering.

### Hosting tradeoffs

| Hosting method | Best for | How it renders | Tradeoffs |
|---|---|---|---|
| HTML web resource launch page | Primary model-driven app app-load pattern | `dodbl_banner-launch-page` is the first sitemap subarea, so the app lands on the banner page at app load. | Best default landing-page behavior. It is UX-level routing, not hard access enforcement for deep links or direct API access. |
| Canvas custom page hosting PCF | Canvas-authored app-load alternative | Put a custom page with `DodBannerControl` first in the app navigation. | Familiar to makers. Requires Canvas code components setting and has Canvas PCF bundle-baking and cookie sandbox limitations. |
| PCF field control on a form | Per-record form experience | Bind `DodBannerControl.bannerEnabled` to a Yes/No column on a form. | Useful for form-specific pages. It renders when the form loads, not when the app loads. |

### Primary reference implementation: launch page as the first sitemap subarea

`DoDBannerLibrary/AppModuleSiteMaps/dodbl_DoDBannerLibraryManagement/AppModuleSiteMap.xml` wires Home as the first group and first subarea. This makes `dodbl_banner-launch-page` the management app's default landing page:

```xml
<Group Id="group_home_dodbl" ...>
  <Titles>
    <Title LCID="1033" Title="Home" />
  </Titles>
  <SubArea Id="subarea_home_dodbl"
           Url="$webresource:dodbl_banner-launch-page"
           Client="All,Outlook,OutlookLaptopClient,OutlookWorkstationClient,Web"
           AvailableOffline="true"
           PassParams="false"
           Sku="All,OnPremise,Live,SPLA">
    <Titles>
      <Title LCID="1033" Title="Home" />
    </Titles>
  </SubArea>
</Group>
```

Because this is the first sitemap entry, the banner can render on app load. That is different from registering `dodbl_dodbanner` on a model-driven form, which only runs when that form is opened.

## 5. How the banner renders

### Classification bar

For model-driven app shell placement, the classification bar uses `window.top.document` so it escapes the hidden or nested app content iframe and appears in the visible UCI shell. ADR 0006 accepts this supportability risk because there is no supported UCI Client API for a persistent full-width classification bar.

The code limits `window.top` DOM injection to classification-bar placement. It uses shared cleanup markers (`data-dodbl-bar`) so navigation between Home and configured forms does not stack duplicate bars.

### Consent

Consent currently uses cookies:

- Cookie name: `dodbl_Accepted`
- Value: `Yes`
- Flags: `Secure; SameSite=Strict`
- Expiry: controlled by `consentExpiryDays` or environment-variable equivalents depending on host

For the model-driven form script, ADR 0005 records the decision to use `Xrm.App.addGlobalNotification` for optional shell-level consent instead of DOM modal injection. In v1.3.0, the management app's primary consent path is the Home launch page.

Sources: `.ai/adr/0005-addglobalnotification-consent.md`, `.ai/adr/0006-window-top-classification-bar.md`, `DoDBannerLibrary/WebResources/dodbl_dodbanner`, `DoDBannerLibrary/WebResources/dodbl_banner-launch-page`, `pcf/DodBannerControl/DodBannerControl/index.ts`.

## 6. Consent and audit architecture

### Current behavior

Current runtime consent acknowledgement is cookie-based. The PCF, MDA form script, and launch page all use `dodbl_Accepted=Yes` with `Secure; SameSite=Strict`. No runtime code in `pcf/DodBannerControl/DodBannerControl/index.ts`, `DoDBannerLibrary/WebResources/dodbl_dodbanner`, or `DoDBannerLibrary/WebResources/dodbl_banner-launch-page` writes a Dataverse consent record today.

### Planned v1.4 behavior

Issues #10, #11, and #12 are open and not yet wired:

- #10: PCF acknowledge action writes a consent record.
- #11: Model-driven app JS and launch-page acknowledge actions write consent records.
- #12: Power Pages uses a server-side write path for consent records.

The planned direction is an append-only consent audit model: acknowledgement creates a new consent row instead of updating a prior row. `.ai/data-model.md` is the authoritative planning document for the consent table, and the exported solution metadata currently contains `dodbl_consentrecord` with audited columns for name, user, banner type, acknowledged timestamp, expiry timestamp, consent text, revoked state, and active state.

The checked-in solution metadata uses the canonical table logical name `dodbl_consentrecord` and includes `dodbl_revoked` plus a formula-backed `dodbl_isactive`:

```powerfx
If(dodbl_expirydate > UTCNow() && Not(dodbl_revoked), true, false)
```

The current checked source shows:

- `DoDBannerLibrary/Other/Solution.xml` root component: `dodbl_consentrecord`
- `DoDBannerLibrary/Entities/dodbl_ConsentRecord/Entity.xml`: `dodbl_revoked` and `dodbl_isactive`
- `DoDBannerLibrary/Entities/dodbl_ConsentRecord/Formulas/dodbl_consentrecord-FormulaDefinitions.yaml`: the `dodbl_isactive` formula definition
- `DoDBannerLibrary/Entities/dodbl_ConsentRecord/SavedQueries/`: saved views using the canonical `dodbl_consentrecord` table logical name

Runtime consent-record writes remain v1.4 work in progress, so reviewers should not expect PCF, MDA JS, Power Pages runtime code, scheduled jobs, or plugins to create consent records yet.

### Security role and least privilege

`.ai/security.md` describes the planned `DoD Banner - Consent Write` role as the minimum role for consent acknowledgement records. The managed package contains a `DoD Banner - Consent Write` role. In the package, the role includes:

- `prvCreatedodbl_ConsentRecord`
- `prvReaddodbl_ConsentRecord`
- No consent-record write/update/delete privilege found

That supports an append-only pattern at the role level. However, least-privilege testing still needs to validate lookup-related privileges, especially whether test users get the needed AppendTo behavior for the SystemUser lookup from Basic User or another baseline role.

Sources: `.ai/security.md`, `DoDBannerLibrary_managed.zip` `customizations.xml`, `DoDBannerLibrary/Entities/dodbl_ConsentRecord/Entity.xml`.

## 7. Power Pages note

Power Pages assets ship as Dataverse web resources and a web template source reference, not as portal website records:

- CSS and JS are delivered as web resources such as `dodbl_bannercore`, `dodbl_dodconsentbanner`, `dodbl_cuiconsentbanner`, and `dodbl_webtemplatesource`.
- ADR 0004 says the solution must not include `adx_website` or `adx_webfile` records because website IDs are environment-specific and cannot be satisfied in a portable managed solution.
- Deployers create the web files and web template records manually in the target portal, using the shipped web resource content as source.

## 8. Install and test in a production environment

### Prerequisites

1. Use a production Power Platform environment appropriate for your organization.
2. Enable environment-level Dataverse auditing if you plan to validate audit-table behavior. Table and column auditing are inert unless environment-level auditing is on.
3. If using Canvas app or custom page hosting, enable the environment setting for Power Apps component framework in canvas apps.
4. Confirm no external script, font, CDN, or jQuery dependency is added during local customization.

### Import the managed solution

Maker portal path:

1. Go to Power Apps maker portal.
2. Open the target environment.
3. Select Solutions.
4. Import `DoDBannerLibrary_managed.zip`.
5. Publish all customizations after import.

PAC CLI equivalent:

```powershell
pac solution import --path DoDBannerLibrary_managed.zip --publish-changes
```

### Assign roles

For users who will smoke test planned consent-record writes, assign:

- `DoD Banner - Consent Write`
- `Basic User`

The Dataverse audit-table write path is not wired in current runtime code, so this role assignment is forward-looking for v1.4 validation and least-privilege testing.

### Smoke test scope

Validate current behavior:

1. Open the model-driven app.
2. Confirm the first page is the Home launch page using `dodbl_banner-launch-page`.
3. With no `dodbl_Accepted` cookie, confirm the consent prompt appears.
4. Click `I Acknowledge`.
5. Confirm the Home content is shown.
6. Refresh or reopen before expiry and confirm the cookie prevents a repeat prompt.
7. Change expiry or delete the cookie and confirm the prompt returns.
8. Configure banner type and position, then confirm the classification bar renders on app load.

Do not mark Dataverse consent-record creation as tested yet. The v1.4 audit-table write is work in progress and is not currently called by PCF, MDA JS, or Power Pages runtime code.

## 9. Use it in your own app

### Recommended maker pattern: launch page as the default page

Use this pattern when you want app-load rendering in a model-driven app.

1. Import the managed solution.
2. In your model-driven app, open App designer.
3. Go to Navigation.
4. Add a page of type Web resource.
5. Set the web resource to:

   ```text
   $webresource:dodbl_banner-launch-page
   ```

6. Name it Home or another clear landing-page label.
7. Move it to the first group and first page in navigation.
8. Save and publish the app.
9. Open the app in a clean browser profile and confirm the launch page is the first page loaded.

This reproduces the reference implementation in `DoDBannerLibrary/AppModuleSiteMaps/dodbl_DoDBannerLibraryManagement/AppModuleSiteMap.xml`.

### Model-driven app field-control variant

Use this when you need a per-record banner on a form, not app-load behavior.

1. Add a Yes/No column to the table or choose an existing Yes/No column.
2. Add that column to the form.
3. Configure the field to use `DoDBannerLibrary.DodBannerControl`.
4. Bind `bannerEnabled` to the Yes/No column.
5. Configure inputs:
   - `bannerType`: `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`, or blank
   - `showConsent`: true if the consent modal should show
   - `consentExpiryDays`: number of days, default 30
   - `consentText`: optional override
6. Save and publish the form.

### Canvas app or custom page variant

Use this when makers want a Canvas-authored page to host the PCF control.

1. Confirm canvas code components are enabled for the environment.
2. Open the Canvas app or custom page in Power Apps Studio.
3. Insert the `DodBannerControl` code component.
4. Set `bannerEnabled` to `true` or bind it to a variable.
5. Configure `bannerType`, `showConsent`, `consentExpiryDays`, and `consentText` using the property reference above.
6. Save and publish.
7. After any PCF bundle update, save and publish again. If the old bundle persists, remove and re-add the control, then publish. See ADR 0008.

Remember the Canvas cookie limitation from ADR 0009: consent may not persist across browser sessions when hosted inside the Canvas PCF sandbox.

## Source discrepancies flagged for review

The following claims could not be fully verified from the current checkout and should be reviewed before release:

1. `DoDBannerLibrary/Other/Solution.xml` does not list the security role root component, but `DoDBannerLibrary_managed.zip` does include a type `20` root component and the `DoD Banner - Consent Write` role.
