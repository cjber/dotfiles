---
name: commit
description: Analyze git changes, create a signed commit, open a PR, and poll CI + review comments until they settle
allowed-tools: Bash, Read, Glob, Grep, Edit
---

# Commit + PR + Poll

End-to-end ship loop: from a clean working tree of staged-or-unstaged changes to an open PR with all CI signal accounted for. Three phases: **commit → PR → poll**.

## Phase 1 — Commit

1. `git status` (no `-uall` — memory issues on large repos), `git diff`, and `git log -5 --oneline` in parallel to understand state + style.
2. Draft a Conventional-Commits message (per project CLAUDE.md): `feat:` / `fix:` / `chore:` / `refactor:` / `docs:` / `test:` / `ci:` / `perf:` / `build:`. Keep title under ~70 chars; body explains the *why*.
3. Stage with explicit file list — never `git add -A` / `git add .` (sweeps secrets, build artifacts).
4. Commit with `git commit -S` (signing is mandatory per repo CLAUDE.md) using a HEREDOC for clean formatting:
   ```bash
   git commit -S -m "$(cat <<'EOF'
   <title>

   <body — paragraphs or bullets>

   Co-Authored-By: Claude <model> <noreply@anthropic.com>
   EOF
   )"
   ```
5. Pre-commit hooks may run — `python scripts/dev_check.py` is the gate. If a hook fails, **fix the underlying issue and create a NEW commit** (never `--amend`, never `--no-verify`).

## Phase 2 — PR

1. `git push -u origin <branch>` (only push if not already on the remote, or if there are new commits).
2. `gh pr create --title "<conv-commit title>" --body "$(cat <<'EOF' ... EOF)"`. Body sections:
   - **Summary** — 1–3 bullets, what changed and why
   - **Scope notes** — anything that diverged from plan, anything explicitly out of scope
   - **Test plan** — `[x]` for what's already verified (e.g. `dev_check.py`), `[ ]` checklist for what still needs human sign-off
3. PR title must match Conventional Commits (the `pr-title-lint` workflow blocks merge if it doesn't).
4. Capture the PR number from the create output for Phase 3.

## Phase 3 — Poll

Poll CI and review comments until they settle. The loop is self-paced — use `ScheduleWakeup` to come back without burning cache.

### What to check each pass

```bash
gh pr checks <pr#>
gh pr view <pr#> --json comments,reviews,reviewDecision \
  --jq '{decision: .reviewDecision,
         comments: [.comments[] | {author: .author.login, body: (.body[0:300])}],
         reviews:  [.reviews[]  | {author: .author.login, state: .state, body: (.body[0:300])}]}'
```

Optionally also: `gh api repos/<owner>/<repo>/pulls/<pr#>/comments --jq '.[] | {path, line, body: (.body[0:300])}'` for inline review comments (different endpoint from `pr view comments`).

### Termination

Stop polling and report when **any** of the following is true:

- All checks have settled (no `pending`) AND no actionable review comments are open.
- Any check has `fail` — surface the failing job name + URL and stop. Don't reschedule on a failure; the user needs to decide whether to fix and push or close.
- A human reviewer left a `CHANGES_REQUESTED` review or actionable inline comments — surface them concisely (file:line, ask) and stop. Polling further wastes cache; the ball is in your court / the user's.
- CodeRabbit's automated review has posted (look for `coderabbitai` in `reviews` with `state` set, not just the in-progress placeholder comment) and you've extracted any non-noise findings.

### Cadence

Use `ScheduleWakeup` with the same `/commit` prompt — passing the PR number through context — so the loop resumes itself.

| Situation | Suggested `delaySeconds` |
|---|---|
| First wake-up after PR open (CodeRabbit + fast checks) | 270 (cache-warm) |
| Long unit/integration suites still pending | 270 then 1200 |
| Genuinely idle (waiting on human review) | 1800–3600 |

Don't pick 300s — it pays the cache miss without amortising it. Stay under 270s for active checks; jump to 1200s+ once you're just waiting.

### Reporting

When the loop terminates, give the user a tight summary:

- Final CI status: counts of pass/fail/skipped, failing job links.
- Review state: `APPROVED` / `CHANGES_REQUESTED` / `COMMENTED` / none, plus any actionable inline asks (file:line).
- Suggested next action: address comments, merge, or wait for a specific reviewer.

Don't dump the full check list or comment bodies — summarise. The user can click into the PR for the rest.

## Notes

- **Never** `--amend` or `--force-push` without explicit user say-so.
- **Never** include `# noqa: PLC0415` lazy imports for circulars without first trying to restructure (per global feedback memory).
- **Never** skip hooks (`--no-verify`, `--no-gpg-sign`).
- If `git status` shows unfamiliar files or branches, investigate before committing — they may be the user's in-progress work.
- The signature line uses the runtime model name (e.g. `Claude Opus 4.7 (1M context)`) — match what the actual model identifies as.
