# CLAUDE.md

@AGENTS.md

## Workflow — SOP router

The SOP lives in the `sop-*` skills under `.claude/skills/` (the "SOP kit"); shared gate criteria, tier depth rules, invariant capture, and escape hatches live in `.claude/skills/sop-shared/GATES.md`. The kit is binding on every agent and human contributor.

**Before any work that mutates anything** (repo files or external state — production services, GitHub issues/PRs, deployed infrastructure): classify **Tier** and **Type** below, state both in the opening response, then **invoke the matching `sop-*` skill before mutating anything**. Pure Q&A / exploration / read-only reports take no tier or route — that status expires at the first intended mutation. When in doubt, route up. Misclassification discovered mid-flight: stop, surface, re-route (see GATES.md).

### Tier (blast radius)

| Tier   | Definition                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **T0** | Trivial. All of: ≤50 LOC, ≤3 closely-related files (size bounds apply to code — commits touching only inert prose, i.e. Markdown documentation and `.scratch/` content but **not** agent-instruction files (`CLAUDE.md`, `AGENTS.md`, `.claude/skills/**`, `.claude/hooks/**`), are exempt from both), no public API change, no business-logic change, no touch of any module named in `docs/invariants.md`, `main` CI green. |
| **T1** | Low-risk. Not T0. All of: ≤3 modules touched, no public API addition or breaking change, no schema migration, no auth / security-boundary change, no payment / billing / data-integrity surface.                                                                                                                                                                                                                              |
| **T2** | Substantive. Not T0 or T1. Multi-module work, public API addition, or business-logic change in a non-isolated module. The historical default for "feature."                                                                                                                                                                                                                                                                   |
| **T3** | Production-critical. Touches schema migrations, auth, payments, billing, data integrity, observability infrastructure, **or** any module flagged in `docs/invariants.md`. Tier dominates LOC: a 5-line auth change is T3.                                                                                                                                                                                                     |

T0/T1 require **all** listed criteria; T2/T3 fire on **any single** criterion. Highest applicable tier wins. "Public API" is defined in GATES.md.

### Type → route skill

| Type                 | Trigger                                                                                 | Skill             |
| -------------------- | --------------------------------------------------------------------------------------- | ----------------- |
| Feature              | New behavior; touches business logic, data flow, or any public API                      | `sop-feature`     |
| Bug fix              | Reported defect, regression, or unexpected behavior                                     | `sop-bugfix`      |
| Refactor             | Structural improvement without changing observable behavior                             | `sop-refactor`    |
| Chore                | Dependencies, tooling, config, non-trivial docs                                         | `sop-chore`       |
| Trivial fast-path    | T0 changes only                                                                         | `sop-fastpath`    |
| Restore main CI      | `main`'s most recent CI run is red — **override, preempts all in-flight work**          | `sop-restore-ci`  |
| Post-deploy rollback | Confirmed production regression after merge — **override, preempts all in-flight work** | `sop-rollback`    |
| Kit edit             | Changing the router, any `sop-*` skill, GATES.md, or SOP hooks                          | `sop-maintenance` |

Precedence (user > SOP kit > individual skills) and written gate-skip exceptions: `sop-shared/GATES.md`.

## Repo map

<!-- TODO(template): one line per area — grep this, then glob the path. -->

## Agent skills

### Issue tracker

GitHub — issues, PRDs, and arch-followups live in this repo's GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical role names used verbatim (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Gotchas

Detailed notes live in `.claude/more-info/` — files are created on demand by the `gotcha-capture` skill and read only when their symptom appears. Keep this section a thin `symptom → file` index; never inline the body here.

<!-- TODO(template): add `**symptom keywords** → .claude/more-info/<bucket>.md` lines as gotchas are captured. -->
