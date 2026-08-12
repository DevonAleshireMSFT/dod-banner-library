### 2026-08-12: Prefer in-flow shell insertion for top classification bars
**By:** Kaylee
**What:** The shared `window.top.__dodBanner` injector now prefers inserting the top classification bar as an in-flow sibling before `#topBar` or `#shell-container`, with the prior fixed/body insertion retained as fallback.
**Why:** This honors ADR 0006's `window.top.document` constraint while avoiding the common MDA header overlap/offset hack when the shell anchor is available. The fixed/body path and `shiftMdaHeader()` remain for selector drift or alternate shells.
