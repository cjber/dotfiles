---
name: pr
description: "Ship an approved change as one reviewed, green PR per repository. Use for 'ship this', 'build this end-to-end', or '/pr'. Use one Claude and one Codex pass for planning, disjoint implementation, and final review without recursive fan-out."
---

# Ship one green PR

Use one Claude arm and one Codex arm in the same controlled workflow. Keep each
phase bounded and avoid spawning any agents beyond those two arms.

## Resource budget

- Claude uses Sonnet at medium effort by default.
- **Codex uses Sol at `xhigh` reasoning effort for every phase** — planning,
  implementation, and review alike. Sol at xhigh is the point of running a second
  model at all: the value of the Codex arm is that it thinks hard enough to catch
  what the Claude arm assumed, and a cheaper tier spends the coordination
  overhead without buying the scrutiny. Do not drop to a lower effort to save
  time; a shallow second opinion is worse than none, because it reads as
  corroboration.

  ```sh
  codex exec -m gpt-5.6-sol -c model_reasoning_effort=xhigh --skip-git-repo-check - < prompt.md
  ```

  Never select the fast service tier. Pass the model fully-qualified as
  `gpt-5.6-sol`; a bare name like `sol` or `terra` is rejected with "not
  supported when using Codex with a ChatGPT account".
- Each phase has one Claude arm and one Codex arm. They may exchange one concise
  critique/reply round to challenge assumptions and surface misses. Do not add
  scouts, agent teams, nested subagents, or recursive workflow calls.
- Keep prompts narrow and outputs concise. Pass the synthesized plan into
  implementation; do not make either arm rediscover settled facts.
- Escalate one judgment turn to Opus only for security, billing, data-loss,
  migration, or architecture risk that neither arm can resolve on its own.

### Invoking Codex — always redirect stdin

**`codex exec` waits for stdin to reach EOF before it starts, whenever stdin is
not a TTY.** A backgrounded Bash call hands it a pipe that never closes, so it
blocks forever having printed only `Reading additional input from stdin...`.
This is the single most repeated failure in this skill's history: it has burned
a launch round-trip on 2026-07-24 and again on 2026-08-17, the latter costing
25 minutes of wall-clock for zero work while looking like a healthy running arm.

So every invocation redirects stdin. Two correct shapes, both verified:

```sh
# Prompt in a file (preferred for anything longer than a line):
cd "$WORKTREE" && codex exec -m gpt-5.6-sol -c model_reasoning_effort=xhigh \
  --skip-git-repo-check - < prompt.md

# Prompt as an argument — still requires closing stdin explicitly:
cd "$WORKTREE" && codex exec -m gpt-5.6-sol -c model_reasoning_effort=xhigh \
  --skip-git-repo-check "$PROMPT" < /dev/null
```

Prefer the file form, and **write the prompt with the Write tool rather than
inlining it**. A long prompt inlined into a shell command needs nested quote
escaping (`'"'"'` chains) that is easy to get wrong and impossible to read back.

Three rules for reading the result, because this failure imitates success:

- **`Reading additional input from stdin...` means the prompt never arrived.**
  Treat that string as a hard failure, whatever the exit code — the 2026-08-17
  occurrence exited **0**.
- **A fast exit is not a fast success.** Before trusting a quick return, confirm
  the arm actually changed something (`git status`, or the artifact it owed).
- **Silence is not progress.** An arm with no output after ~5 minutes has almost
  certainly hit this; check rather than wait. Do not let a long-running process
  reassure you — the hang and the instant no-op share one cause.

Two further flag landmines on this account:

- **`codex exec resume <id>` rejects `--cd` and `--sandbox`** (exit 2,
  `unexpected argument`). Resume is cwd-aware, so `cd` into the worktree first —
  which is why every example above `cd`s rather than passing `--cd`. Sandbox mode
  is inherited from the original `exec`.
