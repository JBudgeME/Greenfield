---
name: sop-feature
description: Binding SOP route for features — new behavior touching business logic, data flow, or any public API. Invoke BEFORE implementing any feature request (T1–T3; T0 routes to sop-fastpath). Requires a GitHub-published brief and explicit user approval before any code.
---

Binding gate sequence for the Feature route. **First read `.claude/skills/sop-shared/GATES.md`** — it holds the canonical gate pass criteria, tier depth rules, invariant capture, and escape hatches referenced below. No gate may be skipped without a written exception (see GATES.md).

**Gate 1 — Aligned.** Run a `/grilling` session using the `/domain-modeling` skill. Interview until the agent can write a brief covering: which domain terms apply (add new ones to `CONTEXT.md` inline), which modules will change, what success criteria are observable, what is out of scope. **The brief must be published to GitHub** — conversation-only alignment is not durable across sessions or subagents.

| Tier  | Artifact                                              | Labels                                        | Brief placement                |
| ----- | ----------------------------------------------------- | --------------------------------------------- | ------------------------------ |
| T1    | Single GH issue; no separate PRD                      | `kind:issue`, `ready-for-agent`, `prd:<slug>` | Issue body                     |
| T2/T3 | PRD via `/to-prd` (mattpocock template) as a GH issue | `kind:prd`, `ready-for-agent`, `prd:<slug>`   | First comment on the PRD issue |

**T3 only:** the PRD additionally includes a Rollback Plan (revert path, forward-fix decision criteria) and an Observability Spec (logs, metrics, feature flag if applicable).

**Sub-rule — Visual treatment.** Whenever grilling surfaces a choice between two or more concrete aesthetics ("which card style?", "compact or beefy?", layout / placement), invoke `ui-ux-pro-max` or `/prototype` and build a runnable preview route. ASCII mockups and prose-rendered layouts are forbidden substitutes. Carve-outs: trivial polish on a T0 surface, or reuse of an established in-codebase pattern with no ambiguity. The prototype lives at a dev-only route or path (e.g. `app/dev/<topic>/`) in a worktree and is deleted in the feature's final slice (or via a follow-up cleanup commit).

**Apply the invariant-capture rule** (GATES.md) if the PRD (or brief) defers any scope item via a workaround relying on a system property.

Pass: **Aligned** (GATES.md) — including **explicit affirmative user approval**.

**Gate 2 — Sliced.** **T2/T3 only.** Invoke `/to-issues`. Break the PRD into tracer-bullet vertical slices. For each slice, create a GH issue with `--label kind:issue --label ready-for-agent --label prd:<slug>`. Issue body opens with `## Parent #<prd-num>` pointing at the parent PRD, then acceptance criteria, then a `## Blocked by` section if dependencies exist. (T1: an inline `- [ ]` slice checklist in the single issue's body instead.) Pass: **Sliced** (GATES.md).

**Gate 3 — Implemented.** `git checkout -b feat/<slug>`. For each slice in dependency order, invoke `/tdd`. **T1:** iterate the in-issue-body checklist items in the same vertical-slice discipline — the absence of per-slice issues does not relax red-green-refactor or Tests-Green. Strict red-green-refactor, vertical slices only. Never commit a red test suite to the feature branch. Pass: **Tests-Green** (GATES.md) holds at the end of every slice.

**Gate 4 — Reviewed.** Invoke `requesting-code-review` AND `two-axis-review` (Spec axis checks the diff against the Gate 1 brief/PRD; Standards axis is a second smell pass). Pass: **Review-Approved** (GATES.md) — no high-confidence findings remain open; two-axis-review Spec findings of missing or wrongly-implemented requirements count as high-confidence.

**Gate 5 — Merged.** Open a PR (standard format: Summary / Test plan). Merge to `main` only after Gate 4 passes and CI is green. On merge: close the slice's GH issue with the `merged` label and run the **R1 cascade** check — if the closed slice was the last open child of its parent PRD, close the PRD issue in the same operation with the `merged` label. The cascade fires on any terminal close of the last child — `wontfix` included, not just merge. `/pr-close` automates the merge path; manual `gh` fallback commands live in `docs/agents/issue-tracker.md`. **T3 only:** verify observability is live (logs flowing, metrics emitting, feature flag toggleable) AND that the revert path was sanity-checked (**Rollback-Verified**, GATES.md). Confirm both in the PR description.

**Gate 6 — Followed-up (trigger-based).** Run `/improve-codebase-architecture` against the modules touched **only if any of:** (a) a new public API was added, (b) a new module was created, (c) more than five files of production code were touched (test files do not count toward this threshold), (d) coupling between two previously-unconnected modules was introduced, (e) work touched a module flagged in `docs/invariants.md`. If a trigger fires, create a GH issue per candidate with `--label kind:arch-followup --label prd:<slug>` plus a process-state label (`queued` / `watch-only` / `blocked`) and an optional `severity:*` label. If no trigger fires, gate trivially passes — no issues required.
