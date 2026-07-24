# Kaylee — History

**Project:** DoD Banner Library — a managed Power Platform solution providing GCC High–safe consent and classification banner assets for Power Pages, Canvas Apps, and Model-Driven Apps in DoD environments (IL4/IL5). Zero external dependencies, no CDN calls, no jQuery.

**My surface:** `pcf/DodBannerControl` (TypeScript PCF virtual component), `dod-consent-banner.html`/JS, `cui-consent-banner.html`, `banner-core.css`, Liquid web template source (`dodbl_webtemplatesource`), MDA `OnLoad` JS (`dodbl_dodbanner`).

**Hard constraints:** No jQuery (removed in v1.0), no CDN calls, no external scripts. Exact id/class contract (`cookieConsent`, `closeCookieConsent`, `cookieConsentOK`, `consentBackground`) must not change without updating docs.

**Requested by:** Devon Aleshire.

**2026-07-24:** Team stood up (Squad init). No decisions recorded yet — starting fresh.
