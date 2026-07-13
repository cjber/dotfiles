---
name: wt
description: "Creates an isolated git worktree on a cb/-prefixed branch off fresh origin/main using plain `git worktree` (worktrees live under ~/.worktrees, .env is copied in, an optional zellij tab + dev server open), and prunes merged worktrees first. Use when the user wants a new worktree, to start isolated/parallel work on a feature or branch, or to spin up/clean up a scratch checkout, even if they don't say 'worktree' or 'wt'."
argument-hint: "[feature-name]"
---

# `/wt` — Create a worktree

Spin up a feature worktree on a `cb/`-prefixed branch off `origin/main`, then `cd` into it so the rest of the session works against the isolated copy.

Backed by **plain `git worktree`** — no external tool. The unmaintained `worktree`/`worktree-bin` crate and `gwq` were both dropped: the crate deleted the local `main` branch on `remove --delete-branch`, and gwq re-invokes `git` from PATH and dies silently in Claude Code's PATH-stripped pipeline subshells. Plain `git worktree` is the single source of truth here — it never touches a branch you don't name, and it's what `prune.sh` already uses.

## The two hard invariants

1. **Worktrees live under `~/.worktrees/<repo>/cb-<feature>`.** Never scatter them into the repo dir, a sibling dir, or a job tmp dir. `~/.worktrees` is *the* worktree root.
2. **The repo's main dir stays on `main`, always.** The primary checkout (e.g. `/home/cjber/drive/agl/<repo>`) is never checked out to a feature branch, never has `main` deleted/moved, and is never itself turned into a worktree. All feature work happens in a `~/.worktrees/...` worktree. Everything below is built to make violating this impossible.

`<repo>` is the repo dir's basename; the branch `cb/<feature>` lands in `~/.worktrees/<repo>/cb-<feature>` (the `/` in the branch is sanitized to `-` for the dir; the git branch keeps the slash).

## Default flow

When the user invokes `/wt`, do this without re-asking:

