# Standard Operating Procedure

This document defines **how work happens** in this repository. It is binding on every agent and every human contributor. It sits alongside `CLAUDE.md` and `AGENTS.md`, which define **principles** (KISS, DRY, fail-fast, surgical changes, etc.). This document defines the **process** that enforces those principles.

If an instruction in `CLAUDE.md` or `AGENTS.md` conflicts with this SOP, the user's instructions win — but the agent **must surface the conflict** before acting. Silent deviation is a process failure.

Reliability and maintainability take precedence over short-term implementation speed. The SOP exists to make the rigorous path the default — the rigor itself serves the goal of shipping a rock-solid product, not its own continuation.

---

## 1. Routing — pick the right procedure first

The first thing an agent does in any new conversation is **classify the work along two axes**: a **Tier** (blast radius / risk) and a **Type** (what kind of change). State both in the opening response. Misclassification must be surfaced immediately and rerouted; it is not a punitive event, but a silent miscalibration is.

### 1.1 Tier classification (blast radius)

| Tier   | Definition                                                                                                                                                                                                                |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **T0** | Trivial. All of: ≤50 LOC, ≤3 closely-related files, no public API change, no business-logic change, no touch of any module named in `docs/invariants.md`, `main` CI green.                                                |
| **T1** | Low-risk. Not T0. All of: ≤3 modules touched, no public API addition or breaking change, no schema migration, no auth / security-boundary change, no payment / billing / data-integrity surface.                          |
| **T2** | Substantive. Not T0 or T1. Multi-module work, public API addition, or business-logic change in a non-isolated module. The historical default for "feature."                                                               |
| **T3** | Production-critical. Touches schema migrations, auth, payments, billing, data integrity, observability infrastructure, **or** any module flagged in `docs/invariants.md`. Tier dominates LOC: a 5-line auth change is T3. |

**Classification rule.** T0 and T1 require all listed criteria. T2 and T3 fire on any single matching criterion. Where multiple tiers apply, classify as the highest — T3 dominates T2, which dominates T1, which dominates T0. When in doubt, route up.

### 1.2 Type and procedure

| Type                 | Trigger                                                            | Procedure |
| -------------------- | ------------------------------------------------------------------ | --------- |
| Feature              | New behavior; touches business logic, data flow, or any public API | §2.1      |
| Bug fix              | Reported defect, regression, or unexpected behavior                | §2.2      |
| Refactor             | Structural improvement without changing observable behavior        | §2.3      |
| Chore                | Dependencies, tooling, config, non-trivial docs                    | §2.4      |
| Trivial fast-path    | T0 changes only                                                    | §2.5      |
| Restore main CI      | `main`'s most recent CI run is red                                 | §2.6      |
| Post-deploy rollback | Confirmed production regression after merge                        | §2.7      |

The skill chain for each procedure lives in §4 — the index, not the routing table, is canonical.

§2.6 and §2.7 are **overrides**: they preempt in-flight work in their respective windows.

### 1.3 Tier scales procedure depth

Tier does not change which procedure runs — it changes how deep each gate goes:

- **T0** → §2.5 fast-path only. Other procedures do not accept T0 work.
- **T1** → Full procedure, light artifacts. Brief published as a GH issue (mandatory all tiers per §3.2 — see §2.1 G1 for placement); PRD only if the work spans more than one commit; no mandatory post-merge architecture review.
- **T2** → Default. Procedure runs as written below.
- **T3** → Procedure runs as written **plus** a rollback plan (filed at Gate 1) and observability requirements (logging / metrics / feature flag for risky surfaces) verified at Gate 5.

---

## 2. Procedures

Each procedure is a sequence of numbered **gates**. A gate is a checkpoint with an observable pass criterion (see §3); an activity (like `git checkout -b`) is a step inside a gate, not a gate. No gate may be skipped without a written exception (see §6).

### 2.1 — Feature

**Gate 1 — Aligned.** Invoke `/grill-with-docs`. Interview until the agent can write a brief covering: which domain terms apply (add new ones to `CONTEXT.md` inline), which modules will change, what success criteria are observable, what is out of scope. **The brief must be published to GitHub** — conversation-only alignment is not durable across sessions or subagents. **T1**: create a single GH issue with `--label kind:issue --label ready-for-agent --label prd:<slug>`; the issue body is the brief content. The work proceeds without a separate PRD. **T2/T3**: synthesize the brief into a PRD via `/to-prd`; create a GH issue with `--label kind:prd --label ready-for-agent --label prd:<slug>`; the issue body is the PRD using mattpocock's template; post the brief as the **first comment** on that PRD issue. **T3 only:** PRD additionally includes a Rollback Plan (revert path, forward-fix decision criteria) and an Observability Spec (logs, metrics, feature flag if applicable).

