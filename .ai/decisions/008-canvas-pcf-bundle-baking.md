# Decision: Canvas App / Custom Page PCF Bundle Baking Behavior

**Date:** 2026-07-24  
**Status:** Decided — documented operational procedure

## Context

After deploying updated PCF bundle code via `pac pcf push`, the DoD consent modal in the Canvas App (Custom Page) was still running the old bundle — the close button (×) was still present and the CSS injection fix was not active. The consent text property updated immediately (bound property, resolved at runtime), but the modal behavior did not change.

Investigation confirmed this is a fundamental Canvas App platform behavior: when a Canvas App or Custom Page is **published**, the Power Apps runtime snapshots the PCF bundle into the app package at that moment. The bundle code is frozen in the app package until the app is explicitly republished.

**Why text updated but code did not:** `consentText` is a bound/input property read at runtime from the Canvas App formula engine — it is dynamic. The JS bundle is a compiled artifact embedded in the package at publish time — it is static.

## Decision

Document this as a known operational procedure and explicitly call it out in `.ai/context.md` (Known Gotchas) and deployment runbooks. The behavior cannot be changed — it is a platform constraint.

**Standard remediation steps:**

1. Push the updated bundle: `pac pcf push --publisher-prefix dodbl`
2. Open the Canvas App or Custom Page in **Power Apps Studio** (`make.high.powerapps.us`)
3. **Save** (Ctrl+S) → **Publish** → **Publish this version**
4. Open the published app in a new tab to confirm the new bundle is active

**Edge case — republish insufficient:** In the testing of v1.2.0, republishing the Custom Page alone did not pick up the new bundle when the page had been previously published with an earlier bundle version. The resolution was to **remove the PCF control from the page and re-add it**, then save and publish. This forces the app package to resolve the control fresh and snapshot the current bundle.

This edge case appears to occur when the app package has a deeply cached control reference from a prior publish. Removing and re-adding the control clears that cached reference.

## Reasons

1. **Platform constraint — not a code issue.** No change to the PCF source or solution structure can bypass this behavior.
2. **Documentation prevents wasted debugging time.** Without this knowledge, a developer might incorrectly conclude `pac pcf push` failed, repeat the push, or attempt to revert code changes.
3. **The remove/re-add workaround is safe.** Removing the PCF control from a Canvas App screen and re-adding it does not delete the screen, other controls, or property bindings on other controls. Only the removed control's property configuration is lost and must be re-entered.

## Consequences

- Include "republish the Canvas App / Custom Page" as an explicit step in all PCF deployment runbooks and release checklists.
- If a deployer reports that their Canvas App is not reflecting a new bundle after `pac pcf push` + republish, the first remediation is remove/re-add + republish.
- This behavior applies to **all** PCF controls in Canvas Apps, not just `DodBannerControl`.
- Model-Driven App form scripts (`dodbl_dodbanner.js`) do **not** have this behavior — web resource JS is resolved at runtime on every page load, not baked into an app package.
