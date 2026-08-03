---
name: "power-platform"
description: "Power Platform solution architecture and GCC High delivery patterns for dod-banner-library"
domain: "power-platform"
confidence: "high"
source: "team-earned"
---

## Context

This repo is a **managed Power Platform solution** for GCC High / IL4-IL5 deployments. The checked-in source of truth is the unpacked `DoDBannerLibrary\` folder plus the PCF source under `pcf\DodBannerControl\`. Treat exported zips, exported PCF bundles, and regenerated relationship/search artifacts as build products, not hand-authored source.

## Patterns

### Solution Structure & ALM

- `DoDBannerLibrary_managed.zip` is the deployable artifact for downstream/shared environments. README quick start imports the managed zip first.
- `DoDBannerLibrary_unmanaged.zip` is for maker/customizer environments where you expect further edits and round-trips back to source.
- `DoDBannerLibrary.zip` is the local pack/export working artifact. In this repo it is produced by `pac solution pack --zipfile DoDBannerLibrary.zip --folder DoDBannerLibrary --packagetype Both`, then unpacked again during source sync.
- Current pack/import/export workflow already documented in repo:
  - Pack: `pac solution pack --zipfile DoDBannerLibrary.zip --folder DoDBannerLibrary --packagetype Both`
  - Import: `pac solution import --path DoDBannerLibrary_managed.zip --force-overwrite --publish-changes`
  - Export/unpack: `pac solution export --name DoDBannerLibrary --path . --managed false` then `pac solution unpack --zipfile DoDBannerLibrary.zip --folder DoDBannerLibrary --packagetype Unmanaged`
- `DoDBannerLibrary\Other\Solution.xml` is the release spine. In this branch it is `1.3.0.0`, `Managed` is `0` in source, publisher unique name is `dod_banner_library`, and the customization prefix is `dodbl` (schema names appear as `dodbl_*`).
- The root components tell you what really ships: web resources (`type="61"`), the model-driven app/site map, the PCF custom control (`type="66"`), and the demo Canvas app (`type="300"`).
- Ship changes with a four-part version bump in `Solution.xml`. In this repo, version bump + release notes update travel together.
- `.gitignore` is explicit about generated Power Platform noise:
  - `DoDBannerLibrary\Controls\` = exported Dataverse copy of the PCF bundle; source of truth is `pcf\DodBannerControl\`
  - `DoDBannerLibrary\dvtablesearchs\` = regenerated search metadata
  - `DoDBannerLibrary\Other\Relationships.xml` and `Relationships\` = standard system relationship exports, not custom-authored logic
  - `*_managed.zip`, `*_unmanaged.zip`, and `DoDBannerLibrary.zip` = pack/export outputs

### Dataverse Fundamentals

- Keep the publisher prefix everywhere: tables, columns, choices, env vars, app names, and web resources should all start with `dodbl_`.
- Environment variables in this repo are first-class solution components under `DoDBannerLibrary\EnvironmentVariableDefinitions\...`. The current set is:
  - `dodbl_BannerEnabled` — Boolean, default `yes`
  - `dodbl_BannerType` — String, current default `CUI` in source
  - `dodbl_ConsentExpiryDays` — Number, default `30`
  - `dodbl_DoDConsentText` — String, no default, optional AO override
  - `dodbl_ShowConsentBanner` — Boolean, default `no`
  - `dodbl_BannerPosition` — String, default `Bottom`
- Remember the Dataverse split: the **definition** carries schema/type/default; the **value** is environment-specific. If behavior must vary per tenant, wire the runtime to the current value instead of hardcoding text or flags in a web resource.
- Security roles compose privilege-by-privilege and scope-by-scope. `Create`, `Read`, `Write`, and `Delete` are independent; granting `Create` does not imply `Read`, and user/business-unit/org scope materially changes behavior.
- For custom tables with lookups, also think about `Append` / `Append To`; CRUD alone is not enough when records reference other records.
- Issue #9 is the right mental model for minimum-permission design here: a consent log writer only needs the narrow privileges required for `dodbl_consentrecord`, not a broad customizer role.
- Table-level auditing is the compliance lever for durable evidence. It captures record create/update/delete events and audited column changes; it only works when auditing is enabled at the org, table, and column levels. Issue #8 already calls for enabling auditing on the future `dodbl_consentrecord` table.
- Client-side Dataverse writes should use the supported Web API surface:
  - MDA/web resource: `Xrm.WebApi.createRecord("dodbl_consentrecord", payload)`
  - PCF: `context.webAPI.createRecord("dodbl_consentrecord", payload)`
  Keep writes non-blocking when the UI action is informational, but do not confuse a successful client-side write with a real access gate.

### PCF (Power Apps Component Framework)

- Start with the manifest. `pcf\DodBannerControl\DodBannerControl\ControlManifest.Input.xml` defines the public contract: `bannerEnabled`, `bannerType`, `showConsent`, `consentExpiryDays`, and `consentText`.
- Lifecycle for this repo's control is the standard PCF shape:
  - `init()` — capture container and first render
  - `updateView()` — re-render on property changes
  - `getOutputs()` — return outbound values (empty in this control)
  - `destroy()` — remove listeners and any DOM appended outside the container
- `index.ts` is the real behavior source. It styles the container for classification bars, injects modal CSS once, appends modal DOM to `document.body`, and removes listeners in `destroy()`. If you add global listeners or detached DOM, clean them up there.
- Do not commit PCF build artifacts. This repo already ignores `pcf\*\node_modules\`, `out\`, `.pcfenv\`, `bin\`, and `obj\`.
- Power Platform docs distinguish **virtual** vs **standard** controls. Virtual means the framework owns host DOM/reconciliation and you must avoid assumptions that require full-page DOM control. **Important repo-specific gotcha:** this checked-in control is currently `control-type="standard"` and implements `ComponentFramework.StandardControl`, even though team shorthand sometimes calls it a "virtual component." Confirm the manifest before applying virtual-control rules.
- For Canvas Apps, pass configuration into the control through manifest properties, not by having the control go hunt for Dataverse environment variables on its own. In this repo, `consentText` is the AO-text override input and `showConsent` decouples the consent modal from the classification bar.
- Operational gotcha: `pac pcf push` updates the custom control in Dataverse, but Canvas Apps/Custom Pages may continue running an older snapshotted bundle until the app is saved and republished. If republish still misses the new bundle, remove/re-add the control and publish again.

### Model-Driven Apps (MDA)

- `DoDBannerLibrary\AppModuleSiteMaps\dodbl_DoDBannerLibraryManagement\AppModuleSiteMap.xml` is the app navigation source. It currently has:
  - `Home` group first, bound to `$webresource:dodbl_banner-launch-page`
  - `Resources` group for docs/release notes/web template source
  - `Demo` group for the Canvas app
- **Anti-pattern: sitemap-as-security-gate.** Issue #13 proves that putting a consent page first in the sitemap is only a UX convention. `ShowPinned="True"` and `ShowRecents="True"` are enabled, and deep links/global search are outside sitemap ordering anyway.
- Name this problem explicitly when reviewing work: **"Sitemap gate != enforcement."** If a task claims to "restrict access" by moving a subarea or making Home first, that is not a compliance control.
- `Xrm.App.addGlobalNotification()` is appropriate for informative, non-blocking banners. `clearGlobalNotification()` clears it after acknowledge. This is useful for visibility and consistency, but it is still informational-only and dismissible by platform design.
- AC-8 wording matters: a **notification** tells the user something; an **enforced gate** prevents access until acknowledgement. Issue #13 and the v1.3.0 review found the current home-page + notification approach bypassable.
- Use `Xrm.Navigation.navigateTo()` from web resources when you need supported in-app navigation. Use it for moving to docs, custom pages, records, or other app surfaces; do not rely on raw URL hacks when a supported navigation call exists.
- Query-string config is possible from sitemap `Url` bindings, but this app's current subareas use `PassParams="false"`, so no implicit sitemap parameters arrive today.

### Web Resources

- Use descriptive `dodbl_` names that tell you both ownership and purpose: `dodbl_dodbanner`, `dodbl_dodconsentbanner`, `dodbl_bannercore`, `dodbl_webtemplatesource`, `dodbl_banner-launch-page`.
- HTML/JS/CSS web resources are still just client assets. They are good for presentation and supported client APIs, not for pretending to be an access-control boundary.
- Follow the zero-dependency rule here too: no CDN, no jQuery, no helper libs for trivial DOM/cookie work.
- Cookie parsing gotcha: **split before decode, not decode before split.** Issue #3 exists because `decodeURIComponent(document.cookie)` can throw `URIError` if any unrelated cookie on the host contains malformed percent-encoding. The old root `dod-consent-banner.html` still shows the risky decode-then-split pattern.
- Cookie hardening gotcha: use `Secure` and an explicit `SameSite` mode. Trusted tenant does not remove browser risks; issue #5 tracks the missing `Secure` flag, and `SameSite` reduces ambient cross-site send behavior.
- Cookie naming gotcha: generic names collide. Issue #4 documents why `Accepted` is too broad and why a solution-owned name like `dodbl_Accepted` is safer.
- Static HTML classification banner rules are CSS-driven and case-sensitive for `data-classification`. `banner-core.css` uses prefix selectors like `data-classification^="CU"` and `^="S"`, so `cui` is not the same as `CUI`. The JS/environment-variable path is case-insensitive.
- Good cross-surface pattern: hardcoded safe default text + AO-approved override. This repo already exposes the override as `dodbl_DoDConsentText` and as a PCF `consentText` input. Treat any surface that ships only a hardcoded string and skips the override as drift.
- The `dodbl_banner-launch-page` feature commit originally hardcoded the full consent text in the web resource while other surfaces already had override plumbing. That is the bug class to avoid: one surface honoring AO text, another silently freezing it.
- Configuration can come from:
  - query-string parameters passed to a web resource URL
  - Dataverse environment variable lookup from supported client APIs
  - for Power Pages specifically, site settings on the portal side

### Power Pages

- Power Pages web templates are not plain HTML web resources. Liquid runs server-side and can read portal context, include snippets, and branch on site settings before markup reaches the browser.
- Use Liquid when the page must integrate with portal data/settings or be installed as a real portal Web Template. In this repo, `dodbl_webtemplatesource` exists specifically so admins can copy the Liquid template into Portal Management.
- If you only need static markup for MDA/Canvas, a normal web resource is enough. If you need Power Pages layout integration, portal context, or site-setting-driven behavior, use Liquid.
- Site settings are the Power Pages equivalent of Dataverse environment values for portal runtime behavior. `dodbl_webtemplatesource.data.xml` already documents optional `BannerEnabled` and `DoDConsentText` site settings.
- Do not try to package environment-specific website-bound records as if they were portable defaults. Website/web file records often carry environment-specific foreign keys and are better handled as post-import portal setup.

### GCC High / IL4-IL5 / DoD Compliance Patterns

- No external CDN or third-party script references. This repo's README, team history, and decisions are consistent on this: self-contained assets only. It matters for ATO scope, dependency review, and tenant CSP behavior.
- AC-8 is about **system use notification**, but a dismissible banner is not the same thing as an **enforced access-control gate**. The v1.3.0 MDA home-page review and issue #13 are the concrete reminder.
- Static HTML classification marking in this repo is data-driven via `data-classification` and optional `data-banner-content`. Those CSS-matched values are case-sensitive, prefix-matched, and mapped to fixed colors in `banner-core.css`; the JS/environment-variable path is case-insensitive.
- AO-approved text overrides must be applied consistently across every delivery surface: web resource, PCF, and Power Pages. The safe pattern is "built-in default exists, but tenant-approved override wins everywhere."
- Compliance drift often comes from surface skew, not bad intent: one channel reads `dodbl_DoDConsentText`, another embeds a literal string, a third uses a stale cookie name. Check every surface before calling the work done.

### Common Gotchas Checklist

- Cookie uses `Secure` and explicit `SameSite`
- Cookie parsing is split-before-decode; malformed unrelated cookies cannot kill the banner
- Cookie name is solution-owned, not generic
- AO-approved text override is wired on **every** surface, not just one
- No CDN or external script/style references were introduced
- `Solution.xml` version is bumped for anything intended to ship
- Environment variable definitions include schema, type, default, and description
- Canvas App PCF changes were republished after `pac pcf push`
- Sitemap/navigation changes are described as UX only unless there is a real enforcement mechanism behind them

## Anti-Patterns

- **Sitemap gate as enforcement** — ordering Home first does not block deep links, search, recents, or pinned items.
- **Treating generated export artifacts as source** — never hand-edit `Controls\`, `dvtablesearchs\`, or standard relationship exports.
- **Generic or insecure cookies** — `Accepted`, no `Secure`, missing `SameSite`, or decode-then-split parsing.
- **Surface-by-surface config drift** — AO text/env-var behavior must match across MDA, PCF, and Power Pages.
- **Client-side notification sold as access control** — `addGlobalNotification` informs; it does not enforce.
