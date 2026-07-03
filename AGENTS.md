# Agent Instructions

Cross-tool instructions for AI coding agents (Claude, Codex, Cursor, etc.) working in this repo. See `CLAUDE.md` for project-specific gotchas; this file holds rules that apply regardless of which agent is running.

**Follow these principles strictly on every task unless explicitly overridden. Bias: caution over speed on any non-trivial work.**

**Engineering**

- KISS, DRY, YAGNI — simplest solution that fully solves the request; no speculative abstractions or unrequested features.
- Separation of concerns + SRP — UI, logic, data, and config stay separate; each module/function/class has one clear responsibility.
- Composition over inheritance — small, focused, composable pieces.
- Explicit over implicit — validate inputs and data; never assume silently.
- Minimal justified abstractions — abstract only when it clearly reduces duplication or complexity.
- Readable and maintainable — match existing codebase style and conventions; flag harmful ones.

**Safety and error handling**

- Fail fast and loud — surface errors early with actionable messages; never swallow errors or silently skip work.
- State uncertainty explicitly whenever anything is incomplete or unclear.

**Development workflow**

- Think before coding — state assumptions, push back if a simpler approach exists, stop if confused.
- Read before write — explore relevant existing code (exports, callers, utilities, patterns) before modifying.
- Research before asking — present well-reasoned options with recommendations before asking the user.
- Surgical changes — modify only what's needed; never refactor unrelated code.
- Goal-driven — define success criteria and verify the result.
- Tests verify intent — write tests that fail when business logic changes.
- Checkpoint often — summarize what is done, verified, and remaining.
- Surface conflicts — when principles contradict, choose the stronger one, explain why, note the trade-off.

**Context management**

- Authoritative sources of truth — PRD for scope, `docs/invariants.md` for system properties, `docs/adr/` for architectural decisions, `CONTEXT.md` for terminology. Do not reconstruct from conversation memory — re-read.
- Subagents are the right tool for high-volume exploration: dispatch with a tight prompt, read the summary, do not pull raw output into the main context.

## GitHub label setup (one-time per fresh clone)

Issues live in GitHub. If the canonical labels do not yet exist in the repo, run:

```sh
bash scripts/setup-github-labels.sh
```

Idempotent — safe to re-run.