**Sub-rule — Visual treatment.** Whenever grilling surfaces a choice between two or more concrete aesthetics ("which card style?", "compact or beefy?", layout / placement), invoke `ui-ux-pro-max` or `/prototype` and build a runnable preview route. ASCII mockups and prose-rendered layouts are forbidden substitutes. Carve-outs: trivial polish on a T0 surface, or reuse of an established in-codebase pattern with no ambiguity. The prototype lives at `app/dev/<topic>/page.tsx` in a worktree and is deleted in the feature's final slice (or via a follow-up cleanup commit).

**Apply §3.1 invariant-capture rule** if the PRD (or brief) defers any scope item via a workaround relying on a system property.

Pass criterion (§3.2 Aligned). For T1, a single GH issue exists with the brief as its body. For T2/T3, a `kind:prd` GH issue exists with the PRD as its body and the brief as its first comment. All issues for this feature carry `prd:<slug>` for grouping.

**Gate 2 — Sliced.** **T2/T3 only.** Invoke `/to-issues`. Break the PRD into tracer-bullet vertical slices. For each slice, create a GH issue with `--label kind:issue --label ready-for-agent --label prd:<slug>`. Issue body opens with `## Parent #<prd-num>` pointing at the parent PRD, then acceptance criteria, then a `## Blocked by` section if dependencies exist.

For T1, the brief's single GH issue body contains an inline slice checklist (`- [ ]` items) instead of separate per-slice issues.

**Gate 3 — Implemented.** `git checkout -b feat/<slug>`. For each slice in dependency order, invoke `/tdd`. **T1:** iterate the in-issue-body checklist items in the same vertical-slice discipline — the absence of per-slice issues does not relax red-green-refactor or Tests-Green. Strict red-green-refactor, vertical slices only. Never commit a red test suite to the feature branch. Pass criterion (§3.2 Tests-Green) holds at the end of every slice.

**Gate 4 — Reviewed.** Invoke `requesting-code-review`. Pass criterion (§3 Review-Approved) — no high-confidence findings remain open.

**Gate 5 — Merged.** Open a PR (standard format: Summary / Test plan). Merge to `main` only after Gate 4 passes and CI is green. On merge: close the slice's GH issue (`gh issue close <num> --comment "merged in <pr-url>"`) and apply the `merged` label. **R1 cascade**: if the closed slice was the last open child of its parent PRD (verify via `gh issue list --label prd:<slug> --state open` returning empty), close the PRD issue in the same operation with the `merged` label. **T3 only:** verify observability is live (logs flowing, metrics emitting, feature flag toggleable) AND that the revert path was sanity-checked (§3 Rollback-Verified). Confirm both in the PR description.

**Gate 6 — Followed-up (trigger-based).** Run `/improve-codebase-architecture` against the modules touched **only if any of:** (a) a new public API was added, (b) a new module was created, (c) more than five files of production code were touched (test files do not count toward this threshold), (d) coupling between two previously-unconnected modules was introduced, (e) work touched a module flagged in `docs/invariants.md`. If a trigger fires, create a GH issue per candidate with `--label kind:arch-followup --label prd:<slug>` plus a process-state label (`queued` / `watch-only` / `blocked`) and an optional `severity:*` label. If no trigger fires, gate trivially passes — no issues required.

### 2.2 — Bug fix

**Gate 1 — Loop-Built.** Invoke `/diagnosing-bugs` and execute Phase 1 until a fast, deterministic, agent-runnable pass/fail signal exists. **Timebox: 60 wall-clock minutes.** If a deterministic <30s loop is impossible (race condition, flake, third-party timing), document the constraint and switch to a **statistical repro** (N runs, observed X% failure rate). If even a statistical repro cannot be established within the timebox, escalate to the user — do not proceed to Gate 2.

**Gate 2 — Reproduced.** Run the loop. Confirm it produces the user's reported symptom, not a nearby one.

