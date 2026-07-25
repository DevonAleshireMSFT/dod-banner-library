# Decision: Remove jQuery from Consent Banner

**Date:** 2026-07  
**Status:** Decided — do not revert

## Context

The original `dodbl_dodconsentbanner` used jQuery for DOM manipulation and the fade-out animation on the consent modal overlay.

## Decision

jQuery was removed entirely. All DOM operations use vanilla JS (`document.getElementById`, `classList`, etc.). The fade-out animation was rewritten using `requestAnimationFrame` with a decreasing opacity loop.

## Reasons

1. **GCC High CDN restriction.** Importing jQuery from a CDN is blocked. Bundling a local copy of jQuery (~87 KB minified) significantly inflates the web resource size with no benefit.
2. **No other jQuery usage.** The rest of the solution uses no jQuery. Adding it as a dependency for one animation pattern is disproportionate.
3. **Maintenance.** Vanilla JS is more readable, auditable, and has no version dependency risk.

## Consequences

- `requestAnimationFrame` pattern must be followed for any future animations. Do not add jQuery back.
- All future web resource JS in this solution must be vanilla JS.
