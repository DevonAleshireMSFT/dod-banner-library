# Decision: Set buildMode=production in PCF pcfconfig.json

**Date:** 2026-07-23  
**Status:** Decided — permanent setting

## Context

The default `pac pcf init` scaffold sets no `buildMode` in `pcfconfig.json`, which causes `pcf-scripts build` to use webpack `mode: development`. In development mode, webpack uses `devtool: 'eval'` (eval-based source maps), embedding the module source inside `eval()` calls in the bundle.

Microsoft Power Apps Solution Checker flags this as a **critical violation**:
> "Usage of the JavaScript eval function should be limited where possible."

The development bundle was 13.3 KiB. Attempting `npm run build -- --buildMode production` (space syntax) failed in PowerShell with "Not a valid sub-command 'production'". Setting `NODE_ENV=production` before `npm run build` also had no effect because pcf-scripts reads `buildMode` from its own config chain, not `NODE_ENV`.

## Decision

Add `"buildMode": "production"` to `pcf/DodBannerControl/pcfconfig.json`:

```json
{
  "outDir": "./out/controls",
  "buildMode": "production"
}
```

`pcf-scripts` reads this file before applying defaults, and passes `buildMode` directly to webpack as `mode`. With `mode: production`, webpack defaults to `devtool: false` (no eval, no source maps).

## Reasons

1. **Eliminates the Solution Checker critical violation** without any code changes.
2. **Smaller bundle.** Production build: 5.92 KiB vs 13.3 KiB (minified + tree-shaken).
3. **Appropriate for a DoD-environment solution.** A production managed solution should not contain developer tooling artifacts.
4. **Permanent ergonomics improvement.** Plain `npm run build` is now always a production build. No special flags or environment variables needed. Developers use `npm start` or `npm run start:watch` for the local test harness.

## Consequences

- **No browser source maps** when inspecting the bundle in DevTools. Use `npm start` (dev mode test harness) for debugging — it uses a local development server with live reload.
- `pcfconfig.json` must be committed to source control (it already is). Do not remove `"buildMode": "production"` when regenerating or scaffolding new controls in this project.
- If a new PCF control is added to this solution, ensure its `pcfconfig.json` also includes `"buildMode": "production"`.
