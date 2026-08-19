---
name: pr
description: Take an approved change end-to-end through one concise plan, serial implementation, repository verification, one review, signed commits, and one ready-for-review PR per repository. Add open PRs to the repository's GitHub stack by default, including unrelated PRs, unless the user says not to stack. Never merge.
---

# Ship one reviewed, green PR per repository

Match Claude's `/pr` outcome contract while using Codex-native agents and tools.
Exactly one task PR is allowed per repository in a session. Task PRs are never
merged by the skill. Publish them through GitHub's native stack workflow by
default, even when adjacent layers are unrelated; only leave a PR unstacked
when the user explicitly says not to stack it.

## 1. Plan and establish scope

- Read every applicable `AGENTS.md` and domain skill before editing.
- Produce one decision-complete plan. Do not fan out planning by default. Use at
  most one bounded discovery helper only when the area is unfamiliar and the
  helper can return a concrete file/contract map without duplicating work.
- Cover scope, contracts, affected repositories, files, migration/rollout concerns, regression coverage, verification, explicit non-goals, and implementation ownership.
- For a reported bug, add a focused failing regression test before production changes. When repository rules require delegation, have a separate agent attempt the fix and prove it with the test.
- Ask only when a missing product or architecture decision would materially change behavior.

## 2. Isolate every repository from main

- Never edit a shared primary checkout. Fetch `origin/main` without changing the primary checkout.
- Create one `cb/<short-slug>` worktree per affected repository from fresh `origin/main`. Multi-repository work gets one worktree and eventually one PR in each repository.
- Copy only required git-ignored local configuration as repository instructions permit; never commit it.
- For Nebula or another database-backed repository, use an isolated per-worktree database. Clone the primary database when clean and suitable; otherwise build one from migrations. Never run branch migrations or schema checks against the user's shared primary database.

## 3. Coordinate implementation

- Make the smallest coherent change that satisfies the approved intent. Preserve unrelated changes.
- Use one executor and one git owner. Do not use parallel editors by default.
  A second executor is allowed only for a genuinely independent repository or
  generated artifact with explicit ownership; never duplicate the same search,
  implementation, or verification.
- Fix producers and authoritative seams, remove superseded paths, and avoid opportunistic cleanup outside the approved scope.
- Run focused verification after each batch and the repository's required full gate before every commit. In Nebula, use `uv run python scripts/dev_check.py`.

## 4. Preserve generated and cross-repository contracts

- When backend API/OpenAPI behavior changes, identify every affected web, mobile, desktop, CLI, and service consumer.
- Regenerate each affected client with its repository command against the correct branch specification. Never regenerate against a remote endpoint that does not yet expose the branch schema.
- Paired client PRs use the same settled schema. An empty generated diff is acceptable evidence of parity; commit a real generated delta.
- Validate mixed-version compatibility, deployment order, and rollback constraints when repositories cannot land atomically.
- Treat native mobile and desktop clients as asynchronously updatable. Before removing or narrowing an API route, schema field, enum/discriminator, event, deep link, or persisted shape, identify the minimum supported native version and prove old installed clients remain functional after the backend deploys. Hiding a feature in new clients does not authorize deleting its server contract.
- Use a phased retirement by default: stop new use and ship updated clients; retain a tested legacy compatibility surface with a named removal condition; observe adoption through the supported-version window; remove the contract only in a later PR. Label retained code as legacy compatibility and state the minimum-version/date/telemetry gate that permits deletion. If no authoritative retirement gate exists, removal is blocked.

## 5. Review the complete main diff

- Treat draft provenance as a hard release boundary. A commit or PR explicitly marked draft, experimental, spike, prototype, or not approved for release must never be incorporated into a main-targeted task PR, regardless of CI, approvals, feature flags, or whether its UI is hidden. Before incorporating another PR/commit, verify its author-approved release state from authoritative PR metadata and comments.
- Invoke the repository's `$simplify` skill on the complete coherent diff before review. Apply its deletion, unification, dependency/SDK, test, documentation, and changed-file disposition gates. Run it again after substantive review fixes or a main merge. Do not push until this gate, `$code-review`, and the final repository check are complete.
- Invoke `$code-review` on `origin/main...HEAD` and fix every verified blocking finding.
- Run one `$code-review` pass. A separate fresh-context review is reserved for
  security, authorization, billing, migrations/data loss, concurrency, or
  public-contract risk. Scope it to that risk and never cross-review reviewers.
- For agent-visible tools, prompts, schemas, events, or routes, run the repository's end-to-end agent validation. In Nebula, derive surfaces from the final main diff and use `cli verify`; explicitly justify infra-only or live-sandbox-blocked skips.

## 6. Commit and publish exactly once

- Stage explicit paths; never use `git add -A` or `git add .`.
- Create signed Conventional Commits with `git commit -S`. Do not amend or bypass hooks.
- Push the task branch and open one ready-for-review PR per repository. If that branch already has a PR, update it instead of opening another. Never turn a ready PR back into a draft.
- Add every new or updated PR to the repository's native GitHub stack with `gh stack`, including unrelated work because one ordered review/merge queue is easier to operate. Preserve declared dependency order; otherwise append the PR to the top. The only opt-out is an explicit user instruction such as "don't stack". A PR deliberately excluded from the stack targets `main`.
- Maintain exactly one `stack-top` label per active stack. After every link, submit, or reorder, resolve the actual top from the resulting stack topology, remove `stack-top` from any former top, and apply it to the current top. Never guess the PR number; the label supports a saved top-only GitHub PR view.
- Never incorporate a draft PR/commit into a main-targeted diff. Draft means not release-authorized, not merely “hidden behind a flag.” Require an explicit ready-for-review transition or author approval first.
- Include Why/Summary, Scope, Test plan, cross-repository or generated-client impact, risks, rollout order, and deliberate deferrals.
- For contract retirements, list the supported stale-client behavior and the explicit legacy-removal gate in every affected PR body.
- Never push to `main`, force-push, merge a task PR, or deploy production.

## 7. Stay current and drive the PR green

- Before handoff, fetch `origin/main`. If the task branch is behind, merge main with a signed merge commit; never rebase shared history. Resolve conflicts semantically and verify key behavior survived even in unconflicted moved files.
- As the final repository change before the last verification, safely consolidate all unpublished Alembic revisions introduced by this PR into the minimum coherent revision set. Preserve operation order, upgrade and downgrade behavior, data backfills, revision ancestry, and a single head. Never rewrite a revision that may already have shipped or is shared by another branch; if publication status is uncertain, leave it intact and document why consolidation was unsafe.
- Re-run the full gate and final agent-visible validation after main merges or substantive review/CI fixes.
- Verify the bottom PR targets `main`, each higher PR targets its immediate stack parent, and GitHub reports every layer clean and mergeable rather than conflicting, dirty, or behind.
- Use `$gh-fix-ci` for GitHub Actions failures and `$gh-address-comments` for actionable review threads. Fix root causes in new signed commits, push, and self-pace polling.
- Finish only when required checks are green and no actionable thread remains. Report exact external blockers rather than claiming success.

## Handoff

Report each PR URL and base, repository/worktree/branch, implementation ownership, signed commits, focused/full/end-to-end checks, review outcomes, final CI and review state, generated-client status, rollout order, and residual risks. Leave every PR ready for review and unmerged.
