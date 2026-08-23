---
name: issue
description: "Two modes. With issue number(s): turns each GitHub issue into a concrete, file-level implementation plan under `~/.claude/plans/` (planning only, no commits). With NO args: triages every open issue in the repo, clarifies scope with the user (pushing for the largest batch), plans them in parallel, then builds them serially onto one branch as signed per-issue commits and opens a SINGLE non-draft PR closing all of them. Use when the user gives an issue number, asks to review/scope/plan a GitHub issue ('look at issue 3765'), or asks to triage/clear/close out the whole issue backlog ('/issue', 'triage all issues', 'close as many issues as you can')."
argument-hint: "[issue-number] [issue-number...]   (omit all args to triage the whole backlog)"
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, WebFetch, AskUserQuestion, Workflow
---

# `/issue` - Issue review, plan, and backlog triage

Two modes, picked by whether the user passed issue numbers:

- **Mode A - specific issue(s)** (`/issue 3765` or `/issue 3765 3801`): turn each into a file-level implementation plan under `~/.claude/plans/`. Planning only; no commits, no branches. This is the **Flow** / **Multi-issue runs** sections below.
- **Mode B - whole backlog** (`/issue` with no args): triage every open issue, clarify scope with the user, then drive as many in-scope issues as possible into **one ready-for-review PR**. See **Mode B: triage the backlog**.

Repo is whatever `gh repo view --json nameWithOwner -q .nameWithOwner` returns from the current working directory. Never assume an org.

## Flow (Mode A)

For each issue, do steps 1 through 4 in order. Run independent reads in parallel (multiple `gh` calls, multiple `Read`s, multiple greps in one message).

### 1. Fetch

```bash
gh issue view <n> --json number,title,state,body,labels,assignees,milestone,author,createdAt,closedAt,comments,url
gh api repos/{owner}/{repo}/issues/<n>/timeline \
  --jq '.[] | select(.event=="cross-referenced" or .event=="referenced" or .event=="closed") | {event, src: (.source.issue.html_url // .commit_id // null)}'
```

- Capture: title, body, every comment, labels, state, author, all cross-referenced PRs/issues/commits.
- For each linked PR: `gh pr view <pr#> --json title,state,body,commits,files,reviewDecision` to see what was tried, what merged, what was abandoned.
- If the issue is closed, surface that prominently. The user may want a retro or follow-up plan, not a fresh implementation plan.
- If the body has external links (Linear, Notion, Slack archive, screenshots) that look load-bearing, fetch with `WebFetch` and quote the relevant fragment.

### 2. Investigate the code

Before drafting anything, map the actual code surface:

- Pull every file path, symbol, identifier, and error string mentioned in the issue body and comments.
- For each, `grep -rn "<symbol>"` from the repo root (or appropriate src/ root). Note call sites with `path:line`.
- `Read` the 3 to 5 most central files end-to-end. Skim the rest to confirm structure.
- If the issue references a commit SHA: `git show <sha> --stat` then `git log <sha>..HEAD -- <paths>` to see drift since.
- If the repo has a `CLAUDE.md`, read it for layout conventions (where tools, runtime, models, integrations live) and follow them in the plan's path references.

Don't speculate about code you haven't opened. Don't write the plan from the issue text alone. If the issue is vague, the investigation phase tells you what to ask.

### 3. Synthesise the plan

If the issue is materially ambiguous - a fork in the approach where
guessing wrong would mean replanning, not a detail you can default -
run `/grilling` to resolve it with the user *before* writing the plan,
rather than baking a guess into the steps and dumping it in "Open
questions." Open questions are for things to confirm at review time;
they are not a place to launder decisions you could have made now.

Write to `~/.claude/plans/<slug>.md` where `<slug>` = `<repo>-<issue#>-<kebab-title>`. Sections, in order:

