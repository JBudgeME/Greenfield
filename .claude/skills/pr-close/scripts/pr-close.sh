#!/usr/bin/env bash
# pr-close — collapse the post-merge ceremony into one command.
# See ../SKILL.md for full docs.

set -euo pipefail

PR="${1:-}"
shift || true
EXPLICIT_ISSUES=("$@")

if [[ -z "${PR}" ]]; then
  echo "usage: pr-close.sh <PR_NUMBER> [ISSUE_NUMBER...]" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

dry() {
  if [[ "${PR_CLOSE_DRY_RUN:-}" == "1" ]]; then
    echo "[dry-run] $*"
    return 0
  fi
  return 1
}

run() {
  if dry "$@"; then return 0; fi
  "$@"
}

# Parse "Closes #N", "Fixes #N", "Resolves #N" from stdin. One number per line.
# `|| true` on BOTH greps: under `set -euo pipefail`, either grep exiting 1 on
# no-match would propagate via pipefail and abort the script before the
# documented orphan-PR branch (exit 6) could run. See #87.
parse_closes() {
  { grep -Eio '(closes|fixes|resolves)[[:space:]]+#[0-9]+' || true; } \
    | { grep -Eo '#[0-9]+' || true; } \
    | tr -d '#' \
    | sort -u
}

# ---------------------------------------------------------------------------
# 1. Validate PR
# ---------------------------------------------------------------------------

echo "==> validating PR #${PR}"
PR_JSON=$(gh pr view "${PR}" --json state,baseRefName,headRefName,isDraft,body,url 2>/dev/null) || {
  echo "ERROR: gh pr view failed. Is gh authenticated and is PR #${PR} reachable?" >&2
  exit 5
}

PR_STATE=$(echo "${PR_JSON}" | jq -r .state)
PR_BASE=$(echo "${PR_JSON}" | jq -r .baseRefName)
PR_HEAD=$(echo "${PR_JSON}" | jq -r .headRefName)
PR_DRAFT=$(echo "${PR_JSON}" | jq -r .isDraft)
PR_URL=$(echo "${PR_JSON}" | jq -r .url)
PR_BODY=$(echo "${PR_JSON}" | jq -r .body)

if [[ "${PR_STATE}" != "OPEN" ]]; then
  echo "ERROR: PR #${PR} is ${PR_STATE}, not OPEN. Refusing to merge." >&2
  exit 2
fi
if [[ "${PR_DRAFT}" == "true" ]]; then
  echo "ERROR: PR #${PR} is a draft. Mark ready for review first." >&2
  exit 2
fi
if [[ "${PR_BASE}" != "main" ]]; then
  echo "ERROR: PR #${PR} targets ${PR_BASE}, not main. Refusing to merge." >&2
  exit 2
fi
if [[ "${PR_HEAD}" == "main" ]]; then
  echo "ERROR: PR #${PR} head is main. Something is very wrong." >&2
  exit 2
fi

echo "    state=${PR_STATE} base=${PR_BASE} head=${PR_HEAD}"

# Locate the worktree that has 'main' checked out. The post-merge ceremony
# (gh pr merge --delete-branch's local cleanup, and the final git pull) needs
# to operate on main, which git refuses if main is checked out in another
# worktree. Pinning the operations to main's worktree avoids the
# "'main' is already used by worktree at X" failure.
#
# If main isn't checked out anywhere, MAIN_DIR falls back to the current
# repo's toplevel and we'll need to `git checkout main` ourselves before
# pull. MAIN_NEEDS_CHECKOUT tracks that case.
MAIN_DIR=$(git worktree list --porcelain 2>/dev/null \
  | awk '/^worktree /{wt=$2} /^branch refs\/heads\/main$/{print wt; exit}')
MAIN_NEEDS_CHECKOUT=0
if [[ -z "${MAIN_DIR}" ]]; then
  MAIN_DIR=$(git rev-parse --show-toplevel)
  MAIN_NEEDS_CHECKOUT=1
fi

# If the current worktree is sitting on the PR's branch, `--delete-branch`
# can't run `git branch -D` against it (the branch is in use). Detach the
# current worktree so the local-ref delete can complete. The merge itself
# is invoked from MAIN_DIR a few lines below, so it won't be tripped up by
# the worktree's checkout state once we've detached.
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# ---------------------------------------------------------------------------
# 2. Determine issues to label (BEFORE merge so we can refuse cleanly)
# ---------------------------------------------------------------------------

