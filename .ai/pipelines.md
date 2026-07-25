# DoD Banner Library — Pipelines & Deployment

> Build and deployment standards for this solution.

---

## Environment

| Setting | Value |
|---|---|
| Org | Dev (UsGovHigh) |
| URL | `orga1b9bfb3.crm.microsoftdynamics.us` (GCC High) |
| Publisher | `dodbl_` (prefix), `DoD Banner Library` (display name) |
| PAC CLI version | 2.6.4 (.NET Framework 4.8) |
| Node.js | 22.12.0 |
| npm | 10.9.0 |

---

## PCF Build

```powershell
cd pcf/DodBannerControl
npm run build          # webpack 5 bundle to out/controls/DodBannerControl/
```

Output: `out/controls/DodBannerControl/bundle.js` (~12.6 KiB gzipped)

To test locally (note: test harness has known exit code 1 on startup; use hard-reload):
```powershell
npm start
```

**Do not use `npm start` output as evidence of Canvas App behavior.** The test harness has quirks (TwoOptions resets to null on reload, container sizing differs from Canvas App runtime).

---

## PCF Push to Environment

Pushes the PCF bundle directly to the environment's custom controls without full solution pack/import cycle:

```powershell
cd pcf/DodBannerControl
pac pcf push --publisher-prefix dodbl
```

Requires an active PAC CLI auth profile (`pac auth list`). The control is deployed under `DoDBannerLibrary.DodBannerControl`.

---

## Solution Pack

Pack the solution from source into a zip file for import or distribution:

```powershell
pac solution pack --zipfile DoDBannerLibrary.zip --folder DoDBannerLibrary --packagetype Both
```

- `--packagetype Both` generates managed and unmanaged zips
- Output: `DoDBannerLibrary_managed.zip`, `DoDBannerLibrary_unmanaged.zip` (both gitignored)

---

## Solution Import

```powershell
pac solution import --path DoDBannerLibrary_managed.zip --force-overwrite --publish-changes
```

- Use `--force-overwrite` to overwrite existing managed solution
- `--publish-changes` triggers auto-publish of web resources

---

## Solution Export (round-trip / source sync)

When pulling environment changes back to source:

```powershell
pac solution export --name DoDBannerLibrary --path . --managed false
pac solution unpack --zipfile DoDBannerLibrary.zip --folder DoDBannerLibrary --packagetype Unmanaged
```

Then review and commit changes. Auto-generated folders (`Controls/`, `dvtablesearchs/`, `Other/Relationships*`) are gitignored.

---

## Release Process

1. Bump version in `DoDBannerLibrary/Other/Solution.xml` (`<Version>X.X.X.X</Version>`)
2. For any PCF code change, bump `pcf/DodBannerControl/DodBannerControl/ControlManifest.Input.xml` version — Canvas apps cache PCF by control version.
3. Update `dodbl_release-notes` web resource
4. Update `dodbl_docs` web resource if setup steps changed
5. Build PCF: `npm run build`
6. Pack: `pac solution pack --zipfile DoDBannerLibrary.zip --folder DoDBannerLibrary --packagetype Both`
7. Import managed to the Dev environment for validation: `pac solution import ...`
8. Commit all source changes
9. Before tagging, reconcile `.ai/` living docs (`context`, `domain`, `data-model`, `security`, `pipelines`) and `.ai/adr/` ADR links to shipped state; confirm `.squad/decisions.md` links to `.ai/` instead of restating product decisions. Co-review `.ai/security.md` / disclosure hygiene with Zoe.
10. Tag: `git tag vX.X.X && git push origin vX.X.X`
11. Create GitHub Release with managed zip attached: `gh release create vX.Y.Z DoDBannerLibrary_managed.zip --title vX.Y.Z --notes-file <notes.md>` (done for v1.3.0)

---

## Gitignore Rules

Files excluded from source control:

| Pattern | Reason |
|---|---|
| `*_managed.zip`, `*_unmanaged.zip`, `DoDBannerLibrary.zip` | Build outputs |
| `pcf/*/node_modules/` | NPM packages |
| `pcf/*/out/` | PCF webpack output |
| `pcf/*/.pcfenv/`, `pcf/*/bin/`, `pcf/*/obj/` | PCF build artifacts |
| `DoDBannerLibrary/Controls/` | Auto-generated PCF bundle in solution export |
| `DoDBannerLibrary/dvtablesearchs/` | Auto-generated search config |
| `DoDBannerLibrary/Other/Relationships.xml`, `Other/Relationships/` | Auto-generated relationships |
| `.ai_local/` | Local AI scratch files |
