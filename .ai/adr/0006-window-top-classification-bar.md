---
adr: 0006
title: Window Top Classification Bar
status: accepted
date: 2026-07-25
deciders: DoD Banner Library Team
reviewers: DoD Banner Library Team
applies-to: dod-banner-library
supersedes: null
superseded-by: null
---
# Decision: Use window.top for MDA Classification Bar Injection

**Date:** 2026-07-23  
**Status:** Decided — accepted risk, no supported alternative

## Context

MDA UCI form web resource scripts execute inside a 0×0 hidden `<iframe>`. Any DOM element injected into `document` (the form iframe document) is invisible to the user. The visible application is rendered in `window.top`.

The consent banner was migrated to `Xrm.App.addGlobalNotification` (ADR 0005), which is a supported UCI API and requires no DOM manipulation. However, no equivalent supported API exists for injecting a persistent, visible classification mark (a full-width colored bar) into the UCI shell page.

Microsoft explicitly flags `window.top` as an anti-pattern:  
> [avoid-window-top](https://learn.microsoft.com/en-us/power-apps/developer/model-driven-apps/best-practices/business-logic/avoid-window-top) — Impact: High, Category: Supportability

## Decision

Continue using `window.top.document` for classification bar DOM injection only. The script targets:

```javascript
var _doc = (window.top && window.top.document) ? window.top.document : document;
```

All classification bar elements are injected into `_doc` (the UCI shell page). The v1.5.0 implementation installs a global `window.top.__dodBanner` singleton so the launch page, form script, documentation pages, release notes, web-template source page, and configuration page share one shell renderer instead of stacking or racing independent bars.

The singleton uses a `MutationObserver` plus an interval watchdog to restore the expected bar after full-page navigation or UCI shell re-renders. Top bars now prefer in-flow insertion immediately before `topBar` / `shell-container`; if those shell anchors are unavailable, the renderer falls back to the older fixed/body insertion with header shifting. This retired the prior offset-only approach for modern UCI shells while preserving a graceful fallback.

## Reasons

1. **No supported alternative.** There is no UCI Client API equivalent to "inject a persistent DOM element at top or bottom of the shell page." `addGlobalNotification` is notification-only. The PCF approach is not available in MDA form scripts.
2. **Scope is limited.** `window.top` is used for classification banner placement, related header positioning/runtime state, and the shared `dodbl_Accepted` consent cookie. It is not used to read Dataverse form fields, page content, or user-entered data.
3. **Fallback is graceful.** If `window.top` is unavailable (cross-origin SameSite restriction or future UCI isolation), the `? window.top.document : document` fallback means the script silently no-ops on bar injection rather than throwing.
4. **Classification is a visual requirement, not optional.** DoD/CUI environments may require a visible classification mark to be present at all times. Omitting it is not an acceptable fallback.

## Consequences

- **Solution Checker will flag this** as a high-impact supportability violation. This is a known, accepted finding. Do not attempt to "fix" it by removing the classification bar.
- If a future MDA/UCI update breaks `window.top` cross-origin access, the classification bar will silently disappear. Monitor Microsoft deprecation notices.
- `shiftMdaHeader()` uses the same `_doc` to shift the MDA nav header down 28px when `dodbl_BannerPosition` is `Top` or `Both`. If the header selector (`header`, `[role='banner']`, `[data-id='navbar']`) doesn't match in a given MDA version, the header shift silently no-ops and the bar overlays the header — no functionality is broken.
- Classification bar elements use `pointer-events: none` so they do not block clicks on any MDA UI even when visually overlapping during the shift retry window.

## Solution Checker Acceptance (v1.5.0)

Microsoft Solution Checker returned 27 High findings for rule `web-avoid-window-top`. All findings are this single supportability rule:

| Web resource | Findings |
|---|---:|
| `dodbl_banner-config.htm` | 6 |
| `dodbl_banner-launch-page.htm` | 6 |
| `dodbl_dodbanner.js` | 6 |
| `dodbl_docs.htm` | 3 |
| `dodbl_release-notes.htm` | 3 |
| `dodbl_webtemplatesource.htm` | 3 |

**Decision:** ACCEPTED as a documented exception for the DoD classification-display requirement. The classification bar must live in the UCI shell (`window.top`) to render above the app shell and persist across navigation. This is not a false positive; it should not be treated as a false positive or silently removed.

**Review:** Reviewed and accepted by Rai on 2026-08-12.

### Security rationale

This solution intentionally uses `window.top` in Model-Driven Apps to place the classification banner in the visible UCI shell rather than inside a hidden form/web-resource iframe. This is a documented exception for a DoD display requirement; Microsoft Solution Checker will continue to flag it as `web-avoid-window-top` (High / supportability), and it should not be treated as a false positive or silently removed.

In the intended GCC High Model-Driven App deployment, the banner web resources and the app shell are first-party pages on the same Dynamics origin, and browser same-origin policy prevents cross-origin DOM access. The `window.top` path is limited to classification-banner placement, related header positioning/runtime state, and the shared `dodbl_Accepted` consent cookie. It is not used to read Dataverse form fields, page content, or user-entered data, and it does not transmit DOM data outside the tenant. Consent audit features, when enabled, write normal Dataverse consent records through supported `Xrm.WebApi` calls rather than through `window.top`.

Residual risk remains: this design depends on same-origin access to the MDA shell. If Microsoft changes UCI frame isolation or the resource is hosted cross-origin, the shell banner and shared-cookie behavior may degrade or fail, and the classification bar could disappear until the implementation is updated. Tenant authentication and Dataverse security remain the access boundary; the banner and consent notification are visibility/audit features, not access-control enforcement.