- **`codex review` takes `-m`/`-c` as TOP-LEVEL flags**, before the subcommand:
  `codex -m gpt-5.6-sol -c model_reasoning_effort=xhigh review --base origin/main`. And `--base main`
  reviews against the *local* main — always pass `origin/main`.

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
  (`uv run sift check`, no `--tests`).
- Before integration, exchange short implementation summaries and diffs. Each arm
  checks the other's slice only for seam mismatches, broken assumptions, and
  missing tests; it does not re-review the entire repository or edit the other's
  owned files. Claude resolves the replies and integrates once.
- If multiple repositories are involved, finish and verify one contract slice
  at a time while recording deployment order and mixed-version compatibility.

## 4. Simplify once, review once on both models

- Run `/simplify` on the coherent final diff and apply worthwhile reductions.
- Run `uv run dead-code` and clear what the diff itself made dead. Removing a
  branch, a call site, or a config entry orphans the code behind it, and that
  residue is invisible to `/simplify` (which reads the diff, not the whole
  program) and to reviewers (who see what changed, not what stopped being
  reached). Treat every hit as a candidate, not a verdict — a hit inside the
  diff's blast radius is usually real; one elsewhere is usually a framework
  entrypoint or a dynamic-dispatch false positive, and belongs in its own sweep,
  not this PR. Prove non-use before deleting; `/deadcode` carries the full
  reachability discipline when a hit is not obvious.
- Launch one Claude review and one Codex review concurrently over the same final
  diff. Neither sees the other's output.
- Exchange only exclusive findings. Each reviewer gets one reply to confirm,
  reject with evidence, or adjust severity for findings the other reviewer alone
  found. Do not repeat shared findings or generate a second full review.
- Claude deduplicates and validates that critique round once, then fixes verified
  blockers.
- **Fix a verified finding in this PR. Filing an issue is not a resolution.**
  Once a finding is confirmed real, the default is a commit on this branch, even
  when the true fix is one layer below the diff — a defect the diff made visible
  is the diff's to fix, and the producer fix is usually smaller than the
  write-up explaining why it was deferred. Do not reach for `gh issue create`
  because the fix touches a shared seam, a contract other surfaces also use, or
  code the PR did not otherwise open. Those are reasons the fix matters, not
  reasons to defer it.

  Defer only when the fix genuinely cannot land here: it needs a migration or
  rollout the PR is not carrying, it depends on an unmerged change elsewhere, or
  it is a redesign whose scope the user should choose. Then say so in your report
  and let the user decide — do not file and move on. If you do file, the issue is
  a record of a decision the user made, never a substitute for one you avoided.

  When you catch yourself writing "tracked separately", "out of scope", or "filed
  as #N" about something you have already verified and could fix: stop and fix it.
- Re-review only the changed risky area after substantive fixes to security,
  data, billing, concurrency, migrations, or public contracts.
- For agent-visible behavior, run the repository's end-to-end validation.
- Run the fast lint/type gate once after the diff is stable.

**Never run the full test suite locally.** CI runs the tests, and it runs the
integration and migration jobs against separate databases. Locally, run ONLY a
test you just wrote or one individually-targeted test — enough to show it fails
without the fix and passes with it. Do not run `uv run pytest` bare, the whole
`tests/integration` tree, or `uv run sift check --tests`: that gate starts its check
groups concurrently against one shared Postgres, so the migration group's
up/down test wipes the schema out from under the integration group and produces
hundreds of `UndefinedColumn` errors that say nothing about the diff. Push and
let CI be the test gate.

## 5. Commit and publish

