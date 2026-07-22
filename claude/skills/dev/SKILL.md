---
name: dev
description: "Audits the persistent remote Nebula staging environment composed from each repository's cb/staging branch. Verifies Vercel web, the hosted development API, service and client artifact SHAs, and cross-repository health without mutation. Use '/dev local' explicitly to run the local stack; use /wt for a feature-specific server."
---

# `/dev` — Audit the owner's persistent `cb/staging` environment

`/dev` represents the configured staging owner's integrated pre-main state. By
default, `/dev` and `/dev audit` inspect the persistent **remote** staging
environment; they do not start local services. Use `/dev local` explicitly to run
the local stack from repository `cb/staging` branches, and `/wt` when the user
wants to exercise a feature branch. This convention is personal to that owner;
do not redirect another contributor's PRs or impose checks on their workflow.

## Status and promotion safety net

`/dev`, `/dev audit`, and `/dev status` are aliases for the same read-only remote
audit. For every repository in scope, fetch remote refs and
report: `main` SHA, `cb/staging` SHA, ahead/behind counts, newest staging
commit and age, and owner-authored task PRs targeting staging. End with one
explicit state: `empty`, `collecting`, `promotion-candidate`,
`awaiting-dev-verification`, `needs-attention`, or `stale`.

Also inspect the persistent remote staging environment. Its browser entry point is
`https://nebula-web-git-cb-staging-agent-labs.vercel.app`; the web deployment
uses the hosted development API at `https://api.nebula-dev.ai`, whose services
must use a dedicated staging database cloned one-way from development. Staging
services must never connect to, migrate, or write the development database.
Report, without mutating either platform:

- the latest successful Vercel deployment SHA for `nebula-web` and whether it is
  descended from current `origin/cb/staging`;
- the latest successful Zeet deployment SHA for each backend staging service and
  whether it is descended from current `origin/cb/staging` in `nebula`;
- the latest successful staging artifact/build SHA for `nebula-mobile` and
  `nebula-desktop`, its workflow state, age, and stable artifact or update-channel
  location when published;
- database-isolation evidence exposed by provider metadata or a safe staging
  health/status surface: dedicated staging database identity, last one-way clone
  age/status when available, and explicit confirmation that the runtime and
  migration jobs target staging rather than development;
- HTTP readiness for the stable browser URL and the API's OpenAPI surface;
- any authentication gate, failed/in-progress deployment, cross-repository SHA
  skew, or unavailable provider evidence.

Use GitHub deployment, check-run, workflow, release, and artifact metadata first
so the audit works without local Vercel or Zeet credentials. Provider CLIs/APIs may enrich the report when already
authenticated, but `/dev status` must never prompt for credentials, reveal
environment values, redeploy, change aliases, or mutate either the development
or dedicated staging database. Never print a DSN, credentials, host, database name, or
other connection material; compare only provider-supplied opaque identities or
an explicit isolation attestation. If isolation cannot be proven, report
`database isolation: unavailable evidence`; if evidence shows staging points at
development, the audit is `needs-attention` and promotion is blocked. A protected Vercel URL redirect is `reachable (authentication
required)`, not an outage. Do not call remote staging `current` until the web and
backend deployments are successful and each deployed SHA contains its repository's
current staging SHA. A newer staging push makes the state `collecting` while its
deployment is in progress and `needs-attention` if it fails or remains stale.

The repository's `staging-promotion.yml` workflow publishes an advisory Actions
summary for the configured owner. Only owner-triggered pushes/manual dispatches
and scheduled maintenance run it. It reports divergence, owner-authored task PRs,
staging age, exact SHAs, and readiness concerns. On owner main or staging pushes,
and on scheduled maintenance, CI merges main into staging when GitHub can do so
cleanly; conflicts or branch-policy failures remain visible. It requires no bot
secret and never mutates issues, labels, statuses, or PRs. This is not a required
check or branch-protection rule and must not affect other contributors.

