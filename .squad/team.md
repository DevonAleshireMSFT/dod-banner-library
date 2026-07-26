# Squad Team

> dod-banner-library

## Coordinator

| Name | Role | Notes |
|------|------|-------|
| Squad | Coordinator | Routes work, enforces handoffs and reviewer gates. |

## Members

| Name | Role | Charter | Status |
|------|------|---------|--------|
| Serenity | Coordinator | (squad.agent.md) | 🎛️ Orchestrator |
| Mal | Lead | .squad/agents/mal/charter.md | 🏗️ Active |
| Zoe | Security/Compliance | .squad/agents/zoe/charter.md | 🔒 Active |
| Kaylee | PCF/Frontend Dev | .squad/agents/kaylee/charter.md | ⚛️ Active |
| Wash | Tester/QA | .squad/agents/wash/charter.md | 🧪 Active |
| Scribe | Session Logger | .squad/agents/scribe/charter.md | 📋 Background |
| Ralph | Work Monitor | .squad/agents/ralph/charter.md | 🔄 Background |
| Rai | RAI Reviewer | .squad/agents/Rai/charter.md | 🛡️ RAI |
| Fact Checker | Fact Checker | .squad/agents/fact-checker/charter.md | 🔍 Verifier |

## Coding Agent

<!-- copilot-auto-assign: false -->

| Name | Role | Charter | Status |
|------|------|---------|--------|
| @copilot | Coding Agent | — | 🤖 Coding Agent |

### Capabilities

**🟢 Good fit — auto-route when enabled:**
- Bug fixes with clear reproduction steps
- Test coverage (adding missing tests, fixing flaky tests)
- Lint/format fixes and code style cleanup
- Dependency updates and version bumps
- Small isolated features with clear specs
- Boilerplate/scaffolding generation
- Documentation fixes and README updates

**🟡 Needs review — route to @copilot but flag for squad member PR review:**
- Medium features with clear specs and acceptance criteria
- Refactoring with existing test coverage
- API endpoint additions following established patterns
- Migration scripts with well-defined schemas

**🔴 Not suitable — route to squad member instead:**
- Architecture decisions and system design
- Multi-system integration requiring coordination
- Ambiguous requirements needing clarification
- Security-critical changes (auth, encryption, access control)
- Performance-critical paths requiring benchmarking
- Changes requiring cross-team discussion

## Project Context

- **Project:** dod-banner-library
- **Created:** 2026-07-24
- **Owner:** Devon Aleshire
- **Description:** Managed Power Platform solution providing reusable, GCC High–safe consent and classification banner assets for Power Pages, Canvas Apps, and Model-Driven Apps in DoD environments (IL4/IL5). Zero external dependencies, no CDN calls, no jQuery.
- **Universe:** Firefly

## Domain Grounding (.ai/)

Agents read the AI Context Framework in `.ai/` for durable domain knowledge; the coordinator injects the ONE relevant file per spawn, and agents must **NOT** bulk-load the whole `.ai/` tree (performance).

| Role / agent | Primary `.ai/` file(s) |
|---|---|
| Lead (Mal) | `.ai/context.md` (Current State, Key Rules) + relevant `.ai/adr/` |
| PCF/Frontend (Kaylee) | `.ai/context.md` (PCF Control, Known Gotchas) + `.ai/adr/0003-pcf-field-template.md`, `.ai/adr/0007-pcf-production-build.md`, `.ai/adr/0008-canvas-pcf-bundle-baking.md` |
| Security/Compliance (Zoe) | `.ai/security.md` + `.ai/context.md` Key Rules |
| Tester/QA (Wash) | `.ai/context.md` (Architecture Summary, Known Gotchas) + `.ai/pipelines.md` |
| Any deployment work | `.ai/pipelines.md` |

Durable product decisions belong in `.ai/adr/` ADRs and living docs; team direction, routing, and session outcomes belong in `.squad/decisions.md`. `.squad` links to `.ai/` product truth and must not restate it.

### Public-repository hygiene (working agreement)

This repository is public. Agents must keep internal-only or confidential material out of committed or public artifacts (issues, PRs, commit messages, docs, and comments), and generalize internal requirements into public-safe wording that still conveys the requirement. Internal-only briefs and decks stay in internal systems; see `.ai/security.md` ("Public-repository disclosure hygiene") for the authoritative guardrail.
