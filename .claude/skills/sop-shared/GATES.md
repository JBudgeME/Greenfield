# SOP shared rules

Binding for every `sop-*` route skill. Route skills reference these rules by name and never restate them — this file is their single home. Read it once per route execution, alongside the route skill.

Reliability and maintainability take precedence over short-term implementation speed. Conflicts and escape hatches resolve per the rules below — surface them before acting; silent deviation is a process failure.

## Tier scales procedure depth

Tier does not change which route runs — it changes how deep each gate goes:

- **T0** → `sop-fastpath` only. Other routes do not accept T0 work.
- **T1** → Full route, light artifacts (per-gate T1 notes in the route skills); PRD only if the work spans more than one commit; no mandatory post-merge architecture review.
- **T2** → Default. Route runs as written.
- **T3** → Route runs as written **plus** a rollback plan (filed at the alignment gate) and observability requirements (logging / metrics / feature flag for risky surfaces) verified at merge.

**"Public API"** (as used in tier criteria): exported package symbols (including subpath exports and published types), HTTP routes and webhook endpoints, server actions, and database RPCs — plus any other contract another module or external consumer relies on across a boundary (env-var schemas and generated type surfaces included). The list is illustrative, not exhaustive: a surface not listed is not thereby internal. This definition never lowers a tier another criterion independently assigns.

## Gate pass criteria (canonical)

A gate is a checkpoint with a single, observable pass criterion; an activity (like `git checkout -b`) is a step inside a gate, not a gate. Route skills may add constraints but never relax these. A gate that cannot be passed is not skipped — it is documented (see Escape hatches) and routed to whoever can resolve it.

