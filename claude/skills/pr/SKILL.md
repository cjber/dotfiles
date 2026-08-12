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
  implementation slice. Never select the fast service tier. Pass the model as the
  fully-qualified `gpt-5.6-terra` (`codex exec -m gpt-5.6-terra`); the bare name
  `terra` is rejected with "not supported when using Codex with a ChatGPT
  account". Sol is likewise `gpt-5.6-sol`.
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

## 2. Isolate

**Branch from fresh `origin/main` by default.** Do not stack onto unrelated work
just because it is open or was touched today — an unrelated lower layer holds the
upper ones back for no benefit.

Two exceptions, both requiring a real dependency:

- **Same coherent effort, PR still open** → add commits to that branch/PR rather
  than opening a second one. One PR per repo beats a new branch for work already
  under review.
- **This change genuinely depends on another unmerged branch of yours**, or a
  security-sensitive slice must land first → stack on that branch specifically,
  and say so in the PR body along with the intended merge order.

```sh
gh pr list --author "@me" --state open --limit 30 \
  --json number,title,headRefName,baseRefName,createdAt,updatedAt
```

Isolation itself:

- Use one `cb/<slug>` worktree per repository, branched from fresh `origin/main`
  (or, in the dependent case above, from the parent branch's head). Copy
  permitted ignored local configuration such as `.env`; never commit it.
- Use an isolated database for migration work. Never test branch migrations
  against the shared primary database.
- Never use `gh pr update-branch` — it strips commit signatures. Rebase locally
  so `commit.gpgsign` re-signs.

## 3. Implement on both models

- Partition the synthesized plan into two disjoint ownership slices. Claude and
  Codex implement concurrently in the same worktree only when their file sets do
  not overlap. If the change cannot be split safely, Codex implements and Claude
  owns integration rather than inventing a second slice.
- Claude is the only git owner. Codex does not stage, commit, push, or open PRs.
- Fix the authoritative producer, remove superseded paths, and avoid unrelated
  cleanup.
- Each arm runs only focused checks for its slice. After both finish, Claude
  inspects the combined diff and runs the repo's fast lint/type gate
  (`dev_check.py`, no `--tests`).
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
- Run the fast lint/type gate once after the diff is stable.

**Never run the full test suite locally.** CI runs the tests, and it runs the
integration and migration jobs against separate databases. Locally, run ONLY a
test you just wrote or one individually-targeted test — enough to show it fails
without the fix and passes with it. Do not run `uv run pytest` bare, the whole
`tests/integration` tree, or `dev_check.py --tests`: that gate starts its check
groups concurrently against one shared Postgres, so the migration group's
up/down test wipes the schema out from under the integration group and produces
hundreds of `UndefinedColumn` errors that say nothing about the diff. Push and
let CI be the test gate.

## 5. Commit and publish

- Stage explicit paths and create signed Conventional Commits.
- Push one branch and open or update one ready-for-review PR per repository.
  Task PRs target `main`, except a stacked layer, which targets the layer below
  it and is published with `gh stack submit --open`. Never merge.
- Include why, scope, tests, risks, rollout order, and deliberate deferrals.
- If the change contradicts a documented rule or contract (a skill file, an
  architecture doc, an invariant list), update that document in the same PR.
  A canonical contract left describing the old behaviour is a defect.

## 6. Drive the PR green before finishing

Publishing is not the end of the task. A PR is done when CI is fully green and
every review comment has been answered.

**Waiting on CI is working time, not idle time.** The moment the PR is open,
start a second `/simplify` and `/review` pass over the published diff and run it
*concurrently* with the checks — never sit polling a status endpoint. This pass
is mandatory, not conditional on the pre-publish pass having found something:

- The pre-publish pass in §4 reviewed a diff you had just finished writing. The
  post-publish pass reads it as published, with that round's fixes folded in —
  a different artifact, and those fixes are themselves unreviewed code until
  this pass looks at them.
- Findings cost nothing here. The branch is already pushed, so a fix is one more
  signed commit onto the open PR; the same finding raised after a human review
  has cost a review cycle.
- Anything it finds goes through the same gates as any other fix commit (see the
  last bullet of this section), and the PR body is updated if scope moved.

Run it as one `/simplify` followed by `/review` over `git diff origin/main`, and
report what it changed alongside the CI result.

- **CI must pass completely.** Wait for the checks to finish and read the
  result — never assume green because the push succeeded or because local
  checks passed. Fix every failure and re-push until all required checks pass.
  If a failure is genuinely environmental or a known-flaky job, say so
  explicitly with the evidence that distinguishes it from a real failure;
  never silently treat red as green.
- **Read and address review comments, including bot reviewers.** Fetch them
  explicitly: a PR-level review body hides the inline comments, so pull the
  inline set too (`gh api repos/{owner}/{repo}/pulls/{n}/comments`) rather than
  relying on `gh pr view`. Automated reviewers (Codex, Copilot, CodeQL) count.
- Evaluate each comment on its merits against the actual code. Fix the valid
  ones; for any you reject, reply on the PR with the evidence rather than
  ignoring it.
- Commits pushed for CI or review fixes go through the same gates as the
  original diff: `/simplify` on substantive changes, the fast lint/type gate,
  and a signed commit.
- Poll efficiently — use the available wait/monitor mechanism instead of
  burning model turns on repeated status checks.

## Finish

Report PR URLs and bases, branches/worktrees, commits, the **final CI state**,
how each review comment was resolved, rollout constraints, and real blockers.
Do not narrate routine exploration. Do not report success while CI is red,
still running, or unchecked, or while review comments are unaddressed.
