---
name: sop-refactor
description: Binding SOP route for refactors — structural improvement without changing observable behavior. Invoke BEFORE any refactoring work. Full test suite runs before the first edit and after every step; T2/T3 require explicit user selection of the candidate.
---

Binding gate sequence for the Refactor route. **First read `.claude/skills/sop-shared/GATES.md`** — canonical pass criteria, tier depth, invariant capture, escape hatches. Cross-references to feature-route gates resolve in `.claude/skills/sop-feature/SKILL.md`.

**Gate 1 — Surveyed.** Invoke `/improve-codebase-architecture` against the area in question. The skill applies the deletion test and produces a numbered candidate list. If the user names the target directly, record it as the sole survey candidate — the fan-out is skipped, not the checks: apply the deletion test to the named candidate and check it against `docs/adr/` before Gate 2, surfacing any conflict per GATES.md precedence rather than proceeding past it. T2/T3 still require the user to confirm selection at Gate 2 after those checks.

**Gate 2 — Selected.** User picks the candidate(s) to act on. **T1 carve-out:** if the surveyed candidate is unambiguous (only one obvious deepening, no ADR conflict, no public-API change, no invariants-listed module touched), the agent may self-select and announce the choice at the opening of Gate 3 rather than waiting on user input. T2/T3 always require explicit user selection. Skip any candidate that contradicts an existing ADR unless the friction warrants revisiting the ADR (see GATES.md, Domain-doc lifecycle).

**Gate 3 — Designed.** Run a `/grilling` session using the `/domain-modeling` skill against the chosen candidate, using the `codebase-design` vocabulary (module, interface, seam, depth, deletion test) for the design discussion. Walk the design tree: constraints, interface shape, what sits behind the seam, what tests survive the refactor. Add new domain terms to `CONTEXT.md` inline. Write an ADR under `docs/adr/` if and only if `/domain-modeling`'s three ADR criteria are all met. **Apply the invariant-capture rule** if the refactor introduces a new seam whose contract becomes load-bearing for callers.

**Gate 4 — Implemented.** `git checkout -b refactor/<slug>`. Run the full test suite **before** the first edit; capture the baseline. Refactor in small, reversible steps. Run the suite after every step. Pass criterion: suite stays green throughout; no test is modified except to update mechanically-changed references. If the deepened interface exposes a behavior that wasn't testable before, add tests via `/tdd` at the new seam (this is a step inside Gate 4, not a separate gate).

**Gate 5 — Reviewed.** `requesting-code-review`. Pass: **Review-Approved** (GATES.md).

**Gate 6 — Merged.** Open PR; merge after CI green. On merge: close the refactor's GH issue per sop-feature Gate 5 (with R1 cascade if relevant). If the refactor lands an arch-followup candidate, also close that candidate's GH issue with the `merged` label in the same operation.
