---
name: pr
description: "End-to-end ship loop, opusplan on the Claude side (Opus plans, Sonnet executes): plan in parallel with Codex (both draft, cross-review, you synthesize), then implement in ONE worktree with Codex (terra) doing the bulk and a Claude arm doing a disjoint slice alongside for speed, cross-review, one /review, finishing with a single green ready-for-review (non-draft) PR per repo. Use for 'ship this as a PR', 'build this end-to-end', or '/pr'."
---

# `/pr` — parallel Opus+Codex plan → coordinated Codex+Opus build → cross-review → one green PR

Deliver a reviewed, green PR. Two non-negotiables, enforced throughout (full rules in §3, completion gate in §5): **(1) exactly ONE PR per repo** — every further change goes as a commit on that same branch, never a second PR; **(2) for the configured staging owner's work, task PRs target and stay current with `cb/staging`**, the personal pre-main branch run by `/dev`. This convention is advisory and must not redirect or gate other contributors. Only the final bundle promotion PR targets `main`. The PR is always opened ready-for-review, never a draft. Claude runs in `opusplan` (Opus plans, Sonnet executes); Codex carries the bulk of the implementation (terra) with a Claude arm working a disjoint slice alongside it for speed.

One narrowly-scoped bootstrap exception exists: infrastructure that must already
exist on the default branch to dispatch or maintain the staging workflow may use a
single installation PR directly to `main`. State the bootstrap reason in the PR,
never combine product work into it, and return immediately to staging-based task
PRs after CI synchronizes that commit into `cb/staging`.

## Model and cost contract

- **Claude runs in `opusplan`** — Opus for planning, Sonnet for execution. Run this skill in an `opusplan` session: the plan/synthesis turns (step 1) and the cross-review reconciliation (step 4) get Opus's judgment; the implementation-side Claude work (the disjoint arm in step 3, the CI/fix loops) runs on Sonnet. The user opted into this to keep cost down — do not relitigate it, and do NOT blanket-force `model: opus` on execution sub-agents. Reserve an explicit `model: opus` Agent only for genuine judgment slices (a hard planning fan-out, final review reconciliation); scouting and edits-only arms run on the session default (Sonnet under opusplan).
- Keep this skill at `high` effort. Use `ultrathink` on a single unusually hard planning turn rather than making the whole workflow `xhigh`/`max`.
- **Codex model + effort — three roles, and NEVER the `fast` service tier.** Query `~/.codex/models_cache.json` (`.models[].slug`/`.description`) for the current lineup rather than trusting hardcoded slugs — it changes. Today it's `gpt-5.6-sol` (frontier), `gpt-5.6-terra` (balanced everyday), `gpt-5.6-luna` (fast/cheap). Pass the model + effort explicitly on every call (self-contained beats inheriting `~/.codex/config.toml`, which may default to `fast`), and force the standard tier with `-c service_tier="default"` so no call silently bills at `fast`:
  - **Discovery / fan-out scouting** (optional, before step 1): `-m gpt-5.6-luna -c model_reasoning_effort=low -c service_tier="default"` — a fast, cheap, high-recall sweep to locate the relevant files/functions/symbols and hand a map to the planners, so sol/Opus don't burn reasoning blind-searching. Use it for larger/unfamiliar targets; skip it when the surface is already well-scoped. Prefer luna over a Haiku Explore pass for *code* discovery (coding-tuned, better grep/read tool use); one `codex exec` per scout, fan them out in parallel.
  - **Planning** (step 1) and **review** (step 4): `-m gpt-5.6-sol -c model_reasoning_effort=low -c service_tier="default"` — sol for the reasoning-heavy plan draft and the bounded cross-review pass.
  - **Implementation** (step 3): `-m gpt-5.6-terra -c model_reasoning_effort=medium -c service_tier="default"` — terra carries the long build/fix loop at medium effort.
- Keep one persistent Codex thread for implementation and all fixes. `codex review` (step 4) is a separate bounded pass, not part of the implementation loop.
- **Rate-limit fallback.** If `codex exec` / `codex exec resume` *returns* a usage-cap error (weekly or 5-hour Codex limit — distinct from a code/tool error; confirm via an `ERROR` line in `$STATE/codex-stderr.log` and a `CODEX_EXIT`, not merely a 100% `used_percent` reading), do not retry the same call. Because a Claude arm is **already implementing part of this feature in parallel** (step 3), the degradation is clean: hand the *remainder of Codex's slice* to that Claude arm (or a fresh `Agent`, `subagent_type: general-purpose`, in the same worktree, picking up from `git status`/`diff`), and skip the Codex cross-review. The `/review` gate still runs — with Codex capped it falls back to its Claude-only path (see `/review`'s fallback). State plainly that you switched and why.