1. **Issue summary** - 2 to 4 sentences. What's broken or wanted, who reported it, current state, link to the issue.
2. **Current behaviour** - what the code does today, with `path/to/file.py:LN` refs for each relevant function or branch. Quote short snippets only when they clarify a subtlety.
3. **Desired behaviour** - what should change, derived from the issue and comments. If the comments reframed the problem, lead with the reframed version.
4. **Approach** - numbered implementation steps. Each step names the file and roughly where (function, class, or section). Each step should map to one logical commit.
5. **Tests and verification** - how we'll know it works. Defer to the repo's CLAUDE.md and existing test patterns; favour pure-function unit tests, integration tests for orchestration, and project-specific benchmark runs for any behaviour that depends on an LLM. Avoid constant-checking and mock-the-world tests.
6. **Risks and edge cases** - what could regress; concurrent-write hazards; soft-delete cascades; cache invalidation; LLM-judgment fragility; auth-scope changes; migration ordering.
7. **Out of scope** - adjacent things the issue might tempt us into but we're explicitly deferring.
8. **Open questions** - what to confirm with the user, the issue author, or a reviewer before merging. Empty list is fine.

Keep references concrete. `path/to/file.py:142` beats "the function that does X." One sentence per bullet; the reader can click through.

Style rules for the plan body:
- No em-dashes anywhere. Use hyphens, commas, or rephrase.
- No user names, emails, or first-person identifiers in the plan content. Use synthetic placeholders if examples are needed.
- No web3 / token / wallet / crypto examples in fixtures or scenarios.
- Match existing project conventions (Conventional Commits, signed commits, `uv run sift check` gate, factory methods on models, no `dict[str, Any]` where Pydantic fits).

### 4. Report

In chat, after the plan file is written:

- Issue title, state, URL.
- Plan file absolute path.
- Top 3 risks or open questions, one line each.
- Suggested next step (typical: `/wt <slug>` to start the worktree, then implement step 1).

Don't paste the full plan back. The file is the source of truth.

## Multi-issue runs

When the user passes multiple numbers, write one plan file per issue. After all files are written, give a one-line digest per issue plus a single "what to start with" recommendation based on dependency, blast radius, and whether one issue's fix subsumes another.

## Mode B: triage the backlog (no args)

Triggered by `/issue` with no issue numbers (or "triage all issues" / "close as many issues as you can"). Goal: drive **as many open issues as possible into ONE ready-for-review PR in a single run**. Never asks the user to pick one issue - it scopes a batch and goes.

The shape is **triage -> clarify scope (push for the largest batch) -> parallel plan, serialized build -> one PR -> report**. The per-issue build reuses the `ship-while-you-sleep` runbook (worktree, signed commit, green check gate); this mode adds the backlog triage, the batch orchestration, and the single-PR bundling around it.

### B1. Triage every open issue

```bash
gh issue list --state open --limit 300 \
  --json number,title,labels,assignees,milestone,comments,updatedAt,author
```

Read enough of each to classify (skim bodies in parallel batches; spawn an `Explore`/`general-purpose` subagent if the backlog is large and you only want the conclusions back). Classify each issue into exactly one bucket - branch explicitly, no silent "other":

- **shippable** - well-scoped, no product/design decision needed, plausibly reaches a commit autonomously.
- **needs-decision** - real work but blocked on a product/architecture/design call only the user can make.
- **needs-info** - blocked on missing repro / detail from the reporter.
- **stale / maybe-closeable** - old, superseded, or already-fixed; candidate to close with a comment (never auto-close without user sign-off).
- **too-big** - an epic / multi-PR effort; plan-only, not a one-run build.

Also note dependency clusters (issues that share a file surface or where one fix subsumes another) - those land as adjacent commits in the bundle, and the ordering matters when one fix subsumes another.

### B2. Clarify scope - push for the largest batch

Use `AskUserQuestion`. **Lead with the most aggressive option and mark it `(Recommended)`** - the explicit ask here is "how big a bite", and the default answer should be the biggest one that's safe. Offer scope as a single multi-select or a single-select of batch sizes, e.g.:

- **All shippable (~N issues)** `(Recommended)` - build every shippable issue onto one branch, one commit each, one PR closing all of them.
- **A themed slice** - e.g. "all the tool-description bugs", "everything touching billing" - largest coherent cluster.
- **Top K by confidence** - the K highest-confidence shippable issues only.
- **Plan-only across the whole backlog** - no PR; one plan file per shippable+too-big issue (the safe Mode-A-at-scale option).

