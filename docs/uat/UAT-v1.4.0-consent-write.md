# PENDING EXECUTION — DoD Banner Library v1.4.0 Consent-Record Writes

| Field | Value |
|---|---|
| Target build | v1.4.0.0 |
| Environment | To be executed in target Dataverse / Power Platform environment |
| Date authored | 2026-08-03 |
| Author | Wash |
| Status | **Checklist only — based on acceptance criteria; no live results recorded** |
| Related work | #10 PCF, #11 MDA JS home-page + global-notification, #12 Power Pages pending architecture ADR, #21 Canvas consent persistence |

## Scope

This is an anticipatory UAT / verification checklist for v1.4.0 consent-record writes. It is based on the acceptance criteria and the planned `dodbl_consentrecord` schema, not on a completed implementation or live environment execution.

Covered:

- PCF / Canvas App consent acknowledgement path (#10).
- Model-Driven App home-page consent and shell global-notification consent paths (#11).
- Power Pages consent acknowledgement path (#12), marked pending until the architecture ADR defines the supported write approach.
- Dataverse audit-row behavior for successful, failed, repeat, and least-privilege acknowledgement attempts.

Not covered:

- Certification, accreditation, ATO, or compliance sign-off.
- Live validation results. Fill the Actual Result and Pass/Fail columns only during execution.

## Authoritative schema expectations

On acknowledgement, the client attempts to create one new `dodbl_consentrecord` row with:

| Field | Expected value |
|---|---|
| `dodbl_userid` | Lookup to the current acknowledging user. |
| `dodbl_bannertype` | Snapshot of the classification / banner value shown at acknowledgement time. Valid values align to `None`, `DoD`, `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`. |
| `dodbl_acknowledgedon` | Acknowledgement timestamp. |
| `dodbl_expirydate` | `dodbl_acknowledgedon` + configured `ConsentExpiryDays`. |
| `dodbl_consenttext` | Snapshot of the exact consent text shown to the user. |
| `dodbl_revoked` | `No`. |
| `dodbl_isactive` | **Not written by the client.** Formula column only; expected to read `True` for a fresh, unexpired, unrevoked record. |

The audit model is append-only. Normal acknowledgement or renewal creates a new row; it does not update the previous row.

## General setup

- Import the v1.4.0 solution containing `dodbl_consentrecord`, the `Active Consent Records` saved view, and the `DoD Banner - Consent Write` security role.
- Confirm environment-level Dataverse auditing is configured if audit-log verification is part of the test window.
- Prepare at least two test users:
  - **Writer user:** has the app access needed for the tested surface and the `DoD Banner - Consent Write` role.
  - **No-write user:** has app access but does **not** have the `DoD Banner - Consent Write` role.
- Use clean browser state before each scenario: delete `dodbl_Accepted`, use a new browser profile, or use InPrivate / Incognito.
- Record the actual configured `ConsentExpiryDays`, banner type, consent text source, browser, host URL, and user account used for each run.

## UAT test cases

| ID | Surface | Scenario | Preconditions / Setup | Steps | Expected Result | Actual Result | Pass/Fail |
|---|---|---|---|---|---|---|---|
| UAT-001 | Dataverse | Consent table and saved view are present | v1.4.0 solution imported. Tester has maker/admin access for verification. | 1. Open Dataverse tables. <br> 2. Locate `dodbl_consentrecord`. <br> 3. Open views for the table. | `dodbl_consentrecord` exists. `Active Consent Records` saved view exists and filters active/unexpired records using stored expiry-date criteria rather than requiring the client to write `dodbl_isactive`. | Not executed. | Pending |
| UAT-002 | Dataverse | Security role is present with least privilege | v1.4.0 solution imported. | 1. Open security roles. <br> 2. Locate `DoD Banner - Consent Write`. <br> 3. Inspect privileges for `dodbl_consentrecord`. | Role permits creating consent acknowledgements and reading the user's own consent records as designed. It does not grant normal update/write privilege for append-only renewal. | Not executed. | Pending |
| UAT-003 | PCF / Canvas (#10) | Writer user acknowledgement creates one active consent record | Writer user has `DoD Banner - Consent Write`. PCF is placed in a Canvas App with `bannerEnabled=true`, `showConsent=true`, known `bannerType`, known `consentText`, and known `ConsentExpiryDays`. Clean browser state. | 1. Sign in as writer user. <br> 2. Open the Canvas App. <br> 3. Confirm the PCF displays the expected classification / consent UI. <br> 4. Click **I Acknowledge**. <br> 5. Open `Active Consent Records`. | Consent UI completes. A new `dodbl_consentrecord` row appears in `Active Consent Records`. `dodbl_userid` is the current writer user. `dodbl_bannertype`, `dodbl_acknowledgedon`, `dodbl_expirydate`, `dodbl_consenttext`, and `dodbl_revoked=No` match the acknowledgement. `dodbl_isactive` reads `True`. | Not executed. | Pending |
| UAT-004 | PCF / Canvas (#10, #21) | Server-side record persists even though PCF sandbox cookie does not | Complete UAT-003. Use the same writer user. | 1. Close all Canvas App tabs. <br> 2. Clear or let the PCF sandbox/session cookie state reset as needed. <br> 3. Reopen the Canvas App. <br> 4. Re-check `Active Consent Records`. | The Dataverse consent record from UAT-003 still exists server-side. This verifies the v1.4.0 server-side audit path mitigates the v1.3.0 Canvas cookie sandbox persistence limitation tracked by #21, even if the PCF cookie/session behavior re-prompts. | Not executed. | Pending |
| UAT-005 | PCF / Canvas (#10) | Failed record create is non-blocking | No-write user can open the Canvas App but lacks `DoD Banner - Consent Write`. Browser console is open. Clean browser state. | 1. Sign in as no-write user. <br> 2. Open the Canvas App. <br> 3. Click **I Acknowledge**. <br> 4. Observe UI/cookie flow. <br> 5. Inspect console. <br> 6. Check `Active Consent Records`. | Consent UI/cookie flow still completes. No blocking error is shown to the end user. No consent record is created for the no-write user. Console contains only a warning for the failed create attempt. | Not executed. | Pending |
| UAT-006 | MDA Home Page (#11) | Home-page acknowledgement creates one active consent record | Writer user has `DoD Banner - Consent Write`. Home-page consent surface is enabled/configured. Clean browser state. | 1. Sign in as writer user. <br> 2. Open the Model-Driven App home page. <br> 3. Confirm displayed banner type and consent text. <br> 4. Click **I Acknowledge**. <br> 5. Open `Active Consent Records`. | Home-page consent completes. A new consent row appears in `Active Consent Records` for the current user with field values matching the displayed home-page consent. `dodbl_isactive` reads `True` and was not written by client payload. | Not executed. | Pending |
| UAT-007 | MDA Home Page (#11) | Home-page failed create is non-blocking | No-write user can open MDA but lacks `DoD Banner - Consent Write`. Browser console is open. Clean browser state. | 1. Sign in as no-write user. <br> 2. Open the MDA home page. <br> 3. Click **I Acknowledge**. <br> 4. Observe UI/cookie flow and console. <br> 5. Check for consent records for that user. | Consent UI/cookie flow still completes. User can proceed. No row is created. Console logs a warning for the failed create attempt without a blocking dialog or unhandled exception. | Not executed. | Pending |
| UAT-008 | MDA Global Notification (#11) | Global-notification acknowledgement creates one active consent record | Writer user has `DoD Banner - Consent Write`. `dodbl_dodbanner` global-notification consent path is enabled/configured on a test form. Clean browser state. | 1. Sign in as writer user. <br> 2. Open the configured MDA form. <br> 3. Confirm `Xrm.App.addGlobalNotification` consent appears. <br> 4. Acknowledge the notification. <br> 5. Open `Active Consent Records`. | Global-notification consent completes. A new consent row appears for the current user with the displayed banner type and consent text snapshot. `dodbl_revoked=No`; `dodbl_isactive=True`. | Not executed. | Pending |
| UAT-009 | MDA Global Notification (#11) | Global-notification failed create is non-blocking | No-write user can open the configured MDA form but lacks `DoD Banner - Consent Write`. Browser console is open. Clean browser state. | 1. Sign in as no-write user. <br> 2. Open the configured MDA form. <br> 3. Acknowledge the notification. <br> 4. Observe UI/cookie flow and console. <br> 5. Check for consent records for that user. | Notification acknowledgement still completes. No blocking UI error appears. No row is created. Console logs only a warning for the failed create attempt. | Not executed. | Pending |
| UAT-010 | All implemented surfaces | Append-only repeat acknowledgement creates a new row | Writer user has already completed one successful acknowledgement on the tested surface. Prepare clean/expired consent state or otherwise force the consent UI to display again without deleting the prior Dataverse row. | 1. Record the existing consent row ID and acknowledgement timestamp. <br> 2. Re-trigger the same surface's consent UI. <br> 3. Click **I Acknowledge** again. <br> 4. Open `Active Consent Records` and table data. | A second, new `dodbl_consentrecord` row is created. The prior row is not updated. Row IDs and acknowledgement timestamps differ. | Not executed. | Pending |
| UAT-011 | All implemented surfaces | Field correctness and formula behavior | At least one fresh successful consent record exists for the writer user. Tester can inspect raw fields or network create payload. | 1. Inspect the created row fields. <br> 2. If browser/network tooling is available, inspect the create request payload. <br> 3. Compare `dodbl_expirydate` to `dodbl_acknowledgedon` + configured `ConsentExpiryDays`. | `dodbl_userid` is the current user. `dodbl_bannertype` is the displayed classification. `dodbl_consenttext` is the displayed text snapshot. `dodbl_revoked=No`. `dodbl_isactive` is absent from the client create payload but reads `True` for the fresh valid record. Expiry date matches the configured consent lifetime within expected clock tolerance. | Not executed. | Pending |
| UAT-012 | Dataverse | Active Consent Records saved view includes fresh valid record | At least one fresh unexpired/unrevoked writer-user consent row exists. | 1. Open `Active Consent Records`. <br> 2. Search/sort by `dodbl_acknowledgedon`. <br> 3. Locate the new row. | The new valid row appears in the saved view. The view is sorted with newest acknowledgements easy to find. | Not executed. | Pending |
| UAT-013 | Dataverse | Active view excludes revoked or expired records | Safe test data exists, or a test record can be manually revoked/expired by an admin without affecting production evidence. | 1. Mark a test record revoked or set expiry into the past using an approved admin-only test method. <br> 2. Refresh `Active Consent Records`. <br> 3. Preserve audit expectations. | Revoked/expired test record does not appear as active. Normal client code did not perform the revocation/update; this is an admin verification of saved-view/formula behavior only. | Not executed. | Pending |
| UAT-014 | Power Pages (#12) | Architecture pending — write path not executed until ADR is approved | Power Pages architecture ADR for consent-record writes is not yet approved. | 1. Confirm ADR status. <br> 2. Do not execute a write-path UAT case until the supported architecture is defined. | #12 remains **Pending architecture ADR**. No fabricated result is recorded. Once the ADR lands, add Power Pages setup, success, non-blocking failure, append-only, and field-correctness cases matching UAT-003 through UAT-011. | Not executed. | Pending ADR |

## Execution notes

- Do not treat absence of a row during no-write-user tests as failure if the UI/cookie flow completes and only a console warning is logged; that is the required non-blocking behavior.
- Do treat any unhandled exception, blocking dialog, failed acknowledgement UI, or missing console warning on create failure as a defect.
- Do treat any client attempt to write `dodbl_isactive` as a defect; it is a formula column.
- Do treat an update to a prior consent row during normal re-acknowledgement as a defect; the audit model is append-only.
- Do not enter live execution results in this checklist until the implementation is deployed and tested.
