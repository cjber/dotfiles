---
name: issue
description: Fetch a GitHub issue (and any linked PRs/issues), investigate the relevant code, and write a comprehensive implementation plan to ~/.claude/plans/. Use when the user invokes /issue <number> or asks for a full plan against one or more issues.
argument-hint: "[issue-number] [issue-number...]"
allowed-tools: Bash, Read, Glob, Grep, Edit, Write, WebFetch
---

# `/issue` - Issue review and plan

Turn a GitHub issue into a concrete, file-level implementation plan. Output is one plan file per issue under `~/.claude/plans/`, plus a tight in-chat summary. Planning only; no commits, no branches.

## Inputs

- One or more issue numbers as positional args: `/issue 3765` or `/issue 3765 3801`.
- If no number is supplied, ask which issue and stop until answered.
- Repo is whatever `gh repo view --json nameWithOwner -q .nameWithOwner` returns from the current working directory. Never assume an org.

## Flow

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
- For Nebula specifically (per project CLAUDE.md): tools live in `src/nebula/tools/`, agents in `src/nebula/agents/`, runtime in `src/nebula/runtime/agent/core.py`, SQL belongs on the model class, integration adapters in `src/services/integration/`.

Don't speculate about code you haven't opened. Don't write the plan from the issue text alone. If the issue is vague, the investigation phase tells you what to ask.

### 3. Synthesise the plan

Write to `~/.claude/plans/<slug>.md` where `<slug>` = `<repo>-<issue#>-<kebab-title>` (e.g. `nebula-3765-agent-gets-lost.md`). Sections, in order:

1. **Issue summary** - 2 to 4 sentences. What's broken or wanted, who reported it, current state, link to the issue.
2. **Current behaviour** - what the code does today, with `path/to/file.py:LN` refs for each relevant function or branch. Quote short snippets only when they clarify a subtlety.
3. **Desired behaviour** - what should change, derived from the issue and comments. If the comments reframed the problem, lead with the reframed version.
4. **Approach** - numbered implementation steps. Each step names the file and roughly where (function, class, or section). Each step should map to one logical commit.
5. **Tests and verification** - how we'll know it works. Per project CLAUDE.md: prefer pure-function unit tests, integration tests for orchestration, and `uv run benchmark` cases for any LLM-facing change (tool descriptions, system prompts, agent-facing schemas). Avoid constant-checking and mock-the-world tests.
6. **Risks and edge cases** - what could regress; concurrent-write hazards; soft-delete cascades; cache invalidation; LLM-judgment fragility; auth-scope changes; migration ordering.
7. **Out of scope** - adjacent things the issue might tempt us into but we're explicitly deferring.
8. **Open questions** - what to confirm with the user, the issue author, or a reviewer before merging. Empty list is fine.

Keep references concrete. `src/nebula/runtime/agent/core.py:142` beats "the agent loop." One sentence per bullet; the reader can click through.

Style rules for the plan body:
- No em-dashes anywhere. Use hyphens, commas, or rephrase.
- No user names, emails, or first-person identifiers in the plan content. Use synthetic placeholders if examples are needed.
- No web3 / token / wallet / crypto examples in fixtures or scenarios.
- Match existing project conventions (Conventional Commits, signed commits, `dev_check.py` gate, factory methods on models, no `dict[str, Any]` where Pydantic fits).

### 4. Report

In chat, after the plan file is written:

- Issue title, state, URL.
- Plan file absolute path.
- Top 3 risks or open questions, one line each.
- Suggested next step (typical: `/wt <slug>` to start the worktree, then implement step 1).

Don't paste the full plan back. The file is the source of truth.

## Multi-issue runs

When the user passes multiple numbers, write one plan file per issue. After all files are written, give a one-line digest per issue plus a single "what to start with" recommendation based on dependency, blast radius, and whether one issue's fix subsumes another.

## Notes

- Plans live at `~/.claude/plans/`. Don't put them in the repo, don't commit them.
- This skill never branches, commits, or pushes. Use `/wt` to start the worktree once the plan is approved, then `/commit` once changes are ready.
- If the same issue already has a plan file, read it first and update in place rather than writing a sibling.
- If the issue is in a different repo than the current cwd (e.g. user is in `nebula` but asks about an issue in `dashboard`), surface that mismatch and confirm before proceeding.
- Memory check: before writing the plan, scan `~/.claude/projects/<cwd-slug>/memory/MEMORY.md` for any existing project memory tied to the issue (e.g. `project_agent_gets_lost.md` for #3765). Cite and reuse rather than rediscover.
