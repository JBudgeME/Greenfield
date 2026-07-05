---
name: github-issue-cleanup
description: Audit a GitHub repo's open issues and report what could be cleaned up — duplicates, superseded/subsumed issues, staleness, obsolescence, unactionable reports, lifecycle problems (abandoned/zombie/orphaned), and metadata hygiene. Produces a compact, decision-ready summary. READ-ONLY — never closes, comments, labels, edits, or mutates anything. Use whenever the user wants to declutter, triage, dedupe, prune, audit, or "clean up" GitHub issues, or asks what could be closed/merged/relabeled — even if they don't name every check.
---

# GitHub Issue Cleanup

Audit open issues and report **what could be done**, organized for fast decisions. Diagnose only — never act.

## Guardrails

- **Read-only.** Use only read commands (`gh issue list/view`, `gh search`, `gh api` GET). Never close, edit, comment, label, transfer, or delete. If the user later asks to act on the findings, treat that as a separate request and confirm first.
- **No invented facts.** Every flag traces to an observable signal — a date, label, cross-reference, or text in the issue. Mark inferences as low confidence.
- **Compact over complete.** Aim for a digest the user can scan in a minute. Cap detail; summarize the tail.

## Workflow

### 1. Scope

Confirm the repo and default to **open issues only**. If the repo isn't clear from context, ask once. For large repos (>~150 open), proceed but summarize the tail rather than listing everything.

### 2. Collect

Pull all needed fields in one call via the `gh` CLI (fall back to a GitHub connector or `gh api` if unavailable):

```bash
gh issue list --repo OWNER/REPO --state open --limit 500 \
  --json number,title,body,labels,assignees,milestone,createdAt,updatedAt,comments,author,stateReason
```

Dedup and superseded detection need title/body text and cross-references. Fetch large bodies lazily, only for candidates being compared. Record the data pulled and the cutoff date in the report header for reproducibility.

### 3. Analyze

`references/flags.md` is the canonical checklist — six categories, ~28 flags, each with a definition, signal, and disposition. **Load it first and run every flag.**

- **Tag with the exact flag term** (`subsumed`, `cant-reproduce`, `discussion-not-issue`). Don't paraphrase or invent names; anything that fits nothing goes under Notes.
- Walk all six categories per issue. An issue may carry multiple flags — collect them, then let the highest-priority disposition win (order in the reference).
- **Relational flags** (duplicate, superseded, merge) describe groups: build clusters, pick a canonical issue, mark the rest against it.
- **Staleness needs a threshold.** Default: ≥90d inactive = stale, ≥180d = likely-abandoned. State the threshold; offer to rerun with another.
- **Confidence:** exact-title dups and explicit "fixed in #X" refs are high; semantic overlap is lower. Label accordingly.

### 4. Report

Use the format below. Lead with the scorecard, group detail by disposition, and close by restating that nothing changed.

## Report format

Follow this structure. Omit any section with zero hits.

```markdown
# Issue Cleanup — OWNER/REPO

{N} open issues scanned · threshold: stale ≥90d / abandoned ≥180d · {date} · **read-only, no changes made**

## Scorecard — flag frequency

| Category              | Flags (count)                                   |
| --------------------- | ----------------------------------------------- |
| Redundancy/overlap    | duplicate ·3, superseded ·1, merge-candidate ·2 |
| Relevance/validity    | stale ·12, obsolete ·4, already-fixed ·2        |
| Quality/actionability | underspecified ·5, question ·3                  |
| Lifecycle/state       | orphaned ·6, abandoned ·4, zombie ·1            |
| Hygiene/metadata      | unlabeled ·8, stale-link ·2                     |
| Consolidation         | epic-candidate ·1, low-value ·5                 |

**By action:** Close {n} · Merge/supersede {n} · Convert {n} · Split {n} · Needs info {n} · Relabel {n} · Keep+link {n} · Clean {n}

## Clusters (duplicates / superseded / merge)

- **Auth timeout** — canonical **#12**; close #45, #88 as duplicates
- **Dark mode** — merge **#30 + #51** into one tracking issue

## Close ({n})

| #                        | Title               | Flags           | Why              | Conf |
| ------------------------ | ------------------- | --------------- | ---------------- | ---- |
| #45                      | Login hangs         | duplicate       | exact dup of #12 | high |
| #77                      | Fix typo in v1 docs | obsolete, stale | v1 removed       | high |
| _… +3 more (on request)_ |

## Merge / supersede ({n})

…

## Convert to Discussion ({n})

…

## Relabel / hygiene ({n})

| #   | Title        | Flags               | Fix         |
| --- | ------------ | ------------------- | ----------- |
| #61 | Slow startup | orphaned, unlabeled | label: perf |

## Needs info ({n})

…

## Split ({n})

…

## Keep + link ({n})

…

## Notes & low-confidence calls

- #92 may be superseded by #103, but scope differs — worth a human look.
- 14 issues older than 180d carry no other flag; sweep candidates.

---

_Read-only audit. Nothing was closed, edited, labeled, or commented._
```

## Style

- One line per issue; truncate titles to ~40 chars.
- Cap each section at ~10 rows; collapse the rest into `… +N more`.
- Sort by confidence (high first), then issue number.
- If the repo is clean, say so plainly rather than manufacturing flags.

## Going deeper

On request ("why #X?", "show the full list"), expand that slice — pull full body/comments for those issues and explain the signal. Keep the default report compact.