- Stage explicit paths and create signed Conventional Commits.
- Push one branch and open or update one ready-for-review PR per repository.
  Task PRs target `main`, except a stacked layer, which targets the layer below
  it and is published with `gh stack submit --open`. Publishing never merges —
  merging is a separate, explicitly authorized step (§7).
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
- **Every comment gets a reply on the PR — accepted, rejected, or already
  fixed. No exceptions.** Evaluate each on its merits against the actual code,
  then reply in its own thread so the resolution is visible where the comment
  was made:

  ```sh
  gh api repos/{owner}/{repo}/pulls/{n}/comments/{comment_id}/replies \
    -f body="$REPLY"
  ```

  A fix pushed without a reply reads as an ignored comment — the reviewer has
  to diff the branch to discover you agreed. Silence is the one response that
  costs a review cycle no matter which way you decided.

  Each reply states the verdict and the evidence, in one or two sentences:
  - **Accepted** — name the commit that fixes it and what it changed.
  - **Rejected** — the specific evidence that disproves it (the guard that
    already exists, the call site that cannot produce the shape, the test that
    covers it). Never reject on assertion alone.
  - **Partially accepted** — say which part you took, which you did not, and
    why. This is common on suggestions whose diagnosis is right but whose
    proposed fix conflicts with something the reviewer could not see.

  Verify a comment's claim against the code before answering it, including a
  bot's. Confirming a wrong finding to look agreeable puts a defect in the
  branch; measure first, then reply with what you measured.
- Commits pushed for CI or review fixes go through the same gates as the
  original diff: `/simplify` on substantive changes, the fast lint/type gate,
  and a signed commit.
- **Every push reopens the comment window.** A push invalidates the sweep you
  did before it: bot reviewers re-run against the new head, and a human reading
  the PR comments on what they now see. So after each push, poll for *both*
  checks and new comments, and keep polling until the checks settle — a review
  posted while CI was still running is the one most easily missed, because the
  natural stopping point is the green tick.

  ```sh
  gh api "repos/{owner}/{repo}/pulls/{n}/comments?per_page=100" \
    --jq '.[] | select(.in_reply_to_id == null) | {id, path, user: .user.login}'
  ```

  A top-level comment with no reply of yours beneath it is unaddressed. Treat
  the reply itself as a push: after posting one, check once more before you
  call the PR done.
- Poll efficiently — use the available wait/monitor mechanism instead of
  burning model turns on repeated status checks.

## 7. Merge only on explicit authorization

**Never merge on your own initiative.** Opening a green PR completes this
skill; merging is the user's decision and requires them to say so for these
specific PRs. A standing preference, an old approval, or "ship it" from earlier
in the session is not authorization for a merge now. If merging seems like the
obvious next step, say so and ask — do not infer it.

When the user does authorize it, **sweep for comments first, and treat the
sweep as a gate rather than a formality**:

1. Re-fetch the inline comments and the PR-level reviews on the current head
   (the query in §6). Authorization was given against the PR as the user last
   saw it; anything posted since is unseen by both of you.
2. If any comment is unanswered, or any answered comment has drawn a follow-up,
   **stop and address it before merging.** Merging over a live comment
   discards the review, and unlike a bad commit it cannot be undone by pushing
   again.
3. Confirm the checks are green on the head you are about to merge, not on an
   earlier commit.
4. Only then merge, using the repository's allowed method
   (`gh api repos/{owner}/{repo}` → `allow_squash_merge` / `allow_merge_commit`
   / `allow_rebase_merge`; assume nothing).

If a comment arrives between the authorization and the merge, the
authorization does not carry over it — report the new comment and ask again.

**Merge order across repositories is part of the ask.** When PRs in two repos
form one contract change, state the required order and follow it; merging a
consumer before the producer publishes a client for an API that does not exist
yet.

## Finish

Report PR URLs and bases, branches/worktrees, commits, the **final CI state**,
how each review comment was resolved, rollout constraints, and real blockers.
Do not narrate routine exploration. Do not report success while CI is red,
still running, or unchecked, or while any review comment lacks a posted reply —
a comment is addressed when the reply is on the PR, not when the fix is in the
diff.

State the merge status plainly: green and awaiting authorization, or merged and
by whose instruction. A green PR left unmerged is the expected end of this
skill, not an unfinished task — say so rather than implying something is
outstanding.
