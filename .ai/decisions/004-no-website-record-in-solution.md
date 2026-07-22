# Decision: No Website Record in Solution (Power Pages Web Files Manual)

**Date:** 2026-07  
**Status:** Decided — permanent constraint

## Context

Power Pages `adx_webfile` records require a non-nullable foreign key to a `adx_website` record. Website records are environment-specific (each portal instance has its own website ID).

## Decision

The solution does not include any `adx_website` or `adx_webfile` records. CSS and JS are delivered as Dataverse web resources (`dodbl_bannercore`, `dodbl_dodconsentbanner`, etc.). Deployers create web files manually in the Portal Management app and copy content from the web resources.

## Reasons

- A website FK cannot be satisfied in a cross-environment managed solution.
- Attempting to include web files in a solution without a matching website record causes import errors or silent failures.

## Consequences

- Deployment guide (in `dodbl_docs`) must clearly document the manual web file creation step.
- The `dodbl_webtemplatesource` web resource provides the Liquid Web Template content as a reference — deployers copy this into a new Web Template record post-import.
- This is a permanent constraint for any Power Pages component added to this solution.
