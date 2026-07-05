---
name: sop-maintenance
description: Binding SOP route for editing the SOP kit itself — the CLAUDE.md router, any sop-* skill, sop-shared/GATES.md, or the SOP hooks. Invoke BEFORE any such edit. Substantive changes (new gates/routes, changed pass criteria) require grilling first; the kit enforces itself.
---

Binding procedure for changes to the SOP kit (the CLAUDE.md router section, `sop-*` skills, `sop-shared/GATES.md`, and SOP-related hooks under `.claude/hooks/`). **First read `.claude/skills/sop-shared/GATES.md`.**

Changes follow one of two paths depending on scope:

**Clarification-class edit.** A single section, no new gates, no new pass criteria, no new routes. Examples: tightening a definition; adding an example; fixing a cross-reference. Path: change note at `.scratch/sop-changes/<date>-<slug>.md` → branch → edit → `requesting-code-review` → merge. No grilling required.

**Substantive edit.** New gates, new routes, restructure of routing, or changes to pass criteria. Path: run a `/grilling` session using `/domain-modeling` → change note (one page, not a PRD) → branch → edit → `requesting-code-review` → merge.

The kit enforces itself. If anyone — agent or human — proposes a substantive change without the substantive path, that proposal is denied and re-routed.

## Metrics (evidence base)

Reviewed on demand — and always as the evidence base for any substantive edit. No fixed calendar cadence. Track lightweight counters:

- `.scratch/sop-fast-path-misses/*.md` — count over time. Spike = fast-path criteria are wrong.
- SOP exceptions filed (`gh issue list --search "SOP exception in:body" --state all --json number,title,labels`). Spike per route = that route's gates are misaligned with real work.
- Rough time-to-merge per route (from branch creation to merge timestamp; `git log` is enough). Median per route, reviewed quarterly.
- Post-merge defect count (bugs filed within 14 days of a feature merge, attributable to that feature). Spike per route = that route's review depth is insufficient.

**Where the result lives:** `.scratch/metrics/<YYYY-MM-DD>.md`. Each entry records: counters for the period, comparison to the previous period, and any kit edits the data suggests.

**Tooling:** manual grep + manual count is acceptable. A `scripts/sop-metrics.ts` helper is a candidate follow-up. Out of scope: real-time dashboard, automated emission, alerting.
