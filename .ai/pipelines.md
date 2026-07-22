# DoD Banner Library — Pipelines & Deployment

> Build and deployment standards for this solution.

---

## Environment

| Setting | Value |
|---|---|
| Org | GFIM-DEV |
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
2. Update `dodbl_release-notes` web resource
3. Update `dodbl_docs` web resource if setup steps changed
4. Build PCF: `npm run build`
5. Pack: `pac solution pack --zipfile DoDBannerLibrary.zip --folder DoDBannerLibrary --packagetype Both`
6. Import managed to GFIM-DEV for validation: `pac solution import ...`
7. Commit all source changes
8. Tag: `git tag vX.X.X && git push origin vX.X.X`
9. Create GitHub release with managed zip attached

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
