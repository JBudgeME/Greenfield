---
name: sop-rollback
description: Binding SOP override route — confirmed production regression after a merge (reproducible user-reported regression, error-rate spike with corroborating reports, or a data-integrity issue). Preempts ALL in-flight work. Default decision is revert; 30-minute triage timebox, inconclusive triage defaults to revert.
---

Binding gate sequence for the Post-deploy-rollback override. **First read `.claude/skills/sop-shared/GATES.md`** — canonical pass criteria and escape hatches.

Triggers on confirmed production regression after a merge. "Confirmed" means: a reproducible user-reported regression, OR an error-rate spike with corroborating reports, OR a data-integrity issue. Overrides any in-flight work.

**Gate 1 — Triaged.** Confirm the regression is real (one repro is enough), identify the suspect commit(s), and estimate blast radius (users affected; reversibility; data implications). **Timebox: 30 minutes.** If triage is inconclusive at the 30-minute mark, default to revert; diagnose the revert's correctness separately.

**Gate 2 — Decided.** Default decision: **revert**. Choose forward-fix only if (a) estimated time-to-fix-forward is under 30 minutes AND (b) blast radius is bounded AND (c) reverting would itself cause data loss or correctness issues. Record the decision and its rationale in the PR description.

**Gate 3 — Applied.** Open `revert/<sha>-<slug>` (revert) or `hotfix/<slug>` (forward-fix). Standard PR format. CI must be green before merge.

**Gate 4 — Verified.** After deploy, confirm production is restored. For data integrity issues, verify the affected dataset is consistent before declaring restored.

**Gate 5 — Retrospective.** File a postmortem at `.scratch/sop-fast-path-misses/<date>-<slug>.md` (reusing the existing retrospective directory). Cover: what shipped, what failed in pre-merge review, what monitoring missed, what (if any) SOP change is warranted. If the retrospective implicates a missing gate or weak pass criterion, route a kit change through `sop-maintenance`.
