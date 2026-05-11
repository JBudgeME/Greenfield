# Bun Quickstart

This project uses [Bun](https://bun.sh) instead of npm / yarn / pnpm. You only need a handful of commands.

## Setup

Install Bun from <https://bun.sh>, then check the version:

```sh
bun --version
```

Inside the project folder:

```sh
bun install
```

This installs everything from `bun.lock` into `node_modules/`.

## Day-to-day

| Command              | What it does                                            |
| -------------------- | ------------------------------------------------------- |
| `bun dev`            | Start the Next.js dev server at <http://localhost:3000> |
| `bun test`           | Run the test suite                                      |
| `bun run test:watch` | Run tests in watch mode                                 |
| `bun lint`           | Run ESLint                                              |
| `bun run build`      | Production build                                        |
| `bun start`          | Serve the production build locally                      |

All of these come from the `scripts` field in `package.json`. Add your own there as the project grows.

## Adding and removing packages

```sh
bun add <pkg>       # runtime dependency
bun add -d <pkg>    # dev dependency (types, tooling, test libs, etc.)
bun remove <pkg>    # uninstall
```

`bun.lock` and `package.json` update automatically. Commit both.

## One-off tools

`bunx` runs a package binary without permanently installing it — used for the shadcn CLI:

```sh
bunx shadcn@latest add button
bunx shadcn@latest add form
```

## Things to know

- **`bun.lock` is committed.** Don't introduce `package-lock.json`, `pnpm-lock.yaml`, or `yarn.lock`.
- **Postinstall scripts are gated.** This project blocks the postinstall steps for `sharp` and `unrs-resolver` by default. If image optimization or the native resolver misbehaves, run once:
  ```sh
  bun pm trust sharp unrs-resolver
  ```
- **`.env` files load automatically.** Use `.env.local` for secrets (it's gitignored). `.env.example` documents which variables exist.

## Help

```sh
bun --help     # list every command
bun upgrade    # update Bun itself
```

Full docs: <https://bun.sh/docs>.
