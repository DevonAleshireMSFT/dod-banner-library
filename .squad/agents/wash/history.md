# Wash — History

**Project:** DoD Banner Library — a managed Power Platform solution providing GCC High–safe consent and classification banner assets for Power Pages, Canvas Apps, and Model-Driven Apps in DoD environments (IL4/IL5). Zero external dependencies, no CDN calls, no jQuery.

**My surface:** Import verification (managed/unmanaged solution), post-import checklist (`dodbl_docs`), cross-host testing (Power Pages, Canvas Apps, MDA), environment variable behavior matrix.

**Known defaults to test against:** `dodbl_BannerEnabled=true`, `dodbl_BannerType=empty`, `dodbl_ConsentExpiryDays=30`, `dodbl_ShowConsentBanner=false`, `dodbl_BannerPosition=Bottom`.

**Requested by:** Devon Aleshire.

**2026-07-24:** Team stood up (Squad init). No decisions recorded yet — starting fresh.

**2026-07-24:** Validated issue #7 consent gate against acceptance criteria and produced manual UAT scenarios for new user, returning user, malformed/expired cookie, and bypass attempt.
Deployed unmanaged solution v1.3.0.0 to GFIM-DEV, then re-deployed after Kaylee's UI fixes.

**2026-07-24:** Re-packed and re-imported unmanaged solution v1.3.0.0 to GFIM-DEV using PAC profile [2] (daleshire@gfim.onmicrosoft.us, UsGovHigh). Import, publish, and version verification succeeded; Solution Checker critical findings were known informational unsupported-API / window.top items, and temporary deployment artifacts were removed.

📌 Team update (2026-07-24T17:49:13-07:00): v1.3.0 consent-gate UAT now includes Home-page classification bar scenarios UAT-023 through UAT-029; static validation passed and live GFIM-DEV validation remains pending Devon — decided by Wash.


📌 Team update (2026-07-24T18:24:15-07:00): v1.3.0.0 redeploy to GFIM-DEV includes Kaylee's classification-bar re-enable fix; validate off→on behavior during UAT — decided by Kaylee/Wash.

📌 Team update (2026-07-24T19:53:00-07:00): Recorded Devon's GFIM-DEV UAT v1.3.0 sign-off with all cases passing, including UAT-023 through UAT-029; commit 2c70ef8.

📌 Team update (2026-08-03T20:28:54-07:00): v1.4.0 consent-write shipped for #10/#11 via merged PRs #36/#37; ADR 0010 set the authenticated-only Power Pages approach for #12; `Unspecified=703870007` was added for empty/unknown bannerType audit rows. — decided by Mal and Zoe

📌 Team update (2026-08-06T22:05:15-07:00): Wash verified the v1.4.0 consent-write contract for PCF/Canvas, MDA form, and MDA launch page, produced the live test plan, and found no defects; Power Pages (#12) remains not implemented.
