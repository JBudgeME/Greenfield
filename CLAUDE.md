@AGENTS.md
@SOP.md

## Workflow

`SOP.md` is binding. Before any work, classify the change and pick a route per `SOP.md` §1:

- Substantive feature → §2.1 (grill → PRD → issues → TDD → review → arch-review)
- Bug fix → §2.2 (`/diagnose` all 6 phases → regression test → review)
- Refactor / architecture → §2.3
- Chore → §2.4
- Trivial fast-path (≤30 LOC, single-file, no public API change, no business-logic change) → §2.5

State the chosen route in the opening response. The SOP overrides individual skill defaults; the user's explicit instructions override the SOP. Skipping a gate requires a written exception per `SOP.md` §6.

## Gotchas

- **ESLint is pinned at v9, not v10.** `eslint-config-next` transitively pulls `eslint-plugin-react` v7, which uses an API removed in ESLint 10. Don't upgrade until the ecosystem catches up.

- **`bunfig.toml` preload order is load-bearing.** `test/happy-dom.ts` must be its own file and listed before `test/setup.ts`. ES module hoisting means if happy-dom registration co-locates with any `@testing-library/*` import, `document.body` is undefined when RTL evaluates and `screen` silently becomes a no-op.

- **`test/matchers.d.ts` starts with `/// <reference types="bun" />` — also load-bearing.** Without it, `next build` fails on test files with `Cannot find module 'bun:test'`. Next's tsc invocation doesn't auto-load `@types/bun`'s module declarations on its own.
