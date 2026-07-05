# Flag Taxonomy

Canonical checklist and source of truth for flag names. **Tag each issue with the exact term** (e.g. `subsumed`, `cant-reproduce`, `discussion-not-issue`); don't invent names — anything that fits nothing goes under Notes.

Each flag has a **signal** (how to detect it, read-only) and a **disposition** (what could be done). An issue may carry several; resolve to one using the priority order at the bottom.

Confidence: **high** = objective signal (exact match, cross-ref, date, label state); **med** = inference from text; **low** = judgment call — defer to the human.

---

## Redundancy / overlap (relational — build clusters)

| Flag                | Definition                                                   | Signal                                                      | Disposition                   |
| ------------------- | ------------------------------------------------------------ | ----------------------------------------------------------- | ----------------------------- |
| **duplicate**       | Exact restatement of another issue                           | Near-identical title; body describes the same repro/feature | Close as dup of canonical     |
| **superseded**      | Replaced by a newer issue/approach                           | A newer issue reframes or replaces it, often referencing it | Close in favor of newer; link |
| **subsumed**        | Folded into a broader epic or parent issue (a.k.a. absorbed) | Fully contained within a larger tracked item                | Close, fold into parent       |
| **overlapping**     | Shares scope but isn't identical (partial-duplicate)         | Overlaps another issue; neither fully contains the other    | Keep both, cross-link         |
| **split-candidate** | One issue that's really several                              | Bundles multiple distinct problems/asks                     | Split into separate issues    |
| **merge-candidate** | Several issues that are really one                           | Cluster of small issues = one unit of work                  | Merge into one issue          |

**Cluster method:** group related issues, pick a canonical (oldest with most context, or the one with an active assignee/milestone), mark the rest relative to it. Report clusters as groups, not scattered rows.

## Relevance / validity

| Flag               | Definition                                             | Signal                                                     | Disposition                              |
| ------------------ | ------------------------------------------------------ | ---------------------------------------------------------- | ---------------------------------------- |
| **stale**          | No activity past a threshold                           | Last update older than the stale threshold                 | Sweep candidate; close if also low-value |
| **obsolete**       | Tech, dependency, or feature it referenced is gone     | References a removed feature, dropped dep, old version     | Close                                    |
| **out-of-scope**   | No longer fits the project's direction                 | Conflicts with current roadmap/direction                   | Close or convert                         |
| **wontfix**        | Intended behavior, not a bug (by-design)               | Describes designed behavior                                | Close as wontfix                         |
| **cant-reproduce** | Not reproducible                                       | Repro steps fail or absent, issue is aging                 | Request info, else close                 |
| **already-fixed**  | Fixed incidentally, never closed (resolved-in-passing) | Works now / a merged PR addressed it but issue stayed open | Close, link the fix                      |
| **invalid**        | Based on a misunderstanding or user error              | Wrong assumption, user error, wrong repo                   | Close as invalid                         |

## Quality / actionability

| Flag                       | Definition                              | Signal                                       | Disposition                       |
| -------------------------- | --------------------------------------- | -------------------------------------------- | --------------------------------- |
| **underspecified**         | Not enough info to act (needs-repro)    | No repro, no context, can't act              | Request info                      |
| **needs-info**             | Blocked on reporter (awaiting-response) | Maintainer asked a question, no reply        | Request info; close if abandoned  |
| **no-acceptance-criteria** | Can't tell when it's "done"             | No definition of done                        | Request criteria / keep + clarify |
| **vague**                  | A wish, not a work item (aspirational)  | Aspirational, not a concrete task            | Convert to discussion or refine   |
| **question**               | Belongs in Discussions, not Issues      | Support/usage question, not a defect/feature | Convert to Discussion             |

## Lifecycle / state

| Flag          | Definition                                              | Signal                                                 | Disposition                   |
| ------------- | ------------------------------------------------------- | ------------------------------------------------------ | ----------------------------- |
| **abandoned** | Assignee gone, no follow-through                        | Past abandoned threshold; assignee inactive/unassigned | Close or unassign + relabel   |
| **blocked**   | Waiting on another issue or external factor (dependent) | References a blocker issue/PR/external dependency      | Keep + link the blocker       |
| **wontstart** | Acknowledged but parked indefinitely (deprioritized)    | Accepted yet shelved with no plan to start             | Keep + label parked, or close |
| **zombie**    | Closed-then-reopened with no resolution                 | Reopened with no new activity or resolution            | Re-triage; close or revive    |
| **orphaned**  | No owner, no labels, no milestone                       | Missing all of: assignee, labels, milestone            | Relabel / assign              |

## Hygiene / metadata

| Flag                  | Definition                                             | Signal                                           | Disposition           |
| --------------------- | ------------------------------------------------------ | ------------------------------------------------ | --------------------- |
| **mislabeled**        | Wrong or missing labels (unlabeled)                    | Labels don't match type/area, or none at all     | Relabel               |
| **wrong-type**        | Feature filed as bug, support req filed as issue, etc. | Type mismatch vs. content                        | Relabel / convert     |
| **missing-milestone** | No milestone / priority where the repo uses them       | Milestone or priority absent                     | Add metadata          |
| **stale-link**        | References a dead PR, branch, or external doc          | Body links to a 404 / deleted branch / moved URL | Note; update or close |

## Consolidation

| Flag                     | Definition                                            | Signal                                      | Disposition            |
| ------------------------ | ----------------------------------------------------- | ------------------------------------------- | ---------------------- |
| **epic-candidate**       | Cluster of small issues that want a parent (tracking) | Several small related issues with no parent | Keep + propose epic    |
| **low-value**            | Real but nice-to-have                                 | Marginal; unlikely to ever be prioritized   | Close or label backlog |
| **discussion-not-issue** | Belongs elsewhere                                     | Open-ended ideation, polls, Q&A             | Convert to Discussion  |

---

## Disposition priority (when an issue carries multiple flags)

Resolve to the **most decisive** action so each issue appears once in the report:

1. **Close** — duplicate, obsolete, already-fixed, invalid, wontfix
2. **Merge / supersede** — subsumed, merge-candidate, superseded
3. **Convert** — question, discussion-not-issue
4. **Split** — split-candidate
5. **Needs info** — underspecified, needs-info, cant-reproduce, no-acceptance-criteria
6. **Relabel / hygiene** — mislabeled, wrong-type, orphaned, missing-milestone, stale-link
7. **Keep + link** — blocked, overlapping, wontstart, epic-candidate, low-value

**stale** and **abandoned** are modifiers: they strengthen the case for Close when stacked on a low-value or unactionable issue, but on their own (a healthy issue that's just quiet) they belong under Notes as sweep candidates, not auto-close.
