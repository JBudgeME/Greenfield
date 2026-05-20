# Standard Operating Procedure

This document defines **how work happens** in this repository. It is binding on every agent and every human contributor. It sits alongside `CLAUDE.md` and `AGENTS.md`, which define **principles** (KISS, DRY, fail-fast, surgical changes, etc.). This document defines the **process** that enforces those principles.

If an instruction in `CLAUDE.md` or `AGENTS.md` conflicts with this SOP, the user's instructions win — but the agent **must surface the conflict** before acting. Silent deviation is a process failure.

The SOP is designed for a single goal: a **rock-solid product** built through disciplined alignment, testing, and review. Speed is a non-goal where it trades against rigor.

---

## 1. Routing — pick the right procedure first

The first thing an agent does in any new conversation is **classify the work**. State the chosen route in the opening response. Misclassifying is itself a gate failure.

| Work type               | Trigger                                                                        | Procedure | Skills (in order)                                                                                               |
| ----------------------- | ------------------------------------------------------------------------------ | --------- | --------------------------------------------------------------------------------------------------------------- |
| Substantive feature     | New behavior; multi-file; touches business logic, data flow, or any public API | §2.1      | `grill-with-docs` → `to-prd` → `to-issues` → `tdd` → `requesting-code-review` → `improve-codebase-architecture` |
| Bug fix                 | Any reported defect, regression, or unexpected behavior                        | §2.2      | `diagnose` (all 6 phases) → `tdd` (regression test) → `requesting-code-review`                                  |
| Refactor / architecture | Improving structure without changing observable behavior                       | §2.3      | `improve-codebase-architecture` → `grill-with-docs` → `tdd` (behavior preservation) → `requesting-code-review`  |
| Chore                   | Dependencies, tooling, config, non-trivial docs                                | §2.4      | Read-before-write → `requesting-code-review`                                                                    |
| Trivial fast-path       | ≤30 LOC, single-file, no public API change, no business-logic change           | §2.5      | Direct commit with SOP-exception line                                                                           |

**Fast-path criteria are conjunctive.** All four must be true. If any single criterion fails, the work is not trivial and takes a full route. Edge cases (e.g. a 5-line change that adds a new exported function — that _is_ a public API change → §2.1, not §2.5).

---

## 2. Procedures

Each procedure is a sequence of numbered **gates**. A gate has a defined pass criterion (see §3). No gate may be skipped without a written exception (see §6).

### 2.1 — Substantive feature

**Gate 1 — Alignment (Grilling-Complete).** Invoke `/grill-with-docs`. Interview until the agent can answer, in writing:

- Which domain terms apply, and are they in `CONTEXT.md`? Add any new ones inline during the grilling.
- Which modules will change? Are any candidates for deep-module refactor?
- What are the success criteria, expressed as observable behavior?
- What is explicitly out of scope?

**Visual-treatment sub-rule.** Whenever the grilling surfaces a question whose answer depends on _how something looks_ rather than _how it behaves_ — "which card style?", "compact or beefy?", "where should this sit on the page?", any choice between two or more concrete aesthetics — the agent **must** invoke `frontend-design:frontend-design` or `/prototype` and build a runnable preview route. ASCII mockups, prose-rendered layouts, and `AskUserQuestion` `preview` blocks are forbidden for visual choices. Carve-outs: trivial polish (≤30 LOC + no design ambiguity), pure behavioral questions, and reuses of an established in-codebase pattern with no design ambiguity. The grilling agent's judgment call: if the answer is "I'll know it when I see it," the rule fires. **When in doubt, build the prototype** — its cost is lower than the wrong-medium cost. The prototype lives at `app/dev/<topic>/page.tsx` in a worktree and is deleted in the feature's final slice (or as a follow-up cleanup commit if the slicing doesn't naturally cover it).

Pass criterion: the user explicitly says "approved" or "go." Never infer approval from silence.

**Gate 2 — Specification (PRD-Ready).** Invoke `/to-prd`. Synthesize the grilling output into a PRD using mattpocock's template. Write to `.scratch/<feature-slug>/PRD.md`. Pass criterion: PRD covers Problem, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope.

**Gate 3 — Breakdown (Issues-Ready).** Invoke `/to-issues`. Break the PRD into tracer-bullet vertical slices. Write each issue to `.scratch/<feature-slug>/issues/NN-<slug>.md`. Pass criterion: every issue is AFK-grabbable — has acceptance criteria, a "Blocked by" line, and uses domain vocabulary.

**Gate 4 — Branch.** `git checkout -b feat/<feature-slug>`. The branch name matches the feature slug exactly.

