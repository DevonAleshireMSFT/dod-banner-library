# Decision: Canvas PCF cookie sandbox limitation

**Date:** 2026-07-24  
**Status:** Decided

## Context

`DodBannerControl` is a PCF code component used in Canvas Apps / Custom Pages, where it runs inside a sandboxed code-component sub-iframe. During v1.3.0 UAT, acknowledging consent in the Canvas demo did not persist across sessions: deleting the `dodbl_Accepted` cookie re-showed the modal, and no new cookie was observed on the visible host origin.

Console testing confirmed the host origin (`apps.high.powerapps.us`) can persist both `SameSite=Strict` and `SameSite=None` cookies, with successful readback in both cases. Therefore the `Secure; SameSite=Strict` cookie flags from issue #5 are not the cause. The PCF component writes `document.cookie` from the deeper sandboxed sub-iframe, and those writes do not surface to the visible host origin, so `getCookie` continues to read empty in Canvas.

## Decision

Accept this as a documented platform limitation for v1.3.0. Cookie-based consent persistence is not viable from a PCF code component in Canvas.

The Canvas consent modal still functions per session: it shows and dismisses, but does not remember acknowledgement across reloads. The Model-Driven App same-origin web-resource path (`dodbl_banner-launch-page`, `dodbl_dodbanner`) persists `dodbl_Accepted` normally and is unaffected.

The proper Canvas fix is to emit consent state through a bound PCF output property, so the host app can store it in a Canvas variable, and/or persist consent in a Dataverse-backed record. That work is tracked in issue #21 for v1.4.0.

## Reasons

1. **Platform sandbox behavior — not a code defect.** The failing write occurs from the sandboxed PCF sub-iframe, not from the visible Canvas host origin.
2. **Host-origin testing isolated the cause.** Direct console tests on `apps.high.powerapps.us` proved that the host can persist the cookie attributes used for issue #5, so the `Secure; SameSite=Strict` flags are not responsible.
3. **Distinct from ADR 008.** ADR 008 documents Canvas bundle baking and caching of PCF control code at publish time. This decision documents runtime cookie-write isolation inside the Canvas PCF sandbox.

## Consequences

- Do not rely on cookie persistence for Canvas consent in v1.3.0.
- The Model-Driven App path remains the supported persistent-consent path today.
- v1.4.0 Canvas persistence must use a bound output property and/or Dataverse-backed storage, tracked in issue #21.
- This is related to ADR 008 because both are Canvas sandbox behaviors, but they affect different layers: bundle packaging versus runtime cookie isolation.
- Full session rationale remains in `.squad/decisions.md`; this ADR is the durable product record.
