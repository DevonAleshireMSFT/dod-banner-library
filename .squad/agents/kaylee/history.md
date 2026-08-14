# Kaylee — History

**Project:** DoD Banner Library — a managed Power Platform solution providing GCC High–safe consent and classification banner assets for Power Pages, Canvas Apps, and Model-Driven Apps in DoD environments (IL4/IL5). Zero external dependencies, no CDN calls, no jQuery.

**My surface:** `pcf/DodBannerControl` (TypeScript PCF virtual component), `dod-consent-banner.html`/JS, `cui-consent-banner.html`, `banner-core.css`, Liquid web template source (`dodbl_webtemplatesource`), MDA `OnLoad` JS (`dodbl_dodbanner`).

**Hard constraints:** No jQuery (removed in v1.0), no CDN calls, no external scripts. Exact id/class contract (`cookieConsent`, `closeCookieConsent`, `cookieConsentOK`, `consentBackground`) must not change without updating docs.

**Requested by:** Devon Aleshire.

**2026-07-24:** Team stood up (Squad init). No decisions recorded yet — starting fresh.

**2026-07-24:** Fixed v1.3.0 consent-gate bugs covering overlay dismissal, Secure cookie flag, `dodbl_DoDConsentText` wiring, and stale docs.
Refined the MDA consent UI to a single custom home page overlay, updated page copy, and made the WARNING label bold red.

📌 Team update (2026-07-24T17:49:13-07:00): Home custom page now self-renders the classification bar because form OnLoad never fires on custom pages; shared data-dodbl-bar dedupe contract is preserved, with shared-helper refactor debt tracked under #17 — decided by Kaylee.


📌 Team update (2026-07-24T18:24:15-07:00): Classification bar env-var reads now use a fresh modifiedon filter and hardened enabled parsing in Home-page and MDA shell assets; GFIM-DEV off→on stale-read fix committed as 6fdced4 — decided by Kaylee.

📌 Team update (2026-07-24T19:53:00-07:00): Fixed Home-page and MDA classification bar rendering by preserving BannerType defaults when env-var value rows are null/empty; commit 6032490. Also recorded the env-var freshness filter revert context.

📌 Team update (2026-07-24T22:50:00-07:00): v1.3.0 closeout shipped PR #20 and tag v1.3.0 with Kaylee's cookie-hardening fixes, launch-page header simplification, PCF control version 1.2.1 rebuild/sync for Canvas cache refresh, and status-card version update. Canvas cross-session consent persistence remains deferred to v1.4.0 issue #21 because the PCF sandbox cannot persist host-origin cookies reliably — decided by Kaylee, Zoe, and Serenity.

📌 Team update (2026-07-24T23:20:00-07:00): Kaylee authored .ai/decisions/009-canvas-pcf-cookie-sandbox-limitation.md; the decision remains in .ai/ as product truth under the new .ai/ / .squad/ boundary. — decided by Kaylee


💬 PM kudos (2026-07-24T23:48:08-07:00): DevonAleshireMSFT said, "I always know I can count on the team to come together for a quality decision."

📌 Team update (2026-07-27T11:37:38-07:00): Authored docs/technical-integration-guide.md for issue #22 as the source-grounded technical reviewer and maker usage reference; flagged four source/schema discrepancies for reconciliation. — decided by Kaylee
📌 Team update (2026-07-27T11:37:38-07:00): Discrepancy #1 from the #22 guide is resolved on chore/fix-consent-table-schema-names; consent table references now use dodbl_consentrecord and Web API set dodbl_consentrecords. — decided by Mal


📌 Team update (2026-08-03T15:42:23-07:00): DoD Banner - Consent Write role passed live least-privilege testing; consent PRs #28, #29, #30, and #31 are merged; issue #9 is closed. — decided by Serenity

📌 Team update (2026-08-03T19:59:53-07:00): Issue #32 consent deployment docs shipped via squash-merged PR #33; docs now include Consent Write role assignment and `dodbl_isactive` delete-and-recreate migration guidance with the exact role name `DoD Banner - Consent Write`. — decided by Serenity, Kaylee, and Zoe

📌 Team update (2026-08-03T20:28:54-07:00): v1.4.0 consent-write shipped for #10/#11 via merged PRs #36/#37; ADR 0010 set the authenticated-only Power Pages approach for #12; `Unspecified=703870007` was added for empty/unknown bannerType audit rows. — decided by Mal and Zoe

📌 Team update (2026-08-04T14:16:27-07:00): GitHub Pages marketing/docs site for issue #38 shipped via merged PR #39; `docs/index.html`, `docs/documentation.html`, `docs/assets/site.css`, and `docs/.nojekyll` are live from `main` `/docs`. — decided by Kaylee

📌 Team update (2026-08-11T21:50:38-07:00): Remaining v1.4.0 UAT blocker is the Active Consent Records view fix — add the active/expiry filter and change acknowledgement sorting from ascending to the expected order. — decided by Wash/Mal/Zoe

📌 Team update (2026-08-11T23:50:59.790-07:00): Fixed consent cookie ordering for launch page and PCF so cookies are written only after audit writes succeed; also fixed Active Consent Records filtering/sort in merged PR #42.
