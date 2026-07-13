---
name: pr
description: "End-to-end hybrid ship loop: use Opus only for an approved plan, switch to Sonnet as the supervising harness, delegate implementation/review/PR/CI to one persistent Codex session, run one final Claude /code-review, and finish with a green reviewed ready-for-review (non-draft) PR. Use for 'ship this as a PR', 'build this end-to-end', or '/pr'."
argument-hint: "[feature-name]"
effort: high
---

# `/pr` — Opus plan → Sonnet supervisor → Codex ship → Claude review

Deliver a reviewed, green PR — always opened ready-for-review, never a draft — without using Opus as the implementation harness.

## Model and cost contract

- Start this workflow in a **fresh Claude session created after `model: opusplan` was configured**. Existing and resumed sessions keep their previous model selection.
- Use Opus only while producing the plan. Do not spawn agents, implement, or invoke `/code-review` from Plan Mode.
- Keep this skill at `high` effort. Use `ultrathink` on a single unusually hard planning turn instead of making the whole workflow `xhigh` or `max`.
- After approval, call `ExitPlanMode` before creating the worktree or delegating. `opusplan` then uses Sonnet for execution. If Plan Mode cannot be exited, stop before mutation.
- Sonnet supervises; Codex executes. Do not launch Claude `Agent` workers during implementation.
- Keep one persistent Codex thread for implementation and all fixes. Run one independent Codex review (`codex review`, see step 4) and one Claude `/code-review` pass per PR; allow one extra review only after substantial review-driven changes.
- **Rate-limit fallback (the one sanctioned exception to "no Claude Agent workers during implementation"):** if `codex exec` / `codex exec resume` fails with a usage-cap error (weekly or 5-hour Codex limit — distinct from a code/tool error), do not retry the same call. Stop using that Codex thread for the rest of the implementation and switch to a Claude `Agent` call with `subagent_type: general-purpose` and `model: opus`, working directly in the same worktree/branch, picking up exactly where Codex left off (git status/diff tell you where that is). State plainly in your next update that you switched and why. `codex review` (step 4) has no dependency on a live exec thread, so the review step can still run against whatever is committed even after switching implementation to an Opus subagent.
- **Codex model tier — default to the cheaper implementation model.** Query
  `~/.codex/models_cache.json` (`.models[].slug`/`.display_name`/`.description`)
  for the current lineup rather than hardcoding names here (it changes). As of
  this writing: `gpt-5.6-sol` (frontier, `xhigh` default — expensive, burns the
  5hr/weekly cap fast) vs `gpt-5.6-terra` (`"Balanced agentic coding model for
  everyday work"`) vs `gpt-5.6-luna` (`"Fast and affordable"`). Default the
  **implementation** thread (step 3) to `gpt-5.6-terra` at `medium` effort:
  `codex exec --json -m gpt-5.6-terra -c model_reasoning_effort=medium ...`
  (same flags on `codex exec resume`). Keep the strongest model, `gpt-5.6-sol`,
  for the **independent review** step (`codex review -m gpt-5.6-sol ...`, step 4)
  — review is a single bounded pass, not the long multi-hour loop that burns the
  rate limit, so the cost/quality tradeoff favors the frontier model there. Only
  use `sol` for implementation too if the user explicitly asks for max quality
  over cost.

## 1. Plan with Opus

Read `AGENTS.md` and the domain skills it routes to. Produce a decision-complete plan containing scope, affected files/contracts, regression coverage, verification, migration/rollout concerns, and explicit non-goals. For reported bugs, require the regression test to fail before the fix.

Present the plan for approval. Do not start implementation until it is approved.

## 2. Exit Plan Mode and isolate

Call `ExitPlanMode`, then invoke `/wt` to create or enter a `cb/<feature>` worktree from fresh `origin/main`. Copy `.env` from the primary Nebula checkout as `/wt` requires. Never edit the shared checkout.

**Run Codex without its own sandbox** — pass `--dangerously-bypass-approvals-and-sandbox` (this environment is already externally isolated in a git worktree, so Codex's filesystem sandbox adds nothing but breakage). Its `--sandbox workspace-write` mode makes the worktree's real gitdir (`<main-repo>/.git/worktrees/<name>`, which lives OUTSIDE the worktree dir) read-only, so Codex can edit files but **cannot `git add`/`commit`/`push`** and stalls before the first commit. Bypassing the sandbox lets Codex do its own commits/push/PR directly from the worktree, as the workflow intends. (If for some reason you do keep a sandbox, Sonnet must do all git operations directly instead — always a safe fallback.)

Record the absolute worktree path and approved plan in a small prompt file under a fresh state directory in `${TMPDIR:-/tmp}`. Do not place orchestration state in the repository.

## 3. Delegate the complete implementation loop to Codex

`$SKILL_DIR` below is this skill's own base directory (`/home/cjber/.claude/skills/pr`
— shown as "Base directory for this skill" when `/pr` is invoked), which is where
the permanent watch scripts live (`scripts/watch_human.sh`, `scripts/watch_digest.sh`).
It is distinct from `$STATE`, the per-run orchestration-state directory under
`${TMPDIR:-/tmp}` created in step 2.

