# DoD Banner Library — Security

> Security roles, access patterns, and constraints for this solution.

---

## Classification

This solution runs in **GCC High (DoD IL4/IL5)**. Treat all tenant-specific configuration (org URL, publisher GUIDs, environment IDs) as sensitive. Do not commit them to source control.

---

## Security Roles _(PLANNED — v1.2)_

| Role | Purpose | Minimum Privileges |
|---|---|---|
| `DoD Banner — Consent Write` | Allows the system service principal to create `dodbl_consent_record` rows | Create on `dodbl_consent_record` |

No custom security roles are deployed in v1.0 or v1.1. Standard Dataverse user roles apply.

---

## Access Patterns

**MDA form script (`dodbl_dodbanner.js`):**
- Runs in the form context of the logged-in user.
- Reads environment variables via `Xrm.WebApi.retrieveMultipleRecords("environmentvariablevalue", ...)` — requires the user to have `Read` on `environmentvariabledefinition` and `environmentvariablevalue`. This is granted to all licensed users by default.
- Does not write any data to Dataverse.
- Sets a browser cookie (`Accepted=Yes`) client-side only.

**PCF (`DodBannerControl`):**
- Runs inside the Canvas App or MDA form context.
- Does not call Dataverse API. Reads only from its own bound/input PCF properties.
- Sets a browser cookie client-side only.

**Power Pages:**
- Banner assets served as static web files. No authenticated API calls.
- Cookie set client-side only.

---

## Code Security Rules

- **No credentials in source.** Never embed connection strings, API keys, org URLs, or GUIDs in web resource source files or PCF source. Use environment variables for runtime configuration.
- **No external requests.** GCC High blocks outbound calls to non-approved endpoints. All JS and CSS must be fully self-contained. CDN calls will silently fail or cause CORS errors.
- **No `eval()` or dynamic script injection.** All consent modal JS uses static DOM APIs.
- **No PII in cookies.** The `Accepted` cookie stores only `Yes`. Do not add user identity, email, or any PII to cookies.
- **No logging of user data.** `dodbl_dodbanner.js` and the PCF do not call `console.log` with user-identifiable information in production builds.
- **Managed solution distribution.** Deploying as managed prevents downstream customization of consent logic — which could be used to bypass the notification requirement.

---

## OWASP Notes

| Risk | Mitigation |
|---|---|
| XSS — consent text injection | `consentText` / `dodbl_DoDConsentText` value is set via `element.textContent`, not `innerHTML`. No HTML injection possible. |
| XSS — cookie value | Cookie value is a static string `Yes`. Cookie is read via string comparison only. |
| CSRF | No write operations from client-side code. |
| Sensitive data exposure | No secrets in source. No PII in cookies. |