## 1. Plan — Codex and Opus in parallel, cross-review, then you own it

Read `AGENTS.md` and the domain skills it routes to. Then produce the plan through a parallel-draft → cross-review → synthesize loop:

1. **In parallel**, kick off two independent drafts:
   - **Codex draft** (background): `codex exec` with sol at low effort, read-only, told to produce a decision-complete plan and **not** implement. Capture its final message with `--output-last-message` (that's written by the wrapper, so a read-only sandbox is fine — no git needed at plan time):
     ```bash
     cd "$REPO" && codex exec --json --sandbox read-only \
       -m gpt-5.6-sol -c model_reasoning_effort=low -c service_tier="default" \
       --output-last-message "$STATE/codex-plan.md" - < "$STATE/plan-prompt.md"
     ```
   - **Opus draft**: while Codex runs, you (Opus) draft your own plan from the same sources.
2. **Cross-review**: read Codex's plan and critique it; resume the same thread once with your plan for its critique. Keep this bounded — one exchange, not a debate.
3. **You own the synthesis.** Merge the two into one final plan: scope, affected files/contracts, regression coverage, verification, migration/rollout concerns, explicit non-goals, **and the implementation partition** (which files Codex owns vs. the Claude arm — see step 3). For a reported bug, require the regression test to fail before the fix.

Present the synthesized plan for approval. Do not start implementation until it is approved.

## 2. Exit Plan Mode and isolate — worktrees off fresh `origin/cb/staging`, one branch per repo

**ALWAYS work in fresh git worktrees — never in the primary checkouts under `$HOME/drive/agl/*`.** The primary checkouts are the user's own working space (often mid-task on a dirty feature branch); mutating them risks losing work. This is non-negotiable, even for a one-repo change.

**Before creating worktrees, fetch `main` and `cb/staging` without mutating primary checkouts:**
- For each affected repo, fetch both branches. If `origin/cb/staging` is absent, create it exactly from current `origin/main` and push it.
- Never switch, reset, merge, or otherwise clean a primary checkout. `$dev` owns synchronizing newer `main` into the shared staging branch in a dedicated staging worktree.

**One worktree per repo, off fresh `origin/cb/staging`.** Multi-repo change → a worktree for EVERY affected repo (backend + each frontend), not just the backend. Use `/wt` or plain `git worktree add -b cb/<feature> <path> origin/cb/staging`; copy `.env` (and `.env.local`) from that repo's primary checkout. Both implementation arms share the one worktree/branch per repo. Never edit a primary checkout.

**HARD RULE — give the worktree its OWN database, cloned from the primary checkout's; never share the primary/base DB.** A worktree that copies `.env` verbatim inherits the primary's `DATABASE_URL` and runs `dev_check`/`alembic` against the *same* shared local Postgres DB. That shared DB accumulates orphan tables from other branches — a model removed on `main` leaves its table behind with no drop migration — so the worktree's autogenerate check **falsely flags phantom drift**, and the run then burns cycles "fixing" it by authoring migrations that DROP tables which don't exist on a clean CI DB (real incident: a stale `user_progress_summary` orphan sent a whole run down this hole and produced a migration that would have broken the clean DB). Prevent it: after copying `.env`, provision a per-worktree database **seeded from the primary checkout's current DB** and repoint the worktree's `DATABASE_URL` at it — `createdb nebula_wt_<name> --template <primary_db>` (fast exact clone; requires no active connections to the template) or `pg_dump <primary_db> | psql nebula_wt_<name>`. This isolates the worktree (its runs can't mutate the primary's DB) and keeps its schema consistent with what `main` sees. If `alembic check` still flags *only* orphan tables afterward, the primary's DB itself carries cruft — seed a fresh DB with `alembic upgrade head` instead (matches the migration head exactly, no orphans). CI (clean DB) is always the drift arbiter: a local-only flag on unrelated tables is never a reason to write a migration.

**Run the implementation Codex without its own sandbox** — pass `--dangerously-bypass-approvals-and-sandbox` (this environment is already externally isolated in a git worktree, so Codex's filesystem sandbox adds nothing but breakage). Its `--sandbox workspace-write` mode makes the worktree's real gitdir (`<main-repo>/.git/worktrees/<name>`, which lives OUTSIDE the worktree dir) read-only, so Codex can edit files but **cannot `git add`/`commit`/`push`** and stalls before the first commit. Bypassing the sandbox lets Codex own commits/push/PR directly, as this workflow intends.

Record the absolute worktree path, the approved plan, and the file-ownership partition in a small prompt file under a fresh state directory in `${TMPDIR:-/tmp}`. Do not place orchestration state in the repository.

## 3. Coordinated parallel implementation — Codex (bulk) + Opus (slice), one branch, one PR

`$SKILL_DIR` below is this skill's deployed base directory (for example,
`$HOME/.claude/skills/pr`), where the permanent watch scripts live
(`scripts/watch_human.sh`, `scripts/watch_digest.sh`). It is distinct from
`$STATE`, the per-run orchestration-state directory under `${TMPDIR:-/tmp}`
created in step 2.

**Partition first, then launch both arms.** From the approved plan, split the work into **disjoint file/module ownership**: Codex owns the majority; an Opus `Agent` owns a smaller, self-contained slice, running alongside purely for speed. Write the exact ownership into both prompts. Neither arm touches the other's files.

**Git coordination — this is the part to get right.** To avoid a shared-index race, git is single-owner:

- **Codex owns the entire git lifecycle** of the branch — every signed commit, the push, the single PR, and CI. It only ever `git add`s its own files by explicit pathspec (never `git add -A`/`.`).
- **The Claude arm is edits-only.** It writes its slice and runs focused checks, but runs **no git at all** — no add, commit, push, or PR. When it finishes, you verify its slice, then **resume the Codex thread** to fold the Claude arm's files into signed commits and integrate.
- **No whole-tree checks during the parallel phase.** While both arms are live, each runs only *focused* checks scoped to its own files. The full `dev_check.py` / test suite (which imports/collects across all of `src/`) must NOT run mid-run — the other arm's in-flight *uncommitted* edits would fail it for a reason the running arm didn't cause and can't fix. The full check runs **once, after the Opus slice is folded in** and the tree is coherent.
- **HARD RULE — ONE PR per repo, no exceptions.** A session opens **exactly one** PR per affected repo. Once this session has opened a PR for a repo, EVERY further change to that repo — new work, review fixes, CI fixes, follow-on scope — is another signed commit pushed to that **same branch/PR**. NEVER open a second PR for a repo you already have one open in. Before opening a PR, check (`gh pr list --head <branch>` / recall this session's PRs); if one exists, push to it instead. Multi-repo work = one PR per repo (backend + each frontend), still one-per-repo. The only split is across a *repo boundary*, or a genuinely security-sensitive/independently-riskier change the user has agreed to carve out — and that carve-out is still one PR in its own right.
- **HARD RULE — every task PR must be up to date with `cb/staging` before handoff.** A long `/pr` run can take hours; staging moves as other work lands. Fetch `origin/cb/staging`, merge it into the task branch when behind, and never rebase or force-push. Resolve conflicts semantically, re-run the full repository gate, push, and verify `gh pr view <#> --json baseRefName,mergeable,mergeStateStatus` reports base `cb/staging` and a clean merge state. `$dev` separately keeps staging current with `main` and proves the integrated deployment.
- **HARD RULE — no PR ships with a stale generated SDK.** Any repo whose PR is affected by a backend API/OpenAPI change (the backend PR itself, or a frontend PR built against one) MUST regenerate its client SDK and commit the delta before finishing — never leave hand-edited or drifted generated code. Run the repo's generate script (`pnpm run build:generate` for nebula-web / nebula-mobile; `bun run sdk:generate` for nebula-desktop — check `package.json`), staging the generated dir by explicit pathspec. **Generate against the correct spec, not blindly against the default dev URL:** the generators pull `${NEBULA_URL:-https://api.nebula-dev.ai}/openapi.json` (override per repo: `NEXT_PUBLIC_NEBULA_URL` / `EXPO_PUBLIC_NEBULA_URL` / `API_URL`). If the backend branch's schema is **not yet deployed to that URL**, generating against it will silently *revert* the branch's schema additions — point the override at a local backend running the branch (or a dumped `openapi.json`) instead. Confirm the target actually serves the branch's new schemas before regenerating. For **paired frontend PRs**, regenerate all of them against the **same** spec so their SDKs stay mutually consistent, and do the frontend regen **after** the backend PR's schema has settled. An empty diff is the success signal (provably already in sync); a non-empty diff was real drift now fixed — commit it.

Launch both arms concurrently:

- **Codex** (background, the bulk):
  ```bash
  cd "$WORKTREE" && codex exec --json --dangerously-bypass-approvals-and-sandbox \
    -m gpt-5.6-terra -c model_reasoning_effort=medium -c service_tier="default" \
    --output-last-message "$STATE/codex-last.md" - < "$STATE/codex-prompt.md" \
    | tee "$STATE/codex-events.jsonl"
  ```
  Prompt shape:
  ```text
  Use $pr to implement YOUR SLICE of this approved plan end-to-end in the current
  worktree — only the files listed as Codex-owned; do NOT touch the Opus-owned
  files (you'll be told when to fold them in). Obey every applicable AGENTS.md and
  required domain skill. For a bug, prove the regression test fails before the fix.
  While the Claude arm is still working, run ONLY focused checks on your own files —
  do NOT run the full repo check suite yet (the Claude arm is editing other files
  uncommitted in this same worktree; a whole-tree check would trip on its in-flight
  edits). Own all git for this branch: signed commits (explicit pathspecs, never
  `git add -A`), open ONE ready-for-review (non-draft) PR (or push to this session's
  existing PR for this repo rather than opening another), and drive CI/review
  comments green. Never merge.
  ```
- **Claude arm** (concurrent, the disjoint slice): spawn a Claude `Agent`, `subagent_type: general-purpose` (session default model — Sonnet under opusplan; no `model` override), working directly in the same worktree. Prompt: implement only the Claude-arm-owned files, obey AGENTS.md + required skills, run focused checks, **run no git commands**, and report back when the slice is complete and checks pass.

Run the Codex launch as a background command (do not block the session on a multi-hour `codex exec`). Watch it through two channels; the Opus `Agent` reports back to you directly on completion.

### Watching Codex progress — two channels, not one

There is no native `codex watch <thread-id>` spectator command. `codex exec --json` streaming JSONL to stdout (`$STATE/codex-events.jsonl`) *is* the native mechanism — everything below just formats that stream (plus a second, richer source — see rate limits). `codex resume <id>` is for *taking back interactive control*, not passive watching; don't use it as a spectator tool.

Both channels are **permanent scripts in this skill directory** (not reconstructed inline, so they can't drift): `scripts/watch_human.sh` and `scripts/watch_digest.sh`. Run-state stays in `${TMPDIR:-/tmp}`; only the tooling is permanent.

**Channel 1 — raw real-time tail, for the human, zero Claude tokens.** Give the user this exact command to run in their own terminal — it never passes through the assistant's context:

```bash
bash "$SKILL_DIR/scripts/watch_human.sh" "$STATE"
```

**Channel 2 — a bounded, periodic ASCII digest, for the assistant, via `Monitor`.** Do NOT attach `Monitor` to a raw `tail -f` of every event — each stdout line is a Claude-side notification, so a narration-heavy run fires dozens back to back. `watch_digest.sh` polls on a **fixed interval** (default ~90s — pass a different value as `$2` if the user wants faster/slower; cost stays bounded either way, one digest per tick) and prints one compact digest per tick: new narration/failures since the last tick, plus rate-limit and token context (below):

```bash
Monitor({
  command: "bash \"$SKILL_DIR/scripts/watch_digest.sh\" \"$STATE\" 90",
  persistent: true,
  timeout_ms: 3600000,
})
```

`persistent: true` because a real run is multi-hour, past Monitor's 3600s single-shot cap. To restart the digest mid-run (e.g. to change the interval), pass the current `wc -l < "$STATE/codex-events.jsonl"` as a third argument (`START_LINE`) so it resumes without replaying stale history.

**When relaying a digest tick to the user, re-render it as a compact plain-ASCII box** (`+`/`-`/`|` borders, no Unicode box-drawing) — not prose. Pull the numbers out and restate as short bullets:

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

Keep it short — one box per tick. **Always render the box, even for a routine/no-narration tick** — put "no narration this interval" as the one bullet rather than dropping to prose or skipping. Consistency of format matters more than saving a few lines.

### Rate limits + token/context usage (NOT in the exec --json stream)

`codex exec --json`'s stdout does **not** carry usage/rate-limit data. That lives in Codex's own session rollout file:

```bash
TID=$(jq -r 'select(.type=="thread.started").thread_id' "$STATE/codex-events.jsonl" | head -1)
ROLLOUT=$(find ~/.codex/sessions -iname "*${TID}*" | head -1)
jq -c 'select(.payload.rate_limits != null) | .payload' "$ROLLOUT" | tail -1
```

The payload carries `.rate_limits.primary`/`.secondary` (each with `used_percent`, `window_minutes`, `resets_at` unix epoch) plus `.info.total_token_usage` / `.info.last_token_usage` / `.info.model_context_window`. **Key the windows off `window_minutes` (300 = 5-hour, 10080 = weekly), not the primary/secondary slot name** — which window lands in which slot varies by plan. Fold a one/two-line ASCII block into every digest tick.

**The 5hr/weekly limit is account-wide, not per-thread.** It can climb faster than this run's own usage if other `codex exec` processes run concurrently. Before treating a fast-climbing or 100% reading as this run's fault or an imminent stop, check `pgrep -af "codex exec"`. A `used_percent` of 100 is not itself a failure — the trigger for the rate-limit fallback is `codex exec`/`resume` *returning* a usage-cap error. A still-producing process at 100% may just be near a soft ceiling — keep watching.

Capture the thread id without exposing prompt contents:

```bash
jq -r 'select(.type == "thread.started") | .thread_id' \
  "$STATE/codex-events.jsonl" | head -1 > "$STATE/codex-thread-id"
```

Inspect Codex's final report, `git status --short`, `git diff --stat origin/cb/staging...HEAD`, signed commits, and check results — avoid rereading the whole codebase. To send focused feedback or trigger integration, resume the same thread. **Integration order once both arms report done:** (1) resume Codex to fold the Claude arm's now-verified files into signed commits so the tree is coherent, then (2) run the full `dev_check.py` / suite once over the whole worktree — this is the first point a whole-tree check is valid. Fix any fallout on the same thread.

```bash
codex exec resume "$(<"$STATE/codex-thread-id")" \
  -m gpt-5.6-sol -c model_reasoning_effort=low \
  --output-last-message "$STATE/codex-last.md" - < "$STATE/codex-feedback.md"
```

Never use `resume --last` when other Codex sessions may be running.

## 3.5. Verify agent-visible surfaces end-to-end (`cli verify`)

`dev_check.py` proves the code is correct; it does NOT prove the LLM actually picks the new tool, that a renamed event lands with the right shape, or that a reworded prompt/skill steers behaviour. For any **agent-visible** surface in the diff, drive it end-to-end with the existing `/cli` skill's `cli verify` (one real prompt per surface against a real user, on `nebula:auto`) — don't hand-roll a new harness:

```bash
uv run cli verify \
  --prompt "<naturalistic prompt that should exercise the surface>" \
  --user <real_user_id_or_omit_for_the_eval_test_user> \
  --require-tool <expected_tool> --forbid-tool <tool_that_must_not_fire> \
  --report "$STATE/verify-<surface>.json"
```

Run it for: agent-facing tool descriptions / param annotations / toolset registration; system-prompt sections and bundled-skill/SKILL.md bodies; new/renamed event types or discriminators; explore/plan-mode filters; agent-reachable HTTP endpoints. Then read the report (`jq '.tool_calls[].name'`, `.final_message`, `.events[].type`) and confirm the fields the `/cli` surface-recipe names. A failing surface is fixed on the same branch before the review gate. **Skip** it for pure-infra diffs (refactors, migrations, build config) with no agent-visible behaviour — it's a real billed LLM call.

**Sandbox constraint (known):** `cli verify` provisions only a *stub* device (`ensure_test_device` → `vm_name=None`, no exe.dev VM — the eval `sandbox_pool` warm-VM borrow is used by the full eval `runner.py`, NOT the ad-hoc verify path). So it validates tool-routing / prompt / event / description surfaces, but a prompt needing a **live sandbox (bash, file writes)** fails with "device deprovisioned / create a new device" in a dev env without a real device. For sandbox-dependent behaviour, lean on real-shell unit tests (run the composed command through host `bash`/`find`) and say plainly in the handoff that the live-sandbox path was not exercised. Do not treat a "sandbox gone" verify as a branch failure.

## 4. Cross-review, then the Claude quality gate

Once both slices are integrated on the branch:

1. **Cross-review the arms against each other.** Run Codex's built-in review over the whole diff (a separate, non-implementing pass):
   ```bash
   codex review -m gpt-5.6-sol -c model_reasoning_effort=low -c service_tier="default" --base cb/staging
   # or --uncommitted if changes aren't committed yet
   ```
   And have the Opus side review Codex's bulk slice (you, or the Claude arm). Treat findings like a human reviewer's: real issues get fixed (resume the persistent Codex thread, or the Claude arm per the fallback if Codex is rate-limited), noise gets a one-line rationale.
2. **The review gate.** Once cross-review is clean, invoke `/review <pr#>` exactly once — the expensive multi-agent cross-check, not an inner loop.
   - Nothing actionable → continue to the final gate.
   - Real findings → resume the same Codex thread (or the Claude arm) with the exact findings; verify each, fix valid ones, rerun required checks, new signed commits, push, resolve addressed threads.
   - Don't rerun the full review for small fixes. After substantial semantic fixes, permit one final `/review <pr#>`, then stop.

## 5. Finish CI and review threads through Codex

Resume the same Codex thread and explicitly request `$gh-fix-ci` for failing Actions checks and `$gh-address-comments` for actionable review threads. Require root-cause fixes, local verification, signed commits, and pushes. Self-pace polling; do not repeatedly poll unchanged checks.

**Final step — a runtime `cli verify` pass over the FINAL diff.** The §3.5 pass ran mid-flow; review fixes, the merge-with-staging, and CI fixes have changed the tree since. So as the **last action before termination**, re-derive the testable surfaces from the *final* `git diff origin/cb/staging` (not the set you noticed at §3.5) and re-run `cli verify` (one real prompt per surface, on `nebula:auto`) over everything agent-visible that changed — this catches surfaces added or altered during review/merge. Enumerate any surface you skip and *why* (pure-infra with no agent-visible behaviour, or live-sandbox-blocked per §3.5's known constraint) — never a silent skip. A failing surface is fixed on the same branch and the pass re-run; terminate only on a green final pass (or an explicitly-justified skip list).

Terminate only when ALL of these hold: required checks green; no actionable review thread remains; the **final `cli verify` pass over the final diff** (above) is green or every skipped surface is explicitly justified (sandbox-blocked / infra-only); the branch is **up to date with `origin/cb/staging`** (fetch + merge staging and re-run the full gate if it drifted; `gh pr view` shows base `cb/staging` and `MERGEABLE`/`CLEAN`, not `CONFLICTING`/`BEHIND`); and this repo has exactly **one** task PR (this one). Leave it ready-for-review and unmerged. After approved task PRs land, `$dev` owns composed `/dev` verification and the eventual `cb/staging` → `main` promotion PR.

## Handoff

Report the PR URL, worktree/branch, the Codex/Opus implementation split, Codex thread-id location (not credentials), signed commits, checks run, both review results (Codex + Claude), the `cli verify` result per agent-visible surface (and any sandbox-blocked surface), final CI state, and residual risks or external blockers.

## Fallback

If Codex is unavailable or unauthenticated, say so before implementation and have the **Claude arm implement the whole feature** directly in the worktree, then `/commit` → one `/review` → CI loop, still as a single PR. This is the opusplan session default (Sonnet execution); escalate a specific slice to an explicit `model: opus` Agent only if it needs Opus-level judgment.

**If auto mode's classifier blocks the `codex exec --dangerously-bypass-approvals-and-sandbox` launch itself** (seen: flagged as "functionally equivalent to full-auto" for a task with real blast radius — DB migrations, deleting core modules, opening a PR): don't reframe/retry around it. Stop, explain concretely what you're launching and why (the task's actual scope), and let the user unblock it explicitly. Once unblocked for a session, subsequent `codex exec resume` calls on the same thread are a continuation, not a new launch, and haven't re-triggered the gate in practice — the risky moment is the *first* invocation.