`/dev promote` reruns the complete **remote audit** and composed remote smoke path.
Local `/dev local` evidence cannot authorize promotion. When every affected
repository is remotely green and every deployed service/artifact SHA contains the
corresponding current `origin/cb/staging` SHA, dispatch that repository's
**Staging promotion** workflow with the exact remotely audited staging SHA as the
configured owner. The durable workflow run and its summary record whether that
exact SHA still matched synchronized staging. Do not attest if staging or any
remote deployment moved during verification. Promotion additionally requires
positive staging-database isolation evidence; a missing or shared-database signal
blocks attestation.
Open or refresh the promotion PR separately; leave merge/deployment to a human.

Useful manual check:

```bash
git fetch origin main cb/staging
git rev-list --left-right --count origin/main...origin/cb/staging
gh pr list --base main --head cb/staging \
  --json number,url,isDraft,mergeStateStatus,statusCheckRollup,updatedAt
gh workflow run staging-promotion.yml \
  -f verified_staging_sha="$(git rev-parse origin/cb/staging)" --ref main
```

## Local mode: `/dev local`

The remaining numbered steps apply only to explicit `/dev local`. Never fall back
to them because remote evidence is unavailable or unhealthy; report the remote
audit boundary instead.

## 0. Resolve the local staging checkout

- With no repository scope supplied, run the complete local Nebula product stack: `nebula`, `nebula-web`, `nebula-mobile`, and `nebula-desktop`. Discover these as sibling checkouts under the current repository's parent directory; report any missing checkout instead of silently omitting it.
- If the user explicitly narrows the repository scope, run only that scope. Include any additional repositories they explicitly name.
- Fetch `origin/main` and `origin/cb/staging`. If the remote staging branch is absent, create it exactly from current `origin/main` and push it.
- Treat each repository's primary/root checkout as the stable `cb/staging` checkout. Keep PR and task branches in separate worktrees; never develop a PR directly in the root checkout.
- If a root checkout is clean but on another branch, switch it to the local `cb/staging` branch, creating that branch to track `origin/cb/staging` when needed. If the root contains uncommitted work, diverges, or cannot switch cleanly, stop for that repository and report the exact state rather than stashing, resetting, or moving work automatically.
- Fast-forward the root checkout to `origin/cb/staging`. Then merge the latest `origin/main` into local `cb/staging` without rewriting history so every service includes current main. If either operation cannot complete cleanly, stop and report the exact state rather than resolving conflicts speculatively. Do not push this local synchronization as part of `/dev local`; promotion owns remote staging mutation.
- Run the remaining steps with that root checkout as `repo`. A `[repo-relative-subdir]` selects a package inside it, such as `apps/cli`.
- Staging synchronization with newer `main`, deployed-SHA proof, and promotion PRs follow the shared `$dev` contract used by Codex: merge `main` into staging without rewriting history; `/dev local` must run staging; production remains untouched.

## 1. Confirm `.env` is present

The root staging checkout should retain its local ignored environment files. Before starting anything:

```bash
repo="$(git rev-parse --show-toplevel)"
for f in .env .env.local .env.development .envrc; do
  [ -f "$repo/$f" ] && printf 'found %s\n' "$f"
done
```

If a repository requires an environment file and its root checkout has none, stop and ask—don't fabricate one. When `/wt` creates a feature worktree, copy the applicable ignored environment files from this root staging checkout.

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

After local readiness, report the local stack only. Run `/dev audit` separately
for authoritative composed-staging and promotion evidence. Local success does not
prove the remote deployment is current, and remote success does not prove an
unmerged task branch. Remote staging is updated by the providers only after an
authorized change reaches `cb/staging`; no `/dev` mode triggers or bypasses that
integration.

## When paired with `/wt` on another repo

A common pattern is `/dev local` for the integrated staging backend plus `/wt`
for one feature-specific frontend. Point the feature worktree at the local staging
service explicitly; do not silently leave it pointed at a remote environment.
