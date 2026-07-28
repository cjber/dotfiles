---
name: pr
description: Take an approved change end-to-end through one concise plan, serial implementation, repository verification, one review, signed commits, and one ready-for-review PR per repository. Task PRs target main; never merge.
---

# Ship one reviewed, green PR per repository

Match Claude's `/pr` outcome contract while using Codex-native agents and tools.
Exactly one task PR is allowed per repository in a session. Task PRs target
`main` unless the repository or user explicitly requires another base.

## 1. Plan and establish scope

- Read every applicable `AGENTS.md` and domain skill before editing.
- Produce one decision-complete plan. Do not fan out planning by default. Use at
  most one bounded discovery helper only when the area is unfamiliar and it can
  return a concrete file and contract map without duplicating work.
- Cover scope, contracts, affected repositories, files, migration and rollout
  concerns, regression coverage, verification, explicit non-goals, and
  implementation ownership.
- For a reported bug, establish the cheapest durable reproduction before editing.
- Ask only when a missing product or architecture decision would materially
  change behavior.

## 2. Isolate every repository from main

- Never edit a shared primary checkout. Fetch `origin/main` without changing it.
- Create one `cb/<short-slug>` worktree per affected repository from fresh
  `origin/main`. Multi-repository work gets one worktree and eventually one PR
  in each repository.
- Copy only required git-ignored local configuration as repository instructions
  permit; never commit it.
- For database-backed repositories, use an isolated per-worktree database. Never
  run branch migrations or schema checks against the user's shared primary
  database.

## 3. Coordinate implementation

- Make the smallest coherent change that satisfies the approved intent. Preserve
  unrelated changes.
- Use one executor and one git owner. Do not use parallel editors by default. A
  second executor is allowed only for a genuinely independent repository or
  generated artifact with explicit ownership.
- Fix producers and authoritative seams, remove superseded paths, and avoid
  opportunistic cleanup outside the approved scope.
- Run focused verification after each batch and the repository's required full
  gate before every commit. In Nebula, use
  `uv run python scripts/dev_check.py`.

## 4. Preserve generated and cross-repository contracts

- Identify every affected client when backend API or OpenAPI behavior changes.
- Regenerate clients with their repository command against the branch schema,
  never against a remote endpoint that does not expose it.
- Validate mixed-version compatibility, deployment order, and rollback
  constraints when repositories cannot land atomically.
- Treat native clients as asynchronously updatable. Retain a tested compatibility
  surface until an authoritative minimum-version, date, or telemetry gate permits
  removal.

## 5. Simplify and review the complete diff

- Treat draft provenance as a hard release boundary. Work marked draft,
  experimental, prototype, or not approved for publication must not be
  incorporated into a ready PR without explicit author approval.
- Invoke `$simplify` on the coherent diff before review and again after
  substantive review fixes or a main merge.
- Invoke `$code-review` on `origin/main...HEAD` and fix every verified blocking
  finding. Use one review pass unless a separate high-risk security, billing,
  migration, data-loss, concurrency, or public-contract review is warranted.
- For agent-visible behavior, run the repository's end-to-end validation. In
  Nebula, derive surfaces from the final diff and use `cli verify`; explicitly
  justify infra-only or live-environment-blocked skips.
- Run the required full repository check after the diff is stable.

## 6. Commit and publish exactly once

- Stage explicit paths; never use `git add -A` or `git add .`.
- Create signed Conventional Commits with `git commit -S`. Do not amend or bypass
  hooks.
- Push the task branch and open one ready-for-review PR per repository with base
  `main`. Update an existing branch PR instead of opening another. Never turn a
  ready PR back into a draft.
- Include Why/Summary, Scope, Test plan, cross-repository or generated-client
  impact, risks, rollout order, and deliberate deferrals.
- Never push to `main`, force-push shared history, merge a task PR, or deploy
  production.

## 7. Stay current and drive the PR green

- Before handoff, fetch `origin/main`. If the task branch is behind, merge main
  with a signed merge commit; never rebase shared history. Resolve conflicts
  semantically and verify behavior survived moved files.
- Re-run the full gate and agent-visible validation after main merges or
  substantive review and CI fixes.
- Verify the PR base is `main` and GitHub reports a clean, mergeable state.
- Use `$gh-fix-ci` for GitHub Actions failures and `$gh-address-comments` for
  actionable review threads. Fix root causes in new signed commits.
- Finish only when required checks are green and no actionable thread remains.

## 8. `/dev`

- Feature-specific verification runs from its isolated worktree; the shared stack
  runs the latest `main`.
- `$dev` verifies every scoped development service runs a SHA descended from
  current `origin/main` and exercises the composed smoke path.

## Handoff

Report each PR URL and base, repository/worktree/branch, implementation ownership,
signed commits, focused/full/end-to-end checks, review outcomes, final CI and
review state, generated-client status, whether `/dev` validation is pending or
proven, rollout order, and residual risks. Leave every PR ready for review and
unmerged.