**Gate 5 — Implement (Tests-Green, per slice).** For each issue in dependency order, invoke `/tdd`. Strict red-green-refactor, vertical slices. **No horizontal slicing.** One test → one implementation → repeat. Pass criterion: full test suite green at the end of every slice. Never commit a red test suite to the feature branch.

**Gate 6 — Review (Review-Approved).** Invoke the superpowers `requesting-code-review` skill. Pass criterion: review returns no high-confidence issues. Medium-confidence issues are either addressed or explicitly deferred with a one-line note in the PR description.

**Gate 7 — Merge.** Open a PR with the standard format (Summary / Test plan). Merge to `main` only after Gate 6 passes.

**Gate 8 — Post-merge (Arch-Reviewed).** Invoke `/improve-codebase-architecture` against the modules touched by the feature. If candidates surface, file them at `.scratch/<feature-slug>/arch-followups.md`. Pass criterion: review completed and findings filed (an empty findings file is a valid pass).

### 2.2 — Bug fix

**Gate 1 — Reproduction loop (Loop-Built).** Invoke `/diagnose` and execute Phase 1 until a fast, deterministic, agent-runnable pass/fail signal exists for the reported bug. **This is the gate, not a step.** No further work proceeds without a loop.

**Gate 2 — Reproduce (Phase 2).** Run the loop. Confirm it produces the user's reported symptom, not a nearby one.

**Gate 3 — Hypothesise (Phase 3).** Generate three to five ranked, falsifiable hypotheses. Show the ranked list before testing. Pass criterion: each hypothesis includes its prediction.

**Gate 4 — Instrument (Phase 4).** One probe per prediction. Change one variable at a time. All debug logs tagged `[DEBUG-<short-id>]` for grep-and-strip later.

**Gate 5 — Fix + regression test (Phase 5).** Write the regression test before the fix **if a correct seam exists**. If no correct seam exists, document that as a finding and flag it for §2.3 follow-up. Apply fix. Re-run the Phase 1 loop. Pass criterion: original repro no longer reproduces.

**Gate 6 — Cleanup (Phase 6).** Remove all `[DEBUG-…]` instrumentation. Delete throwaway prototypes. Write the winning hypothesis into the commit message.

**Gate 7 — Review.** Invoke `requesting-code-review`. Same pass criterion as §2.1 Gate 6.

**Gate 8 — Merge.** PR + merge to main.

**Gate 9 — Post-mortem.** Answer in the PR description: what architectural change would have prevented this bug? If the answer is non-trivial, file `.scratch/<bug-slug>/arch-followups.md` and route the follow-up through §2.3.

### 2.3 — Refactor / architecture

**Gate 1 — Survey.** Invoke `/improve-codebase-architecture` to surface deepening candidates against the area in question. The skill applies the deletion test and produces a numbered candidate list.

**Gate 2 — Selection.** User picks the candidate(s) to act on. Skip any candidate that contradicts an existing ADR unless the friction warrants revisiting the ADR (see §5).

**Gate 3 — Design (Grilling-Complete).** Invoke `/grill-with-docs` against the chosen candidate. Walk the design tree: constraints, interface shape, what sits behind the seam, what tests survive the refactor. Add any new domain terms to `CONTEXT.md` inline.

**Gate 4 — Branch.** `git checkout -b refactor/<short-slug>`.

**Gate 5 — Implement (Tests-Green, behavior-preserving).** Run the full test suite **before** the first edit. Capture the baseline. Refactor in small, reversible steps. Run the suite after every step. Pass criterion: the suite stays green throughout; no test is modified except to update mechanically-changed references.

**Gate 6 — New test coverage (when the refactor reveals it).** If the deepened interface exposes a behavior that wasn't testable before, add tests via `/tdd` at the new seam.

**Gate 7 — ADR (if appropriate).** If the refactor encodes a hard-to-reverse decision with real alternatives, write an ADR under `docs/adr/`. See §5.

**Gate 8 — Review.** `requesting-code-review`.

**Gate 9 — Merge.**

### 2.4 — Chore

Applies to dependency upgrades, tool configuration, build scripts, and substantive documentation changes that aren't trivial fast-path.

**Gate 1 — Read before write.** Read every file the chore will touch. For Next.js or framework upgrades, also read the relevant file under `node_modules/next/dist/docs/` (per `AGENTS.md`).

**Gate 2 — Branch.** `git checkout -b chore/<short-slug>`.

**Gate 3 — Implement.** Surgical change. No unrelated edits, no opportunistic reformatting.

**Gate 4 — Verify.** Run `bun lint` and the test suite. Pass criterion: both clean.

**Gate 5 — Review.** `requesting-code-review`.

**Gate 6 — Merge.**

### 2.5 — Trivial fast-path

All four criteria must hold: **≤30 LOC, single file, no public API change, no business-logic change.** If any fails, route up.

