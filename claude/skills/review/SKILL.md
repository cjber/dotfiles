---
name: review
description: "Review a branch, diff, commit, or PR for high-confidence correctness, security, data-loss, concurrency, and contract regressions. Review once with the current model; use one independent second pass only for high-risk or unusually large changes."
---

# Review one diff efficiently

This skill is review-only unless the user explicitly requests fixes.

## Resource budget

- Use the current model at medium effort. Do not force Opus or Codex Sol.
- Do not launch parallel reviewers, agent teams, or cross-reconciliation loops.
- One fresh-context second pass is allowed only for security, authorization,
  billing, migrations/data loss, concurrency, or a diff too large for one
  coherent pass. Scope it to the risky area rather than repeating the full review.

## Resolve the target

- Fetch the relevant base without modifying the user's checkout.
- No argument: review the current branch from its merge-base with its upstream
  base, including uncommitted work when requested.
- PR number: inspect authoritative PR metadata and diff.
- Branch/range/commit: resolve it explicitly and state the base used.
- Preserve dirty user work; use a temporary worktree for a remote PR if needed.

## Review

1. Read applicable repository instructions and only the domain skills relevant
   to changed files.
2. Inspect the complete diff, then trace changed producers to their consumers.
3. Prioritize executable defects: wrong results, security boundary breaks, data
   loss, races, compatibility failures, and missing protection for a realistic
   regression.
4. Validate each candidate against surrounding code before reporting it. Drop
   style preferences and speculative concerns.
5. Run cheap focused checks when they materially increase confidence. Do not run
   a full suite merely to produce activity.

For coordinated multi-repository changes, add one contract check across the seam:
confirm the producer emits the shape and lifecycle every consumer expects.

## Output

List findings by severity. Each finding includes `file:line`, the defect, a
concrete failure scenario, and the smallest viable fix. Then state residual
uncertainty and tests/checks run. If no finding survives validation, say so
plainly.

`--comment` may publish validated findings on a PR. `--fix` may implement them
serially, followed by focused verification and at most one targeted re-review.
