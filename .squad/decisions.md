# Squad Decisions

## Active Decisions

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

## Governance
- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction

