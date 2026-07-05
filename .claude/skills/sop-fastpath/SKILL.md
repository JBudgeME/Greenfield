---
name: sop-fastpath
description: Binding SOP route for T0 trivial changes only — ≤50 LOC, ≤3 closely-related files, no public API or business-logic change, no invariants-listed module, main CI green. Invoke BEFORE committing any trivial change. If main CI is red, fast-path is suspended — route through sop-restore-ci.
---

Binding gate sequence for the Trivial fast-path (T0). **First read `.claude/skills/sop-shared/GATES.md`** for the shared rules; the T0 criteria live in the CLAUDE.md tier table and ALL must hold. The "main CI green" criterion is part of T0; if `main`'s most recent CI run is failing, fast-path is suspended — route through `sop-restore-ci` even for changes that otherwise qualify.

**Gate 1 — Self-classification line.** First line of the commit message: `SOP: fast-path — <one-clause justification>` (e.g. `SOP: fast-path — typo in error message in app/error.tsx, 1 LOC`).

**Gate 2 — Verified.** Run the project's lint command and test suite locally. Pass criterion: clean.

**Gate 3 — Commit directly to main.** No branch, no PR.

**T0 has no exception path.** If a change qualifying for T0 nonetheless needs to skip a step or document a deviation, it is by definition not T0 — re-classify (typically to T1 via `sop-feature` Gate 1) and route up.

If the change later proves not to have been trivial (it breaks something, requires a follow-up edit, or had a hidden API/logic implication), open a retroactive `.scratch/sop-fast-path-misses/<date>-<slug>.md` capturing the misclassification. The trigger is mechanical and the entry is filed by whoever lands the correction: a revert of a fast-path commit, or a follow-up that fixes a defect it introduced, owes the ledger entry in the same working session (feature continuations flagged at commit time do not fire it). Only T0 misclassifications belong in this ledger — CI-restore retrospectives live with `sop-restore-ci`'s own artifacts, not here. Pattern detection improves over time.
