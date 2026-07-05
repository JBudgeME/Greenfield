---
name: gotcha-capture
description: Capture footguns, runbook facts, and load-bearing properties uncovered during a session into the repo's docs, routed to the right place. Use at the end of a working session, or after a debugging session confirms a non-obvious footgun worth writing down. Also owns audit mode — use when asked to audit, prune, or compress the gotcha docs, or when capture touches a file with stale entries.
---

# Gotcha capture

Record what the session confirmed, so the next agent doesn't relearn it. Docs only — no code, merge, or deploy.

## Workflow

1. **Scan** the session for anything newly _confirmed_ and not yet written down: a footgun, an environment quirk, an operational step, or a property other modules now rely on. Skip anything unconfirmed.
2. **Check** it isn't already captured: `grep -ril "<symptom keyword>" CLAUDE.md .claude/more-info docs/runbooks docs/invariants.md`.
3. **Route** each finding:
   - **Footgun / quirk** → append the body to the matching existing `.claude/more-info/` bucket (e.g. `build-and-dev`, `testing-and-ci`, `conventions`; create the bucket file on first use). Add a new `signature → file` pointer to CLAUDE.md's Gotchas section _only_ if no bucket fits. CLAUDE.md stays a thin index, never the body.
   - **Operational step** → a `docs/runbooks/` runbook.
   - **Property other modules rely on** → `docs/invariants.md` with a `**Modules:**` line and a back-link comment in each upholding module (invariant-capture rule, `.claude/skills/sop-shared/GATES.md`).
4. **Verify** the symptom is greppable and points to the right file.

## Audit mode

Capture only adds; entropy accumulates until something audits it. Run on request ("audit the gotchas"), or when capture touches a file with entries you can see are stale.

1. **Verify** every mechanically checkable claim in the target file(s) against the repo: file paths, ports, script names, package fields, flags, policy statements. Batch the checks; don't trust prose.
2. **Route-check both directions**: every entry has a symptom keyword on its CLAUDE.md index line (an unkeyed entry is unreachable — the file only loads when its symptom matches), and every index keyword is still true.
3. **Classify** each entry: **valid** (keep; compress if the idea survives in fewer words), **drifted** (correct it), or **superseded-by-fix** (a small code fix kills the entry permanently — prefer fixing and deleting over polishing; the fix routes through its own SOP procedure).
4. **Decide per item with the user** before editing, then land it: docs via T0 fast-path, code fixes via their own branch/PR.

## Stop

- **Done** — every confirmed finding is captured.
- **No-op** — the session surfaced nothing new.
- **Blocked** — a finding can't be confirmed or you can't tell which doc owns it: leave it out with a note, don't guess.
