# Decision: MDA JS Uses Inline CSS Injection (Not `<link>` Tag)

**Date:** 2026-07  
**Status:** Decided — do not revert

## Context

The initial design of `dodbl_dodbanner.js` loaded the consent modal stylesheet by injecting a `<link href="...dodbl_bannercore">` element into the form's `<head>`.

## Problem

MDA forms open inside an iframe. Browsers apply same-origin and content-security-policy restrictions that silently prevent externally-referenced stylesheets from loading inside the iframe context. The consent modal rendered without any CSS — unstyled HTML.

## Decision

`injectCSS()` in `dodbl_dodbanner.js` embeds the full consent modal CSS as a template literal inside a `<style data-dodbl-core>` element injected into the document head. The `data-dodbl-core` attribute makes the injection idempotent.

Additionally, `position: fixed` (not `absolute`) is used in the MDA-embedded CSS so the overlay layers correctly over the MDA chrome.

## Consequences

- `banner-core.css` (repo root) remains the source of truth for CSS.
- When updating consent modal styles, both `banner-core.css` AND the embedded CSS string in `dodbl_dodbanner.js` AND `pcf/DodBannerControl/DodBannerControl/css/DodBannerControl.css` must be updated.
- The PCF embeds its own copy of the CSS as a bundled web resource (`css/DodBannerControl.css`).
- Do not revert `dodbl_dodbanner.js` to use `<link>` tags.
