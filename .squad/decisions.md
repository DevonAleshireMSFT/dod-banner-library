# Squad Decisions

## Active Decisions

### 2026-08-11: Consent creation UAT readiness findings
**By:** Wash
**What:** Consent-record create calls exist in PCF, MDA form/global-notification, and MDA launch-page paths, but current solution metadata still reports `1.3.0.0`, and the `Active Consent Records` saved view has no active/expiry filter and sorts acknowledgement ascending.
**Why:** Devon is ready to test v1.4.0 consent creation. Test execution should import a confirmed v1.4.0 build containing these writes; otherwise version identity and saved-view assertions in UAT-001/UAT-012 can mislead or fail even when create calls work.

### 2026-08-11: Consent Audit Reader least-privilege review
**By:** Zoe
**What:** Reviewed the `DoD Banner - Consent Audit Reader` role for least privilege and accepted it as read-only for consent audit reporting. The role grants `prvReaddodbl_ConsentRecord` at Organization/Global scope so auditors can report across all consent rows. It does not grant Create, Write, Delete, Append, AppendTo, Assign, or Share on `dodbl_consentrecord`. The remaining Global `prvRead*` grants are Dataverse UI/metadata/read dependencies needed to open apps, tables, views, forms, web resources, and related user/team/business-unit metadata; non-read personal UI/query privileges are baseline user personalization privileges and do not affect the consent audit table.
**Why:** The consent audit trail is append-only. End users use the separate `DoD Banner - Consent Write` role for create plus own-row read, while auditors need tenant-wide read without any mutation authority. This split preserves audit integrity and avoids broadening the writer role.

### 2026-07-28T12:13:41-07:00: Separate consent-schema (revoked+formula) onto its own branch/PR #31, distinct from role PR #28 and doc-fix PR #30.
**By:** Squad (Coordinator), merged by Scribe
**What:** Keep the formerly bundled export concerns cleanly separated across three PRs: PR #30 owns the doc/web-resource name fixes (dodbl_docs, dodbl_release-notes), PR #28 owns the DoD Banner - Consent Write role, and PR #31 owns only the consent-schema changes (dodbl_revoked, dodbl_isactive formula SourceType 3, formula definitions, saved query, and management app surfacing).
**Why:** The unmanaged solution export bundled doc fixes, role artifacts, and consent-schema work together and clobbered already-correct documentation. Separating the branches preserves each review scope and keeps the schema PR explicit because changing the formula SourceType requires delete-and-reimport handling in existing environments.

### 2026-07-27: Correct consent table logical name
**By:** Mal
**What:** The consent table logical name is `dodbl_consentrecord` and the primary key logical name is `dodbl_consentrecordid`; the previously documented variants with an extra underscore between `consent` and `record` were incorrect.
**Why:** Exported metadata at `DoDBannerLibrary/Entities/dodbl_ConsentRecord/Entity.xml` verifies schema name `dodbl_ConsentRecord`, entity set `dodbl_consentrecords`, and primary key logical name `dodbl_consentrecordid`.

### 2026-07-25: Reconciled consent record audit schema
**By:** Mal
**What:** Use `dodbl_consent_record` as a User/Team-owned Dataverse audit table with Auto Number primary name (`dodbl_name`), required user lookup (`dodbl_userid`), required banner type choice (`dodbl_bannertype`), acknowledged/expiry timestamps, required consent text snapshot, and active flag.
**Why:** Dataverse needs a primary name column, so Auto Number is the safe audit-record choice. The choice column should mirror the real `dodbl_BannerType` vocabulary (`None`, `DoD`, `CUI`, `U`, `CONFIDENTIAL`, `SECRET`, `TOP SECRET`) instead of the issue's narrower DoD/CUI/Custom list, because the audit row must capture what the library actually showed.

### 2026-07-24 (revised): Optional consent modes; classification bar is the core
**By:** Devon Aleshire (with Mal — Lead, Zoe — Compliance)
**What:** Consent is optional, configurable tooling — NOT an enforced access control. Introduce a single `dodbl_ConsentMode` selector (`Off` | `HomePage` | `GlobalNotification`, default `Off`) so an admin enables the home-page overlay (`dodbl_banner-launch-page`) OR the shell global notification (`dodbl_dodbanner` / `Xrm.App.addGlobalNotification`) OR neither. The two consent surfaces can NEVER fire simultaneously — enforced by code path, not config. `dodbl_ShowConsentBanner` becomes a legacy fallback only. The data **classification marking bar** (CUI/U/CONFIDENTIAL/SECRET/TOP SECRET) is the solution's primary feature and focus. Consent-cookie consistency debt is fixed **atomically** across all three consent surfaces (`pcf/DodBannerControl` index.ts, `dodbl_dodbanner`, `dodbl_banner-launch-page`): #3 malformed-cookie `URIError`, #4 rename `Accepted` → `dodbl_Accepted`, #5 `Secure` flag, #6 PCF `_consentSetup` reset. PCF docs corrected: control-type is `standard`, not virtual.
**Why:** Authentication into the GCC High tenant is the real access boundary; AC-8 system-use notification is inherited at the tenant/workstation logon banner (pending AO/ISSO confirmation), so in-app consent is supplementary hardening, not the primary control. This avoids fragile, unsupported `window.top` DOM enforcement and stops repeated direction churn. Keeps the solution simple and centered on its most compliance-significant contribution (classification marking).
**Supersedes:** "Single consent entry point" (below) — consent is no longer one hardwired path; both surfaces are selectable options. Also reframes "Ship v1.3.0 with UX-only consent gate; defer hard enforcement."
**Issue disposition:** #13 reframed as optional advanced-enforcement guidance for adopters requiring enforced in-app consent (not a blocking defect). #7 and #14 reframed around optional consent tooling, not mandatory AC-8 enforcement.
**Verification action (open):** Confirm AC-8 inheritance posture with the AO/ISSO and document it in the compliance/ATO trail.