**Gate 3 — Hypothesised.** Generate three to five ranked, falsifiable hypotheses with predictions. Show the ranked list before testing. **T1 carve-out:** if the root cause is unambiguously visible from the repro itself (typo, off-by-one, obvious missing case, single-line logic error), a one-line documented hypothesis suffices in place of the ranked list. T2/T3 bugs always require the full ladder — even when the cause looks obvious.

**Gate 4 — Instrumented.** One probe per prediction. Change one variable at a time. Tag debug logs `[DEBUG-<short-id>]` for later grep-and-strip.

**Gate 5 — Fixed-with-regression-test.** Write the regression test **before** the fix if a correct seam exists; otherwise document the missing seam as a finding for §2.3 follow-up. Apply fix. Re-run the loop. Pass criterion (§3 Tests-Green) holds. **Apply §3.1 invariant-capture rule** if the regression test asserts a new behavioral contract that other modules rely on (or could come to rely on).

**Gate 6 — Cleaned-up.** Remove all `[DEBUG-…]` instrumentation. Delete throwaway prototypes. Write the winning hypothesis into the commit message.

**Gate 7 — Reviewed and Merged.** Invoke `requesting-code-review`. After approval, open PR and merge. On merge: close the bug's GH issue per §2.1 Gate 5 (with R1 cascade if relevant). Post-mortem ("what architectural change would have prevented this?") lives in the PR description. If the post-mortem is non-trivial (suggests real follow-up work), also create an arch-followup GH issue per §2.1 Gate 6 conventions and route through §2.3. **T3 only:** include a Rollback Verification line in the PR confirming the revert path was sanity-checked.

### 2.3 — Refactor

**Gate 1 — Surveyed.** Invoke `/improve-codebase-architecture` against the area in question. The skill applies the deletion test and produces a numbered candidate list.

**Gate 2 — Selected.** User picks the candidate(s) to act on. **T1 carve-out:** if the surveyed candidate is unambiguous (only one obvious deepening, no ADR conflict, no public-API change, no invariants-listed module touched), the agent may self-select and announce the choice at the opening of Gate 3 rather than waiting on user input. T2/T3 always require explicit user selection. Skip any candidate that contradicts an existing ADR unless the friction warrants revisiting the ADR (see §5).

**Gate 3 — Designed.** Invoke `/grill-with-docs` against the chosen candidate. Walk the design tree: constraints, interface shape, what sits behind the seam, what tests survive the refactor. Add new domain terms to `CONTEXT.md` inline. Write an ADR under `docs/adr/` if and only if the §5 ADR criteria are all met. **Apply §3.1 invariant-capture rule** if the refactor introduces a new seam whose contract becomes load-bearing for callers.

**Gate 4 — Implemented.** `git checkout -b refactor/<slug>`. Run the full test suite **before** the first edit; capture the baseline. Refactor in small, reversible steps. Run the suite after every step. Pass criterion: suite stays green throughout; no test is modified except to update mechanically-changed references. If the deepened interface exposes a behavior that wasn't testable before, add tests via `/tdd` at the new seam (this is a step inside Gate 4, not a separate gate).

**Gate 5 — Reviewed.** `requesting-code-review`.

**Gate 6 — Merged.** Open PR; merge after CI green. On merge: close the refactor's GH issue per §2.1 Gate 5 (with R1 cascade if relevant). If the refactor lands an arch-followup candidate, also close that candidate's GH issue with the `merged` label in the same operation.

### 2.4 — Chore

Applies to dependency upgrades, tool configuration, build scripts, and substantive documentation changes that aren't trivial fast-path.

**Gate 1 — Read.** Read every file the chore will touch. For Next.js or framework upgrades, also read the relevant file under `node_modules/next/dist/docs/`.

**Gate 2 — Implemented.** `git checkout -b chore/<slug>`. Surgical change. No unrelated edits, no opportunistic reformatting.

**Gate 3 — Verified.** Run `bun lint` and the test suite. Pass criterion (§3 Tests-Green).

**Gate 4 — Reviewed and Merged.** `requesting-code-review`. After approval, PR and merge.

### 2.5 — Trivial fast-path (T0)

All criteria from §1.1 T0 must hold. The "main CI green" criterion is part of T0; if `main`'s most recent CI run is failing, fast-path is suspended — route through §2.6 even for changes that otherwise qualify.

**Gate 1 — Self-classification line.** First line of the commit message: `SOP: fast-path — <one-clause justification>` (e.g. `SOP: fast-path — typo in error message in app/error.tsx, 1 LOC`).

