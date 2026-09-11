---
name: dev
description: "Runs the local Nebula backend plus the desktop app (pointed at that backend) from the worktrees relevant to the active conversation, falling back to current main checkouts when no feature worktree is in scope. Supplies local env files, starts services in tmux or the background, and verifies health. Use for '/dev' or starting the development stack the user wants to inspect."
---

# `/dev` — Run the development stack in scope

By default, run the Nebula backend and the Nebula desktop app (pointed at that
local backend, never web in a browser) from the worktrees relevant to the active
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

- With no repository scope supplied, run `nebula` and `nebula-desktop` only. Do not start nebula-web. Add web (browser), mobile, CLI, or other repositories only when the user explicitly asks for them.
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
- **If `$TMUX` is set**: open a split pane in the current window so the server runs alongside the shell, rather than blocking it.
  ```bash
  tmux split-window -v -c "$repo" bash -lc '<detected-command>'
  tmux select-pane -U
  ```
- **Otherwise**: run it in a persistent background shell session so it doesn't block the turn, and note the session identifier for later log checks.

Starting the server processes is not enough. Once readiness checks pass, present
each requested client surface:

- Desktop (default): launch it per "Desktop against the local backend" below.
- Only when web was explicitly requested: open the Next.js URL in the default browser (`xdg-open` on Linux, `open` on macOS).
- When mobile or CLI was explicitly requested, launch and verify that
  surface using its native readiness signal. Do not launch unrequested clients.

## 5. Confirm it's up

Poll each service using its own readiness surface for a few seconds before declaring done:

- Nebula: use `SERVER_PORT` from `.env` when set and default to `4242` (`curl -sf "http://localhost:${SERVER_PORT:-4242}/health/ready"`).
- Next.js: use `curl -sf http://localhost:3000`.
- Expo and desktop: inspect startup output for their ready state and report the URL, QR code, simulator, or application target they expose; do not pretend they use the Next.js health check.
- Browser: confirm the open command succeeded after the Next.js readiness check.
- CLI: confirm the Kitty process/window was launched with the interactive CLI command.

Report every started service and how to inspect its logs. If any repository fails to start or become ready, report the partial stack explicitly rather than declaring `$dev` complete.

## Desktop against the local backend

Current desktop `main` renders its own UI (no embedded nebula-web bundle), so
only the API base needs pointing. From `nebula-desktop/apps/desktop`, after the
backend readiness check passes:

```bash
NEBULA_API_BASE="http://127.0.0.1:<backend SERVER_PORT>" bun run dev
```

`scripts/dev.ts` gives each worktree its own renderer/CDP ports and an isolated
`NEBULA_HOME` (`<worktree>/.nebula`, seeded from `~/.nebula`), and adds
`--ozone-platform=x11` on Linux. It signs in with the installed app's session
(shared `~/.nebula` auth), which only exists on a database that already has
that user; on a fresh database use the demo account auto-login below. Ready = log line `[main] config: apiBase=http://127.0.0.1:...`
plus `POST /auth/device/token` and `GET /workspaces` returning 200 in the backend log.

If the desktop root checkout is not on a clean `main`, use a detached worktree
(`git worktree add --detach ~/.worktrees/nebula-desktop/<name> origin/main`)
rather than resetting it.

## Backend + Zero on the existing local infra

Infra is the system unit `nebula-compose.service` (docker compose postgres :5432
with `wal_level=logical`, redis :6379). Secrets come from `pass` via `.envrc`, so
run every backend command through `direnv exec .`. Do not use a `dev-cluster`
for this: its Postgres lacks logical WAL and it has no Zero.

Desktop needs Zero, or it sits on "connecting" (`GET /zero/session` 503). `.env`
must carry (stub them if missing; never print the secret):

```
DBOS_DATABASE_URL=postgresql://postgres:postgres@localhost:5432/<db>_dbos   # never the same DB as DATABASE_URL
ZERO_AUTH_SECRET=<openssl rand -hex 32>
ZERO_CACHE_URL=http://localhost:4848
```

