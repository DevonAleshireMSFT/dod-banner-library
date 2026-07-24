# UNVALIDATED — PENDING UAT SIGN-OFF: DoD Banner Library v1.3.0 Consent Gate

| Field | Value |
|---|---|
| Target build | v1.3.0.0 |
| Environment | GFIM-DEV (GCC High) |
| Date | 2026-07-24 |
| Author | Wash |
| Status | **UNVALIDATED — PENDING UAT SIGN-OFF** |

## Scope

This UAT plan covers the current GFIM-DEV deployment of DoD Banner Library v1.3.0.0 after the unmanaged re-import. It is a test script for Devon to execute and sign off; no result in this document should be treated as validated until the Actual Result and Pass/Fail columns are filled in.

Covered current-build behavior:

- Model-Driven App (MDA) custom home page consent gate delivered by `dodbl_banner-launch-page`.
- `dodbl_banner-launch-page` is the single MDA consent entry point in this build; the duplicate shell-level global-notification consent banner has been removed.
- Consent page text/UI updates:
  - Title: `U.S. Government System - Authorized Users Only`
  - Subtitle: `DoD Banner Library`
  - `WARNING:` label renders bold and red.
- Consent cookie hardening: cookie is written with `Secure` and `SameSite=Lax`.
- Classification marking bar delivered by `dodbl_dodbanner` for configured MDA forms.
- AC-8 posture documentation visible in README and `dodbl_docs`.
- Release notes ordering corrected: Planned, then v1.3.0, v1.2.0, v1.1.0, v1.0.0; v1.2.0 entry restored.

## Environment and configuration notes

