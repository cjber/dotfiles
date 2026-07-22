---
name: pr
description: Take an approved change end-to-end through parallel planning where useful, isolated staging-based worktrees, coordinated implementation, repository verification, independent review, signed commits, one ready-for-review PR per repository, CI repair, and review-comment resolution. Task PRs target cb/staging; never merge.
---

# Ship one reviewed, green PR per repository

Match Claude's `/pr` outcome contract while using Codex-native agents and tools. Exactly one task PR is allowed per repository in a session. For the configured staging owner's work, task PRs target `cb/staging`; `/dev` runs composed staging; only the bundle promotion PR targets `main`. This is a personal convention, not a required repository gate, and must not alter other contributors' PR bases or checks.

One narrowly-scoped bootstrap exception exists: infrastructure that must already
exist on the default branch to dispatch or maintain the staging workflow may use a
single installation PR directly to `main`. State the bootstrap reason, never mix
product work into it, and return immediately to staging-based task PRs after CI
synchronizes that commit into `cb/staging`.

## 1. Plan and establish scope

- Read every applicable `AGENTS.md` and domain skill before editing.
- For a large or unfamiliar change, run bounded independent discovery/plan drafts in parallel, cross-review them once, and synthesize one decision-complete plan. Skip fan-out for an already narrow change.
- Cover scope, contracts, affected repositories, files, migration/rollout concerns, regression coverage, verification, explicit non-goals, and implementation ownership.
- For a reported bug, add a focused failing regression test before production changes. When repository rules require delegation, have a separate agent attempt the fix and prove it with the test.
- Ask only when a missing product or architecture decision would materially change behavior.

## 2. Isolate every repository from staging

- Never edit a shared primary checkout. Fetch `origin/main` and `origin/cb/staging` without changing the primary checkout.
- If staging is absent, create it exactly from current `origin/main` and push it. `$dev` owns later main-to-staging synchronization and deployed-SHA proof.
- Create one `cb/<short-slug>` worktree per affected repository from fresh `origin/cb/staging`. Multi-repository work gets one worktree and eventually one PR in each repository.
- Copy only required git-ignored local configuration as repository instructions permit; never commit it.
- For Nebula or another database-backed repository, use an isolated per-worktree database. Clone the primary database when clean and suitable; otherwise build one from migrations. Never run branch migrations or schema checks against the user's shared primary database.

## 3. Coordinate implementation

- Make the smallest coherent change that satisfies the approved intent. Preserve unrelated changes.
- Use one executor for small work. For substantial work, partition disjoint files/modules between agents and state ownership explicitly.
- With parallel editors in one worktree, designate one git owner. Other agents edit and run focused checks only; they do not stage, commit, push, or open PRs.
- During parallel edits, run only ownership-scoped checks. Run whole-tree checks after all slices are integrated and coherent.
- Fix producers and authoritative seams, remove superseded paths, and avoid opportunistic cleanup outside the approved scope.
- Run focused verification after each batch and the repository's required full gate before every commit. In Nebula, use `uv run python scripts/dev_check.py`.

## 4. Preserve generated and cross-repository contracts

- When backend API/OpenAPI behavior changes, identify every affected web, mobile, desktop, CLI, and service consumer.
- Regenerate each affected client with its repository command against the correct branch specification. Never regenerate against a remote endpoint that does not yet expose the branch schema.
- Paired client PRs use the same settled schema. An empty generated diff is acceptable evidence of parity; commit a real generated delta.
- Validate mixed-version compatibility, deployment order, and rollback constraints when repositories cannot land atomically.
- Treat native mobile and desktop clients as asynchronously updatable. Before removing or narrowing an API route, schema field, enum/discriminator, event, deep link, or persisted shape, identify the minimum supported native version and prove old installed clients remain functional after the backend deploys. Hiding a feature in new clients does not authorize deleting its server contract.
- Use a phased retirement by default: stop new use and ship updated clients; retain a tested legacy compatibility surface with a named removal condition; observe adoption through the supported-version window; remove the contract only in a later PR. Label retained code as legacy compatibility and state the minimum-version/date/telemetry gate that permits deletion. If no authoritative retirement gate exists, removal is blocked.

## 5. Review the complete staging diff

- Invoke `$code-review` on `origin/cb/staging...HEAD` and fix every verified blocking finding.
- Run one independent fresh-context review with `codex exec review --base origin/cb/staging`; use `--uncommitted` when appropriate.
- For substantial review-driven changes, permit at most one final independent review. Avoid recursive review loops.
- For agent-visible tools, prompts, schemas, events, or routes, run the repository's end-to-end agent validation. In Nebula, derive surfaces from the final staging diff and use `cli verify`; explicitly justify infra-only or live-sandbox-blocked skips.

## 6. Commit and publish exactly once

- Stage explicit paths; never use `git add -A` or `git add .`.
- Create signed Conventional Commits with `git commit -S`. Do not amend or bypass hooks.
- Push the task branch and open one ready-for-review PR per repository with base `cb/staging`. If that branch already has a PR, update it instead of opening another. Never turn a ready PR back into a draft.
- Include Why/Summary, Scope, Test plan, cross-repository or generated-client impact, risks, rollout order, and deliberate deferrals. Make the staging base conspicuous.
- For every staging-targeted draft PR, derive the entire body from `origin/main...HEAD`, not only `origin/cb/staging...HEAD`. Before every push/handoff, re-read that full diff and update the PR body so it describes all code GitHub would ultimately promote to main, including staging-only changes. A body that is stale or narrower than the main diff is a blocking defect.
- For contract retirements, list the supported stale-client behavior and the explicit legacy-removal gate in every affected PR body.
- Never push to `main`, force-push, merge a task PR, or deploy production.

## 7. Stay current and drive the PR green

- Before handoff, fetch `origin/cb/staging`. If the task branch is behind, merge staging with a signed merge commit; never rebase shared history. Resolve conflicts semantically and verify key behavior survived even in unconflicted moved files.
- Re-run the full gate and final agent-visible validation after staging merges or substantive review/CI fixes.
- Verify the PR base is `cb/staging` and GitHub reports a clean, mergeable state rather than conflicting, dirty, or behind.
- Use `$gh-fix-ci` for GitHub Actions failures and `$gh-address-comments` for actionable review threads. Fix root causes in new signed commits, push, and self-pace polling.
- Finish only when required checks are green and no actionable thread remains. Report exact external blockers rather than claiming success.

## 8. Promotion and `/dev`

- A task PR being green does not prove `/dev`: it must first be approved and integrated into staging.
- `$dev` verifies that every scoped repository's development service runs a SHA descended from current `origin/cb/staging` and exercises the composed smoke path.
- When the bundle is ready, open or update one advisory `cb/staging` to `main` promotion PR per repository and review `origin/main...origin/cb/staging`. Do not add a required promotion check or ruleset. Never merge it without explicit user authority.

## Handoff

Report each PR URL and base, repository/worktree/branch, implementation ownership, signed commits, focused/full/end-to-end checks, review outcomes, final CI and review state, generated-client status, staging divergence, whether `/dev` validation is pending or proven, promotion order, and residual risks. Leave every PR ready for review and unmerged.