If `uv run migrate` fails with "Can't locate revision" the `.env` database is on
another branch's lineage - give the worktree its own `wt_<feature>` +
`wt_<feature>_dbos` databases in its `.env` and migrate those; never reset a
shared one. Then, each in the background:

```bash
direnv exec . uv run migrate
direnv exec . uv run dev        # api+worker :4242, ready = /health/ready
direnv exec . uv run zero       # zero-cache :4848, start after the backend
```

Worktree gotchas:

- A feature worktree has no `.envrc` (ignored, so not checked out): without it
  there are no secrets. Copy every ignored root `.env*` (step 1), then
  `direnv allow .` in the worktree.
- Cloning a shared DB (`createdb -T <db>`) only helps if its `alembic_version`
  is in this branch's graph; otherwise migrate fails with "Can't locate
  revision". Default to fresh empty `wt_<feature>` + `wt_<feature>_dbos`.
- Stop a service by PID or process group (`kill -TERM -- -<pgid>`, found with
  `ps -eo pid,pgid,args | awk '/<worktree>/ && /electron/ && !/awk/'`). Never
  `pkill -f <pattern>` from the tool shell - it matches its own command line
  and kills the shell (exit 144).

`/calls` 500 and `/workspace/presence/room` 503 mean `LIVEKIT_URL` is unset -
voice only, harmless for Task testing.

## Demo account auto-login (default for a fresh database)

A fresh database has no users, and OTP codes go by email. Skip all of it with
the CI test-login route (`src/routers/auth_test_login.py`), which the dev
deploy enables against the same Cognito dev pool the local `.envrc` uses:

1. Append to the worktree's `.env` (never commit), then (re)start the backend:
   ```
   E2E_LOGIN_ENABLED=true
   E2E_LOGIN_EMAIL_DOMAIN=nebula-ci.internal
   ```
   `E2E_LOGIN_SECRET` already comes from `.envrc`. The domain is deliberately
   undeliverable and must match `deploy/overlays/dev/backend-config.env`.
2. Mint a session (response `token` is an `nbs_…` session token; never print it):
   ```bash
   direnv exec . bash -c 'curl -s -X POST localhost:4242/auth/test-login \
     -H "Content-Type: application/json" -H "X-E2E-Login-Secret: $E2E_LOGIN_SECRET" \
     -d "{\"email\":\"demo@nebula-ci.internal\"}"' > "$tmp/login.json"
   ```
3. Clear the only two onboarding gates (`apps/desktop/src/renderer/src/gates/decide-gate.ts`):
   profile needs first/last name + username, workspace needs any workspace.
   Test-login creates neither.
   ```bash
   H="Authorization: Bearer $TOKEN"
   curl -s -X PUT  localhost:4242/user       -H "$H" -H "Content-Type: application/json" \
     -d '{"first_name":"Demo","last_name":"User","username":"demo-<feature>"}'
   curl -s -X POST localhost:4242/workspaces -H "$H" -H "Content-Type: application/json" \
     -d '{"name":"Demo","slug":"demo-<feature>"}'
   ```
   Username and slug must be unique; leave `team_description`/`work_description`
   out or a personalised onboarding run starts.
4. Launch desktop with the token as an env override:
   ```bash
   NEBULA_AUTH_TOKEN="$TOKEN" NEBULA_API_BASE=http://127.0.0.1:4242 bun run dev
   ```
   `NEBULA_AUTH_TOKEN` wins over the on-disk envelope and never writes it
   (`packages/auth/src/internal/token-store.ts`), so the installed app's shared
   sign-in in `~/.nebula` is untouched. Spawned daemons inherit it. It has no
   refresh token - mint a new one when it expires.

Do not write the demo session into the envelope: worktree dev runs share the
installed app's `~/.nebula` auth file (`NEBULA_AUTH_HOME`, #2444) unless
`NEBULA_DEV_NO_SEED=1`. Launch the desktop only after steps 1-3; a launch
before onboarding was satisfied exited silently with code 0 in testing.

## Coordinating paired worktrees

When backend and web changes belong to the same task or PR set, run both matching
feature worktrees together. Point the web worktree at the selected local backend
explicitly; do not leave it pointed at a remote environment or a different local
branch.
