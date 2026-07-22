# Decision: PCF as Field Control (Not Dataset) with Direct Container Styling

**Date:** 2026-07  
**Status:** Decided

## Context

The PCF control was scaffolded to serve two modes: (1) a DoD consent modal full-page overlay and (2) a classification color bar. Two template choices exist: `field` (single bound value) and `dataset` (tabular data).

## Decision

**Template: `field`.** The `bannerEnabled` property is a `TwoOptions` bound property — a single yes/no value. Dataset template is inappropriate.

**Direct container styling for classification bar.** The classification bar renders by styling `_container` (the PCF-provided `div`) directly via individual `element.style.*` assignments, rather than appending a child `div` with `cssText`.

## Reasons

- **Template:** `field` matches the `TwoOptions` data type used for `bannerEnabled`. Dataset template would require row data, which is not needed.
- **Direct styling:** Using `cssText` with `font-family: "Segoe UI", sans-serif` causes the browser CSS parser to silently discard the rule in some contexts (the quoted comma-separated value is parsed as invalid by the cssText setter). Individual property assignments are reliable.
- **No child div:** Inserting a child `div` inside `_container` introduced height-inheritance issues. Styling `_container` directly avoids needing the child to inherit an explicit pixel height.

## Consequences

- `clearBar()` must reset all individual `style.*` properties that `renderClassificationBar()` sets — using `element.style.removeProperty()` or empty string assignment.
- The PCF `field` template limits the control to one bound property. Additional inputs (`bannerType`, `consentExpiryDays`, `consentText`) are `input` type (not bound).
- `bannerEnabled` may be `null` in the test harness if no value is set — the code treats `null` as "don't show" and returns early.