### 2026-07-24: Issue #7 closeout includes consent-cookie hardening regressions
**By:** Wash
**What:** Treat consent-cookie hardening regressions in the new `dodbl_banner-launch-page` landing page as blocking closeout findings, even though issue #7 acceptance criteria only explicitly call out split-before-decode and version bump.
**Why:** Issue #7 says the new page "already implements the correct pattern." Reusing the generic `Accepted` cookie name or omitting the `Secure` flag means the new page still shares known issues #4 and #5 with other hosts, so closing the branch as "validated" would be misleading.
**Routing impact:** Kaylee should handle implementation fixes; Zoe should review whether cookie naming/flags are required for the intended GCC High compliance posture.

### 2026-07-24: AC-8 gate requirements for MDA entry points
**By:** Zoe
**What:** Treat a home-page consent gate as AC-8-complete only if every alternative Model-Driven App entry path (deep links, search, direct subarea URLs) is covered by the same acknowledgement control, and require every consent surface to source AO-approved text from `dodbl_DoDConsentText`.
**Why:** Sitemap-first ordering improves the default path but is not a complete enforcement boundary by itself. Compliance posture depends on preventing bypass through alternate navigation and on keeping the displayed system-use notification aligned with the AO-approved override across all surfaces.

### 2026-07-24: Launch page consent text resolution
**By:** Kaylee
**What:** `dodbl_banner-launch-page` now resolves consent text by honoring query-string overrides first (`dodbl_DoDConsentText` / `consentText` / `data` payload), then falling back to the same `Xrm.WebApi` environment-variable lookup pattern used by `dodbl_dodbanner`.
**Why:** The current sitemap subarea does not pass a populated consent-text query parameter, so matching the existing `dodbl_dodbanner` env-var lookup keeps behavior consistent today while remaining compatible with future subarea query-string wiring.

### 2026-07-24: Single consent entry point  — ⚠️ SUPERSEDED
**Superseded by:** "Optional consent modes; classification bar is the core" (top of Active Decisions). Both consent surfaces are now selectable via `dodbl_ConsentMode`; they remain mutually exclusive by code path, so the duplicate-banner concern this decision addressed is still guaranteed — just via config rather than removal.
**By:** Devon Aleshire
**What:** The MDA consent gate is delivered only via the custom home page overlay (`dodbl_banner-launch-page`); the shell-level `Xrm.App.addGlobalNotification` path was removed.
**Why:** This is the simplest and most logical implementation path and avoids over-complicating the UX with duplicate entry points.

### 2026-07-24: Ship v1.3.0 with UX-only consent gate; defer hard enforcement
**By:** Devon Aleshire
**What:** Ship v1.3.0 with the UX-only consent gate while consciously accepting the known AC-8 deep-link/global-search bypass limitation, tracked in issue #13.
**Why:** The team accepted the limitation for v1.3.0 so UAT can proceed while hard enforcement is deferred and tracked explicitly.

### 2026-07-24: Home page classification bar injection
**By:** Kaylee
**What:** `dodbl_banner-launch-page` now self-renders the shell-level classification bar on the custom Home page by reading `dodbl_BannerEnabled`, `dodbl_BannerType`, and `dodbl_BannerPosition` from Dataverse environment variables, honoring per-environment overrides, injecting into `window.top.document`, and using the shared `[data-dodbl-bar]` cleanup contract so later form loads dedupe instead of stacking bars.
**Why:** Model-Driven App form `OnLoad` handlers never fire on custom pages, so the existing `dodbl_dodbanner` shell helper could not create the classification bar on Home. Self-rendering keeps the classification marking visible on the app landing page while preserving the current dedupe contract.
**Tech debt:** The bar helper logic is duplicated from `dodbl_dodbanner` because the two web resources are separate assets today. Track this under #17: move shared classification-bar rendering into one common web resource or generated source so colors, DOM contract, cleanup, and header-shift behavior cannot drift.

### 2026-07-24: Home-page classification bar UAT extension
**By:** Wash
**What:** Extended `docs/uat/UAT-v1.3.0-consent-gate.md` with Home-page classification bar coverage in UAT-023 through UAT-029, including Bottom/Top/Both positions, disabled state, SECRET color mapping, shared `data-dodbl-bar` no-double-stacking, and env-var read failure graceful degradation. Live browser validation remains pending Devon's manual GFIM-DEV execution; static code validation of `dodbl_banner-launch-page` passed.
**Why:** The v1.3.0.0 fix made the custom Home page self-render the classification bar independently of configured forms, so UAT needs explicit Home-page coverage without fabricating unobserved live results.

