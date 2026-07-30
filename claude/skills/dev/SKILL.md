---
name: dev
description: "Runs the local Nebula web and backend stack from the worktrees relevant to the active conversation, falling back to current main checkouts when no feature worktree is in scope. Supplies local env files, starts services in zellij or the background, and verifies health. Use for '/dev' or starting the development stack the user wants to inspect."
---

# `/dev` — Run the development stack in scope

By default, run Nebula web and backend from the worktrees relevant to the active
conversation so the user sees the changes being discussed. Fall back to clean,
current `main` checkouts only when no feature worktree is in scope. Never
silently substitute `main` for an identified feature worktree.

## Status

`/dev status` is read-only. For every repository in scope, fetch remote refs and
report the checked-out SHA, `origin/main` SHA, ahead/behind counts, working-tree
state, and open task PRs targeting main. End with one explicit state: `current`,
`behind`, `diverged`, `dirty`, or `needs-attention`.

Useful manual check:

```bash
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
gh pr list --base main --state open \
  --json number,url,headRefName,isDraft,mergeStateStatus,statusCheckRollup,updatedAt
```

## 0. Resolve the checkouts

- With no repository scope supplied, run `nebula` and `nebula-web` only. Add mobile, desktop, CLI, or other repositories only when the user explicitly asks for them.
- If the user explicitly narrows the repository scope, run only that scope. Include any additional repositories they explicitly name.
- Resolve each repository's intended worktree from the active conversation, current working directory, named PR branches, and associated sibling worktrees. Prefer an explicitly discussed or currently active feature worktree over the root checkout.
- Fetch `origin/main` and update every selected feature branch to latest `main` before launch when the user asks for current-main testing. Preserve its history with the repository's normal merge/rebase policy; never rewrite a published branch without explicit authorization.
- If no feature worktree is identifiable for a repository, use its clean root `main` checkout. Fast-forward it to `origin/main`; if it is dirty or diverged, stop for that repository rather than stashing or resetting.
- Run the remaining steps with the selected checkout as `repo`. Report the exact branch and path chosen for each service before launch.

## 1. Confirm local environment is available

The root checkout normally retains the ignored local environment files. Before
starting anything, list them through Git:

```bash
repo="$(git rev-parse --show-toplevel)"
git -C "$repo" ls-files --others --ignored --exclude-standard -- ':(top).env*'
```

Before every feature-worktree launch, copy every ignored root `.env*` file from
that repository's primary checkout, preserving permissions. Discover files
through Git so `.envrc`, `.env.test`, and future variants are included while
tracked templates are excluded:

```bash
git -C "$root_checkout" ls-files -z --others --ignored --exclude-standard -- ':(top).env*' |
  while IFS= read -r -d '' f; do
    cp -p "$root_checkout/$f" "$repo/$f"
  done
```

Never commit these files. If the root checkout has no required environment,
stop and ask rather than fabricating one.
Run the detected command through `direnv exec .` when the repository has an
`.envrc`; starting without it can produce a superficially running but broken
service.

## 2. Synchronize dependencies

After branch synchronization and before starting any service, install each repository's locked dependencies:

- Nebula: `uv sync`.
- pnpm repositories with a pinned `packageManager`: honor that exact pnpm version. Use `corepack pnpm install --frozen-lockfile` when Corepack is available; otherwise parse the declared version and run `npx --yes pnpm@<version> install --frozen-lockfile`. Use unversioned `pnpm` only when the repository does not pin a version.
- Bun repositories: `bun install --frozen-lockfile`.

Stop an existing dev process before updating its repository or dependencies, then relaunch it. If a locked install would modify a lockfile or fails, stop for that repository and report it; do not silently regenerate dependency state.

## 3. Detect the dev command

Same detection table as `/wt`'s auto-start step — check in this order at the target dir root:

| Detected | Dev command | Note |
|---|---|---|
| `pyproject.toml` with `uvicorn`/`fastapi` in deps AND a `uv run dev` script (check `[project.scripts]`) | `uv run dev` | nebula backend — the documented development command |
| `pyproject.toml` with `uvicorn`/`fastapi`, no packaged script | `uv run uvicorn <module>:app --reload` | module from `[tool.uvicorn]` or `main.py` |
| `Makefile` with a `dev` target | `make dev` | python services wrapping uv/uvicorn |
| `bun.lockb` present, or `package.json` with `"packageManager": "bun@…"` | `bun run dev` if present; otherwise `bun run dev:desktop`; otherwise `bun run start` | nebula-cli, nebula-desktop |
| `package.json` with `expo` dep and a `dev` script | run `pnpm dev` through the exact pinned pnpm version (Corepack, or the `npx` fallback above) | nebula-mobile |
| `package.json` with a `dev` script | run `pnpm dev` through the exact pinned pnpm version (Corepack, or the `npx` fallback above) | Next.js (nebula-web, nebula-docs) |

Check bun before pnpm - some repos carry both lockfiles mid-transition.

For nebula specifically, also confirm local Postgres and Redis are reachable first:

```bash
psql -h 127.0.0.1 -U postgres -d postgres -c '\q'
redis-cli -h 127.0.0.1 ping
```

If either check fails, say so rather than starting a server that will just crash-loop.

## 4. Run it

- When the feature being tested includes an inbound OAuth callback or webhook,
  do not leave `BASE_URL` pointed at staging while running local state and
  storage. Reuse an already-approved stable development tunnel when available;
  otherwise start an HTTPS tunnel to the selected backend, register that exact
  origin with the development app, and launch the backend with `BASE_URL` set
  to it. Verify the public readiness URL before presenting the client. The
  authorization URL, token exchange, and provider manifest must use the same
  callback URI.
- **If `$ZELLIJ` is set**: open a split pane in the current tab so the server runs alongside the shell, rather than blocking it.
  ```bash
  zellij action new-pane --direction down --cwd "$repo" --name dev -- bash -lc '<detected-command>'
  zellij action move-focus up
  ```
- **Otherwise**: run it in a persistent background shell session so it doesn't block the turn, and note the session identifier for later log checks.

Starting the server processes is not enough. Once readiness checks pass, present
each requested client surface:

- Open the Next.js URL in the default browser (`xdg-open` on Linux, `open` on macOS).
- When mobile, desktop, or CLI was explicitly requested, launch and verify that
  surface using its native readiness signal. Do not launch unrequested clients.

## 5. Confirm it's up

Poll each service using its own readiness surface for a few seconds before declaring done:

- Nebula: use `SERVER_PORT` from `.env` when set and default to `4242` (`curl -sf "http://localhost:${SERVER_PORT:-4242}/health/ready"`).
- Next.js: use `curl -sf http://localhost:3000`.
- Expo and desktop: inspect startup output for their ready state and report the URL, QR code, simulator, or application target they expose; do not pretend they use the Next.js health check.
- Browser: confirm the open command succeeded after the Next.js readiness check.
- CLI: confirm the Kitty process/window was launched with the interactive CLI command.

Report every started service and how to inspect its logs. If any repository fails to start or become ready, report the partial stack explicitly rather than declaring `$dev` complete.

## Coordinating paired worktrees

When backend and web changes belong to the same task or PR set, run both matching
feature worktrees together. Point the web worktree at the selected local backend
explicitly; do not leave it pointed at a remote environment or a different local
branch.