**Gate 2 — Verified.** Run `bun lint` and the test suite locally. Pass criterion: clean.

**Gate 3 — Commit directly to main.** No branch, no PR.

**T0 has no exception path.** If a change qualifying for T0 nonetheless needs to skip a step or document a deviation, it is by definition not T0 — re-classify (typically to T1 via §2.1 G1) and route up.

If the change later proves not to have been trivial (it breaks something, requires a follow-up edit, or had a hidden API/logic implication), open a retroactive `.scratch/sop-fast-path-misses/<date>-<slug>.md` capturing the misclassification. Pattern detection improves over time.

### 2.6 — Restore main CI (override)

Triggers the moment `main`'s most recent CI run is observed red. Overrides any in-flight work. The agent stashes WIP. §2.5 fast-path is suspended for the duration; all commits route through this procedure until `main` returns to green.

**Concurrency.** First agent to declare §2.6 owns restoration. Any other agent observing red main stashes WIP and stands down until announce/recovery. If two agents announce within the same minute, the first to declare in writing (committed message or PR description) owns restoration; the other(s) defer.

**Gate 1 — Announced.** Declare the route in the opening message of the session: "main CI is red; routing through §2.6." Stash or commit any work-in-progress on its own branch.

**Gate 2 — Diagnosed.** Invoke `/diagnosing-bugs` Phase 1 to build a deterministic local pass/fail signal for the failing CI check. **Max 3 attempts to reproduce locally.** Sources to consult: `gh run view <run-id> --log-failed` for the trace, `gh run list --branch main` for the flip commit. If 3 attempts fail to reproduce, escalate to the user — the failure may be environmental, transient, or runner-specific and a code-level root cause may not exist.

**Gate 3 — Fixed.** Apply the fix on a `fix/restore-ci-<slug>` branch. **Not direct-to-main**, even if the change qualifies for §2.5 — red-main restoration requires the PR's own CI to confirm green before merging.

**Gate 4 — Merged.** Open PR (standard format). Invoke `requesting-code-review`. Merge after the PR's CI is green and the §3.2 Review-Approved criterion holds (no high-confidence findings open).

**Gate 5 — Retrospective.** File `.scratch/sop-fast-path-misses/<date>-<short-slug>.md` covering: what broke, when it went red, how it escaped earlier slices' CI, the restoration commit. Filed in the same PR as the fix, so the merge atomically lands the restoration and its record.

After Gate 5 lands, normal routing resumes.

### 2.7 — Post-deploy rollback (override)

Triggers on confirmed production regression after a merge. "Confirmed" means: a reproducible user-reported regression, OR an error-rate spike with corroborating reports, OR a data-integrity issue. Overrides any in-flight work.

**Gate 1 — Triaged.** Confirm the regression is real (one repro is enough), identify the suspect commit(s), and estimate blast radius (users affected; reversibility; data implications). **Timebox: 30 minutes.** If triage is inconclusive at the 30-minute mark, default to revert; diagnose the revert's correctness separately.

**Gate 2 — Decided.** Default decision: **revert**. Choose forward-fix only if (a) estimated time-to-fix-forward is under 30 minutes AND (b) blast radius is bounded AND (c) reverting would itself cause data loss or correctness issues. Record the decision and its rationale in the PR description.

**Gate 3 — Applied.** Open `revert/<sha>-<slug>` (revert) or `hotfix/<slug>` (forward-fix). Standard PR format. CI must be green before merge.

**Gate 4 — Verified.** After deploy, confirm production is restored. For data integrity issues, verify the affected dataset is consistent before declaring restored.

**Gate 5 — Retrospective.** File a postmortem at `.scratch/sop-fast-path-misses/<date>-<slug>.md` (reusing the existing retrospective directory). Cover: what shipped, what failed in pre-merge review, what monitoring missed, what (if any) SOP change is warranted. If the retrospective implicates a missing gate or weak pass criterion, route a §7 SOP change.

---

## 3. Gates — pass criteria, reference

A gate is a checkpoint with a single, observable pass criterion. The criteria below are canonical; procedure sections may add constraints but never relax these.

### 3.1 Cross-cutting rule — Invariant capture

Fires whenever work introduces a new **load-bearing system property** — a property that other modules now rely on, or that a deferred scope item assumes will continue to hold. Applies regardless of procedure.

