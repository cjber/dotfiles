---
name: review
description: "Canonical review entrypoint: review a target diff with two independent reviewers — Codex and Claude (Opus) — in parallel, have each vet the other's findings, and synthesize one ranked, deduplicated verdict. Targets a provided branch/range/PR, or the current branch vs origin/main when given no args. Review-only (delegates fixing). Use for 'review this branch', 'review PR 1234', or '/review'."
argument-hint: "[branch | base..head | PR# | (empty = current branch vs origin/main)]"
effort: high
---

# `/review` — parallel Codex + Opus review, cross-reconciled into one verdict

The single canonical review command. It reviews the target diff with **two independent reviewers running in parallel** — Codex and Claude (Opus) — has each vet the other's findings, and synthesizes **one** ranked, deduplicated verdict. This is the review counterpart to `/pr`'s parallel-draft → cross-review → you-own-it pattern.

**Review-only.** `/review` never implements. It calls `/code-review` as its Claude-side primitive; fixing is out of scope unless `--fix` is passed (which just delegates).

## Target resolution

Fetch `origin/main` fresh first, then resolve the argument:

- **no args** → the current branch's diff vs the merge-base with `origin/main`.
- **`<PR#>`** → that GitHub PR's diff.
- **`<base>..<head>`** or a bare **`<branch>`** → that range (branch vs `origin/main`).
- uncommitted local work → use Codex's `--uncommitted`.

## Model and cost contract

- **Claude runs in `opusplan`** — Opus for the final cross-reconciliation/verdict (the judgment step 3), Sonnet for the multi-agent `/code-review` pass and any per-worktree reviewer Agents (session default; no `model` override). Reserve an explicit `model: opus` Agent only where a reviewer genuinely needs Opus-level judgment. The user opted into this for cost — don't relitigate it.
- **Codex = `gpt-5.6-sol` at `low` effort, never the `fast` service tier** — review is a single bounded pass; sol at low is enough. Pass `-c service_tier="default"` so it doesn't inherit a `fast` default from `~/.codex/config.toml`. `-m`/`-c`/`-C` are **top-level** flags and MUST precede the `review` subcommand (`codex review -m …` fails with `unexpected argument '-m'`). (Confirm the slug against `~/.codex/models_cache.json`; the lineup changes — today `sol` frontier / `terra` balanced / `luna` fast.)

## 1. Two independent reviews, in parallel

Launch both concurrently — neither should see the other's output yet:

- **Codex** (background): global flags first, then `review`, then the review flag mapping the target —
  ```bash
  codex -m gpt-5.6-sol -c model_reasoning_effort=low -c service_tier="default" -C <dir> review --base origin/main   # branch/range
  # review-subcommand flags (AFTER `review`): --base <ref> | --uncommitted | --commit <SHA>
  ```
  Use `-C <dir>` to point Codex at a worktree instead of `cd`. Prefer `--base origin/main` over `--base main` (local `main` may lag origin). For a PR#, check its head into a worktree and review vs `origin/main`. **`--base`/`--uncommitted`/`--commit` are mutually exclusive with a custom `[PROMPT]`** (`the argument '--base' cannot be used with '[PROMPT]'`) — with `--base` you get Codex's default review instructions, so carry any focused scope in the Claude-side reviewer agents instead, not the Codex call.
  **Launch gotchas (bit me every time):** `codex` is usually a shell **alias** (adds `--dangerously-bypass-approvals-and-sandbox` etc.) that does NOT expand in non-interactive/background shells — call the real binary (`/usr/bin/codex`) with those flags inline. And in **zsh** an unquoted `$VAR` holding `"bin --flag"` does NOT word-split, so it's read as one filename — inline the command, don't stash it in a variable.
- **Claude** (concurrent): `/code-review medium` for a local diff, or `/code-review medium <PR#>` for a PR. This is the expensive multi-agent Claude pass. `/code-review` is cwd-bound to the current repo; for a **multi-repo / paired-PR** target (below) spawn one Opus `Agent` reviewer per worktree instead, each pointed at its worktree diff.

## 1b. Paired / multi-repo PRs (backend + web/mobile/desktop companions)

When the target is a set of coordinated PRs across repos (a backend change with frontend companions), review them as ONE job — the seam between them is the highest-value, most-missed surface:

- **Set up a clean worktree at each PR head** (`git worktree add --detach <wt> origin/<branch>`), so a dirty working checkout on another branch is never disturbed. Base every diff on the merge-base with that repo's `origin/main`.
- **Add a dedicated cross-repo contract pass** on top of the per-repo reviews: verify the backend PRODUCER actually emits the shape each client CONSUMER now parses (event kinds/discriminators, field names, units), and that no removed backend producer leaves a surviving frontend consumer. Per-repo passes each find their own repo internally consistent and structurally miss this drift.
- **Run cheap high-signal checks yourself** rather than outsourcing: byte-diff any files the PRs claim are "shared/identical" across repos; explicitly task a reviewer with the specific logic a PR body admits was buggy (e.g. a race the author already fixed once — hunt for the second).
- **Structure the verdict with a first-class cross-repo / contract section** so seam findings aren't buried under stacked per-repo lists.

## 2. Cross-reconcile the two reviews

Merge, don't concatenate:

- **Deduplicate** by `file:line` + defect — one entry when both reviewers land the same issue (note it was corroborated).
- **Each side vets the other's exclusives.** For a Codex-only or Claude-only finding, judge whether it's real and its severity; drop noise with a one-line rationale rather than silently. A finding only one reviewer caught still survives if it's valid — the point of two reviewers is catching what one misses.

## 3. Synthesize one verdict — you own it

Produce a single ranked list, most severe first. Per finding: `file:line`, severity, a one-line statement of the defect, a concrete failure scenario (inputs/state → wrong result), a suggested fix, and which reviewer(s) surfaced it. State residual uncertainty plainly. If nothing survives, say so — an empty verdict is a valid result.

## Output modes

- **default** — print the synthesized verdict; make no changes.
- **`--comment`** — post the reconciled findings as inline comments on the PR target (requires a PR). Reuse `/code-review --comment` for its share; add the Codex-surfaced ones.
- **`--fix`** — delegate application to `/code-review --fix` (or hand off to `/pr` for anything substantial). Off by default; `/review` stays review-only.

## Fallback

- **Codex unavailable/unauthenticated** → run the Claude `/code-review` alone and say the cross-review was skipped, so the verdict is single-reviewer.
- **Large diff** → resolve into file/area groups and reconcile per group, then merge; note any group you did not cover rather than silently truncating.
