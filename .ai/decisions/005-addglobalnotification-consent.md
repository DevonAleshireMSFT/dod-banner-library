# Decision: Use Xrm.App.addGlobalNotification for MDA Consent Banner

**Date:** 2026-07-23  
**Status:** Decided — do not revert to DOM modal

## Context

The original `dodbl_dodbanner.js` MDA consent implementation used DOM injection to render a blocking modal overlay inside `window.top.document`. This required five functions (`injectCSS`, `injectModal`, `showBanner`, `fadeIn`, `fadeOut`) and depended on `window.top` manipulation — a Microsoft-flagged anti-pattern.

Two additional problems surfaced:
1. GCC High CSP blocks nonce-less `<style>` injection, so the modal had no styles unless all CSS was embedded inline per-element (fragile and verbose).
2. The modal was tied to `dodbl_BannerType` — if no classification type was configured, no consent notification appeared either, coupling two unrelated concerns.

## Decision

Replace the DOM modal with `Xrm.App.addGlobalNotification` — a supported UCI Client API in the Xrm namespace.

```javascript
Xrm.App.addGlobalNotification({
  type: 2,
  level: 3,               // Warning — yellow notification bar
  message: consentText,
  showCloseButton: false,
  action: {
    actionLabel: "I Acknowledge",
    eventHandler: function () {
      setCookie("Accepted", "Yes", expiryDays);
      Xrm.App.clearGlobalNotification(notificationId);
    }
  }
}).then(function (id) { notificationId = id; });
```

## Reasons

1. **Supported path.** `addGlobalNotification` is a documented UCI API. Using it is categorically different from `window.top` DOM injection. Microsoft will not break it in a patch release.
2. **No CSP issue.** Rendered by the UCI shell with its own styles. No `<style>` injection required.
3. **Persists across navigation.** The notification remains visible when the user navigates between forms in the same app session. The modal injection re-ran on every form load.
4. **Decouples consent from classification.** `dodbl_ShowConsentBanner` (Boolean env var) now controls consent independently of `dodbl_BannerType` (classification bar).
5. **Simpler code.** Five functions replaced by one. No race conditions from `setTimeout` fade timing.

## Consequences

- `injectCSS()`, `injectModal()`, `showBanner()`, `fadeIn()`, `fadeOut()` are removed from `dodbl_dodbanner.js`. Do not restore them.
- The consent notification renders as a yellow UCI warning bar with "I Acknowledge" action, not a full-page blocking modal. The built-in "See Less / See More" truncation handles long consent texts.
- `dodbl_ShowConsentBanner` must be set to `yes` / `true` / `1` in env vars for the notification to appear. It defaults to off.
- `window.top` is still used for the classification bar (no supported UCI API equivalent — see Decision 006).
- Cookie name `"Accepted"` is unchanged. Existing user consent cookies remain valid.
