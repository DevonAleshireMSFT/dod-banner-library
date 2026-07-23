# Decision: Use window.top for MDA Classification Bar Injection

**Date:** 2026-07-23  
**Status:** Decided — accepted risk, no supported alternative

## Context

MDA UCI form web resource scripts execute inside a 0×0 hidden `<iframe>`. Any DOM element injected into `document` (the form iframe document) is invisible to the user. The visible application is rendered in `window.top`.

The consent banner was migrated to `Xrm.App.addGlobalNotification` (Decision 005), which is a supported UCI API and requires no DOM manipulation. However, no equivalent supported API exists for injecting a persistent, visible classification mark (a full-width colored bar) into the UCI shell page.

Microsoft explicitly flags `window.top` as an anti-pattern:  
> [avoid-window-top](https://learn.microsoft.com/en-us/power-apps/developer/model-driven-apps/best-practices/business-logic/avoid-window-top) — Impact: High, Category: Supportability

## Decision

Continue using `window.top.document` for classification bar DOM injection only. The script targets:

```javascript
var _doc = (window.top && window.top.document) ? window.top.document : document;
```

All classification bar elements are injected into `_doc` (the UCI shell page). Consent uses `Xrm.App` instead (no window.top needed for that path).

## Reasons

1. **No supported alternative.** There is no UCI Client API equivalent to "inject a persistent DOM element at top or bottom of the shell page." `addGlobalNotification` is notification-only. The PCF approach is not available in MDA form scripts.
2. **Scope is limited.** `window.top` is only used for classification bar rendering. Consent, env var reads, and cookie operations do not use it.
3. **Fallback is graceful.** If `window.top` is unavailable (cross-origin SameSite restriction or future UCI isolation), the `? window.top.document : document` fallback means the script silently no-ops on bar injection rather than throwing.
4. **Classification is a visual requirement, not optional.** DoD/CUI environments may require a visible classification mark to be present at all times. Omitting it is not an acceptable fallback.

## Consequences

- **Solution Checker will flag this** as a high-impact supportability violation. This is a known, accepted finding. Do not attempt to "fix" it by removing the classification bar.
- If a future MDA/UCI update breaks `window.top` cross-origin access, the classification bar will silently disappear. Monitor Microsoft deprecation notices.
- `shiftMdaHeader()` uses the same `_doc` to shift the MDA nav header down 28px when `dodbl_BannerPosition` is `Top` or `Both`. If the header selector (`header`, `[role='banner']`, `[data-id='navbar']`) doesn't match in a given MDA version, the header shift silently no-ops and the bar overlays the header — no functionality is broken.
- Classification bar elements use `pointer-events: none` so they do not block clicks on any MDA UI even when visually overlapping during the shift retry window.
