---
adr: 0010
title: Power Pages Consent-Write Approach
status: accepted
date: 2026-08-03
deciders: Mal
reviewers: Zoe
applies-to: dod-banner-library
supersedes: null
superseded-by: null
---
# Decision: Power Pages consent-write approach

**Date:** 2026-08-03  
**Status:** Decided  
**Related issue:** #12

## Context

The v1.4.0 consent-audit work creates a Dataverse `dodbl_consentrecord` row when a user acknowledges the banner. The exported schema requires `dodbl_userid`, a lookup to the current Dataverse `systemuser`, plus the banner type, acknowledgement time, expiry time, consent-text snapshot, and revoked flag.

Power Pages is different from the PCF and Model-Driven App hosts. It may run for anonymous visitors or authenticated portal users, and it does not provide the same `context.webAPI` / `Xrm.WebApi` current-user surface used by the logged-in Dataverse app hosts. Anonymous sessions also do not have a current `systemuser` value that satisfies the required `dodbl_userid` lookup.

This repository is public and the solution is intended for GCC High / DoD IL4/IL5 Power Platform deployments. This ADR describes the product architecture posture only; it does not assert certification, accreditation, authorization, or standards compliance. Deployment teams must confirm the chosen approach with their AO/ISSO and tenant architecture.

## Options considered

| Option | Assessment |
|---|---|
| Power Automate instant HTTP flow | Not the default. It introduces a publicly reachable write endpoint or shared-secret pattern for a consent action, which increases exposed surface area and still does not solve anonymous-to-`systemuser` identity without extra design. |
| Power Pages Web API | Best fit for an authenticated-only Power Pages path because it stays inside the Power Pages / Dataverse platform boundary and avoids a separate public proxy. It still requires deployment proof that the authenticated site identity can be authorized and mapped to the required `dodbl_userid` `systemuser` lookup. |
| Azure Function | Viable only as an adopter-specific extension when a deployment already has an approved Azure boundary, operations model, authentication design, and identity-mapping design. It adds infrastructure this library should not require by default. |
| Dataverse Web API via browser CORS | Not the default. Browser-side token/CORS setup for Dataverse adds authentication complexity and a larger client-side attack surface than the native Power Pages path. It also does not make anonymous users valid `systemuser` lookup targets. |

## Decision

Do not implement anonymous server-side consent capture for Power Pages under the current v1.4.0 schema. The current audit table requires `dodbl_userid` to point at a Dataverse `systemuser`, and an anonymous Power Pages visitor cannot provide that value. Writing anonymous records through a shared service identity would weaken the audit meaning of the `User` column and needs a separate AO/ISSO-approved design and likely schema decision.

For v1.4.0, Power Pages consent-write support is **authenticated-only capture**:

1. Use the native Power Pages Web API as the preferred implementation path only on pages that require authentication.
2. Before enabling the write, verify in the target GCC High tenant that the authenticated Power Pages identity can be authorized to create `dodbl_consentrecord` and can populate `dodbl_userid` with the correct Dataverse `systemuser`.
3. If that identity mapping cannot be proven, do not create a Dataverse audit row from Power Pages. Keep the cookie-based consent flow working and log only a non-blocking warning.
4. If a deployment requires anonymous server-side audit capture, treat it as a separate implementation outside the default library path. The deployment must choose and approve its own proxy/flow/function architecture, identity semantics, table permissions, monitoring, and data model changes.

## Reasons

1. **Schema truth first.** `dodbl_userid` is required and targets `systemuser`; anonymous Power Pages sessions do not satisfy that contract.
2. **Least additional surface area.** The native Power Pages Web API avoids adding a new public HTTP endpoint or Azure component for the default product path.
3. **No false audit identity.** A shared service identity would show who performed the write, not who acknowledged the consent notice.
4. **Disclosure-safe compliance posture.** The ADR states what must be verified by the deployment team without claiming IL4/IL5, FedRAMP, NIST, CMMC, AC-8, or authorization status.

## Consequences

- Issue #12 implementation remains open; this ADR only decides the approach.
- Power Pages anonymous consent remains cookie-based unless a deployment separately approves an anonymous audit architecture.
- Authenticated-only capture must be best-effort and must not block the cookie consent flow or UI dismissal if the Dataverse write fails.
- Zoe should review the compliance framing before implementation guidance is treated as release-ready.
