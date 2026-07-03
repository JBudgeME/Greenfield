# CLAUDE.md

@AGENTS.md
@SOP.md

## Workflow

`SOP.md` is binding. Before any work, classify the change and pick a route per `SOP.md` §1:

- Substantive feature → §2.1 (grill → PRD → issues → TDD → review → arch-review)
- Bug fix → §2.2 (`/diagnosing-bugs` all 6 phases → regression test → review)
- Refactor / architecture → §2.3
- Chore → §2.4
- Trivial fast-path (T0 per `SOP.md` §1.1) → §2.5

State the chosen route in the opening response. The SOP overrides individual skill defaults; the user's explicit instructions override the SOP. Skipping a gate requires a written exception per `SOP.md` §6.

## Agent skills

### Issue tracker

GitHub — issues, PRDs, and arch-followups live in this repo's GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical role names used verbatim (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Gotchas
