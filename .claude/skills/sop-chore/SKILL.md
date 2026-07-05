---
name: sop-chore
description: Binding SOP route for chores — dependency upgrades, tool configuration, build scripts, or substantive documentation changes that aren't trivial fast-path. Invoke BEFORE the chore. Surgical change only; no unrelated edits or opportunistic reformatting.
---

Binding gate sequence for the Chore route. **First read `.claude/skills/sop-shared/GATES.md`** — canonical pass criteria, tier depth, escape hatches.

**Gate 1 — Read.** Read every file the chore will touch. For framework upgrades, consult current framework docs per `AGENTS.md` (Library documentation); for version-pinned specifics, the installed package's bundled docs (e.g. `node_modules/next/dist/docs/`) are authoritative.

**Gate 2 — Implemented.** `git checkout -b chore/<slug>`. Surgical change. No unrelated edits, no opportunistic reformatting.

**Gate 3 — Verified.** Run the project's lint command and test suite. Pass: **Tests-Green** (GATES.md).

**Gate 4 — Reviewed and Merged.** `requesting-code-review`. After approval (**Review-Approved**, GATES.md), PR and merge.