### 2026-07-24: Fresh env-var reads for classification bar re-enable
**By:** Kaylee
**What:** `dodbl_banner-launch-page` and `dodbl_dodbanner` now add a changing, valid `modifiedon le {now+5m}` predicate to environment-variable WebApi reads and normalize `dodbl_BannerEnabled` with trim/null/default handling.
**Why:** GFIM-DEV UAT showed an off→on asymmetry: disabling removed the Home-page classification bar, but re-enabling did not restore it on reload. The defensible root cause is a stale cached `environmentvariablevalue` read returning the old `No` value after re-enable; the fresh predicate changes the OData URL without using unsupported custom query parameters, and empty/null values still default to enabled.

### 2026-07-24: Revert env-var modifiedon freshness filters
**By:** Kaylee
**What:** Reverted the `addFreshReadFilter()` mechanism from both `dodbl_banner-launch-page` and `dodbl_dodbanner`, restoring plain `schemaFilter` / `valFilter` environment-variable WebApi queries. Retained the safer `dodbl_BannerEnabled` parsing where null, empty, unknown, or default values resolve enabled, while explicit `no`, `false`, and `0` disable the bar.
**Why:** GFIM-DEV showed the `modifiedon le <future ISO>` cache-bust predicate can make environment-variable reads fail, and the launch page intentionally catches env-var failures silently, so the classification bar disappeared with otherwise-valid defaults. The original off→on delay is better understood as Power Platform environment-variable value propagation/publish timing or the specific re-enable path used, not something the client should paper over with unsupported OData predicates.

### 2026-07-24: Null-guard env-var value override (fixes Home-page bar not rendering)
**By:** Kaylee
**What:** In getBannerEnvVars (both dodbl_banner-launch-page and dodbl_dodbanner), only override a definition's defaultvalue with the environmentvariablevalue when that value is non-null and non-empty.
**Why:** A cleared env-var value leaves a null value row in Dataverse; the old code clobbered the "CUI" default with null, so bannerType became "" and no bar rendered. Also fixes the disable→re-enable regression.

### 2026-07-24: Clarify case-sensitivity in docs (env-var values are case-insensitive)
**By:** Zoe
**What:** Scoped the "case-sensitive" guidance to the data-classification HTML/CSS path; documented that environment-variable banner values (dodbl_BannerType/Enabled/Position) are case-insensitive.
**Why:** Devon verified on GFIM-DEV that lowercase "secret" and "internal" rendered correct bars; the old wording misleadingly implied env-var values were case-sensitive.

### 2026-07-24: UAT v1.3.0 signed off by Devon
**By:** Wash
**What:** All UAT-v1.3.0 cases (incl. Home-page bar UAT-023–029) marked PASSED; Devon approved on GFIM-DEV.
**Why:** Manual verification confirmed banner types, positions, acknowledgement, enable/disable, and Home-page classification bar all work after the null-guard fix (6032490).

### 2026-07-24: Header title simplified without subtitle replacement
**By:** Kaylee
**What:** `dodbl_banner-launch-page` uses a single header title, "DoD Banner Library Management App", and removes the duplicated GCC High / IL4/IL5 subtitle rather than replacing it.
**Why:** The environment/compliance context already appears in the Solution Status card, and the existing flex header remains visually balanced with the icon and version badge without CSS changes.

### 2026-07-24: PCF control version bump for canvas-app cache refresh
**By:** Kaylee
**What:** Bumped `DoDBannerLibrary.DodBannerControl` from v1.2.0 to v1.2.1 and synced the rebuilt PCF manifest/bundle into the solution Controls artifact folder.
**Why:** Canvas apps cache PCF controls by control version. The v1.3.0 cookie-hardening bundle was present on disk, but the manifest still advertised v1.2.0, so re-importing the solution did not force canvas apps to refresh and they continued using the old `Accepted` cookie behavior. Incrementing the PCF control version makes the platform pick up the rebuilt bundle containing `dodbl_Accepted` and `Secure; SameSite=Strict`.

### 2026-07-24: v1.3.0 cookie & robustness hardening (#3,#4,#5,#6)
**By:** Kaylee
**What:** Renamed consent cookie Accepted->dodbl_Accepted (all 3 files); added Secure; SameSite=Strict to all cookie writes; hardened getCookie to split-before-decode (index.ts, dodbl_dodbanner); reset _consentSetup on showConsent off->on cycle (PCF).
**Why:** Close v1.3.0 release-blocking security/robustness gaps (collision/bypass, plaintext-cookie CWE-614, URIError DoS of the gate, consent-gate not re-showing).

### 2026-07-24: v1.3.0 acceptance criteria and readiness verdict
**By:** Mal
**What:** Defined consolidated, testable v1.3.0 acceptance criteria in `docs/releases/v1.3.0-acceptance-criteria.md` and assessed each criterion against merged code and signed UAT.
**Why:** The release needs one source of truth for readiness. The Home-page consent gate, #14 refinements, classification bar, versioning, sitemap order, and UAT sign-off are met, but #3, #4, #5, and #6 remain release-scope gaps in PCF/form cookie hardening, cookie naming, Secure attributes, and `_consentSetup` reset behavior. Recommendation: close #7 and #14; keep #3/#4/#5/#6 open and fix before tagging v1.3.0 unless explicitly deferring them to a patch.