When triggered, the agent **must**:

- (a) Record the property in `docs/invariants.md` (creating the file on first use) under a clear heading, with a `**Modules:**` line listing the file paths that uphold it.
- (b) Reference the invariant by heading from the source that triggered capture — PRD deferral text in §2.1 G1, regression-test header in §2.2 G5, or design note in §2.3 G3.
- (c) Add a comment to each module that upholds the invariant, naming it and linking to `docs/invariants.md`.

The module-side back-link is the operational core — without it, a future refactor-author has no reason to open the invariants file before deleting code.

Triggers by procedure (non-exhaustive):

- **§2.1 G1** — PRD defers scope via a workaround relying on a system property.
- **§2.2 G5** — Regression test asserts a new behavioral contract.
- **§2.3 G3** — Refactor introduces a new seam whose contract is load-bearing for callers.

If no trigger fires, the rule trivially passes — no file edits required.

### 3.2 Gate pass criteria

- **Aligned.** A brief is published to GitHub (mandatory for all tiers) covering user intent, domain terms used (with `CONTEXT.md` additions), modules expected to change, success criteria as observable behavior, explicit out-of-scope. **T1**: the brief IS the issue body of a single `kind:issue` GH issue. **T2/T3**: the brief is the first comment on a `kind:prd` GH issue whose body is the PRD following the `/to-prd` template. For T3: PRD additionally contains a Rollback Plan and an Observability Spec. **User has given explicit affirmative approval.** Silence, hedging, or implicit signals are not approval. Synonyms count: "yes," "go," "approved," "ship it," "lgtm," "do it," etc. Absence does not.
- **Sliced.** Per-slice GH issues exist with `--label kind:issue --label prd:<slug>`, each with a `## Parent #<prd-num>` body section, acceptance criteria, and a `## Blocked by` section if dependencies exist. (T1 features use an inline slice checklist in the single issue's body instead.)
- **Loop-Built.** A command exists that returns a deterministic pass/fail signal for the bug in under 30 seconds, runnable by the agent without human input. **OR** a statistical repro (N runs, observed X% failure rate ±tolerance) where deterministic repro is impossible. Built within a 60-minute timebox; if neither emerges, escalate.
- **Tests-Green.** `bun lint` is clean AND the full test suite passes AND no new `.skip` / `.only` / `xfail` was added unless explicitly approved. CI is part of this gate: a change cannot pass Tests-Green if (a) its own PR CI is failing, or (b) `main`'s most recent CI run is failing — see §2.6 for restoration. **T3 only:** observability hooks specified in the PRD are live and emitting.
- **Review-Approved.** The `requesting-code-review` skill ran on the diff. **High-confidence findings** (reviewer has direct evidence — line numbers, repro, named failure mode — that the change is unsafe or incorrect as written) are zero. **Medium-confidence findings** (pattern, smell, or partial evidence without a demonstrable failure) are either addressed or deferred with a one-line note in the PR description stating the reason. **Low-confidence findings** (style, optional improvement) are logged but non-gating.
- **Arch-Reviewed (trigger-based, §2.1 Gate 6).** Either no trigger fired (gate trivially passes), or `/improve-codebase-architecture` ran against the modules touched and each candidate is filed as a GH issue with `--label kind:arch-followup --label prd:<slug>` plus a process-state label.
- **Rollback-Verified (T3 only, where applicable).** The revert path was sanity-checked: revert produces a working build, restores prior behavior, and does not cause data inconsistency. Recorded in the PR description.

A gate that cannot be passed is not skipped. It is documented (see §6) and routed to whoever can resolve it.

---

## 4. Skill index — when to invoke

When multiple skills could apply, **best skill for the current need wins**. Tiebreaker: prefer the skill with the cleaner side effects on this repo's documentation. Author identity is not the criterion.

### Engineering

- **`/setup-matt-pocock-skills`** — Already run. Re-run only to change issue tracker, label vocabulary, or domain-doc layout.
- **`/grill-with-docs`** — Gate 1 of §2.1, Gate 3 of §2.3. Mandatory before every substantive change. Updates `CONTEXT.md` inline.
- **`/grilling`** — The core relentless-interview discipline; invoked by `/grill-with-docs`, `/triage`, and `/improve-codebase-architecture`. Use directly for non-code grilling sessions (product decisions, scoping) — no domain-doc side effects.
- **`/to-prd`** — Gate 1 of §2.1 for T2/T3 features. Synthesizes a PRD from the grilling brief. Does **not** interview — comes after `/grill-with-docs`.
- **`/to-issues`** — Gate 2 of §2.1. Breaks the PRD into vertical-slice issues.
- **`/triage`** — When reviewing the inbox of `.scratch/` issues or external bug reports.
- **`/tdd`** — Gate 3 of §2.1, Gate 5 of §2.2 (for the regression test), Gate 4 of §2.3. Red-green-refactor, vertical slices only.
- **`/diagnosing-bugs`** — Gates 1–6 of §2.2 and Gate 2 of §2.6. Every bug fix begins with Phase 1. Honors gate timeboxes.
- **`/improve-codebase-architecture`** — Gate 1 of §2.3 and Gate 6 of §2.1 (trigger-based). Surface deepening candidates; apply the deletion test.
- **`/codebase-design`** — Deep-module vocabulary and principles. Support skill for `/improve-codebase-architecture` and any interface-design work.
- **`/domain-modeling`** — Maintains `CONTEXT.md` and `docs/adr/`. Invoked by `/grill-with-docs` and `/triage` as terms and decisions land.
- **`/implement`** — User-invoked implementation of a PRD or its issues; enters §2.1 Gate 3.
- **`/code-review`** — Two-axis review (Standards + Spec) of changes since a fixed point. Complements the gate-mandated `requesting-code-review`; not a substitute for it.
- **`/resolving-merge-conflicts`** — When an in-progress merge/rebase has conflicts.
- **`/zoom-out`** — Anytime an agent (or user) needs a higher-level map of an unfamiliar area before editing.
- **`/prototype`** — Throwaway code for design questions. Optional for state-model / data-shape; mandatory under the §2.1 Gate 1 visual-treatment sub-rule.
- **`/open-work`** — Read-only query of GitHub Issues. Bucketed output (Actionable / Queued / Watch-only / Blocked). Answer "what's open?".

### Productivity

- **`/caveman`** — Available on user request only.
- **`/handoff`** — When context grows too long to continue cleanly, or before pausing work.
- **`/research`** — Background research agent. Investigates a question against primary sources and writes findings to a Markdown file in the repo.
- **`/write-a-skill`** — When creating new skills.

### Gap-fillers (superpowers)

- **`ui-ux-pro-max`** — Mandatory for visual-treatment decisions per the §2.1 Gate 1 sub-rule.
- **`brainstorming`** — At the very start of a project or sub-project when even the goal is unclear. Hands off to `writing-plans` or `/grill-with-docs`.
- **`writing-plans` / `executing-plans`** — Plans that aren't product features.
- **`requesting-code-review`** — Mandatory pre-merge in every procedure.
- **`receiving-code-review`** — When reading a review report and acting on it.
- **`verification-before-completion`** — Pre-declaration check.
- **`finishing-a-development-branch`** — End-of-feature cleanup checklist.

Context-window discipline is documented in `AGENTS.md` (Context management) — not an SOP concern.

---

## 5. Domain-doc lifecycle

`CONTEXT.md`, `docs/adr/`, and `docs/invariants.md` are created **lazily**, never as empty templates.

- **`CONTEXT.md`.** Created the first time a domain term is sharpened during `/grill-with-docs` or `/improve-codebase-architecture`. Glossary only — no implementation details, no specs.
- **`docs/adr/`.** Created the first time a decision satisfies all three of: hard to reverse, surprising without context, the result of a real trade-off with stated alternatives.
- **`docs/invariants.md`.** Created the first time the §3.1 invariant-capture rule fires — which may happen in any procedure (§2.1 G1 PRD deferral, §2.2 G5 regression test pinning a contract, §2.3 G3 refactor introducing a load-bearing seam). Each entry has a heading and a `**Modules:**` line listing the file paths that uphold it (greppable for the T0 module check).

---

## 6. Escape hatches and conflict resolution

Priority order, highest first:

1. **The user's explicit instructions** (in `CLAUDE.md`, `AGENTS.md`, or conversation) override anything in this SOP. The agent must surface the conflict, name the SOP clause being overridden, and proceed only after acknowledgment.
2. **This SOP** overrides individual skill defaults.
3. **Individual skill instructions** govern within their own scope.

**Skipping a gate.** An agent may skip a gate only with a written exception:

- **Where:** appended to the GH issue body (the work-item itself, or the parent PRD issue if at the feature level) as a `## SOP exception` section. Inline so it surfaces alongside the work; a separate issue is not required.
- **Format:** Gate name, reason for skip, what would have been verified if the gate had run, follow-up commitment. One paragraph.
- **Limit:** Two exceptions per work-item is a smell. **Three is a process failure — pause and re-plan.** A third exception requires explicit human decision before proceeding; not something the agent can self-grant.

**Discovering misclassification mid-flight.** Stop, surface, re-route. Work-in-progress is preserved; the SOP picks up at the new tier/route's first gate. If the misclassification is a tier change (T1 → T2 mid-flight, say), backfill missing artifacts (e.g. write the PRD now) rather than starting over.

---

## 7. Maintenance

Changes to this SOP follow one of two paths depending on scope.

**Clarification-class edit.** A single section, no new gates, no new pass criteria, no new procedures. Examples: tightening a definition; adding an example; fixing a cross-reference. Path: change note at `.scratch/sop-changes/<date>-<slug>.md` → branch → edit → `requesting-code-review` → merge. No grilling required.

**Substantive edit.** New gates, new procedures, restructure of routing, or changes to pass criteria. Path: grill via `/grill-with-docs` → change note (one page, not a PRD) → branch → edit → `requesting-code-review` → merge.

The SOP enforces itself. If anyone — agent or human — proposes a substantive change without the substantive path, that proposal is denied and re-routed.

---

## 8. Metrics

The SOP cannot improve itself without instrumentation. Track lightweight counters:

- `.scratch/sop-fast-path-misses/*.md` — count over time (already exists). Spike = fast-path criteria are wrong.
- SOP exceptions filed (`gh issue list --search "SOP exception in:body" --state all --json number,title,labels`). Spike per procedure = that procedure's gates are misaligned with real work.
- Rough time-to-merge per route (from branch creation to merge timestamp; `git log` is enough). Median per route, reviewed quarterly.
- Post-merge defect count (bugs filed within 14 days of a feature merge, attributable to that feature). Spike per route = that procedure's review depth is insufficient.

**Where the result lives:** `.scratch/metrics/<YYYY-MM-DD>.md`, written by the agent or human running the review. Each entry records: counters for the period, comparison to the previous period, and any §7 edits the data suggests.

**Cadence:** quarterly (1st of Jan / Apr / Jul / Oct), or whenever a §7 substantive edit is proposed — the metric file is the proposed edit's evidence base. A missed quarterly read is itself a process smell.

**Tooling:** for v2, manual grep + manual count is acceptable. A `scripts/sop-metrics.ts` helper is a candidate follow-up (logged in the change note).

**Out of scope for v2:** real-time dashboard, automated emission, alerting. Counters are derivable from git + filesystem; that's enough.

---

## 9. Glossary

Project-specific terms with non-obvious meanings. Common terms (slug, gate, route, flip, brief, PRD, slice, work-item, tier) are defined inline at first use in the procedure that introduces them.

- **AFK-grabbable.** An issue with enough context (acceptance criteria, blocked-by, domain vocabulary) that an agent can implement it without further human input.
- **Deepening candidate.** A refactor opportunity surfaced by `/improve-codebase-architecture` — typically a tightly-coupled module pair, a leaky abstraction, or duplicated structure.
- **Deletion test.** "What would I delete if this candidate did not exist?" — applied during `/improve-codebase-architecture` to distinguish real consolidations from speculative abstractions.
- **HC / MC / LC finding.** Review-finding confidence levels used by §3.2 Review-Approved. HC = direct evidence (line numbers, repro, named failure mode) of unsafe-as-written; gating. MC = pattern / smell / partial evidence; addressed-or-deferred with PR note. LC = stylistic; logged not gating.
- **Invariant.** A load-bearing system property — a behavior that other modules now rely on, or that a deferred scope item assumes will continue to hold. Registered in `docs/invariants.md` per §3.1 capture rule.
- **R1 rule.** When the last open child issue of a PRD closes (via merge or wontfix), the parent PRD issue is also closed in the same operation. Cascade rule for terminal-state propagation.
- **Tracer bullet.** A thin end-to-end implementation slice that cuts through every layer (schema → API → UI → tests) rather than building one layer horizontally across the whole feature. Each slice is demoable on its own.
