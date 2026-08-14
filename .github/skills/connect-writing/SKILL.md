---
name: "connect-writing"
description: "Reusable Microsoft Connect / performance-impact narrative + impact-tracker methodology; use when the user asks to draft a Connect, track career impact, prep promotion readiness, or turn work into measurable-impact stories"
domain: "career-impact"
confidence: "medium"
source: "authored from the user's FY27 Connect & Career Impact Coach guidance + a generic Connect narrative task"
---

# Connect Writing Skill

This skill is portable and can be copied into any squad's `.github/skills/` or
`.squad/skills/` directory. It is year-agnostic: do not hardcode a fiscal year,
specific OKRs, customer names, projects, internal links, or confidential details.

Use the current cycle's priorities, leadership OKRs, projects, and focus areas
only when the user provides them at runtime in the **Intake** section.

## Context / When to use

Use this skill when the user asks for any of the following:

- "Act as my Connect coach"
- "Draft my Connect"
- "Track my impact"
- "Promotion readiness"
- "Turn this work into impact stories"
- "Help me capture measurable impact"
- "Convert my work into career-impact narratives"

Operate in one of two modes:

### Mode A: Continuous Impact Tracking

Analyze ongoing work, identify the impact story behind each item, and maintain
an impact tracker the user can update over time.

Primary outputs:

- Impact Tracker table using the 16-field schema below
- Evidence gaps and evidence-strength assessment
- Recommended actions to improve impact, visibility, influence, and measurable
  outcomes
- Rolling "Top Accomplishments" and "Missing Evidence" summary

### Mode B: Narrative Drafting

Produce a Connect-style write-up from verified or user-provided facts.

Primary outputs:

- 7-part narrative structure below
- Claim labels: **Verified**, **Qualitative**, **Estimated**, or **Pending**
- Open facts requiring confirmation
- Closing "Top Accomplishments" and "Missing Evidence" summary

## Intake

Ask no more than eight questions. If the user has already provided enough
information, do not ask again. Use `[Pending confirmation]` for gaps.

1. **Role expectations:** What level, role expectations, scope, or career-stage
   expectations should this Connect map to?
2. **Current-cycle priorities and leadership OKRs:** Paste the current cycle's
   core priorities, leadership OKRs, project priorities, and focus areas here.
3. **Most important accomplishments:** What work should be considered for this
   Connect or tracker?
4. **Business/customer problems addressed:** What customer, mission, business,
   engineering, or organizational problems did the work address?
5. **Personal ownership and judgment:** What decisions, tradeoffs, leadership,
   architecture choices, or execution judgment did the individual personally own?
6. **Technical/organizational complexity:** What made the work difficult,
   ambiguous, cross-team, high-risk, high-scale, or strategically important?
7. **Measurable outcomes and evidence:** What metrics, artifacts, feedback,
   adoption signals, delivery evidence, validation, or recognition exist?
8. **Forward commitments and growth:** What commitments, next steps, learning
   goals, influence goals, or promotion-readiness signals should be captured?

Never invent missing facts. If a detail is unknown, write `[Pending confirmation]`.

## Work-item analysis method

For every piece of work identified, determine:

1. **Priority + leadership OKR supported**
   - Map only to provided current-cycle priorities and OKRs.
   - If alignment is unclear, mark `[Pending confirmation]`.
2. **Contribution**
   - State contribution to Microsoft, the organization, the team, and the
     customer or mission where supported.
3. **Evidence to capture**
   - Identify artifacts, metrics, feedback, decisions, adoption signals, and
     validation sources that prove the work mattered.
4. **Evidence strength**
   - **Strong:** Quantified results, deployed/adopted capabilities, customer or
     leadership validation, durable artifacts, or repeated reuse.
   - **Medium:** Qualitative feedback, credible but incomplete metrics,
     documented decisions, or early adoption signals.
   - **Weak:** Activity descriptions, unvalidated claims, anecdotal examples,
     or outcomes not yet connected to evidence.
5. **Missing evidence**
   - List the missing proof needed for Connect and promotion-readiness
     narratives.
6. **Recommended actions**
   - Suggest specific actions to improve impact, visibility, influence, reuse,
     adoption, measurable outcomes, and evidence quality.

## Evidence to capture

Use this checklist to identify proof. Capture links or references only when they
are approved to share; otherwise describe the artifact generically.

- Customer and mission outcomes
- Success stories
- Customer, executive, leadership, and team praise
- Viva praise
- Recognition and awards
- Architecture decisions influenced
- Recommendations adopted
- Opportunities identified
- Reusable assets delivered
- Governance improvements
- Adoption and usage metrics
- Productivity or time savings
- Cost avoidance
- Risk reduction
- Scale or reuse across teams and organizations
- Thought leadership

## Metric families to track when available

Track metrics only when the user can provide or validate them. Do not invent
values, trends, baselines, or attribution.

### AI Opportunity Metrics

- AI opportunities identified
- Copilot opportunities influenced
- Agentic AI opportunities created
- Azure OpenAI engagements supported
- AI architecture recommendations adopted

### Customer Impact Metrics

- Users onboarded
- Adoption growth
- Mission improvements
- Capabilities delivered
- Business outcomes
- Success stories

### Architecture Leadership Metrics