**Gate 1 — Self-classification line.** First line of the commit message: `SOP: fast-path — <one-clause justification>` (e.g. `SOP: fast-path — typo in error message in app/error.tsx, 1 LOC`).

**Gate 2 — Verify.** Run `bun lint` and the test suite locally. Pass criterion: clean.

**Gate 3 — Commit directly to main.** No branch, no PR.

If the change later proves not to have been trivial (it breaks something, requires a follow-up edit, or had a hidden API/logic implication), the agent **must** open a retroactive `.scratch/sop-fast-path-misses/<date>-<slug>.md` capturing the misclassification. Pattern detection improves over time.

---

## 3. Gates — pass criteria, reference

A gate is a checkpoint with a single, observable pass criterion. The criteria below are the canonical definitions; procedure sections may add constraints but never relax these.

- **Grilling-Complete.** A written brief exists (in conversation or in `.scratch/<slug>/brief.md`) covering: the user's intent in their own words, domain terms used (with any additions to `CONTEXT.md`), modules expected to change, success criteria as observable behavior, explicit out-of-scope. The user has said "approved" or "go" verbatim.
- **PRD-Ready.** A file at `.scratch/<feature-slug>/PRD.md` exists, follows the `/to-prd` template, contains no placeholder text.
- **Issues-Ready.** Files at `.scratch/<feature-slug>/issues/NN-<slug>.md` exist, one per vertical slice, each with acceptance criteria and a Blocked-by line.
- **Loop-Built.** A command exists that returns a deterministic pass/fail signal for the bug in under 30 seconds, runnable by the agent without human input.
- **Tests-Green.** `bun lint` is clean AND the full test suite passes AND no new `.skip` / `.only` / `xfail` was added unless explicitly approved.
- **Review-Approved.** The `requesting-code-review` skill ran on the diff, returned no high-confidence issues, and any medium-confidence issues are either resolved or noted as deferred in the PR description.
- **Arch-Reviewed.** `/improve-codebase-architecture` ran against the modules touched. Findings (or "no candidates") are filed at `.scratch/<slug>/arch-followups.md`.

A gate that cannot be passed is not skipped. It is documented (see §6) and routed to whoever can resolve it.

---

## 4. Skill index — when to invoke

Skills are listed once. **mattpocock skills win for any overlap with superpowers**, per the project's stated direction. Superpowers fills only the gaps.

### Engineering (mattpocock)

- **`/setup-matt-pocock-skills`** — Already run. Re-run only to change issue tracker, label vocabulary, or domain-doc layout.
- **`/grill-with-docs`** — Gate 1 of §2.1, Gate 3 of §2.3. Mandatory before every substantive change. Updates `CONTEXT.md` inline.
- **`/grill-me`** — For non-code grilling sessions (e.g. product decisions, scoping). Same discipline, no domain-doc side effects.
- **`/to-prd`** — Gate 2 of §2.1. Synthesizes a PRD from the grilling brief. Does **not** interview — comes after `/grill-with-docs`.
- **`/to-issues`** — Gate 3 of §2.1. Breaks the PRD into vertical-slice issues.
- **`/triage`** — When reviewing the inbox of `.scratch/` issues or external bug reports. Moves issues through the state machine defined in `docs/agents/triage-labels.md`.
- **`/tdd`** — Gate 5 of §2.1, Gate 5 of §2.2 (for the regression test), Gate 5–6 of §2.3. Red-green-refactor, vertical slices only. **Replaces** superpowers `test-driven-development`.
- **`/diagnose`** — Gates 1–6 of §2.2. **Replaces** superpowers `systematic-debugging`. Every bug fix begins with Phase 1.
- **`/improve-codebase-architecture`** — Gate 1 of §2.3, Gate 8 of §2.1, Gate 9 of §2.2. Run after every PRD-scale feature merges. Surface deepening candidates; apply the deletion test.
- **`/zoom-out`** — Anytime the agent (or user) needs a higher-level map of an unfamiliar area before editing.
- **`/prototype`** — Throwaway code to flesh out a design before committing to it. Optional for state-model / data-shape questions. **Mandatory** for UI-shape questions per the §2.1 Gate 1 visual-treatment sub-rule; reach for `frontend-design` first if the choice is between distinct visual aesthetics.

### Productivity (mattpocock)

- **`/caveman`** — Available on user request only. Not a default. Useful during long debugging sessions.
- **`/handoff`** — When context grows too long to continue cleanly, or before pausing work. Produces a handoff doc at a `mktemp` path.
- **`/prompt-refiner`** — When the user is writing a prompt for another agent. Returns the refined prompt as a single markdown code block.
- **`/write-a-skill`** — When creating new skills for this repo or others.

### Superpowers (gap-fillers only)