Also confirm the depth in the same question or a second one: **one bundled PR** (default for shippable) vs **plans only**. Do not ask the user to enumerate issues - you present the batches, they pick the bite size. If the answer is obvious from their phrasing ("close as many as you can" = All shippable + one bundled PR), skip the question and state the scope you're running, per `feedback_skip_askquestion_when_obvious`.

Report the triage counts before/with the question so the user sees the whole backlog shape: `triaged N open: X shippable, Y needs-decision, Z needs-info, W stale, V too-big`.

### B3. Plan in parallel, build serially on one branch

Everything in the batch lands on **one branch in one worktree**. Only the read-only planning phase fans out.

1. **Plan (parallel).** Fan out one investigator per issue - subagents, or a single `Workflow` if the batch is large enough to want deterministic control flow (this skill telling you to call `Workflow` is the explicit opt-in). Each does the Mode-A investigation (fetch, map code surface, write the plan file) and returns `{shippable: bool, slug, summary, plan_path, skip_reason}`. **No agent in this phase edits, commits, or branches** - concurrent writers on one branch corrupt each other.
2. **Order the batch.** Sort by dependency: a fix that subsumes another comes first; issues sharing a file surface sit adjacent so their commits do not conflict.
3. **Build (serialized).** One worktree, one branch off the default branch, named for the batch (not for any single issue). Work the ordered list yourself, one issue at a time: implement, stage an explicit file list (never `git add -A`), run the repo's check gate (`uv run sift check` here), and only on green make **one signed commit per issue** (`git commit -S`) whose message names the issue. A red gate or a mid-build blocker **drops that issue to plan-only** - revert its edits, leave the branch clean, record the blocker, move to the next. Never force a low-confidence commit onto a shared branch.
4. **One PR, ready for review.** After the last issue, run `/simplify` over the whole diff, then `/code-review`, then push and open a **single non-draft PR** for the whole batch. Never `--draft`. The body carries, per issue, its own `Closes #<n>` line (`Closes #A, #B` closes only A - one keyword per issue), plus the plan link and test plan for each. Title is Conventional Commits describing the batch.

Hard rules (never cross autonomously):

- **Stop at an open PR.** Merging is a separate step and needs the user's authorization *at merge time* - ambient approval from earlier in the session never carries (`feedback_confirm_before_merge`). Never trigger Push to Production (`feedback_never_push_to_production`).
- **One PR per repo, not per issue.** Keep adding commits to the same branch; a batch spanning two repos gets one PR each. Split out a separate PR only for a change that is security-sensitive or independently riskier and would otherwise block the safe work behind it.
- **Never `--draft`.** Copilot/bot review skips drafts, so a draft PR is a PR nobody reviews.
- If the branch already exists from an earlier run of this batch, keep appending commits to it and update the existing PR's title/body as scope grows - do not open a second PR.
- Local checks share one Postgres on this machine, which is another reason the build phase is serialized: `migrate` / `sift check` must never run concurrently against the same DB (see `reference_local_postgres_shared_across_worktrees`).

### B4. Report

After the run, one consolidated table:

- Per in-scope issue: outcome (`committed <sha>` / `plan-only: <reason>` / `blocked: <reason>` / `skipped: <reason>`), with links.
- The single PR: number, URL, and the full list of issues it closes.
- Counts: `shipped P issues in PR #NNN, planned Q, blocked R, skipped S` out of the batch.
- The untouched buckets (needs-decision / needs-info / stale) listed for the user to action, with a one-line suggested next step each (a decision to make, info to request, or a close-with-comment).
- Suggested next step: review the PR; confirm explicitly before any merge.

Plans still live at `~/.claude/plans/`. Nothing merges without explicit user confirmation given at merge time.

## Notes

- Plans live at `~/.claude/plans/`. Don't put them in the repo, don't commit them.
- **Mode A never branches, commits, or pushes.** Use `/wt` to start the worktree once the plan is approved, then `/commit` once changes are ready. **Mode B** does branch/commit/push and opens one ready-for-review PR, but it never merges and never pushes to a default branch.
- If the same issue already has a plan file, read it first and update in place rather than writing a sibling.
- If the issue is in a different repo than the current cwd, surface that mismatch and confirm before proceeding.
- Memory check: before writing the plan, scan `~/.claude/projects/<cwd-slug>/memory/MEMORY.md` for any existing project memory tied to the issue. Cite and reuse rather than rediscover.