Launch one persisted Codex execution from the worktree:

```bash
codex exec --json --cd "$WORKTREE" --dangerously-bypass-approvals-and-sandbox \
  -m gpt-5.6-terra -c model_reasoning_effort=medium \
  --output-last-message "$STATE/codex-last.md" - < "$STATE/codex-prompt.md" \
  | tee "$STATE/codex-events.jsonl"
```

The prompt must include the approved plan and say:

```text
Use $pr to implement this approved plan end-to-end in the current worktree.
Obey every applicable AGENTS.md and required domain skill. For a bug, prove the
regression test fails before the fix. Run focused checks and the repository's
full required check. Use $code-review plus one independent Codex review, make
signed commits, open a ready-for-review (non-draft) PR (or, if this session
already opened one for this repo, push to that same branch and update it rather
than opening another — one PR per repo per session), and drive CI/review
comments green. Never merge.
```

Run the launch as a background command (do not block the session on a multi-hour
`codex exec` call). Do not wait silently for the final completion notification —
set up two separate watch channels, since they have very different cost profiles:

### Watching progress — two channels, not one

There is no native `codex watch <thread-id>` spectator command. `codex exec --json`
streaming JSONL to stdout (`$STATE/codex-events.jsonl`) *is* the native mechanism —
everything below just formats that stream (plus a second, richer source — see
rate limits below). `codex resume <id>` is for *taking back interactive control* of
a session, not for passively watching one that's still running non-interactively;
don't use it as a spectator tool.

