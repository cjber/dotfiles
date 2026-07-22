---
name: dev
description: "Runs each repository's local development server from its cb/staging integration branch, using a stable staging worktree so primary and feature checkouts stay untouched. Auto-detects backend/frontend commands, supplies local env files, starts services in zellij or the background, and verifies health. Use for '/dev', starting the shared development stack, or proving the composed pre-main environment. Use /wt for a feature-specific server instead."
---

# `/dev` — Run the shared `cb/staging` development stack

`/dev` represents integrated pre-main state. For every repository in scope, run the server from that repository's `cb/staging`, never from `main` or an individual task branch. Use `/wt` when the user explicitly wants to exercise a feature branch instead.

## Status and promotion safety net

`/dev status` is read-only. For every repository in scope, fetch remote refs and
report: `main` SHA, `cb/staging` SHA, ahead/behind counts, newest staging commit
and age, open task PRs targeting staging, the single `cb/staging` -> `main`
promotion PR (or `missing`), its draft/readiness state, mergeability, and checks.
End with one explicit state: `empty`, `collecting`, `promotion-ready`,
`promotion-blocked`, or `stale`.

The repository's `staging-promotion.yml` workflow owns the durable tracker. On
every staging push it creates or refreshes exactly one draft promotion PR,
invalidates the `composed-dev-verified` label, and publishes divergence, pending
task PRs, staging age, exact SHAs, and blockers. Its promotion gate requires
staging to contain current main, no task PRs to remain, and composed proof for the
current staging SHA. On main or staging pushes, CI merges main into staging when
GitHub can do so cleanly; conflicts or branch-policy failures remain explicit
blockers. Scheduled runs keep forgotten staging visible. CI never merges a task
PR, promotes staging to main, or deploys.

`/dev promote` reruns the complete status and composed health checks. When every
affected repository is green, dispatch that repository's **Staging promotion**
workflow with the exact tested `origin/cb/staging` SHA; CI rejects a stale SHA,
records the actor/run URL as a successful commit status bound to that SHA, and
adds a display label to the current promotion. The commit status—not the mutable
label—is authoritative. Do not edit the tracker or label directly, and do not
attest if staging moved during verification. Leave readiness and every
repository's ordinary promotion checks to CI; leave merge/deployment to a human.

Useful manual check:

```bash
git fetch origin main cb/staging
git rev-list --left-right --count origin/main...origin/cb/staging
gh pr list --base main --head cb/staging \
  --json number,url,isDraft,mergeStateStatus,statusCheckRollup,updatedAt
gh workflow run staging-promotion.yml \
  -f verified_staging_sha="$(git rev-parse origin/cb/staging)" --ref main
```

## 0. Resolve the staging checkout

- Resolve all repositories named by the user. For a multi-repository product stack, do not silently start only the current repository.
- Fetch `origin/main` and `origin/cb/staging`. If the remote staging branch is absent, create it exactly from current `origin/main` and push it.
- Reuse an existing worktree whose branch is `cb/staging`. Otherwise create a stable dedicated worktree outside the primary checkout from `origin/cb/staging`; never switch, reset, or overwrite the user's primary checkout.
- Fast-forward the local staging worktree to `origin/cb/staging`. If it has local changes, diverges, or conflicts, stop and report the exact state rather than cleaning it destructively.
- Run the remaining steps with that staging worktree as `repo`. A `[repo-relative-subdir]` selects a package inside it, such as `apps/cli`.
- Staging synchronization with newer `main`, deployed-SHA proof, and promotion PRs follow the shared `$dev` contract used by Codex: merge `main` into staging without rewriting history; `/dev` must run staging; production remains untouched.

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

A common pattern is `/dev` for the integrated staging backend plus `/wt` for one feature-specific frontend. Point the feature worktree at the local staging service explicitly; do not silently leave it pointed at a remote environment.
