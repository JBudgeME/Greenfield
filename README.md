<p align="center">
  <img src="app/icon.svg" alt="Greenfield logo" width="96" height="96" />
</p>

<h1 align="center">Greenfield</h1>

<p align="center">
  A ready-to-go starter kit for building a modern website.<br/>
  Everything is pre-wired so you can start building features instead of fiddling with setup.
</p>

---

## Getting started (the short version)

You need one tool installed: **Bun**. It's a faster replacement for Node and npm, and it's the only thing this project uses to manage itself.

1. **Install Bun** (one-time, takes about a minute):
   - **macOS / Linux** — open a terminal and paste:
     ```sh
     curl -fsSL https://bun.sh/install | bash
     ```
   - **Windows** — open PowerShell and paste:
     ```powershell
     powershell -c "irm bun.sh/install.ps1 | iex"
     ```
2. **Open this folder in your terminal** and run:
   ```sh
   bun install
   bun dev
   ```
3. **Open the site in your browser**: <http://localhost:3000>

That's it. The page reloads automatically as you edit files. Start by opening `app/page.tsx` and changing some text.

## What you're getting (in plain English)

A modern website starter with a working homepage, a light/dark theme switcher, popup notifications, and tests — all wired together so you don't have to. Specifically:

- **A web framework** — the engine that runs your pages, handles routing (which URL shows what), and serves images and fonts efficiently. (Next.js)
- **A UI library** — the system that draws what users see and updates the screen when they click things. (React)
- **A styling system** — write styles by adding short class names directly to your HTML, instead of writing separate CSS files. Fast to learn, fast to type. (Tailwind CSS)
- **Pre-built components** — buttons, dialogs, dropdowns, forms, and other building blocks that already look polished and behave correctly. Drop them in and customize. (shadcn/ui)
- **An icon set** — thousands of icons you can use anywhere in your site with a single import. (Hugeicons)
- **Light and dark mode** — a switcher that respects the user's system preference, with no flicker on page load. (next-themes)
- **Popup notifications** — the little toast messages that slide in from the corner to confirm an action or show an error. (Sonner)
- **Forms with validation** — type-safe forms that catch mistakes (missing fields, bad email addresses, etc.) before the data ever leaves the browser. (react-hook-form + zod)
- **Testing built in** — write small tests that prove your code works, and run them in seconds. (`bun:test` + Testing Library)
- **A type checker** — catches typos, missing properties, and a whole class of bugs before you even hit save. (TypeScript)
- **A code linter** — points out style issues and likely mistakes as you write. (ESLint)

