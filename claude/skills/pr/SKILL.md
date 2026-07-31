---
name: pr
description: "Ship an approved change as one reviewed, green PR per repository. Use for 'ship this', 'build this end-to-end', or '/pr'. Use one Claude and one Codex pass for planning, disjoint implementation, and final review without recursive fan-out."
---

# Ship one green PR

Use one Claude arm and one Codex arm in the same controlled workflow. Keep each
phase bounded and avoid spawning any agents beyond those two arms.

## Resource budget

- Claude uses Sonnet at medium effort by default.
- Codex uses Terra at low effort for planning/review and medium effort for its
  implementation slice. Never select the fast service tier.
- Each phase has one Claude arm and one Codex arm. They may exchange one concise
  critique/reply round to challenge assumptions and surface misses. Do not add
  scouts, agent teams, nested subagents, or recursive workflow calls.
- Keep prompts narrow and outputs concise. Pass the synthesized plan into
  implementation; do not make either arm rediscover settled facts.
- Escalate one judgment turn to Opus or Sol only for security, billing, data-loss,
  migration, or architecture risk that the default model cannot resolve.

## 1. Plan once on both models

- Read applicable `AGENTS.md` and only the domain skills needed for the touched
  area.
- Launch one Claude plan and one Codex plan concurrently. Both inspect the same
  target but return only decisions, affected files/contracts, risks, and checks.
- Exchange the two drafts. Each planner returns only: incorrect assumptions,
  missing contracts/risks, and proposed corrections. No rewritten plan.
- The primary Claude turn resolves that single critique round from source
  evidence and synthesizes one implementation plan.
- For a bug, establish the cheapest durable reproduction before editing.
- Ask only when a missing decision would materially change behavior.

## 2. Check what of yours is already in motion, then isolate

Before creating any branch, list your own unmerged work in each target
repository and decide what this change builds on. Branching from `origin/main`
while your own dependency sits unmerged produces a diff that duplicates or
conflicts with it, and a review nobody can evaluate in isolation.

```sh
gh pr list --author "@me" --state open --limit 30 \
  --json number,title,headRefName,baseRefName,createdAt,updatedAt,mergeStateStatus
```

Treat a PR as **in motion** when it is open and either opened/updated today or
created earlier in this session. Older open PRs are stale parking, not a base —
do not stack onto them.

Then pick exactly one option, per repository:

- **Same coherent effort, PR still open** → add commits to that branch/PR. One
  PR per repo still wins over stacking; do not open a second PR for a later
  phase of the same work.
- **New work depends on, or edits the same files/contracts as, an in-motion PR**
  → stack on it: branch from that PR's head, not `origin/main`.
- **Genuinely independent work** → branch from fresh `origin/main` as normal.
  Never stack independent work — a layer cannot merge until every layer below it
  merges, so an unrelated dependency silently blocks it.
- **Security-sensitive or independently riskier slice blocking safe work** → the
  pre-existing split exception; express it as a stack, not two hand-managed PRs.

Stacking mechanics (`gh stack`, github/gh-stack v0.1.0 — install with
`gh extension install github/gh-stack`):

- Adopt an in-motion PR as the bottom layer, then add yours on top:
  `gh stack checkout <pr-number>` (fetches the branch and sets up local
  tracking), then `gh stack add cb/<slug>`.
- Several existing open branches of yours belong in one chain:
  `gh stack init <bottom> <mid> <top>` — bottom to top, adopting existing
  branches; `--base <trunk>` if the trunk is not the default branch.
- Managing branches outside gh-stack tracking: `gh stack link <pr> <pr>` links
  existing PRs into a stack on GitHub without local state.
- Publish: `gh stack submit --open`. Non-interactive runs need `--auto`, and
  `--auto` creates drafts unless `--open` is also passed.
- Restack after the trunk moves or a layer merges: `gh stack sync --prune`.
- Inspect before acting: `gh stack view --json`.
- Never hand-manage bases with `gh pr edit --base`, and never use
  `gh pr update-branch` — it strips commit signatures. `gh stack` rebases
  locally, so `commit.gpgsign` re-signs every layer.
- Merging a stack is `gh stack merge --yes --squash` (atomic, all-or-nothing up
  to the chosen PR), but `/pr` still never merges.
- New-repository preflight: a workflow with a `pull_request: branches: [...]`
  filter that owns a required check never reports on a non-bottom layer, leaving
  it permanently unmergeable. Verify that before the first stack in a repo.
- Each PR body states its base layer and the intended merge order.

Isolation itself:

- Use one `cb/<slug>` worktree per repository, branched from fresh `origin/main`
  or from the chosen parent layer's head. Copy permitted ignored local
  configuration such as `.env`; never commit it.
- Use an isolated database for migration work. Never test branch migrations
  against the shared primary database.

## 3. Implement on both models

- Partition the synthesized plan into two disjoint ownership slices. Claude and
  Codex implement concurrently in the same worktree only when their file sets do
  not overlap. If the change cannot be split safely, Codex implements and Claude
  owns integration rather than inventing a second slice.
- Claude is the only git owner. Codex does not stage, commit, push, or open PRs.
- Fix the authoritative producer, remove superseded paths, and avoid unrelated
  cleanup.
- Each arm runs only focused checks for its slice. After both finish, Claude
  inspects the combined diff and runs Nebula's required full gate.
- Before integration, exchange short implementation summaries and diffs. Each arm
  checks the other's slice only for seam mismatches, broken assumptions, and
  missing tests; it does not re-review the entire repository or edit the other's
  owned files. Claude resolves the replies and integrates once.
- If multiple repositories are involved, finish and verify one contract slice
  at a time while recording deployment order and mixed-version compatibility.

## 4. Simplify once, review once on both models

- Run `/simplify` on the coherent final diff and apply worthwhile reductions.
- Launch one Claude review and one Codex review concurrently over the same final
  diff. Neither sees the other's output.
- Exchange only exclusive findings. Each reviewer gets one reply to confirm,
  reject with evidence, or adjust severity for findings the other reviewer alone
  found. Do not repeat shared findings or generate a second full review.
- Claude deduplicates and validates that critique round once, then fixes verified
  blockers.
- Re-review only the changed risky area after substantive fixes to security,
  data, billing, concurrency, migrations, or public contracts.
- For agent-visible behavior, run the repository's end-to-end validation.
- Run the required final full check once after the diff is stable.

## 5. Commit and publish

- Stage explicit paths and create signed Conventional Commits.
- Push one branch and open or update one ready-for-review PR per repository.
  Task PRs target `main`, except a stacked layer, which targets the layer below
  it and is published with `gh stack submit --open`. Never merge.
- Include why, scope, tests, risks, rollout order, and deliberate deferrals.
- Address CI failures and actionable review comments with focused fixes. Avoid
  polling through model turns; use the available wait/monitor mechanism.

## Finish

Report PR URLs and bases, branches/worktrees, commits, checks, review outcome,
rollout constraints, and real blockers. Do not narrate routine exploration.
