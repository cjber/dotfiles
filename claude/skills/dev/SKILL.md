---
name: dev
description: "Starts the current repo's local dev server (backend or frontend) in the CURRENT checkout/worktree - no new worktree created. Auto-detects the run command (uv run api / uvicorn for python backends, pnpm dev / bun dev for JS frontends), copies .env from the primary checkout if missing, and opens it in a zellij split (or background bash) so you can exercise the app live. Use when the user wants to 'spin up the backend', 'start the dev server', 'run this locally', or '/dev'. For a NEW isolated worktree use /wt instead (its own auto-start-dev-server step supersedes this)."
argument-hint: "[repo-relative-subdir]"
---

# `/dev` — Start the current repo's dev server, in place

Spin up whatever's already checked out — the current repo dir, worktree, or `[repo-relative-subdir]` if the user names a specific app/package in a monorepo (e.g. nebula-desktop's `apps/cli`). This never creates a worktree; for that, use `/wt` (its "Auto-start dev server" step already does this as part of creating one).

## 1. Confirm `.env` is present

Worktrees are git-ignored for `.env`, so a fresh worktree boots with none. Before starting anything:

```bash
repo="$(git rev-parse --show-toplevel)"
if [ ! -f "$repo/.env" ]; then
  primary="$(git worktree list | head -1 | awk '{print $1}')"
  for f in .env .env.local .env.development .envrc; do
    [ -f "$primary/$f" ] && cp "$primary/$f" "$repo/$f"
  done
fi
```

If no primary checkout has a `.env` either, stop and ask — don't fabricate one.

## 2. Detect the dev command

Same detection table as `/wt`'s auto-start step — check in this order at the target dir root:

| Detected | Dev command | Note |
|---|---|---|
| `pyproject.toml` with `uvicorn`/`fastapi` in deps AND a `uv run api` script (check `[project.scripts]`) | `uv run api` | nebula backend — the documented Quick Start command |
| `pyproject.toml` with `uvicorn`/`fastapi`, no packaged script | `uv run uvicorn <module>:app --reload` | module from `[tool.uvicorn]` or `main.py` |
| `Makefile` with a `dev` target | `make dev` | python services wrapping uv/uvicorn |
| `bun.lockb` present, or `package.json` with `"packageManager": "bun@…"` | `bun dev` (or `bun start` if no `dev` script) | nebula-cli, nebula-desktop |
| `package.json` with a `dev` script | `pnpm dev` | Next.js (nebula-web, nebula-docs) |
| `package.json` with `expo` dep and a `start` script | `pnpm start` | nebula-mobile |

Check bun before pnpm - some repos carry both lockfiles mid-transition.

For nebula specifically, also confirm local Postgres/Redis are reachable first (`psql -h 127.0.0.1 -U postgres -d postgres -c '\q'`) — if not, say so rather than starting a server that will just crash-loop.

## 3. Run it

- **If `$ZELLIJ` is set**: open a split pane in the current tab so the server runs alongside the shell, rather than blocking it.
  ```bash
  zellij action new-pane --direction down --cwd "$repo" --name dev -- bash -lc '<detected-command>'
  zellij action move-focus up
  ```
- **Otherwise**: run it with the Bash tool's `run_in_background: true` so it doesn't block the turn, and note the background task id for later log checks.

## 4. Confirm it's up

Poll the expected port/health endpoint (nebula: `curl -sf http://localhost:8000/health` or similar; Next.js: `curl -sf http://localhost:3000`) for a few seconds before declaring done. Report the URL and, if backgrounded, how to tail logs.

## When paired with `/wt` on another repo

A common pattern (e.g. testing a backend PR's UI surface): `/dev` the backend in the current worktree, then `/wt` a fresh frontend worktree pointed at the same feature area — the frontend dev server env should point at the backend's local port (check the frontend's `.env.local` / `NEXT_PUBLIC_API_URL`-style var; don't silently leave it pointed at a remote/dev environment when the point is to exercise local backend changes).
