---
name: dev
description: "Runs the complete local Nebula development stack from each repository root on main, while PR branches live in separate worktrees. Auto-detects backend/frontend commands, supplies local env files, starts services in zellij or the background, and verifies health. Use for '/dev', starting the shared development stack, or proving the current integrated environment. Use /wt for a feature-specific server instead."
---

# `/dev` — Run the integrated `main` development stack

`/dev` represents the latest integrated state. For every repository in scope,
run the server from that repository's `main`, never from an individual task
branch. Use `/wt` when the user explicitly wants to exercise a feature branch.

`/dev status` is read-only. For every repository in scope, fetch `origin/main`
and report the local and remote SHAs, ahead/behind counts, current process state,
and readiness result.

## 0. Resolve the main checkout

- With no repository scope supplied, run the complete local Nebula product stack: `nebula`, `nebula-web`, `nebula-mobile`, and `nebula-desktop`. Discover these as sibling checkouts under the current repository's parent directory; report any missing checkout instead of silently omitting it.
- If the user explicitly narrows the repository scope, run only that scope. Include any additional repositories they explicitly name.
- Fetch `origin/main`.
- Treat each repository's primary/root checkout as the stable `main` checkout.
  Keep PR and task branches in separate worktrees; never develop a PR directly
  in the root checkout.
- If a root checkout is clean but on another branch, switch it to local `main`,
  creating it to track `origin/main` when needed. If the root contains
  uncommitted work, diverges, or cannot switch cleanly, stop for that repository
  and report the exact state rather than stashing, resetting, or moving work.
- Fast-forward the root checkout to `origin/main`. If it cannot fast-forward
  cleanly, stop and report the exact state rather than rewriting or resolving
  history speculatively.
- Run the remaining steps with that root checkout as `repo`. A `[repo-relative-subdir]` selects a package inside it, such as `apps/cli`.

## 1. Confirm `.env` is present

The root main checkout should retain its local ignored environment files. Before starting anything:

```bash
repo="$(git rev-parse --show-toplevel)"
for f in .env .env.local .env.development .envrc; do
  [ -f "$repo/$f" ] && printf 'found %s\n' "$f"
done
```

If a repository requires an environment file and its root checkout has none, stop and ask—don't fabricate one. When `/wt` creates a feature worktree, copy the applicable ignored environment files from this root main checkout.

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

- **If `$ZELLIJ` is set**: open a split pane in the current tab so the server runs alongside the shell, rather than blocking it.
  ```bash
  zellij action new-pane --direction down --cwd "$repo" --name dev -- bash -lc '<detected-command>'
  zellij action move-focus up
  ```
- **Otherwise**: run it in a persistent background shell session so it doesn't block the turn, and note the session identifier for later log checks.

Starting the server processes is not enough for the default full-stack invocation. Once their readiness checks pass, present every client surface:

- Open the Next.js URL in the default browser (`xdg-open` on Linux, `open` on macOS).
- Launch the Expo app on an available attached device or emulator. On Linux, start an Android AVD when no device is attached, wait for `adb` readiness, then trigger Expo's Android target. On macOS, prefer the iOS simulator unless the user requests Android. Do not report mobile as running when only Metro is ready.
- Start the desktop app with its `dev:desktop` script and confirm the application process remains running.
- Open the CLI in a detached Kitty window rooted at `nebula-desktop` and run its `cli` script. If Kitty is unavailable, report that surface as blocked instead of substituting another terminal silently.

## 5. Confirm it's up

Poll each service using its own readiness surface for a few seconds before declaring done:

- Nebula: use `SERVER_PORT` from `.env` when set and default to `4242` (`curl -sf "http://localhost:${SERVER_PORT:-4242}/health/ready"`).
- Next.js: use `curl -sf http://localhost:3000`.
- Expo and desktop: inspect startup output for their ready state and report the URL, QR code, simulator, or application target they expose; do not pretend they use the Next.js health check.
- Browser: confirm the open command succeeded after the Next.js readiness check.
- CLI: confirm the Kitty process/window was launched with the interactive CLI command.

Report every started service and how to inspect its logs. If any repository fails to start or become ready, report the partial stack explicitly rather than declaring `$dev` complete.

## When paired with `/wt` on another repo

A common pattern is `/dev` for the integrated main backend plus `/wt` for one
feature-specific frontend. Point the feature worktree at the local main service
explicitly; do not silently leave it pointed at a remote environment.