- **Aligned.** A brief is published to GitHub per the sop-feature Gate 1 placement table (all tiers), covering user intent, domain terms used (with `CONTEXT.md` additions), modules expected to change, success criteria as observable behavior, explicit out-of-scope. For T3: the PRD additionally contains a Rollback Plan and an Observability Spec. **User has given explicit affirmative approval.** Silence, hedging, or implicit signals are not approval. Synonyms count: "yes," "go," "approved," "ship it," "lgtm," "do it," etc. Absence does not.
- **Sliced.** Per-slice GH issues exist with `--label kind:issue --label prd:<slug>`, each with a `## Parent #<prd-num>` body section, acceptance criteria, and a `## Blocked by` section if dependencies exist. (T1 features use an inline slice checklist in the single issue's body instead.)
- **Loop-Built.** A command exists that returns a deterministic pass/fail signal for the bug in under 30 seconds, runnable by the agent without human input. **OR** a statistical repro (N runs, observed X% failure rate ±tolerance) where deterministic repro is impossible. Built within a 60-minute timebox; if neither emerges, escalate.
- **Tests-Green.** the project's lint command is clean AND the full test suite passes AND no new `.skip` / `.only` / `xfail` was added unless explicitly approved. CI is part of this gate: a change cannot pass Tests-Green if (a) its own PR CI is failing, or (b) `main`'s most recent CI run is failing — route through `sop-restore-ci`. **T3 only:** observability hooks specified in the PRD are live and emitting.
- **Review-Approved.** The `requesting-code-review` skill ran on the diff. **High-confidence findings** (reviewer has direct evidence — line numbers, repro, named failure mode — that the change is unsafe or incorrect as written) are zero. **Medium-confidence findings** (pattern, smell, or partial evidence without a demonstrable failure) are either addressed or deferred with a one-line note in the PR description stating the reason. **Low-confidence findings** (style, optional improvement) are logged but non-gating.
- **Arch-Reviewed (trigger-based).** Either no trigger fired (gate trivially passes), or `/improve-codebase-architecture` ran against the modules touched and each candidate is filed as a GH issue with `--label kind:arch-followup --label prd:<slug>` plus a process-state label.
- **Rollback-Verified (T3 only, where applicable).** The revert path was sanity-checked: revert produces a working build, restores prior behavior, and does not cause data inconsistency. Recorded in the PR description.

## Invariant capture (cross-cutting)

Fires whenever work introduces a new **load-bearing system property** — a property that other modules now rely on, or that a deferred scope item assumes will continue to hold. Applies regardless of route. When triggered, the agent **must**:

- (a) Record the property in `docs/invariants.md` (creating the file on first use) under a clear heading, with a `**Modules:**` line listing the file paths that uphold it.
- (b) Reference the invariant by heading from the source that triggered capture — PRD deferral text, regression-test header, or design note.
- (c) Add a comment to each module that upholds the invariant, naming it and linking to `docs/invariants.md`.

The module-side back-link is the operational core — without it, a future refactor-author has no reason to open the invariants file before deleting code. Per-gate triggers are marked inline in the route skills ("Apply invariant-capture rule if…"); the firing condition above is canonical and broader than any inline trigger. If no trigger fires, the rule trivially passes — no file edits required.

## Precedence and escape hatches

Priority order, highest first:

1. **The user's explicit instructions** (in `CLAUDE.md`, `AGENTS.md`, or conversation) override anything in the SOP kit. The agent must surface the conflict, name the rule being overridden, and proceed only after acknowledgment.
2. **The SOP kit** (route skills + this file) overrides individual skill defaults.
3. **Individual skill instructions** govern within their own scope.

When multiple skills could apply, best skill for the current need wins; tiebreaker: prefer the skill with the cleaner side effects on this repo's documentation. Two known skill-default overrides: `brainstorming`'s "before any creative work" default is overridden by `sop-feature` Gate 1; `writing-plans` / `executing-plans` are for plans that aren't product features — features route through `sop-feature`.

**Skipping a gate.** An agent may skip a gate only with a written exception:

- **Where:** appended to the GH issue body (the work-item itself, or the parent PRD issue if at the feature level) as a `## SOP exception` section. Inline so it surfaces alongside the work; a separate issue is not required.
- **Format:** Gate name, reason for skip, what would have been verified if the gate had run, follow-up commitment. One paragraph.
- **Limit:** Two exceptions per work-item is a smell. **Three is a process failure — pause and re-plan.** A third exception requires explicit human decision before proceeding; not something the agent can self-grant.

**Discovering misclassification mid-flight.** Stop, surface, re-route. Work-in-progress is preserved; the SOP picks up at the new tier/route's first gate. If the misclassification is a tier change (T1 → T2 mid-flight, say), backfill missing artifacts (e.g. write the PRD now) rather than starting over.

## Domain-doc lifecycle

`CONTEXT.md`, `docs/adr/`, and `docs/invariants.md` are created **lazily**, never as empty templates. The `CONTEXT.md` glossary discipline and the ADR criteria/format are owned by the `/domain-modeling` skill (run it alongside `/grilling` wherever a route calls for grilling). Consumption conventions for agents: `docs/agents/domain.md`.

- **`CONTEXT.md`** — glossary only (no implementation details, no specs); terms land as they sharpen during grilling or `/improve-codebase-architecture`.
- **`docs/adr/`** — write an ADR only when `/domain-modeling`'s three criteria all hold (hard to reverse, surprising without context, a real trade-off with stated alternatives).
- **`docs/invariants.md`** — repo-specific, not owned by any skill: created the first time the invariant-capture rule fires. Each entry has a heading and a `**Modules:**` line (greppable for the T0 module check).

## Process glossary

- **AFK-grabbable.** An issue with enough context (acceptance criteria, blocked-by, domain vocabulary) that an agent can implement it without further human input.
- **Deepening candidate.** A refactor opportunity surfaced by `/improve-codebase-architecture` — typically a tightly-coupled module pair, a leaky abstraction, or duplicated structure.
- **Deletion test.** See the `codebase-design` skill (and `AGENTS.md`, Minimal justified abstractions) — distinguishes real consolidations from speculative abstractions.
- **Tracer bullet.** A thin end-to-end slice cutting through every layer (schema → API → UI → tests) rather than building one layer horizontally; each slice is demoable on its own.