Both channels are **permanent scripts in this skill directory** (not
reconstructed inline each run, so they can't drift):
`scripts/watch_human.sh` and `scripts/watch_digest.sh`. Run-state
(`$STATE/codex-events.jsonl`, `codex-stderr.log`, etc.) stays in
`${TMPDIR:-/tmp}` per this skill's own orchestration rule — only the tooling
itself is permanent.

**Channel 1 — raw real-time tail, for the human, zero Claude tokens.** Give the
user this exact command to run in their own terminal — it never passes through
the assistant's context, so it can be as verbose and as real-time as they want
at no token cost:

```bash
bash "$SKILL_DIR/scripts/watch_human.sh" "$STATE"
```

**Channel 2 — a bounded, periodic ASCII digest, for the assistant, via `Monitor`.**
Do NOT attach `Monitor` directly to a raw `tail -f` of every event — each stdout
line is a Claude-side notification, so cost scales with how chatty Codex is on
that run, and a narration-heavy run can fire dozens of notifications back to back.
`watch_digest.sh` instead polls on a **fixed interval** (default ~90s — pass a
different value as `$2` if the user asks for faster/slower, e.g. per user request
this can go well under 90s; cost stays bounded either way since it's one digest
per interval, not one per raw event) and prints one compact digest per tick: new
narration/failures since the last tick (not raw event counts), plus rate-limit
and token-usage context (see below):

```bash
Monitor({
  command: "bash \"$SKILL_DIR/scripts/watch_digest.sh\" \"$STATE\" 90",
  persistent: true,
  timeout_ms: 3600000,
})
```

`persistent: true` because a real implementation run is multi-hour, well past
Monitor's default 300s/max 3600s single-shot timeout. If you need to restart the
digest mid-run (e.g. to change the interval), pass the current `wc -l <
"$STATE/codex-events.jsonl"` as a third argument (`START_LINE`) so it resumes
without replaying the full history as a wall of stale notifications.

**When relaying a digest tick to the user, re-render it as a compact plain-ASCII
box** (`+`/`-`/`|` borders, no Unicode box-drawing, matching the digest script's
own style) — not a prose paragraph. Pull the numbers out of the raw notification
and restate the activity as short bullet lines, e.g.:

```
+------------------------------------------------------------+
| CODEX PROGRESS                                             |
+------------------------------------------------------------+
| 5hr:  63% used (resets ~4h)                                |
| week: 10% used (resets ~6d)                                |
| tokens: 6.6M session | 191k last turn                      |
+------------------------------------------------------------+
| - Updated memory skill ownership map (graph -> flat paths) |
| - Now rewriting stale graph rules in the skill doc         |
+------------------------------------------------------------+
```

Keep it short — one box per tick, numbers + a couple of bullets, not the full raw
digest dump. **Always render the box, even for a routine/no-narration tick** (e.g.
bare command failures with no accompanying message, or a no-op heartbeat) — put
"no narration this interval" or similar as the one bullet rather than dropping to
plain prose or skipping the update. Consistency of format matters more than saving
a few lines on a quiet tick.

### Rate limits + token/context usage (NOT in the exec --json stream)

`codex exec --json`'s stdout stream does **not** carry usage/rate-limit data. That
lives in Codex's own internal session rollout file, one level richer than the
simplified exec stream:

```bash
TID=$(jq -r 'select(.type=="thread.started").thread_id' "$STATE/codex-events.jsonl" | head -1)
ROLLOUT=$(find ~/.codex/sessions -iname "*${TID}*" | head -1)
jq -c 'select(.payload.rate_limits != null) | .payload' "$ROLLOUT" | tail -1
```

That payload carries `.rate_limits.primary` (5-hour window: `used_percent`,
`window_minutes=300`, `resets_at` unix epoch) and `.rate_limits.secondary`
(weekly window: `window_minutes=10080`), plus `.info.total_token_usage` /
`.info.last_token_usage` / `.info.model_context_window` for session token spend
and context size. Fold a one/two-line ASCII block summarizing these into every
digest tick (see the digest script pattern above) — it's what tells you whether
an implementation run is approaching the same class of usage-cap error the
rate-limit fallback (above) exists to handle, before it actually happens.

**The 5hr/weekly limit is account-wide, not per-thread.** It can climb faster
than this run's own token usage would suggest if other unrelated `codex exec`
processes are running concurrently on the same machine/account (other sessions,
other jobs). Before treating a fast-climbing or 100%-used reading as this run's
fault or as an imminent hard stop, check `pgrep -af "codex exec"` for other
consumers. A `used_percent` of 100 is not itself a failure — the actual trigger
for the rate-limit fallback is `codex exec`/`resume` *returning* a usage-cap
error (check `$STATE/codex-stderr.log` for an `ERROR` line and confirm the
process actually exited via `CODEX_EXIT` before switching). A still-running,
still-producing process at 100% used_percent may just be near a soft ceiling —
keep watching, don't preemptively kill it.

Capture the thread id without exposing prompt contents:

```bash
jq -r 'select(.type == "thread.started") | .thread_id' \
  "$STATE/codex-events.jsonl" | head -1 > "$STATE/codex-thread-id"
```

Sonnet should inspect Codex's final report, `git status --short`, `git diff --stat origin/main...HEAD`, signed commits, and test/check results. Avoid rereading the whole codebase. If Codex is incomplete or off-plan, write focused feedback to a file and resume the same thread:

```bash
codex exec resume "$(<"$STATE/codex-thread-id")" \
  --output-last-message "$STATE/codex-last.md" - < "$STATE/codex-feedback.md"
```

Never use `resume --last` when other Codex sessions may be running.

## 4. Independent Codex review, then the Claude quality gate

Before opening the PR (or right after, against the pushed branch), run Codex's own built-in review command — a separate, non-implementing pass over the diff:

```bash
codex review -m gpt-5.6-sol --base main   # or --uncommitted if the changes aren't committed yet
```

Treat its findings the same way as a human reviewer's: real issues get fixed (resume the persistent implementation thread, or the Opus-subagent fallback if that thread is rate-limited), noise gets a one-line rationale for why it's not actioned.

Once that's clean, invoke `/code-review medium <pr#>` exactly once. This is the expensive multi-agent cross-check, not an inner development loop.

- If it finds nothing actionable, continue to the final gate.
- If it posts real findings, resume the same Codex thread with the exact findings (or the Opus-subagent fallback, per the cost contract, if Codex is rate-limited). Ask it to verify each one, fix valid issues, rerun required checks, create new signed commits, push, and resolve addressed threads.
- Do not rerun the full Claude review for small fixes. After substantial semantic fixes, permit one final `/code-review low <pr#>` and then stop the review loop.

## 5. Finish CI and review threads through Codex

Resume the same Codex thread and explicitly request `$gh-fix-ci` for failing Actions checks and `$gh-address-comments` for actionable review threads. Require root-cause fixes, local verification, signed commits, and pushes. Self-pace polling; do not repeatedly poll unchanged checks.

Terminate only when all required checks are green and no actionable review thread remains. Leave the PR ready-for-review (never draft) and unmerged.

## Handoff

Report the PR URL, worktree/branch, Codex thread id location (not credentials), signed commits, checks run, Codex review result, Claude review result, final CI state, and residual risks or external blockers.

## Fallback

If Codex is unavailable or unauthenticated, say so before implementation and fall back to the original direct `/wt` → implement → `/commit` → one `/code-review` → CI loop under Sonnet. Do not silently fall back to Opus execution or Claude agent fan-out.

**If auto mode's classifier blocks the `codex exec --dangerously-bypass-approvals-and-sandbox` launch itself** (seen: flagged as "functionally equivalent to full-auto" for a task with real blast radius — DB migrations, deleting core modules, opening a PR): don't try to reframe/retry around it. Stop, explain concretely what you're launching and why (the task's actual scope, not a vague description), and let the user unblock it explicitly if they want to proceed. Once unblocked for a given session, subsequent `codex exec resume` calls in the same session on the same thread are a continuation, not a new launch, and haven't re-triggered the same gate in practice — the risky moment is the *first* invocation, not every call after.