### 2026-07-24: Canvas consent persistence limitation for v1.3.0
**By:** Zoe (Compliance/Security + documentation)
**What:** v1.3.0 is release-ready for the Model-Driven App production path. The MDA launch-page consent gate persists the renamed `dodbl_Accepted` cookie with `Secure; SameSite=Strict` on the same-origin path, and issues #3, #4, and #5 are treated as met for that path. Issue #6 code is implemented, but Canvas verification is deferred to v1.4.0 and persistent Canvas consent is tracked in issue #21.
**Why:** Canvas app testing showed `DodBannerControl` runs inside a sandboxed code-component sub-iframe. `document.cookie` writes from the PCF component do not surface to the host origin (`apps.high.powerapps.us`), while console testing confirmed the host origin itself can persist `SameSite=Strict` cookies. The consent modal still functions per session in Canvas; cross-session persistence needs a host-persisted output property / Dataverse-backed approach aligned with the v1.4.0 consent epic.

### 2026-07-24T21:05:00-07:00: v1.3.0 cookie hardening review approved
**By:** Zoe (Compliance/Security + documentation)
**What:** Approved Kaylee's v1.3.0 cookie-hardening diffs for PCF, `dodbl_dodbanner`, and `dodbl_banner-launch-page`: cookie rename is consistent as `dodbl_Accepted`; consent writes include `Secure; SameSite=Strict`; split-before-decode prevents malformed unrelated cookies from breaking the gate; PCF `_consentSetup` re-arms on showConsent OFF->ON; no classification-bar regression risk found.
**Why:** Same-site Dataverse/browser consent reads do not need cross-site cookie attachment, so `SameSite=Strict` is appropriate, and the reviewed changes close the targeted consent-gate robustness/security gaps.
**Note:** Preserving `=` inside arbitrary cookie values remains a non-blocking robustness improvement for future generic cookie helpers.

### 2026-07-24T22:45:00-07:00: v1.3.0 documentation reconciliation
**By:** Zoe (Compliance/Security + documentation)
**What:** Reconciled release notes, `dodbl_docs`, and README with shipped PR #20 cookie-hardening behavior: consent cookie references now use `dodbl_Accepted`; cookie flags are documented as `Secure; SameSite=Strict`; release notes include malformed-cookie `getCookie` hardening, PCF `showConsent` off-to-on re-arm behavior, PCF bundle version `1.2.1`, and the Canvas consent-persistence limitation tracked in #21.
**Why:** Documentation needed to match the shipped v1.3.0 behavior without overstating certification or compliance claims.

### 2026-07-24: Governance boundary for .ai and .squad
**By:** Mal
**What:** `.ai/` is durable PRODUCT truth: ADRs plus living docs such as context, domain, data model, security, and pipelines. `.squad/` is team direction, routing, and session log. `.squad/decisions.md` must link to `.ai/` product truth, never restate product decisions. Squad grounding stays tiered: the coordinator injects one relevant `.ai/` file per spawn; agents must not bulk-load the `.ai/` tree. The freed `.ai/decisions/009` number is available for Kaylee's Canvas-limitation product ADR.
**Why:** Product facts need one durable home, while Squad needs fast routing and session memory without duplicated content or context bloat.

### 2026-07-24: AI security context must avoid compliance overclaims
**By:** Zoe
**What:** `.ai/security.md` now treats GCC High / IL4/IL5 as the intended deployment environment and describes implemented controls factually, without claiming certification, accreditation, ATO, AC-8 compliance, or other standards compliance.
**Why:** The `.ai/` context will ground agents; if it overstates compliance posture, agents may repeat unsupported claims in docs, PRs, or release material.

### 2026-07-24: Public-repo hygiene working agreement added to team.md
**By:** Mal
**What:** Added a concise public-repository hygiene working agreement to `.squad/team.md`.
**Why:** Public repo; keep internal-to-Microsoft material out of committed/public artifacts; points to .ai/security.md as authoritative.

### 2026-07-24: Public-repo do-not-publish guardrail documented
**By:** Zoe
**What:** Added concise public-repository disclosure hygiene guidance to `.ai/security.md`, `.ai/context.md`, `.github/copilot-instructions`, and `README.md`.
**Why:** Public repo; keep internal-to-Microsoft material out and generalize internal requirements to high-level public-safe wording.

### 2026-07-24: `.ai/` reconciliation formalized as Lead responsibility (no new role)
**By:** Mal
**What:** Team decided against a dedicated `.ai` curator ("Ghost"); `.ai/` release-time reconciliation is now an explicit Lead responsibility — charter + routing.md updated by coordinator, and a reconciliation step added to `.ai/pipelines.md` release checklist. Security/disclosure sections co-reviewed with Zoe.
**Why:** `.ai/` upkeep is bursty (clusters at releases), not continuous — a process trigger, not new headcount, closes the gap.

