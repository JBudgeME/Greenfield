@AGENTS.md

## Gotchas

- **ESLint is pinned at v9, not v10.** `eslint-config-next` transitively pulls `eslint-plugin-react` v7, which uses an API removed in ESLint 10. Don't upgrade until the ecosystem catches up.

- **`bunfig.toml` preload order is load-bearing.** `test/happy-dom.ts` must be its own file and listed before `test/setup.ts`. ES module hoisting means if happy-dom registration co-locates with any `@testing-library/*` import, `document.body` is undefined when RTL evaluates and `screen` silently becomes a no-op.

- **`test/matchers.d.ts` starts with `/// <reference types="bun" />` — also load-bearing.** Without it, `next build` fails on test files with `Cannot find module 'bun:test'`. Next's tsc invocation doesn't auto-load `@types/bun`'s module declarations on its own.
