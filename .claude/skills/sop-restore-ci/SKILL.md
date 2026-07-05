---
name: sop-restore-ci
description: Binding SOP override route — fires the moment main's most recent CI run is observed red. Preempts ALL in-flight work; stash WIP and invoke this immediately. Fast-path commits are suspended until main is green. Fix goes on a fix/restore-ci-<slug> branch with its own PR CI — never direct to main.
---

Binding gate sequence for the Restore-main-CI override. **First read `.claude/skills/sop-shared/GATES.md`** — canonical pass criteria and escape hatches.

Triggers the moment `main`'s most recent CI run is observed red. Overrides any in-flight work. The agent stashes WIP. `sop-fastpath` is suspended for the duration; all commits route through this procedure until `main` returns to green.

**Concurrency.** First agent to declare this route owns restoration. Any other agent observing red main stashes WIP and stands down until announce/recovery. If two agents announce within the same minute, the first to declare in writing (committed message or PR description) owns restoration; the other(s) defer.

**Gate 1 — Announced.** Declare the route in the opening message of the session: "main CI is red; routing through sop-restore-ci." Stash or commit any work-in-progress on its own branch.

**Gate 2 — Diagnosed.** Invoke `/diagnosing-bugs` Phase 1 to build a deterministic local pass/fail signal for the failing CI check. **Max 3 attempts to reproduce locally.** Sources to consult: `gh run view <run-id> --log-failed` for the trace, `gh run list --branch main` for the flip commit. If 3 attempts fail to reproduce, escalate to the user — the failure may be environmental, transient, or runner-specific and a code-level root cause may not exist.

**Gate 3 — Fixed.** Apply the fix on a `fix/restore-ci-<slug>` branch. **Not direct-to-main**, even if the change qualifies for fast-path — red-main restoration requires the PR's own CI to confirm green before merging.

**Gate 4 — Merged.** Open PR (standard format). Invoke `requesting-code-review`. Merge after the PR's CI is green and **Review-Approved** (GATES.md) holds (no high-confidence findings open).

**Gate 5 — Retrospective.** File `.scratch/sop-fast-path-misses/<date>-<short-slug>.md` covering: what broke, when it went red, how it escaped earlier slices' CI, the restoration commit. Filed in the same PR as the fix, so the merge atomically lands the restoration and its record.

After Gate 5 lands, normal routing resumes.
