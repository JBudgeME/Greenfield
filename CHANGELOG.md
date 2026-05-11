# Changelog

All notable changes to this template are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/).

## [0.1.0] - 2026-05-11

Initial template release.

### Added

- Added Next.js 16.2.6 with the App Router and React 19.2.6.
- Added Bun ≥ 1.2 as the package manager with `bun.lock` committed.
- Added Tailwind v4 via `@tailwindcss/postcss` with theme tokens in `app/globals.css` and no `tailwind.config.*`.
- Added `tw-animate-css` to provide the animation utilities required by shadcn dialogs, popovers, and dropdowns.
- Added `class-variance-authority`, `clsx`, and `tailwind-merge` with a `cn()` helper in `lib/utils.ts`.
- Added shadcn/ui configured in `components.json` with the `radix-mira` style and `baseColor: neutral`.
- Added the `radix-ui` umbrella package as the source of Radix primitives instead of individual `@radix-ui/react-*` packages.
- Added Hugeicons (`@hugeicons/react` + `@hugeicons/core-free-icons`) as the icon library in place of lucide-react.
- Added `next-themes` for light, dark, and system theme switching without a flash on page load.
- Added `sonner` for toast notifications with `<Toaster />` mounted in `app/layout.tsx`.
- Added `react-hook-form`, `zod`, and `@hookform/resolvers/zod` for type-safe form state and validation.
- Added App Router scaffolds at `app/not-found.tsx`, `app/error.tsx`, `app/loading.tsx`, and `app/icon.svg`.
- Added `bun:test` with `happy-dom`, `@testing-library/react`, `@testing-library/user-event`, and `@testing-library/jest-dom`, with preload order pinned in `bunfig.toml`.
- Added sample tests at `lib/utils.test.ts` and `components/ui/button.test.tsx` demonstrating unit and component patterns.
- Added TypeScript 6 and ESLint 9 with `eslint-config-next`, pinned at v9 because v10 breaks `eslint-plugin-react`.
- Added `.gitattributes` enforcing LF line endings and `.editorconfig` standardizing whitespace for cross-platform contributors.
- Added `.vscode/extensions.json` recommending the Tailwind, ESLint, EditorConfig, and Bun extensions.
- Added `.env.example` as the documented template for environment variables.
- Added `AGENTS.md` for cross-tool agent rules, imported into `CLAUDE.md` for project-specific gotchas.
- Added `docs/forms.md` and `docs/testing.md` as on-demand references for agents working on those topics.
- Added the 0BSD license in `LICENSE`.

---

<!--
TEMPLATE FOR NEW ENTRIES — copy the block below, fill it in, and place it directly under the "# Changelog" header (newest version on top). Delete sections you don't need; do not include empty ones.

Version rules (SemVer):
- MAJOR (X.0.0) — breaking changes (anything that forces consumers to update their code)
- MINOR (0.X.0) — new functionality, backwards-compatible
- PATCH (0.0.X) — bug fixes only, backwards-compatible

Section order (Keep a Changelog) — use only the ones that apply, in this order:
- Added — new features
- Changed — changes to existing behavior
- Deprecated — soon-to-be-removed features
- Removed — features removed in this release
- Fixed — bug fixes
- Security — vulnerabilities patched

Date format: YYYY-MM-DD (ISO 8601), the actual release date.

Each bullet: one sentence, past tense, user-facing language. Reference packages/files in backticks. If a change is breaking, prefix the bullet with **BREAKING:**.

## [X.Y.Z] - YYYY-MM-DD

### Added

- Short description of what was added.

### Changed

- Short description of what changed.

### Deprecated

- Short description of what's now deprecated and what to use instead.

### Removed

- Short description of what was removed.

### Fixed

- Short description of the bug fixed.

### Security

- Short description of the vulnerability patched.
-->

