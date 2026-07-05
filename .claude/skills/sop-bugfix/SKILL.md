---
name: sop-bugfix
description: Binding SOP route for bug fixes — a reported defect, regression, or unexpected behavior. Invoke BEFORE attempting any fix. A deterministic (or documented-statistical) repro loop is mandatory before touching code; 60-minute timebox, then escalate.
---

Binding gate sequence for the Bug fix route. **First read `.claude/skills/sop-shared/GATES.md`** — canonical pass criteria, tier depth, invariant capture, escape hatches. Cross-references to feature-route gates resolve in `.claude/skills/sop-feature/SKILL.md`.

**Gate 1 — Loop-Built.** Invoke `/diagnosing-bugs` and execute Phase 1 until a fast, deterministic, agent-runnable pass/fail signal exists. **Timebox: 60 wall-clock minutes.** If a deterministic <30s loop is impossible (race condition, flake, third-party timing), document the constraint and switch to a **statistical repro** (N runs, observed X% failure rate). If even a statistical repro cannot be established within the timebox, escalate to the user — do not proceed to Gate 2. Pass: **Loop-Built** (GATES.md).

**Gate 2 — Reproduced.** Run the loop. Confirm it produces the user's reported symptom, not a nearby one.

**Gate 3 — Hypothesised.** Generate three to five ranked, falsifiable hypotheses with predictions. Show the ranked list before testing. **T1 carve-out:** if the root cause is unambiguously visible from the repro itself (typo, off-by-one, obvious missing case, single-line logic error), a one-line documented hypothesis suffices in place of the ranked list. T2/T3 bugs always require the full ladder — even when the cause looks obvious.

**Gate 4 — Instrumented.** One probe per prediction. Change one variable at a time. Tag debug logs `[DEBUG-<short-id>]` for later grep-and-strip.

**Gate 5 — Fixed-with-regression-test.** Write the regression test **before** the fix if a correct seam exists; otherwise document the missing seam as a finding for a refactor follow-up (`sop-refactor`). Apply fix. Re-run the loop. Pass: **Tests-Green** (GATES.md). **Apply the invariant-capture rule** if the regression test asserts a new behavioral contract that other modules rely on (or could come to rely on).

**Gate 6 — Cleaned-up.** Remove all `[DEBUG-…]` instrumentation. Delete throwaway prototypes. Write the winning hypothesis into the commit message.

**Gate 7 — Reviewed and Merged.** Invoke `requesting-code-review`. After approval (**Review-Approved**, GATES.md), open PR and merge. On merge: close the bug's GH issue per sop-feature Gate 5 (with R1 cascade if relevant). Post-mortem ("what architectural change would have prevented this?") lives in the PR description. If the post-mortem is non-trivial (suggests real follow-up work), also create an arch-followup GH issue per sop-feature Gate 6 conventions and route through `sop-refactor`. **T3 only:** include a Rollback Verification line in the PR confirming the revert path was sanity-checked.
