---
name: pr-close
description: Collapse the post-merge ceremony into one command for this repo — wait for CI, squash-merge with branch delete, label closed issues `merged`, surface R1 cascade decisions for explicit human approval, and sync local `main`. Use when the user says "merge PR N", "close out PR N", "ship PR N", or any time after a PR's review is approved and it's ready to land.
---

# pr-close

## Quick start

```bash
.claude/skills/pr-close/scripts/pr-close.sh <PR_NUMBER> [ISSUE_NUMBER...]
```

Common invocations:

```bash
# Auto-detect issues from "Closes #N" / "Fixes #N" / "Resolves #N" in PR body
.claude/skills/pr-close/scripts/pr-close.sh 52

# Explicit issue list (overrides auto-detection)
.claude/skills/pr-close/scripts/pr-close.sh 56 45 46 48

# Cascade decision is HITL — script halts pre-merge with instructions if
# cascade would fire. Re-run with the explicit flag:
PR_CLOSE_CASCADE=1    .claude/skills/pr-close/scripts/pr-close.sh 60 39    # close parent PRD too
PR_CLOSE_NO_CASCADE=1 .claude/skills/pr-close/scripts/pr-close.sh 60 39    # leave parent open

# Skip CI wait (already verified green)
PR_CLOSE_SKIP_CI=1 .claude/skills/pr-close/scripts/pr-close.sh 52
```

## What it does, in order

1. **Validate PR** — refuses if state ≠ OPEN, draft, base ≠ `main`, or head == `main`.
2. **Determine issues to label.** Explicit args win; otherwise parse PR body for `Closes/Fixes/Resolves #N`. If neither produces an issue list, **refuse** with instructions to add the directive, pass explicit args, or set `PR_CLOSE_ALLOW_ORPHAN=1` (genuine no-issue PRs).
3. **Pre-detect R1 cascade.** For each `prd:<slug>` label on the to-close issues, count open children that aren't in this merge. If any PRD would drop to zero open children, **refuse** with two re-run commands (close parent / leave open). The cascade is HITL — closing a PRD is a meaningful event and shouldn't fire silently.
4. **Wait for CI green.** `gh pr checks --watch`. Skippable via `PR_CLOSE_SKIP_CI=1`.
5. **Squash-merge with branch delete.**
6. **Label each closed issue `merged`.** GitHub auto-closes the issues via the PR's `Closes` directives — this step only applies the label.
7. **R1 cascade (only if `PR_CLOSE_CASCADE=1`).** Close the parent PRD with a back-link comment and the `merged` label.
8. **Sync local main.** `git checkout main && git pull --ff-only`.
9. **Print summary.** PR URL, merged commit SHA, issues labeled, cascade closures.

## Refusal modes (script exits non-zero)

| Exit | Cause                          | Action                                                                                                      |
| ---- | ------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| 2    | PR state / base / draft        | Fix the PR (mark ready, retarget to `main`, etc.) and re-run.                                               |
| 3    | CI failing                     | Investigate the failed check, fix the underlying issue, wait for CI to go green, re-run.                    |
| 4    | Merge conflict at squash       | `git fetch && git rebase origin/main` on the PR branch, push, re-run.                                       |
| 5    | `gh` not authenticated         | `gh auth login`, re-run.                                                                                    |
| 6    | Orphan PR (no issues to label) | Add `Closes #N` to PR body OR pass issues as args OR `PR_CLOSE_ALLOW_ORPHAN=1`, re-run.                     |
| 7    | R1 cascade situation detected  | Decide explicitly: re-run with `PR_CLOSE_CASCADE=1` (close parent) or `PR_CLOSE_NO_CASCADE=1` (leave open). |

The script does **not** retry on its own. Don't blindly re-run after a refusal — read the message and address the root cause.

## Environment overrides

- `PR_CLOSE_SKIP_CI=1` — skip the CI-wait step.
- `PR_CLOSE_CASCADE=1` — enable R1 cascade close. Required when cascade is detected.
- `PR_CLOSE_NO_CASCADE=1` — disable R1 cascade. Required when cascade is detected if you want to keep the parent open.
- `PR_CLOSE_ALLOW_ORPHAN=1` — allow merge with zero issues to label.
- `PR_CLOSE_DRY_RUN=1` — print actions without making any writes.

## Worktree-aware

Safe to run from a git worktree (e.g. `.claude/worktrees/<slug>/`), including when the PR's branch is checked out IN that worktree:

- The script detects which worktree has `main` checked out via `git worktree list --porcelain` and pins the merge + final pull to that directory. Avoids `'main' is already used by worktree at X` when `main` is held by the parent repo while you run from a feature worktree.
- If the current worktree is sitting on the PR's branch, the script detaches HEAD before `gh pr merge --delete-branch` so the local-ref delete (`git branch -D <pr-head>`) doesn't trip over "branch is checked out". After the merge the worktree ends up at a detached HEAD on the squash-merged commit's pre-squash tip — fine to leave there or remove via `ExitWorktree`.

## Why this exists

The post-merge ceremony for this repo runs five+ commands every time: `gh pr checks --watch`, `gh pr merge --squash --delete-branch`, `gh issue edit --add-label merged` per issue, R1 cascade check + close, `git checkout main && git pull`. The cycle ran 5 times in one session (#52–#56), mechanical and error-prone. The script enforces SOP gates (CI green, base = `main`, every PR labels at least one issue) and surfaces the cascade decision instead of letting it happen silently.

See also: `sop-feature` Gate 5, `sop-refactor` Gate 6, `sop-chore` Gate 4 — all converge on this post-merge ceremony.