if [[ ${#EXPLICIT_ISSUES[@]} -gt 0 ]]; then
  ISSUES=("${EXPLICIT_ISSUES[@]}")
  echo "==> using explicit issue list: ${ISSUES[*]}"
else
  # shellcheck disable=SC2207
  ISSUES=($(echo "${PR_BODY}" | parse_closes))
  if [[ ${#ISSUES[@]} -eq 0 ]]; then
    if [[ "${PR_CLOSE_ALLOW_ORPHAN:-}" == "1" ]]; then
      echo "==> orphan PR allowed via PR_CLOSE_ALLOW_ORPHAN=1; no issues will be labeled"
    else
      echo "ERROR: PR #${PR} has no Closes/Fixes/Resolves directive in body and no explicit issue numbers." >&2
      echo "       Fix one of the following before re-running:" >&2
      echo "         1. Add a 'Closes #N' line to the PR body:" >&2
      echo "              gh pr edit ${PR} --body-file <(gh pr view ${PR} --json body --jq .body; echo; echo 'Closes #N')" >&2
      echo "         2. Pass issue numbers as positional arguments:" >&2
      echo "              pr-close.sh ${PR} <ISSUE_NUMBER>..." >&2
      echo "         3. If the PR genuinely closes no issue, pass PR_CLOSE_ALLOW_ORPHAN=1:" >&2
      echo "              PR_CLOSE_ALLOW_ORPHAN=1 pr-close.sh ${PR}" >&2
      exit 6
    fi
  else
    echo "==> auto-detected issues from PR body: ${ISSUES[*]}"
  fi
fi

# ---------------------------------------------------------------------------
# 3. Pre-detect R1 cascade situation (HITL — require explicit decision)
# ---------------------------------------------------------------------------

# For each closed issue, collect its prd:<slug> label. For each slug, count
# open children that AREN'T in this merge's to-close set. If zero, cascade
# will trigger.

CASCADE_PRDS=()     # prd:<slug> values where cascade will fire
CASCADE_PARENTS=()  # parent kind:prd issue numbers (parallel array)

if [[ ${#ISSUES[@]} -gt 0 ]]; then
  # Build a sed-friendly "to-close set" for filtering.
  TO_CLOSE_SET=$(printf "%s\n" "${ISSUES[@]}" | sort -u)

  # Collect unique prd:<slug> labels across all to-close issues.
  PRD_SLUGS=$(
    for ISSUE in "${ISSUES[@]}"; do
      gh issue view "${ISSUE}" --json labels --jq '.labels[].name' 2>/dev/null \
        | grep -E '^prd:' || true
    done | sort -u
  )

  for SLUG in ${PRD_SLUGS}; do
    # Open children (kind:issue OR kind:arch-followup) with this slug.
    OPEN_CHILDREN_NUMS=$(
      gh issue list --label "${SLUG}" --state open --json number,labels \
        --jq '[.[] | select(.labels[].name | test("^kind:(issue|arch-followup)$")) | .number] | .[]' \
        | sort -u
    )
    # Subtract the ones this merge will close.
    REMAINING=$(comm -23 <(echo "${OPEN_CHILDREN_NUMS}") <(echo "${TO_CLOSE_SET}"))
    REMAINING_COUNT=$(echo "${REMAINING}" | grep -c . || true)

    if [[ "${REMAINING_COUNT}" -eq 0 ]]; then
      PARENT_NUM=$(
        gh issue list --label "${SLUG}" --label kind:prd --state open --json number \
          --jq '.[0].number // empty'
      )
      if [[ -n "${PARENT_NUM}" ]]; then
        CASCADE_PRDS+=("${SLUG}")
        CASCADE_PARENTS+=("${PARENT_NUM}")
      fi
    fi
  done
fi

if [[ ${#CASCADE_PRDS[@]} -gt 0 ]]; then
  if [[ "${PR_CLOSE_CASCADE:-}" == "1" ]]; then
    echo "==> R1 cascade WILL fire (PR_CLOSE_CASCADE=1):"
    for i in "${!CASCADE_PRDS[@]}"; do
      echo "      ${CASCADE_PRDS[$i]} → close parent PRD #${CASCADE_PARENTS[$i]}"
    done
  elif [[ "${PR_CLOSE_NO_CASCADE:-}" == "1" ]]; then
    echo "==> R1 cascade detected but DISABLED (PR_CLOSE_NO_CASCADE=1):"
    for i in "${!CASCADE_PRDS[@]}"; do
      echo "      ${CASCADE_PRDS[$i]} → parent PRD #${CASCADE_PARENTS[$i]} WILL be left open"
    done
  else
    echo "ERROR: R1 cascade situation detected. This merge will close the last open child of:" >&2
    for i in "${!CASCADE_PRDS[@]}"; do
      echo "         ${CASCADE_PRDS[$i]} (parent PRD #${CASCADE_PARENTS[$i]})" >&2
    done
    echo "       Decide explicitly and re-run:" >&2
    echo "         PR_CLOSE_CASCADE=1 pr-close.sh ${PR} ${EXPLICIT_ISSUES[*]:-}    # close the parent PRD too" >&2
    echo "         PR_CLOSE_NO_CASCADE=1 pr-close.sh ${PR} ${EXPLICIT_ISSUES[*]:-} # leave the parent open" >&2
    exit 7
  fi
fi

# ---------------------------------------------------------------------------
# 4. Wait for CI
# ---------------------------------------------------------------------------

if [[ "${PR_CLOSE_SKIP_CI:-}" == "1" ]]; then
  echo "==> CI wait skipped (PR_CLOSE_SKIP_CI=1)"
else
  echo "==> waiting for CI to go green on PR #${PR}"
  if ! run gh pr checks "${PR}" --watch --interval 15 >/dev/null; then
    echo "ERROR: CI failed. Investigate before re-running." >&2
    gh pr checks "${PR}" || true
    exit 3
  fi
  echo "    CI green"
fi

# ---------------------------------------------------------------------------
# 5. Squash-merge with branch delete
# ---------------------------------------------------------------------------

# If we're currently sitting on the PR's branch (likely: ran pr-close from
# the same checkout where the feature work happened), get off it so gh's
# --delete-branch local cleanup can run `git branch -D <pr-head>` without
# being blocked by "branch is checked out". Two cases:
#
#   - Multi-worktree (main is checked out elsewhere → MAIN_NEEDS_CHECKOUT=0):
#     detach this worktree. `gh pr merge` runs in MAIN_DIR (the other
#     worktree, on a real branch), so the merge command itself is fine.
#
#   - Single-worktree (no other worktree has main → MAIN_NEEDS_CHECKOUT=1):
#     `gh pr merge` will run in this worktree (MAIN_DIR == here). gh
#     refuses to operate from a detached HEAD ("could not determine
#     current branch"), so detaching breaks the merge. Switch to main
#     instead — that gets us off the PR branch AND onto a real branch.
#     Pre-empts step 8's checkout.
if [[ "${CURRENT_BRANCH}" == "${PR_HEAD}" ]]; then
  if [[ "${MAIN_NEEDS_CHECKOUT}" == "1" ]]; then
    echo "==> switching current worktree from ${PR_HEAD} to main so --delete-branch can complete"
    run git checkout main
    MAIN_NEEDS_CHECKOUT=0
  else
    echo "==> detaching current worktree from ${PR_HEAD} so --delete-branch can complete"
    run git switch --detach
  fi
fi

echo "==> squash-merging PR #${PR}"
MERGE_OUT=$(mktemp)
if ! (cd "${MAIN_DIR}" && run gh pr merge "${PR}" --squash --delete-branch) >"${MERGE_OUT}" 2>&1; then
  cat "${MERGE_OUT}" >&2
  echo "ERROR: merge failed. If the cause is a merge conflict, rebase manually and re-run." >&2
  rm -f "${MERGE_OUT}"
  exit 4
fi
rm -f "${MERGE_OUT}"

# ---------------------------------------------------------------------------
# 6. Label each closed issue `merged`
# ---------------------------------------------------------------------------

LABELED=()
for ISSUE in "${ISSUES[@]:-}"; do
  [[ -z "${ISSUE}" ]] && continue
  echo "==> labeling issue #${ISSUE} as merged"
  if run gh issue edit "${ISSUE}" --add-label merged >/dev/null; then
    LABELED+=("${ISSUE}")
  else
    echo "    WARN: failed to label #${ISSUE} (already merged-labeled? doesn't exist?)" >&2
  fi
done

# ---------------------------------------------------------------------------
# 7. R1 cascade (only if explicitly opted in)
# ---------------------------------------------------------------------------

CASCADED=()
if [[ "${PR_CLOSE_CASCADE:-}" == "1" && ${#CASCADE_PARENTS[@]} -gt 0 ]]; then
  for PARENT_NUM in "${CASCADE_PARENTS[@]}"; do
    echo "==> R1 cascade: closing parent PRD #${PARENT_NUM}"
    run gh issue close "${PARENT_NUM}" --comment "Last open child closed by ${PR_URL}; closing parent per SOP R1 cascade."
    run gh issue edit "${PARENT_NUM}" --add-label merged >/dev/null
    CASCADED+=("${PARENT_NUM}")
  done
fi

# ---------------------------------------------------------------------------
# 8. Sync local main
# ---------------------------------------------------------------------------

echo "==> syncing local main"
if [[ "${MAIN_NEEDS_CHECKOUT}" == "1" ]]; then
  run git -C "${MAIN_DIR}" checkout main >/dev/null
fi
run git -C "${MAIN_DIR}" pull --ff-only

MAIN_SHA=$(git -C "${MAIN_DIR}" rev-parse --short HEAD)

# ---------------------------------------------------------------------------
# 9. Summary
# ---------------------------------------------------------------------------

echo
echo "=========================================="
echo " PR merged: ${PR_URL}"
echo " main now at: ${MAIN_SHA}"
if [[ ${#LABELED[@]} -gt 0 ]]; then
  echo " issues labeled merged: ${LABELED[*]}"
fi
if [[ ${#CASCADED[@]} -gt 0 ]]; then
  echo " R1 cascaded (parent PRDs closed): ${CASCADED[*]}"
fi
echo "=========================================="