1. **Prune merged worktrees first** — see [Prune merged worktrees](#prune-merged-worktrees). Run it silently before creating; it's a no-op when there's nothing to remove.
2. **Pick a feature name** — kebab-case, no slashes. Derive from the approved plan, the current task, or recent conversation.
3. **Create the branch off fresh `origin/main`, then add the worktree** — always **from the repo's main checkout** (never from inside another worktree):
   ```bash
   repo="$(git rev-parse --show-toplevel)"          # the main checkout
   name="$(basename "$repo")"
   wt="$HOME/.worktrees/$name/cb-<feature>"
   git -C "$repo" fetch --quiet origin main
   git -C "$repo" worktree add "$wt" -b cb/<feature> origin/main   # branch off FRESH origin/main
   ```
   - `-b cb/<feature> origin/main` bases the branch on `origin/main`, NOT the current HEAD — so a stale local `main` or a feature checkout can't leak in.
   - If the branch already exists: `git -C "$repo" branch -D cb/<feature>` first (when safe — it's merged/unwanted) or pick a new name.
   - `git worktree add` creates the branch, the worktree dir, and its admin ref atomically. It refuses to overwrite a non-empty dir.
4. **Copy `.env*` / `.envrc` in** so `dev_check.py` / the dev server work immediately (git worktree does NOT copy untracked files):
   ```bash
   for f in .env .env.local .env.development .envrc; do
     [ -f "$repo/$f" ] && cp "$repo/$f" "$wt/$f"
   done
   ```
5. **Open the worktree** depending on whether the user is inside zellij:
   - **If `$ZELLIJ` is set** (the common case from `mosh nuc`): spawn a new zellij tab named after the feature, cwd'd to the worktree, then split for the dev server when appropriate (see [Auto-start dev server](#auto-start-dev-server)).
     ```bash
     zellij action new-tab --name <feature> --cwd "$wt"
     ```
   - **Otherwise** (plain shell): `cd "$wt"` so the current shell follows (the Bash tool preserves CWD across calls).
6. **Confirm**: one-line "Worktree `cb/<feature>` ready at `<wt>`" plus, if you opened a server pane, what's running there.

## Auto-start dev server

When opening a new zellij tab, detect the repo's dev command and start it in a split pane so the user sees the server come up alongside their shell. Layout: shell on top (focused), server below.

**Detection priority** (first match at the worktree root):

| Detected | Dev command | Note |
|---|---|---|
| `bun.lockb` present, **or** `package.json` with `"packageManager": "bun@…"` | `bun dev` (or `bun start` if no `dev` script) | nebula-cli, nebula-desktop |
| `package.json` with a `dev` script | `pnpm dev` | Next.js (nebula-web, nebula-docs), most Node monorepos |
| `package.json` with `expo` dep and a `start` script | `pnpm start` | nebula-mobile |
| `Makefile` with a `dev` target | `make dev` | python services wrapping uv/uvicorn |
| `pyproject.toml` with `uvicorn`/`fastapi` in deps | `uv run uvicorn <module>:app --reload` (module from `[tool.uvicorn]` or `main.py`) | nebula backend |
| None of the above | skip the split — just open the shell tab |

Check bun *before* pnpm — some repos have both lockfiles in transition and bun is the actual tool.

Run the detected command in a split pane *below*:
```bash
zellij action new-pane --direction down --cwd "$wt" --name server -- bash -lc '<detected-command>'
zellij action move-focus up
```

If the user invoked `/wt <feature> --no-dev` (or context says no server is wanted), skip the split.

## Never move `main` off the main dir

The single hard invariant restated (invariant 2 above): **`main` must always stay checked out in the primary repo dir, and must never be deleted, moved, or relocated to a worktree.**

- **Never run `gh pr merge --delete-branch` or any branch delete from inside a worktree.** The old crate deleted the local `main` ref this way; even with plain git, deleting a branch while standing in its worktree is the footgun. Do merges and branch deletion **from the main checkout** (`/home/cjber/drive/agl/<repo>`), never from `~/.worktrees/...`. `gh pr merge` acts on the remote PR regardless of cwd, so there is no reason to run it from a worktree.
- **Don't delete the remote branch by hand.** GitHub auto-deletes the PR head branch on merge (repo setting). Locally you just `git fetch --prune` to drop the now-stale remote-tracking ref — see the prune flow.
- **Recovery — missing `main`:** `git branch main origin/main` from the primary dir restores it.
- **Recovery — missing whole `.git`** (repo shows "not a git repository", working tree intact): re-init in place without losing the working tree —
  ```bash
  git init -b main && git remote add origin <url> && git fetch origin
  git reset --mixed origin/main          # HEAD -> main, working tree untouched; `git status` shows any local drift
  git reset --hard origin/main           # only once you've confirmed nothing local is worth keeping
  ```

## Prune merged worktrees

Pruning is **a full local removal of each merged worktree (worktree dir + local branch) plus a remote-tracking prune** — the remote branch itself is already gone (auto-deleted on merge), so we never push a delete.

**Run the checked-in script — do NOT re-type an inline loop:**

```bash
bash /home/cjber/.claude/skills/wt/prune.sh /home/cjber/drive/agl/<repo>
```

(The repo-path argument is optional; it defaults to `$PWD`. The script is idempotent — safe to run before every worktree create.)

What the script enforces:
- **GitHub-authoritative merged detection, ONE `gh` call.** A branch is removable iff its name is in the `gh pr list --state merged` head set, or it is a literal fast-forward ancestor of `origin/main` (no-PR local branch). No tree-equivalence heuristics — the old `git cherry` approach flagged unmerged branches as merged. Per-branch `gh pr view` calls get secondary-rate-limited to empty; never do that either.
- **Open-PR guard:** a branch with an open PR is always kept, even if a same-named merged PR exists.
- **Three main-safety guards:** refuses to run from a worktree, skips the main checkout dir, skips `main`/`master`.
- **Skip rules** (worktree kept if any apply): dirty working tree, open PR, not a `cb/` branch, directory missing, not merged.
- **Second pass:** merged `cb/` local branches with no worktree at all are also deleted (they accumulate otherwise).
- Ends with `git worktree prune` to mop up orphaned admin refs (e.g. a worktree dir removed out-of-band).

The scheduled `wt-cleanup.timer` (systemd user timer) runs the same `prune.sh` across every repo listed in `~/.config/wt-cleanup/repos.conf`, so the manual and automatic paths share one implementation.

## Quick reference

```bash
# Create (branch off fresh origin/main, then add the worktree under ~/.worktrees)
repo="$(git rev-parse --show-toplevel)"; name="$(basename "$repo")"
git -C "$repo" fetch --quiet origin main
git -C "$repo" worktree add "$HOME/.worktrees/$name/cb-<feature>" -b cb/<feature> origin/main
cd "$HOME/.worktrees/$name/cb-<feature>"

# List worktrees (run inside the repo or any of its worktrees)
git worktree list
git worktree list --porcelain

# Remove a worktree (from the MAIN checkout). Removes the dir + admin ref; branch is kept.
git -C "$repo" worktree remove ~/.worktrees/<repo>/cb-<feature>
git -C "$repo" branch -D cb/<feature>           # then delete the (merged) branch explicitly — never main
git -C "$repo" worktree remove --force ...       # if the worktree is dirty/locked and you're sure

# Merge a PR — ALWAYS from the main checkout, never from a worktree, never --delete-branch
cd /home/cjber/drive/agl/<repo> && gh pr merge <pr#> --squash   # remote head branch auto-deletes on merge

# Clean up orphaned worktree admin refs (after a manual rm -rf of a worktree dir)
git -C "$repo" worktree prune

# Prune merged worktrees (idempotent, run from the main checkout)
bash /home/cjber/.claude/skills/wt/prune.sh /home/cjber/drive/agl/<repo>
```

`wt` is aliased to `git worktree` in `~/.zshalias`, so `wt list` / `wt add` / `wt remove` / `wt prune` all work interactively as plain git-worktree subcommands.

## Gotchas

- **Worktrees live at `~/.worktrees/<repo>/cb-<feature>`** — nowhere else. If you find worktrees under a repo-local `.worktrees/`, a sibling `<repo>-worktrees/`, or a job tmp dir, they're strays from before this convention; relocate new work to `~/.worktrees` and let `prune.sh` retire the merged ones.
- **`git worktree add` bases the branch on whatever ref you pass.** Always pass `origin/main` explicitly (`-b cb/<feature> origin/main`) — omitting it bases on the current HEAD, which is usually not `main`.
- **The Bash tool preserves CWD across calls**, so a plain `cd "$wt"` is enough to follow the worktree — no shell-function or path arithmetic needed.
- **Always use the `cb/` prefix** on the branch (the prune tooling only touches `cb/*`).
- **`.env*` / `.envrc` must be copied in** after `git worktree add` (step 4) — git worktree only materializes tracked files, so untracked env files don't come along.
- **Never merge or delete branches from inside a worktree.** `gh pr merge --delete-branch` (or any branch delete) run from a worktree is the footgun that can drop the local `main` ref. Always `cd` to the main checkout first; `gh pr merge` works on the remote PR from anywhere, so the worktree buys you nothing.
- **Pruning is gh-authoritative, not a guess.** Use `prune.sh` — a merged worktree is removed only when its branch name is in the one-call `gh pr list --state merged` head set (or the branch is a literal ancestor of `origin/main`). The old tree-equivalence/`git cherry` heuristic produced false positives on still-open, far-ahead branches, and per-branch `gh pr view` calls get rate-limited to empty — never resurrect either.
- **If a repo's `.git` disappears** ("not a git repository") the working tree is usually intact — restore in place with the re-init recipe in [Never move `main` off the main dir](#never-move-main-off-the-main-dir) rather than re-cloning.