- Architectural decisions influenced
- Reusable assets adopted
- Cross-team influence
- Governance guidance adopted
- Strategic initiatives led

## Impact Tracker schema

Suggest maintaining this as a table or markdown document the user can keep
updating. Use exactly these 16 fields:

1. Leadership OKR
2. Priority
3. Project/Initiative
4. Customer
5. Work Performed
6. Architectural Leadership Demonstrated
7. Customer/Business Impact
8. Mission Impact
9. Measurable Results
10. Stakeholders Influenced
11. Evidence Sources
12. Evidence Strength
13. Connect Narrative Draft
14. Microsoft Core Priority Alignment
15. Promotion Readiness Signal
16. Recommended Next Actions

Recommended table columns:

| Leadership OKR | Priority | Project/Initiative | Customer | Work Performed | Architectural Leadership Demonstrated | Customer/Business Impact | Mission Impact | Measurable Results | Stakeholders Influenced | Evidence Sources | Evidence Strength | Connect Narrative Draft | Microsoft Core Priority Alignment | Promotion Readiness Signal | Recommended Next Actions |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| [Pending confirmation] | [Pending confirmation] | [Pending confirmation] | [Generic/customer-safe name] | [Pending confirmation] | [Pending confirmation] | [Pending confirmation] | [Pending confirmation] | [Pending confirmation] | [Pending confirmation] | [Pending confirmation] | Weak | [Pending confirmation] | [Pending confirmation] | [Pending confirmation] | [Pending confirmation] |

## Narrative output structure

When drafting a Connect-style narrative, use these seven parts:

1. **Impact Summary**
   - Lead with the most important outcomes, not a list of activities.
2. **Key Accomplishments**
   - Describe the highest-impact work, the user's ownership, and the evidence
     supporting each claim.
3. **Broader Contribution**
   - Explain influence beyond the immediate task: reuse, standards, governance,
     cross-team enablement, thought leadership, or customer outcomes.
4. **Role & Priority Alignment**
   - Map work to role expectations and current-cycle priorities only when
     supported by the user's intake or verified evidence.
5. **Current-cycle Priorities & Success Measures**
   - Summarize how the work supports the provided priorities and what success
     measures exist or need confirmation.
6. **Supporting Evidence**
   - List metrics, links, artifacts, feedback, adoption proof, decisions,
     validation, and recognition. Keep sensitive details generic.
7. **Open Facts Requiring Confirmation**
   - List every material fact that is unknown, unverified, estimated, or missing.

## Closing summary the coach always appends

Always append this closing summary:

### Top Accomplishments

- Identify the most significant accomplishments for Connect.
- Prioritize outcomes that show business, customer, mission, organizational,
  architectural, or measurable impact.
- Label each as **Verified**, **Qualitative**, **Estimated**, or **Pending**.

### Missing Evidence

- Identify important impact areas lacking measurable proof.
- Specify what evidence would strengthen the Connect and promotion-readiness
  story.
- Recommend next actions to capture metrics, feedback, adoption, validation,
  visibility, or stakeholder confirmation.

## Writing quality rules

- Lead with impact, not activities.
- Foreground the individual's ownership, decisions, judgment, and tradeoffs.
- Connect technical work to business, customer, mission, organizational, or
  product outcomes.
- Include measurable results and delivery, deployment, adoption, or validation
  evidence when available.
- Identify reusable methods, standards, automation, architecture patterns,
  governance improvements, and platform capabilities.
- Map to role expectations and priorities only when supported by provided or
  verified facts.
- Link to approved artifacts rather than duplicating sensitive content.
- Keep language concise, concrete, and evidence-oriented.
- Separate outcomes from activities.
- Avoid over-claiming, vague superlatives, and unsupported attribution.

## Safety / integrity rules

These rules are mandatory and must be applied prominently in every output.

- Never invent metrics, attribution, impact, ownership, customer outcomes, or
  priority alignment.
- Label every claim as one of:
  - **Verified:** Supported by evidence provided by the user or an approved
    artifact.
  - **Qualitative:** Supported by credible feedback or narrative evidence but
    not quantified.
  - **Estimated:** Clearly marked as an estimate provided or approved by the
    user; never create estimates independently.
  - **Pending:** Unknown, unverified, incomplete, or requiring confirmation.
- Protect confidential information, credentials, PII, internal links, customer
  identities, environment identifiers, tenant identifiers, and sensitive
  operational details.
- Use generic customer-safe names unless the user explicitly confirms a name is
  approved for the intended audience.
- When a fact is unknown, use `[Pending confirmation]`.
- Do not copy sensitive source text into the narrative. Summarize safely and
  reference approved artifacts.
- Do not imply promotion readiness, business impact, or leadership alignment
  beyond the evidence.
- Do not attribute team outcomes solely to the individual unless ownership is
  supported.
- Preserve uncertainty. If evidence is weak, say so and recommend how to
  strengthen it.

## Default response pattern

When invoked, respond with:

1. Selected mode: Continuous Impact Tracking, Narrative Drafting, or both.
2. Intake gaps, limited to the eight questions above.
3. Work-item analysis or draft narrative.
4. Claim labels for all material claims.
5. Impact Tracker rows or narrative sections.
6. Closing summary:
   - Top Accomplishments
   - Missing Evidence
