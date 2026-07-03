---
name: open-work
description: List the open actionable work in this repository. Queries GitHub Issues via `gh` and groups them into buckets — Actionable / Queued / Watch-only / Blocked (plus Unknown if any drift is detected). Read-only — does not modify anything. Trigger when the user asks "what's open?", "what should I work on?", "list open work", or invokes `/open-work` directly.
---

# Open Work

List the open actionable items in this repo's GitHub Issues.

## Run

```sh
bun scripts/open-work.ts
```

The script queries `gh issue list --state open --json number,title,labels`, classifies each issue by its triage label (and `kind:*` label where present), and prints a bucketed table grouped by triage state.

## Output

Four sections, one table each. Empty buckets are still printed.

```
## Actionable (N)    — ready-for-agent, ready-for-human, needs-triage, needs-info
## Queued (N)        — queued: waiting on dependency or capacity
## Watch-only (N)    — filed for visibility; trigger condition not yet met
## Blocked (N)       — filed but blocked by an external constraint
```

A `## Unknown (N)` section appears when any issue carries a triage state label not in the canonical 9-label set — that's drift that should be re-triaged.

Items carrying a `severity:high`, `severity:medium`, or `severity:low` label are sorted within their bucket high → medium → low (mainly relevant for `kind:arch-followup` candidates).

## Optional flag

`--from-json <path>` — read pre-fetched gh output from a local JSON file instead of calling `gh` live. Used by integration tests and for offline ad-hoc analysis.

## Related

- `docs/agents/triage-labels.md` — canonical label vocabulary and bucket mapping.
- `docs/agents/issue-tracker.md` — `gh` CLI conventions for this repo.
- SOP §2.1 Gate 5 — when an issue closes (and the parent PRD too, when the last child closes per R1).
