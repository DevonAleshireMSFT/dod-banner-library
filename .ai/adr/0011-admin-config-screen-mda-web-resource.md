---
adr: 0011
title: Admin Banner Config Screen as Model-Driven Web Resource
status: accepted
date: 2026-08-12
deciders: Mal
reviewers: Zoe
applies-to: dod-banner-library
supersedes: null
superseded-by: null
---
# Decision: admin banner config screen is a Model-Driven App web resource

**Date:** 2026-08-12  
**Status:** Decided  
**Related issue:** #43

## Context

Deployers need to change the four banner environment variables — `dodbl_BannerEnabled`, `dodbl_BannerType`, `dodbl_BannerPosition`, `dodbl_ConsentExpiryDays` — without opening the maker portal and without redeploying the solution. Environment variable values are environment-specific data, not code: the banner web resources resolve them at page load and prefer the per-environment `environmentvariablevalue` over the definition default, so a value change reflects on the next page load.

`dodbl_BannerType` is a classification setting. The screen therefore has to be governed, not simply convenient.

## Options considered

| Option | Assessment |
|---|---|
| Canvas app using the Dataverse connector | Rejected for this repository. A Canvas app ships as a binary `.msapp` that cannot be reviewed or maintained as source in Git, which conflicts with the source-first ALM posture of this solution. |
| PCF control on a Custom Page or form | Rejected. `context.webAPI` cannot write from a Canvas/Custom Page host (ADR 0009 documents the related Canvas sandbox limitation), and the PCF control here is deliberately dependency-free and reads only bound properties. A config editor would need a host field or table to bind to, which adds a component with no runtime purpose. |
| Model-Driven App HTML web resource using `parent.Xrm.WebApi` | **Chosen.** Plain-text source in Git, reuses the existing `dodbl_banner-launch-page` pattern and its `getBannerEnvVars` read order, no new dependency, and `Xrm.WebApi` supports both read and write in the Model-Driven host. |

## Decision

Ship the admin config screen as the HTML web resource `dodbl_banner-config`, surfaced in the `dodbl_DoDBannerLibraryManagement` app under **Administration → Banner Configuration**.

- It reads the four environment variable definitions and their `environmentvariablevalue` records through `parent.Xrm.WebApi`, using the same "environment value wins over definition default" resolution as the runtime banner code.
- It writes by updating the existing `environmentvariablevalue` record, or creating one when only the definition default exists.
- Access is gated to the `DoD Banner - Config Admin` or `System Administrator` role. The client-side role check is a usability guard; the enforcement boundary is the Dataverse privilege set on `environmentvariablevalue`.
- Changing a classification value requires an explicit confirmation dialog listing the old and new values.

Auditing uses the platform record: every write stamps `modifiedby` / `modifiedon` on the `environmentvariablevalue` row, and the screen displays that attribution per variable. Dataverse auditing on `environmentvariablevalue` gives the full before/after change history and must be enabled at the environment level to retain it — this is a deployment prerequisite, not something the solution can package.

## Reasons

1. **Source-reviewable.** An HTML web resource is diffable and code-reviewable; an `.msapp` is not.
2. **Writes actually work.** The Model-Driven `Xrm.WebApi` path performs Dataverse writes, unlike the Canvas PCF path.
3. **Reuses proven code.** The read pattern already exists in `dodbl_banner-launch-page` and `dodbl_dodbanner`.
4. **Governable.** A dedicated, least-privilege security role scopes who may change a classification setting.

## Consequences

- Config changes apply to every user of the environment on their next page load or refresh. Live push to already-open sessions is explicitly out of scope.
- Deployers must assign `DoD Banner - Config Admin` to the small set of users allowed to change banner configuration, and must not grant it broadly.
- Deployers must enable environment-level auditing (and table auditing on `environmentvariablevalue`) to retain a full change history; without it, only the latest `modifiedby` / `modifiedon` attribution is available.
- The screen intentionally does not expose `dodbl_DoDConsentText` or `dodbl_ShowConsentBanner`; those remain maker-portal settings until a follow-up decides how AO-approved text is governed.
- Related: ADR 0009 (Canvas PCF sandbox limitation) explains why the Canvas/PCF write path was not viable.