### 2026-07-27: Technical integration guide for issue #22
**By:** Kaylee
**What:** Created `docs/technical-integration-guide.md` as a source-grounded reference for technical reviewers and makers integrating the DoD Banner Library into their own Power Platform apps.
**Why:** Issue #22 needs one public-safe guide that explains shipped solution components, app-load hosting through the launch page, PCF hosting options, consent behavior, planned v1.4 audit work, and source discrepancies reviewers must reconcile before audit writes are treated as implemented.

### 2026-07-27: Correct consent record column logical names
**By:** Mal
**What:** In-app web resource content must refer to the consent record lookup column as `dodbl_userid` and banner snapshot column as `dodbl_bannertype`; the prior standalone system-user and consent-type aliases are not consent table column logical names.
**Why:** Exported consent record metadata and `.ai/data-model.md` identify `dodbl_userid` and `dodbl_bannertype` as the authoritative logical names. Keeping release content aligned prevents admins from creating or documenting the wrong columns.

## Governance
- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction

### 2026-07-25: Migrated .ai/ to slim convention (.ai/decisions/ → .ai/adr/)
**By:** Mal
**What:** Regenerated slim `.ai/` from `.ai_old/`: context + domain/data-model/security/pipelines + adr/0001-0009 (4-digit), added `.ai/` grounding pointer to copilot-instructions.md, updated all `.ai/decisions/` → `.ai/adr/` pointers in team.md/README/copilot-instructions.
**Why:** User migrated `.ai/`→`.ai_old/` and asked to regenerate via the slim setup prompt, preserving all durable knowledge reconciled to v1.3.0.


### 2026-08-03T22-44-08: DoD Banner - Consent Write role passed least-privilege testing (issue #9 / PR #28)
**By:** Serenity
**What:** DoD Banner - Consent Write role passed least-privilege testing (issue #9 / PR #28)
**References:** issue #9, PR #28, dodbl_consentrecord
**Why:** Devon (requester) manually validated the `DoD Banner - Consent Write` role in a live environment. Results: (1) created a consent record as admin user; (2) logged in as a different user and could NOT see the admin's record — confirms no cross-user read (Basic-scope Read); (3) could create a new consent record as the second user — confirms Create works; (4) could NOT update or delete the created record — confirms append-only enforcement at the role level (no Write/Delete privileges). This clears the "Least-privilege test in a separate environment" gate in the PR #28 checklist. Role approved for merge pending rebase on main.

### 2026-08-04T03-09-40: PR 33 compliance review found role-name accuracy edit only
**By:** Zoe
**What:** PR 33 compliance review found role-name accuracy edit only
**References:** PR #33, .ai/security.md, DoDBannerLibrary\WebResources\dodbl_docs, DoDBannerLibrary\WebResources\dodbl_release-notes
**Why:** Reviewed PR #33 documentation diff for compliance-safe and disclosure-safe phrasing. No compliance/certification overclaims, internal-only material, or incorrect consent table logical name were found. Recommended aligning the public docs' displayed role name with authoritative `.ai/security.md`: use `DoD Banner - Consent Write` rather than `DoD Banner — Consent Write` in `DoDBannerLibrary\WebResources\dodbl_docs` and `DoDBannerLibrary\WebResources\dodbl_release-notes`.


### 2026-08-03T20:28:54-07:00: v1.4.0 consent-write audit contract and Unspecified banner type (consolidated)
**By:** Mal, Zoe
**References:** #10, #11, #12, PR #36, PR #37, `.ai/adr/0010-power-pages-consent-write.md`, `.ai/data-model.md`, `.ai/security.md`, `DoDBannerLibrary\Entities\dodbl_ConsentRecord\Entity.xml`, `DoDBannerLibrary\OptionSets\dodbl_bannertype.xml`
**What:** #10 (PCF) and #11 (MDA JS) consent acknowledgements must best-effort create `dodbl_consentrecord` audit rows using the exported Dataverse schema. Create only `dodbl_userid@odata.bind` for the current `systemuser`, `dodbl_bannertype`, `dodbl_acknowledgedon`, `dodbl_expirydate`, `dodbl_consenttext`, and `dodbl_revoked=false`; never set formula/system fields such as `dodbl_isactive`, `dodbl_name`, or `dodbl_consentrecordid`. Banner type choices are `DoD=703870001`, `CUI=703870002`, `U/UNCLASSIFIED=703870003`, `CONFIDENTIAL=703870004`, `SECRET=703870005`, `TOP SECRET=703870006`, and `Unspecified=703870007`. Empty or unsupported runtime `bannerType` values map to `Unspecified` so the acknowledgement audit row is still attempted without fabricating a displayed classification. Consent audit creation remains non-blocking: failures are caught and logged without user-identifiable data, and cookie/UI acknowledgement continues. For #12 Power Pages capture, link to ADR 0010 rather than restating the product decision.
**Why:** The real exported `dodbl_ConsentRecord` schema makes `dodbl_bannertype` required and marks formula/system columns invalid for create. Zoe's PR #36/#37 review found that skipping creates for empty/unsupported `bannerType` left an audit gap when consent is enabled without a classification bar. Mal reconciled the contract by adding the explicit `Unspecified=703870007` choice, preserving append-only acknowledgement auditing while avoiding a false classification snapshot.


### 2026-08-04: GitHub Pages site structure for issue #38
**By:** Kaylee
**What:** Built a two-page static GitHub Pages site under `docs/`: `index.html` for the marketing landing page and `documentation.html` for maker/reference documentation, sharing `docs/assets/site.css` and reusing existing `docs/images/*` assets. Added `docs/.nojekyll` so GitHub Pages serves the static files directly.
**Why:** A two-page structure keeps the landing page polished and concise while giving classification markup, environment variables, usage notes, and limitations a stable documentation URL. The site remains self-contained, uses relative paths for project Pages hosting, and preserves existing docs content such as the technical integration guide.

### 2026-08-06T22:38:59-07:00: Consent audit table remains User/Team-owned; audit reader gets tenant-wide read
**By:** Zoe; approved by Devon
**References:** DoDBannerLibrary\Roles\DoD Banner - Consent Audit Reader.xml, DoDBannerLibrary\Other\Solution.xml, .ai/data-model.md, .ai/security.md
**What:** Keep dodbl_ConsentRecord User/Team-owned and preserve the end-user append-only write model. Add DoD Banner - Consent Audit Reader as a separate read-only auditor/app-manager role with Organization-scope Read on dodbl_ConsentRecord and no create, write, delete, assign, or share privileges.
**Why:** User/Team ownership keeps row-level least privilege for consent creators while a separate auditor role provides tenant-wide reporting without allowing tampering. Release follow-up: include the new security role in the next v1.4 solution version bump and dodbl_release-notes update.

### 2026-08-11: Consent cookie waits for audit write and active view filters current records
**By:** Kaylee
**What:** The launch-page and PCF consent flows now set the `dodbl_Accepted` cookie only after the consent audit write promise resolves. Guard-skip paths for unavailable Xrm/Web API or missing user resolve successfully so standalone previews can remember dismissal, while actual write failures reject and leave the cookie unset for retry on the next load. The Active Consent Records view now excludes revoked records, limits expiry dates to a relative future window, and sorts newest acknowledgements first.
**Why:** Setting the cookie before the Dataverse write could permanently suppress retries after a failed audit write. The saved view was showing revoked/expired history and burying the newest UAT records at the bottom.

### 2026-08-11: Release 1.4.1.0 patch bump
**By:** Mal
**What:** Bumped the managed solution metadata and current-version documentation from 1.4.0.0/v1.4.0 to 1.4.1.0/v1.4.1, synced the management launch page, in-solution docs, public docs index, and release notes, and added the 1.4.1 release-notes entry for the consent write-ordering fix, Active Consent Records view fix, and Consent Audit Reader role.
**Why:** PRs #41 and #42 landed after the 1.4.0.0 release and need a clean patch-version identity before GFIM-DEV redeployment. These are bug fixes plus an additive read-only role, so no new ADR is warranted; the durable role rationale already lives in `.ai/security.md` and `.ai/data-model.md`.

### 2026-08-11: GFIM-DEV v1.4.0 deploy halted at solution import
**By:** Wash
**What:** PCF control push completed successfully and the unmanaged solution packed successfully, but the GFIM-DEV unmanaged solution import halted because Dataverse returned a duplicate key error for dbo.DVTableSearchBase / ndx_for_entitykey_key_name on M365_Primary_model_dodbl_DoDBannerLibraryManagement.
**Why:** The runbook requires halting on live GCC High import failures. Web resource import/publish success was not confirmed, so Devon should not assume the stale dodbl_banner-launch-page web resource was updated by this run.


### 2026-08-12: Consolidate all post-v1.3.0 work into a single v1.5.0 release
**By:** Squad (Coordinator), on behalf of Devon Aleshire
**What:** The entire 1.4.x line (1.4.0 consent-write fix, 1.4.1.0 cookie/view fixes) plus the #43 admin config screen will ship as ONE consolidated release: **v1.5.0**. No separate v1.4.0 / v1.4.1 tags will be cut.
**Why:** The 1.4.x line was never released (last tag/release is v1.3.0). Rather than backfill intermediate tags, fold everything into a single clean release once #43 (PR #45) merges. This supersedes the earlier "hold and reconcile tag↔manifest" plan — the reconciliation target is now v1.5.0.
**Implications:**
- PR #45's manifest bump 1.4.1.0 → 1.5.0.0 is DESIRED — keep it.
- On merge: tag 'v1.5.0', reconcile tag↔manifest, aggregate release notes covering v1.4.0 → v1.5.0 changes.
- UAT sign-off (docs/uat/UAT-v1.4.0-consent-write.md) is still the release gate; extend it to cover the config screen before final release.
- Mal owns the release prep (notes aggregation, tag, managed export) on the user's word.

### 2026-08-12T15-20-47: v1.5.0 managed-solution export and verification
**By:** Mal
**What:** For the v1.5.0 cut, 'pac solution pack --packagetype Managed' was attempted from source after moving DoDBannerLibrary\dvtablesearchs out of the solution folder, but PAC reported Solution package type did not match requested type because the source tree is unmanaged. I reselected and verified PAC against GFIM-DEV (https://orga1b9bfb3.crm.microsoftdynamics.us/, org id 34e70151-afbb-ee11-9076-001dd802fc81), confirmed the unmanaged DoDBannerLibrary solution there is 1.5.0.0 and unmanaged, exported a managed solution to DoDBannerLibrary_managed.zip, then refreshed the changed dodbl_release-notes and dodbl_docs web-resource payloads in the managed zip from local source because no environment import is allowed in this release-prep step.
**Why:** The release needs a managed artifact for manual managed-import testing without creating a tag/release or importing anything into any environment. Final verification showed all 9 environment variable definitions are present (dodbl_BannerColor, dodbl_BannerEnabled, dodbl_BannerLabel, dodbl_BannerPosition, dodbl_BannerType, dodbl_BannerVersion, dodbl_ConsentExpiryDays, dodbl_DoDConsentText, dodbl_ShowConsentBanner), solution.xml has Managed=1, and the version is 1.5.0.0.

### 2026-08-12: App version display sourced from dodbl_BannerVersion env var
**By:** Squad (Coordinator), on behalf of Devon Aleshire
**What:** Kill hardcoded version strings in the running app. Introduce dodbl_BannerVersion (String) as the authoritative runtime version indicator. Web resources read it and display it; nothing hardcodes the current version anymore.
**Why:** Hardcoded stamps scattered across launch-page status card, dodbl_dodbanner, and docs drifted out of sync. Single env var readable by ALL users (avoids solution table privilege requirement). Config table rejected as unnecessary third source of truth.
**Scope / ownership:**
- Kaylee (web resources): add dodbl_BannerVersion env var definition; read at runtime and replace hardcoded version indicators (launch-page Solution Status card). Initial value = current solution version. Display read-only on config screen (NOT editable). Folded into PR fix/banner-classification-label-and-config-reload.
- Mal (release process): owns STAMPING dodbl_BannerVersion at each release matching Solution.xml Version. For v1.5.0, set to 1.5.0.0. Consider automating stamp in pack/build as follow-up. Release-notes PROSE stays version-specific; only "what version am I running" indicators go dynamic.
**Implication:** After this ships, updating displayed app version = update ONE env var value (or automated stamp), not N hardcoded strings.

### 2026-08-12: Environment variables pack through EnvironmentVariables component marker
**By:** Mal
**What:** Source solution folders should keep environment variable definition XML under DoDBannerLibrary/environmentvariabledefinitions/... and Other/Customizations.xml must include childless <EnvironmentVariables /> component marker. Do not add type 380 root components for env vars in Solution.xml; PAC 2.6.4 warns on them even after marker is present.
**Why:** 'pac solution pack' only processes env var shard files when childless component marker is present. With marker and no type 380 roots, pack emits no "root components are not defined" warning, import provisions definitions, and Dataverse exports them back under environmentvariabledefinitions.

### 2026-08-12T15-31-54: ADR 0006 Solution Checker findings formally accepted with supportability caveat
**By:** Mal; reviewed and accepted by Rai
**What:** Updated ADR 0006 to formally accept v1.5.0 Solution Checker 'web-avoid-window-top' findings as documented exception. ADR records 27 High findings across dodbl_banner-config.htm, dodbl_banner-launch-page.htm, dodbl_dodbanner.js, dodbl_docs.htm, dodbl_release-notes.htm, and dodbl_webtemplatesource.htm; Rai reviewed and accepted rationale on 2026-08-12.
**Why:** MDA classification bar must render in visible UCI shell and persist across navigation, requiring same-origin window.top access. Finding is accepted supportability risk, not access-control enforcement and not something future work should silently remove.

### 2026-08-12: window.top Security & Transparency wording approved with caveats
**By:** Rai
**What:** Approved publication of Security & Transparency section only if it avoids overclaiming fail-safe behavior and narrows "no user data" claim to window.top path. Approved wording provided in full detail in source document with caveats about same-origin assumptions, residual risks, and non-access-control boundaries.
**Why:** Original draft was directionally accurate but overstated two points: (1) "fails safe if origin differs" not safe to publish as blanket claim because dodbl_dodbanner initializes _doc without try/catch, future UCI isolation could break shell bar; (2) "no user data read/transmitted" too broad because consent audit paths write current user acknowledgement to Dataverse via Xrm.WebApi. Approved text keeps transparency benefit while preserving residual-risk caveat.

### 2026-08-12: Classification code-to-label map stays paired with color prefixes
**By:** Kaylee
**What:** MDA shell and launch-page bars translate banner codes to display labels using same prefix order as color map: CU -> CUI/purple, U -> UNCLASSIFIED/green, CO -> CONFIDENTIAL/blue, S -> SECRET/red, T -> TOP SECRET/orange. Unknown values keep grey fallback and display uppercased value; legacy DoD displays DOD with grey. dodbl_BannerColor is optional hex override: empty means type-derived default; valid #RGB/#RRGGBB overrides background and picks black/white text by luminance. Invalid color values ignored at runtime, fall back to type default.
**Why:** Admin config stores short codes (U, CUI, etc.); visible classification mark shows full user-facing label. Keeping label/color prefix precedence together prevents CUI/CONFIDENTIAL drift/collision on naive C match. Color override gives controlled customization without allowing malformed values to become injected CSS.

### 2026-08-12: Displayed app version comes from dodbl_BannerVersion
**By:** Kaylee
**What:** Runtime "current version" labels read dodbl_BannerVersion instead of hardcoded web-resource strings. Env var definition seeded to 1.5.0.0; launch page and docs labels fall back to 'unknown' only if value unavailable. Config screen displays value read-only and excludes from editable admin settings.
**Why:** Running app had stale hardcoded version stamps. Single string env var readable by normal users, avoids querying Solution table (which can require elevated privileges). Mal owns keeping dodbl_BannerVersion aligned with Solution.xml for each release.

### 2026-08-12: Accepted-risk global banner injector
**By:** Kaylee
**What:** Implemented shared window.top.__dodBanner classification-bar singleton seeded by Management app web resources, with throttled MutationObserver/interval watchdog that re-injects shell bar if MDA client-side navigation removes it.
**Why:** User approved full-coverage approach and accepted supportability risk related to ADR 0006 (window.top classification bar) so grid/view navigation keeps classification mark visible after seeded page installs runtime. ADR 0006 may warrant update to explicitly cover global watchdog/injector pattern; Coordinator/Mal should formalize.

### 2026-08-12: Prefer in-flow shell insertion for top classification bars
**By:** Kaylee
**What:** Shared window.top.__dodBanner injector now prefers inserting top classification bar as in-flow sibling before #topBar or #shell-container, with prior fixed/body insertion retained as fallback.
**Why:** Honors ADR 0006's window.top.document constraint while avoiding common MDA header overlap/offset hack when shell anchor available. Fixed/body path and shiftMdaHeader() remain for selector drift or alternate shells.

### 2026-08-12: Reload applies banner changes through app reload
**By:** Kaylee
**What:** Banner Configuration screen Reload action now performs full app reload instead of only re-fetching environment variable fields.
**Why:** Visible classification bar injected in model-driven app shell (not inside config iframe), so shell/app reload required to repaint bar immediately after configuration changes.

### 2026-08-12T15-24-20: Security & Transparency language added to public docs
**By:** Kaylee
**What:** Added Rai-approved Security & Transparency language about intentional MDA window.top usage to README and technical integration guide, surfaced public GitHub Pages showcase link near top of README.
**Why:** v1.5.0 security review requires supportability flag, same-origin assumptions, residual risk, and non-access-control boundary transparent up front for evaluators and implementers.

### 2026-08-12: PR #45 code review (admin banner-config screen)
**By:** Independent reviewer (not PR author Kaylee)
**Requested by:** Devon Aleshire
**References:** PR #45, issue #43
**Verdict:** APPROVE WITH NITS
**What:** Reviewed admin banner-config screen (issue #43) for RBAC safety, ES5 compliance, OData injection risk. RBAC role DoD Banner - Config Admin has least-privilege (no Delete on environmentvariablevalue); web resource uses parent.Xrm.WebApi correctly; GUID/schema validation gates all filter concatenation; ES5-clean; classification confirm wraps entire save batch. Non-blocking: multi-field save sequential (mid-batch failure leaves earlier saves committed); BannerType "(empty)" can't take effect when definition default non-empty (fails safe). PR #45 bumps solution manifest 1.4.1.0 → 1.5.0.0 (release-process decision for Coordinator/Devon, not code defect).
**Deploy readiness:** Safe to import to GFIM-DEV as-is once version-bump decision made; requires standard dvtablesearchs/ move-aside before pac solution import.

### 2026-08-12: PR #46 code review (fix/banner-classification-label-and-config-reload)
**By:** Independent reviewer (not PR author Kaylee)
**Requested by:** Devon Aleshire
**References:** PR #46
**Verdict:** APPROVE (with non-blocking nits)
**What:** Comprehensive review covering CSS/HTML injection safety, label/color agreement, cookie clearing, env var definitions, config field logic, dodbl_BannerVersion read-only enforcement, ES5 compliance, public-site documentation. Key findings: normalizeHexColor() runs BEFORE CSS injection; label/color logic byte-identical across web resources; cookie clear/set use matching scope; env var definitions well-formed consistent with existing vars; config logic correctly distinguishes "cleared to auto" from "unchanged auto"; dodbl_BannerVersion read-only on config screen; ES5-clean; public site has no GUIDs/org URLs/tenant names. Non-blocking: solution.xml asymmetry (6 pre-existing env vars no RootComponent, 2 new vars do—harmless but inconsistent); color normalization write cosmetic only.
**Deploy readiness:** Safe to import to GFIM-DEV at solution version 1.5.0.0 using standard dvtablesearchs/ move-aside. Post-import: confirm dodbl_BannerVersion resolves to 1.5.0.0.

### 2026-08-12: Connect writing skill added
**By:** Book
**What:** Added portable connect-writing skill and reusable prompt methodology for Connect narratives, impact tracking, promotion-readiness coaching.
**Why:** Squad needs generic, reusable way to transform work into evidence-based career-impact stories without hardcoding cycle-specific priorities or exposing sensitive information.

