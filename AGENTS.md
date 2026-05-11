# Agent Instructions

Cross-tool instructions for AI coding agents (Claude, Codex, Cursor, etc.) working in this repo. See `CLAUDE.md` for project-specific gotchas; this file holds rules that apply regardless of which agent is running.

**Follow these principles strictly on every task unless explicitly overridden. Bias: caution over speed on any non-trivial work.**

## Core Design Principles

- **KISS, DRY, YAGNI**: Prefer the simplest solution. Write the minimum code that fully solves the requested problem. Never add speculative abstractions or unrequested features.
- **Separation of Concerns + SRP**: Keep UI, logic, data, and config fully separated. Every module, function, or class must have exactly one clear responsibility.
- **Composition over inheritance**: Prefer small, focused, composable pieces.
- **Explicit over implicit**: Make no assumptions. Always validate inputs and data explicitly.
- **Minimal justified abstractions**: Add abstraction only when it clearly reduces duplication or complexity.
- **Readable & maintainable**: Code must be clear, modular, and production-ready. Match the existing codebase style and conventions unless they are genuinely harmful (in which case, flag it).

## Safety & Error Handling

- **Fail fast and loud**: Surface all errors early with clear, actionable messages. Use defensive checks, proper error handling, and error boundaries. Never swallow errors or silently skip work. If anything is uncertain or incomplete, say so explicitly.

## Development Workflow

1. **Think before coding**: State assumptions, ask clarifying questions when uncertain, push back if a simpler approach exists, and stop if confused.
2. **Read before write**: Always explore relevant existing code (exports, callers, utilities, patterns) first.
3. **Research before asking**: When uncertainty or questions surface, first perform research, explore options, and reason through them. Provide clear recommendations with justifications. Only ask the user after presenting well-reasoned options.
4. **Surgical changes**: Modify only what is necessary. Match existing style. Do not refactor unrelated code.
5. **Goal-driven**: Define clear success criteria and verify the result. Do not follow instructions blindly.
6. **Tests verify intent**: Write tests that will actually fail when business logic changes.
7. **Checkpoint often**: Regularly summarize what is done, verified, and still remaining.
8. **Surface conflicts**: When principles or patterns contradict, choose the stronger one (favor recent/tested), explain your choice, and note the trade-off.

## Read the installed Next.js docs before writing Next-specific code

This project uses **Next.js 16.2.6** and **React 19.2.6**, both of which are newer than most agent training data. APIs have shifted (App Router, RSC, caching, `use cache`, route handlers, etc.) and hallucinated code will silently break.

Next.js ships its documentation as markdown inside the installed package. Before writing or modifying anything Next-specific (routing, data fetching, caching, middleware, config, metadata, image, font, server actions, etc.), read the relevant file from:

```
node_modules/next/dist/docs/
```

If `node_modules/` is missing, run `bun install` first. Do not write Next-specific code from memory.

## Package manager

**Bun** — `bun.lock` is committed. Use `bun install`, `bun dev`, `bun run build`, `bun lint`. Do not introduce `npm`, `pnpm`, or `yarn` lockfiles.

## Tailwind v4

There is no `tailwind.config.*`. Theme tokens and `@theme` live in `app/globals.css`. Do not create a JS Tailwind config.

## shadcn/ui

Style is `radix-mira` (see `components.json`). Icon library is **Hugeicons** (`@hugeicons/react`), not lucide. Radix primitives come from the `radix-ui` umbrella package (`import { Slot } from "radix-ui"` then `<Slot.Root>`), **not** individual `@radix-ui/react-*` packages — the granular packages are the obvious default and the wrong choice here. Match this pattern when adding components.

Add components via `bunx shadcn@latest add <name>`.

## Topic-specific docs (read on demand)

- Working with forms → read `docs/forms.md`
- Writing or modifying tests → read `docs/testing.md`

## Project hygiene

- **Line endings: LF.** `.gitattributes` enforces this. Do not introduce CRLF — it will normalize back to LF on commit, but generates noisy diffs in the meantime.
- **Formatting:** `.editorconfig` defines indent (2 spaces), final newline, trim trailing whitespace. Honor it. Don't reformat unrelated files when editing one.
- **Environment variables:** Add new vars to `.env.example` (with a comment explaining purpose) the same moment you reference them in code. Never commit `.env` or `.env.local`.
- **License:** Project is 0BSD. New source files do not need a copyright header.
