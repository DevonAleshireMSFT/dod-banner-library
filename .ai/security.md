# DoD Banner Library — Security

> Security posture, access patterns, and known limitations for AI grounding.

---

## Compliance Language Guardrail

The solution is intended for GCC High / DoD IL4/IL5 Power Platform environments. Do not describe the project as certified, accredited, authorized, FedRAMP/NIST/CMMC/AC-8 compliant, or otherwise standards-compliant without independent evidence.

It is acceptable to describe implemented controls factually, such as cookie attributes, CSP-safe rendering choices, and client-side-only data handling.

---

## Security Roles

No custom security roles are deployed in v1.3.0.

Planned v1.4 work:

| Role | Purpose | Minimum Privileges |
|---|---|---|
| `DoD Banner — Consent Write` | Allows consent acknowledgment records to be created | Create on planned `dodbl_consent_record` table |

---

## Access Patterns

**MDA home page (`dodbl_banner-launch-page`):**
- Implements a system-use-notification consent pattern intended to support AC-8-style requirements; it is not evidence of AC-8 compliance.
- Reads `dodbl_DoDConsentText` and banner env vars through `parent.Xrm.WebApi` when available.
- Stores acknowledgment in `dodbl_Accepted=Yes` with `Secure; SameSite=Strict`.
- `getCookie` splits cookie pairs before decoding and catches malformed values to avoid `URIError` failures.
- Renders the classification bar with inline styles; GCC High CSP can block nonce-less `<style>` injection.

**MDA form script (`dodbl_dodbanner`):**
- Runs in the form context of the logged-in user.
- Reads banner/consent environment variables through `Xrm.WebApi`.
- Uses `Xrm.App.addGlobalNotification` for optional shell-level consent notification.
- Does not write to Dataverse in v1.3.0.
- Uses `dodbl_Accepted=Yes` with `Secure; SameSite=Strict`; cookie parsing is split-before-decode with a `URIError` guard.
- Uses `window.top.document` only for classification-bar DOM placement, a known supportability risk with no supported UCI classification-bar API alternative.

**PCF (`DodBannerControl`):**
- Runs inside Canvas App, Custom Page, or MDA PCF host context.
- Reads only bound/input PCF properties; it does not call Dataverse APIs.
- Uses `dodbl_Accepted=Yes` with `Secure; SameSite=Strict`; cookie parsing is split-before-decode with a `URIError` guard.
- Known limitation: Canvas PCF runs in a sandboxed iframe, so the consent cookie does not persist across browser sessions in Canvas. The MDA path persists. Canvas persistence is tracked in issue #21.

**Power Pages:**
- Banner assets are served as static web files. No authenticated API calls are made by this library.
- Current checked-in Power Pages consent HTML still uses the legacy `Accepted=Yes` cookie path; do not use it as evidence for v1.3.0 cookie-hardening behavior until that path is updated.

---

## Code Security Rules

- **No credentials in source.** Never embed connection strings, API keys, tenant URLs, publisher GUIDs, environment IDs, or other tenant-specific configuration in source.
- **No external requests.** Keep JS and CSS self-contained. Do not add CDN calls, external fonts, or third-party scripts.
- **No `eval()` or dynamic script injection.** PCF production builds disable eval-based source maps.
- **No PII in cookies.** Consent cookies store only `Yes`.
- **No production logging of user data.** Do not log user-identifiable information.
- **No compliance overclaims.** Describe what the product implements; do not claim standards compliance, authorization, or accreditation.

---

## OWASP Notes

| Risk | Mitigation |
|---|---|
| XSS — consent text injection | Consent text is rendered with `textContent`, not `innerHTML`. |
| XSS — cookie value | Consent value is static `Yes`; malformed cookie values are caught during parsing in hardened paths. |
| CSRF | v1.3.0 client code performs no Dataverse writes. |
| Sensitive data exposure | No secrets or PII are stored in consent cookies. |

---

## Known Limitations

| Limitation | Impact | Tracking |
|---|---|---|
| Canvas PCF cookie persistence | Consent works for the active Canvas session but does not persist cross-session because the PCF runs in a sandboxed iframe. | #21 |
| Power Pages legacy cookie helper | Current static HTML path still uses `Accepted=Yes` without the v1.3.0 hardened cookie attributes. | Needs follow-up before claiming parity |
| `window.top.document` for MDA classification bar | Microsoft flags `window.top` access as a supportability anti-pattern; used only because no supported UCI API renders a persistent classification bar. | Decision 006 |