You also get sensible defaults for cross-platform development (so Mac and Windows contributors don't generate noisy diffs), a VS Code extension recommendation list, and an `.env.example` template for secrets.

## Pages you can edit right away

These files are already in the project — open any of them and start changing things.

- **Home page** — `app/page.tsx`. The "Hello, world" page you see at <http://localhost:3000>. A **Server Component** that renders a server-side timestamp; the three demo buttons are a small **client island** in `components/demo-buttons.tsx`.
- **About page** — `app/about/page.tsx`. A second route demonstrating how to add pages: drop a folder with a `page.tsx` under `app/`.
- **Shared header / nav** — `components/site-nav.tsx`. Rendered once in the root layout, links every route, and hosts the theme toggle.
- **404 / Not Found page** — `app/not-found.tsx`. Shown when a visitor goes to a URL that doesn't exist.
- **Error page** — `app/error.tsx`. Shown when something on the page crashes. Catches errors so the whole site doesn't break.
- **Loading page** — `app/loading.tsx`. A placeholder that flashes briefly while the next page is being prepared.
- **Site-wide layout** — `app/layout.tsx`. Wraps every page. Put your header, footer, fonts, or anything else that should appear on every page in here.
- **Favicon** — `app/icon.svg`. The little icon shown in the browser tab. Replace this one file and Next.js handles every size automatically.
- **Global styles & theme colors** — `app/globals.css`. The site's color palette (light and dark mode), fonts, and any CSS that applies everywhere.

To **add a new page** (say, an About page at `/about`), create `app/about/page.tsx` with a default-exported React component. That's the whole step.

## License

[0BSD](https://opensource.org/license/0bsd) — see `LICENSE`. Use this template for any purpose, no attribution required. Replace the `[YOUR NAME]` placeholder in `LICENSE` before publishing a derived project.

---

# Technical reference

The rest of this document is the detailed reference: exact package versions, directory conventions, and notes for experienced developers.

## Prerequisites

- **Bun** ≥ 1.2 — install: <https://bun.sh> (`curl -fsSL https://bun.sh/install | bash` on macOS/Linux, `powershell -c "irm bun.sh/install.ps1 | iex"` on Windows)
- Node is **not** required at runtime, but a recent Node-compatible toolchain helps your editor.

## What you get

A running Next.js dev server at <http://localhost:3000> with hot-reload, plus the following dependencies installed:

- **Framework** — `next@16` + `react` / `react-dom` 19 (App Router, RSC).
- **Styling**
  - `tailwindcss@4` + `@tailwindcss/postcss` — utility CSS via the PostCSS plugin. No `tailwind.config.*`; theme tokens live in `app/globals.css`.
  - `tw-animate-css` — animation utilities shadcn dialogs/popovers/dropdowns rely on (Tailwind v4 dropped its own).
  - `class-variance-authority` + `clsx` + `tailwind-merge` — variant-driven components and conflict-free class merging. `lib/utils.ts` exposes `cn()`.
- **UI primitives**
  - `radix-ui` — umbrella package (`import { Slot } from "radix-ui"` → `<Slot.Root>`), not individual `@radix-ui/react-*`.
  - `shadcn` — CLI; `bunx shadcn@latest add <name>` drops components into `components/ui/`.
  - `@hugeicons/react` + `@hugeicons/core-free-icons` — icon library (replaces lucide-react default; wired up in `components.json`).
  - `next-themes` — light / dark / system theme switching.
  - `sonner` — toast notifications. Drop `<Toaster />` near the root and call `toast(...)` anywhere.
- **Forms**
  - `react-hook-form` — form state with minimal re-renders.
  - `zod` — schema + inferred TS types.
  - `@hookform/resolvers` — bridges `zod` into `react-hook-form`. Pair with `bunx shadcn@latest add form` for the matching shadcn primitive.
- **App Router scaffolds** — `app/not-found.tsx` (custom 404), `app/error.tsx` (error boundary), `app/loading.tsx` (Suspense fallback), `app/icon.svg` (favicon — Next auto-serves at all sizes), `app/robots.ts` + `app/sitemap.ts` (SEO file conventions wired off `NEXT_PUBLIC_SITE_URL`).
- **Testing** — `bun:test` (built-in, ~5–10× faster than vitest) with `happy-dom` for the DOM and `@testing-library/react` + `@testing-library/user-event` + `@testing-library/jest-dom` for component tests. Setup files in `test/`, wired via `bunfig.toml`. Sample tests in `lib/utils.test.ts` and `components/ui/button.test.tsx`.
- **Tooling** — `typescript@6`, `eslint@9` + `eslint-config-next` + `eslint-config-prettier`, `prettier` + `prettier-plugin-tailwindcss` (sorts Tailwind classes on format), `@next/bundle-analyzer` (opt-in via `ANALYZE=true`), `simple-git-hooks` + `lint-staged` (pre-commit runs Prettier + `eslint --fix` on staged files), ambient `@types/*` and `@types/bun`.
- **CI** — `.github/workflows/ci.yml` runs `format:check`, `lint`, `build`, and `test` on every push and PR to `main` using `oven-sh/setup-bun@v2` and `bun install --frozen-lockfile`.

**Postinstall gate** — `sharp` and `unrs-resolver` skip their native postinstall scripts by default. If image optimization or the native resolver misbehaves, opt in with:

```bash
bun pm trust sharp unrs-resolver
```

## Scripts

| Command                | What it does                                                             |
| ---------------------- | ------------------------------------------------------------------------ |
| `bun install`          | Install dependencies (uses committed `bun.lock`)                         |
| `bun dev`              | Next.js dev server                                                       |
| `bun run build`        | Production build                                                         |
| `bun start`            | Serve the production build                                               |
| `bun lint`             | ESLint (flat config)                                                     |
| `bun run format`       | Format the whole tree with Prettier (+ Tailwind class sort)              |
| `bun run format:check` | Verify formatting without writing — what CI runs                         |
| `bun test`             | Run the test suite (`bun:test` + happy-dom + Testing Library)            |
| `bun run test:watch`   | Tests in watch mode                                                      |
| `bun run analyze`      | Production build with `@next/bundle-analyzer` open (sets `ANALYZE=true`) |

## Conventions worth knowing

- **`bun.lock` is committed and in sync with `package.json`.** Don't delete it; don't introduce `package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`. `bun install --frozen-lockfile` works from a fresh clone — safe for CI.
- **shadcn style is `radix-mira`** (see `components.json`), with `baseColor: neutral` and RSC enabled.
- **Cross-platform hygiene.** `.gitattributes` forces LF line endings on all text files and `.editorconfig` standardizes indentation and whitespace, so Windows and Mac contributors stay in sync. VS Code users will be prompted to install the recommended extensions in `.vscode/extensions.json` (Tailwind, ESLint, EditorConfig, Bun).
- **Environment variables.** Copy `.env.example` to `.env.local` and fill in values. When you add a new env var to the project, document it in `.env.example` so others know it exists.
- For deeper conventions and AI-agent rules see `AGENTS.md` and `CLAUDE.md`. Topic-specific guides (forms, testing) live in `docs/` and are loaded on demand. For a wider Bun command reference see `BUN-USERGUIDE.md`.