- Target environment: GFIM-DEV, GCC High (`https://orga1b9bfb3.crm.microsoftdynamics.us/`).
- Target solution: `DoDBannerLibrary`, version `1.3.0.0`, unmanaged in GFIM-DEV.
- Current MDA consent behavior is home-page based: `dodbl_banner-launch-page` is first in the DoD Banner Library Management app sitemap and presents the consent overlay before revealing home-page content.
- `dodbl_ConsentMode` is the agreed future consent configuration model (`Off`, `HomePage`, `GlobalNotification`), but this UAT plan must not assume it is implemented unless Devon confirms it exists in the deployed solution. Validate the current deployed behavior, not the future selector.
- Existing environment variables relevant to this plan:
  - `dodbl_DoDConsentText`: optional AO-approved text override for consent copy.
  - `dodbl_ConsentExpiryDays`: expected consent cookie lifetime input where implemented; default expectation is 30 days for MDA/PCF surfaces.
  - `dodbl_BannerEnabled`: enables classification bar behavior when `dodbl_dodbanner` is registered on a form.
  - `dodbl_BannerType`: classification text/value such as `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, or `TOP SECRET`.
  - `dodbl_BannerPosition`: expected values `Top`, `Bottom`, or `Both`; default documented value is `Bottom`.
  - `dodbl_ShowConsentBanner`: legacy form-script consent toggle. In the current v1.3.0 MDA management app, consent should be through the home page only, not a duplicate global notification.
- Cookie state setup is browser-specific. Use a clean browser profile, InPrivate/Incognito session, or browser developer tools to delete or edit the consent cookie as directed by each case.

## Known limitation to verify and document

The v1.3.0 home-page consent gate is a UX-level entry pattern, not hard enforcement. Deep links, global search, pinned/recent items, disabled JavaScript, browser developer tools, and direct API/OData access can bypass client-side consent. This is tracked as issue #13 and should be documented during UAT as a known limitation, not treated as an unexpected failure of this build.

## UAT test cases

| ID | Scenario | Preconditions / Setup | Steps | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|---|---|
| UAT-001 | New user / no cookie — consent overlay appears and content is gated | Use clean browser profile or delete the consent cookie for GFIM-DEV. Do not pre-set `Accepted` / `dodbl_Accepted` cookie. Open DoD Banner Library Management app from GFIM-DEV. | 1. Launch the DoD Banner Library Management app. <br> 2. Observe the initial home page. <br> 3. Do not click **I Acknowledge** yet. | `dodbl_banner-launch-page` displays the consent overlay before home content is usable. The navigation tiles/home content are hidden or blocked until acknowledgement. |  |  |
| UAT-002 | Consent overlay content matches v1.3.0 UI copy | No valid consent cookie. `dodbl_DoDConsentText` may be blank or set to AO-approved test text; note which was used in Actual Result. | 1. Launch the app with no valid cookie. <br> 2. Inspect the consent card title, subtitle, warning label, and button. | Title reads `U.S. Government System - Authorized Users Only`. Subtitle reads `DoD Banner Library`. The label `WARNING:` appears before the consent body. Button reads `I Acknowledge`. |  |  |
| UAT-003 | WARNING label renders bold and red | No valid consent cookie. Browser zoom at 100% unless accessibility testing requires otherwise. | 1. Launch the app with no valid cookie. <br> 2. Visually inspect the `WARNING:` label. <br> 3. Optionally inspect DOM/CSS for `.consent-warning-label`. | `WARNING:` is bold and red, visually distinct from the remaining consent body text. |  |  |
| UAT-004 | Acknowledgement reveals home content | No valid consent cookie. | 1. Launch the app. <br> 2. Click **I Acknowledge**. <br> 3. Observe the page after acknowledgement. | Overlay is dismissed. Home content is revealed, including the DoD Banner Library header, quick navigation tiles, and solution status area. |  |  |
| UAT-005 | Consent cookie is written with Secure and SameSite=Lax | No valid consent cookie before test. Browser developer tools available. | 1. Launch the app. <br> 2. Click **I Acknowledge**. <br> 3. In developer tools, inspect cookies for the GFIM-DEV Dynamics host. | Consent cookie is present after acknowledgement and includes `Secure` and `SameSite=Lax`. Record the cookie name observed in Actual Result. |  |  |
| UAT-006 | Returning user / valid cookie — overlay skipped | A valid consent cookie from UAT-004/UAT-005 exists and has not expired. | 1. Close and reopen the app, or refresh the page. <br> 2. Observe the home page load. | Consent overlay is skipped. User lands directly on the home/documentation navigation content. |  |  |
| UAT-007 | Expired cookie — graceful re-prompt | Set consent cookie expiry into the past or delete the cookie. | 1. Open the app after expiring/removing the cookie. <br> 2. Observe initial page load. | Consent overlay appears again. No script error blocks the page. |  |  |
| UAT-008 | Malformed cookie — graceful re-prompt, no URIError | Add or edit an unrelated cookie on the same host with malformed percent encoding, for example a value containing a lone `%`. Ensure no valid consent cookie is present. | 1. Open browser developer tools console. <br> 2. Launch or refresh the app. <br> 3. Watch console and page behavior. | App does not throw `URIError: URI malformed`. Consent overlay appears normally and can be acknowledged. |  |  |
| UAT-009 | Single consent banner — no duplicate global notification | No valid consent cookie. If `dodbl_ShowConsentBanner` exists, note its current value; do not rely on it for the home-page test. | 1. Launch the DoD Banner Library Management app. <br> 2. Observe the home-page overlay. <br> 3. Look for any additional yellow MDA shell/global notification consent banner. | Only the home-page consent overlay appears. No duplicate shell-level `Xrm.App.addGlobalNotification` consent prompt appears in the MDA chrome. |  |  |
| UAT-010 | Bypass attempt — direct deep link | Valid or invalid cookie state may be tested; record state used. Identify a direct URL to a resource/subarea/form other than the home page, such as docs or release notes. | 1. Paste the direct URL into a new tab. <br> 2. Attempt to load the target directly. <br> 3. Record whether consent overlay appears first. | Expected known limitation: sitemap/home-page gate is not hard enforcement. Some deep links may bypass the home-page consent overlay. If bypass occurs, record it as issue #13 known limitation, not a new v1.3.0 regression. |  |  |
| UAT-011 | Bypass attempt — global search / recents / pinned items | User has access to MDA global search, recent items, or pinned items. Cookie state recorded before test. | 1. Navigate using global search, recent item, or pinned item to bypass the Home sitemap entry. <br> 2. Observe whether the home-page consent overlay appears. | Expected known limitation: navigation paths that do not load `dodbl_banner-launch-page` can bypass the UX-level gate. Record observed route and result under issue #13 known limitation. |  |  |
| UAT-012 | Bypass attempt — disabled JavaScript | Browser configured to block JavaScript for the test host, if feasible in the test browser. | 1. Disable JavaScript for the GFIM-DEV host. <br> 2. Attempt to open the app/home page. <br> 3. Re-enable JavaScript after the test. | Expected known limitation: client-side consent requires JavaScript and is not hard enforcement. Page may fail to operate normally or may not enforce acknowledgement. Record actual browser behavior. |  |  |
| UAT-013 | Classification bar renders at Bottom | `dodbl_dodbanner` registered on a test MDA form. Set `dodbl_BannerEnabled=true`, `dodbl_BannerType=CUI`, `dodbl_BannerPosition=Bottom`. Publish changes if environment variables are edited. | 1. Open the configured test form. <br> 2. Observe the bottom of the app window/form shell. | CUI classification marking bar renders at the bottom only. It uses the expected CUI styling/text and does not overlap critical controls. |  |  |
| UAT-014 | Classification bar renders at Top | `dodbl_dodbanner` registered on a test MDA form. Set `dodbl_BannerEnabled=true`, `dodbl_BannerType=CUI`, `dodbl_BannerPosition=Top`. Publish changes if environment variables are edited. | 1. Open or refresh the configured test form. <br> 2. Observe the top of the app window/form shell. | Classification marking bar renders at the top only. MDA header/nav remains usable and is not obscured. |  |  |
| UAT-015 | Classification bar renders at Both | `dodbl_dodbanner` registered on a test MDA form. Set `dodbl_BannerEnabled=true`, `dodbl_BannerType=CUI`, `dodbl_BannerPosition=Both`. Publish changes if environment variables are edited. | 1. Open or refresh the configured test form. <br> 2. Observe top and bottom of the app window/form shell. | Classification marking bars render at both top and bottom. Layout remains usable. |  |  |
| UAT-016 | Classification bar disabled when configured off | `dodbl_dodbanner` registered on a test MDA form. Set `dodbl_BannerEnabled=false`; leave other banner variables unchanged. Publish changes if edited. | 1. Open or refresh the configured test form. <br> 2. Observe top and bottom locations. | No classification marking bar is displayed when banner is disabled. |  |  |
| UAT-017 | AC-8 posture section visible in in-app docs | App accessible. Consent state may be valid or acknowledge first. | 1. Open DoD Banner Library Management app. <br> 2. Navigate to Documentation (`dodbl_docs`). <br> 3. Locate the Compliance & AC-8 section. | `dodbl_docs` includes a visible `Compliance & AC-8 Posture` section explaining adopter verification, inherited AC-8 posture, optional in-app consent, and known client-side limitations. |  |  |
| UAT-018 | README AC-8 posture is available in repository artifact | Access to repository working tree or GitHub page for README. | 1. Open `README.md`. <br> 2. Locate `Compliance & AC-8 Posture`. | README contains the AC-8 posture documentation aligned with `dodbl_docs`, including adopter AO/ISSM verification responsibility and the issue #13 limitation. |  |  |
| UAT-019 | Release notes ordering corrected | App accessible. Consent state may be valid or acknowledge first. | 1. Open DoD Banner Library Management app. <br> 2. Navigate to Release Notes (`dodbl_release-notes`). <br> 3. Read the top-to-bottom section order. | Release notes display Planned first, then v1.3.0, v1.2.0, v1.1.0, and v1.0.0. v1.3.0 is marked latest or otherwise clearly current. |  |  |
| UAT-020 | v1.2.0 release note entry restored | App accessible; release notes page open. | 1. On `dodbl_release-notes`, locate v1.2.0. <br> 2. Confirm v1.2.0 includes the PCF `showConsent`/consent modal improvements from that release. | v1.2.0 section is present between v1.3.0 and v1.1.0 and includes its restored release details. |  |  |
| UAT-021 | Navigation tiles work after consent | Valid consent cookie or acknowledge during test. | 1. From the home page, click Documentation. <br> 2. Return to Home if available. <br> 3. Click Release Notes. <br> 4. Optionally click Web Template Source and Canvas App Demo if accessible. | Home-page navigation tiles route to the intended resources without re-showing duplicate consent prompts. |  |  |
| UAT-022 | AO-approved consent text override path | Set `dodbl_DoDConsentText` to a safe test string if Devon wants to validate override behavior; otherwise leave blank and record not tested. Ensure no valid consent cookie before launch. | 1. Launch the app with no valid cookie. <br> 2. Observe consent body text. <br> 3. If test override was set, confirm the custom text appears after any query-string override behavior is accounted for. | Consent page uses the configured AO-approved override where available; otherwise it falls back to the built-in DoD warning text. |  |  |

## Sign-off

| Role | Name | Date | Signature / Approval Notes |
|---|---|---|---|
| UAT reviewer | Devon Aleshire |  |  |
| QA/DevOps | Wash | 2026-07-24 | Prepared only; not validated. |
