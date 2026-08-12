### 2026-08-12: Accepted-risk global banner injector
**By:** Kaylee
**What:** Implemented a shared `window.top.__dodBanner` classification-bar singleton seeded by Management app web resources, with a throttled `MutationObserver`/interval watchdog that re-injects the shell bar if MDA client-side navigation removes it.
**Why:** The user approved the full-coverage approach and accepted the supportability risk related to ADR 0006 (`window.top` classification bar) so grid/view navigation keeps the classification mark visible after a seeded page installs the runtime. ADR 0006 may warrant an update to explicitly cover the global watchdog/injector pattern; coordinator/Mal should formalize.
