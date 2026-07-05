---
name: open-work
description: List the open actionable work in this repository. Queries GitHub Issues via `gh` and groups them into buckets — Actionable / Queued / Watch-only / Blocked (plus Unknown if any drift is detected). Read-only — does not modify anything. Trigger when the user asks "what's open?", "what should I work on?", "list open work", or invokes `/open-work` directly.
---

# Open Work

List the open actionable items in this repo's GitHub Issues.

Query `gh issue list --state open --limit 500 --json number,title,labels,body` — one call; bodies are included so blockers parse in-memory (no per-issue fetch). `--limit` is required: `gh` silently caps at 30 otherwise. Classify each issue by its triage label (and `kind:*` label where present), and print a bucketed table grouped by triage state.

## Output

Four sections, one table each. Empty buckets are still printed.

```
## Actionable (N)    — ready-for-agent, ready-for-human, needs-triage, needs-info
## Queued (N)        — queued: waiting on dependency or capacity
## Watch-only (N)    — filed for visibility; trigger condition not yet met
## Blocked (N)       — filed but blocked by an external constraint
```

A `## Unknown (N)` section appears when any issue carries a triage state label not in the canonical 9-label set — that's drift that should be re-triaged.

Items carrying a `severity:high`, `severity:medium`, or `severity:low` label are sorted within their bucket high → medium → low, with no-severity items last (mainly relevant for `kind:arch-followup` candidates).

## Dependency suffix

From each issue's `body` (already in the list payload above — no extra calls), parse the `## Blocked by` section to extract referenced issue numbers (`#N` tokens). Cross-reference against the open-issue set: closed dependencies are silent (they don't gate work).

Append `← #N,#M,…` to the title of each issue with one or more **open** blockers. Issues with no open blockers get no suffix — they pop visually as grabbable right now.

Parse the bodies from the one payload — zero extra `gh` calls (the old per-issue `gh issue view` loop is gone):

```sh
# Hold the one payload in a variable (gh can't be re-piped without re-fetching); never a repo-root temp file.
OW=$(gh issue list --state open --limit 500 --json number,title,labels,body)
# Per issue, emit "<number> #<blocker>…" from the lines under its "## Blocked by" heading:
jq -c '.[] | [.number, (.body // "")]' <<<"$OW" | while read -r row; do
  n=$(jq -r '.[0]' <<<"$row")
  jq -r '.[1]' <<<"$row" \
    | awk '/^## Blocked by/{f=1;next} /^## /&&f{f=0} f' \
    | grep -oE '#[0-9]+' | sed "s/^/$n /"
done
```

Filter the extracted `#N` list to those still open, then format as `← #N,#M` joined by commas (no space between). For the rare issue with no blockers at all, or where every blocker is closed, omit the suffix entirely.

When the suffix would be very long (≥6 open blockers — typical for cutover / go-live slices that depend on everything), still list them all; the visual weight is meaningful signal.

## Related

- `docs/agents/triage-labels.md` — canonical label vocabulary and bucket mapping.
- `docs/agents/issue-tracker.md` — `gh` CLI conventions for this repo.
- `sop-feature` Gate 5 — when an issue closes (and the parent PRD too, when the last child closes per R1).