Used where mattpocock has no equivalent. If a future mattpocock skill replaces one of these, the SOP is updated and that mattpocock skill takes priority. Gap-fillers may themselves be **mandatory** for specific triggers — flagged in the relevant gate or in the bullet below.

- **`frontend-design:frontend-design`** — **Mandatory** for visual-treatment decisions per the §2.1 Gate 1 sub-rule. Whenever a grilling surfaces a choice between two or more concrete visual aesthetics ("which card style?", "compact or beefy?", layout / placement questions affecting visual rhythm), invoke this skill and build a runnable preview route. ASCII mockups, prose layout descriptions, and `AskUserQuestion` `preview` blocks are forbidden substitutes.
- **`brainstorming`** — At the very start of a project or sub-project when even the goal is unclear. Hands off to `writing-plans` or to `/grill-with-docs`. Do not use brainstorming if `/grill-with-docs` better fits — pick the one closer to the current need.
- **`writing-plans`** — Reserved for plans that aren't product features (e.g. an internal migration plan, a test-suite reorganization). For product features, `/to-prd` is the entry point.
- **`executing-plans`** — Walking through a written plan step by step. Pairs with `writing-plans`.
- **`requesting-code-review`** — Gate 6 of §2.1, Gate 7 of §2.2, Gate 8 of §2.3, Gate 5 of §2.4. Mandatory pre-merge.
- **`receiving-code-review`** — When you are on the **other** side — reading a code-review report and acting on it.
- **`verification-before-completion`** — Pre-declaration check. Use this before saying "done" on anything substantive.
- **`finishing-a-development-branch`** — End-of-feature checklist (cleanup, branch hygiene).
- **`using-git-worktrees`**, **`dispatching-parallel-agents`**, **`subagent-driven-development`** — Available for parallel agent work. Optional; not a gate.

---

## 5. Domain-doc lifecycle

`CONTEXT.md` and `docs/adr/` are created **lazily**, never as empty templates.

- **`CONTEXT.md`.** Created the first time a domain term is sharpened during `/grill-with-docs` or `/improve-codebase-architecture`. It is a glossary and **only** a glossary — no implementation details, no specs. Add a term whenever the team commits to using a specific word for a concept. Update a term whenever its meaning changes.
- **`docs/adr/`.** Created the first time a decision satisfies all three of:
  1. **Hard to reverse** — undoing it later costs meaningful effort.
  2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
  3. **The result of a real trade-off** — there were genuine alternatives and one was chosen for stated reasons.

  If any one of those three is missing, do not write an ADR. Reasons that count as ephemeral ("not worth it right now") never become ADRs.

The skills already know this. The SOP enforces that nobody talks themselves out of either file when the trigger fires, and nobody preemptively creates empty ones.

---

## 6. Escape hatches and conflict resolution

Priority order, highest first:

1. **The user's explicit instructions** (in `CLAUDE.md`, `AGENTS.md`, or directly in conversation) override anything in this SOP. The agent must surface the conflict the moment it notices, name the SOP clause being overridden, and proceed only after the user acknowledges.
2. **This SOP** overrides individual skill defaults. Example: `/to-prd` says it can synthesize a PRD from existing context without an interview. The SOP requires `/grill-with-docs` first. The SOP wins.
3. **Individual skill instructions** govern within their own scope.

**Skipping a gate.** An agent may skip a gate only if it writes an exception:

- **Where:** `.scratch/<slug>/sop-exception.md` for procedure-level skips; commit message body for fast-path classification disputes.
- **Format:** Gate name, reason for skip, what would have been verified if the gate had run, follow-up commitment (e.g. "will revisit on next PRD"). One paragraph.
- **Limit:** Two exceptions per feature/bug/refactor is a smell. Three is a process failure — pause and re-plan.

**Discovering misclassification mid-flight.** If an agent realizes mid-procedure that the work is bigger than its route (e.g. a "bug fix" turns out to be a feature), it must stop, surface the discovery to the user, and re-route. The work-in-progress is preserved; the SOP picks up at the new route's first gate.

---

## 7. Maintenance

This SOP is itself a substantive document. Changes to it follow §2.1.

- Gate 1 — `/grill-with-docs` against the proposed change. What problem does the change solve? What gate is being added, removed, or moved? What is the failure mode without the change?
- Gate 2 — A PRD is overkill for SOP changes; instead, write a one-page change note at `.scratch/sop-changes/<date>-<slug>.md` covering Problem / Change / Rationale / Impact-on-existing-procedures.
- Gate 3 — Branch `chore/sop-<slug>`, edit `SOP.md`, run the test suite (lint must still pass), open PR, `requesting-code-review`, merge.

The SOP enforces itself. If anyone — agent or human — proposes changing this document without following its own rules, that proposal is denied and re-routed through §2.1.
