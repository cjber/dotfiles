---
name: wt
description: "Creates an isolated git worktree on a cb/-prefixed branch off fresh origin/main via gwq (auto-copies .env, opens a zellij tab, auto-starts the repo's dev server) and prunes merged worktrees first. Use when the user wants a new worktree, to start isolated/parallel work on a feature or branch, or to spin up/clean up a scratch checkout, even if they don't say 'worktree' or 'wt'."
argument-hint: "[feature-name]"
---

# `/wt` — Create a worktree

Spin up a feature worktree on a `cb/`-prefixed branch off `origin/main`, then `cd` into it so the rest of the session works against the isolated copy.

Backed by **[gwq](https://github.com/d-kuro/gwq)** (`go install github.com/d-kuro/gwq/cmd/gwq@latest`), which replaced the unmaintained `worktree`/`worktree-bin` crate (it deleted the local `main` branch on `remove --delete-branch` — see Gotchas). gwq config lives at `~/.config/gwq/config.toml`: `basedir = ~/.worktrees`, `cd.launch_shell = false`, and per-repo `copy_files` that copy `.env*` / `.envrc` into each new worktree (so `dev_check.py` works immediately).

**gwq is branch-addressed.** A worktree *is* its branch — there's no separate "feature name vs directory" split the old tool had. The branch `cb/<feature>` lands in a directory `~/.worktrees/github.com/<owner>/<repo>/cb-<feature>` (the `/` in the branch is sanitized to `-` for the dir; the git branch keeps the slash). You address it by any unique substring of the branch, e.g. `<feature>`.

## Default flow

When the user invokes `/wt`, do this without re-asking:

1. **Prune merged worktrees first** — see [Prune merged worktrees](#prune-merged-worktrees). Run it silently before creating; it's a no-op when there's nothing to remove.
2. **Pick a feature name** — kebab-case, no slashes. Derive from the approved plan, the current task, or recent conversation.
3. **Create the branch off fresh `origin/main`, then add the worktree:**
   ```bash
   git fetch --quiet origin main
   git branch cb/<feature> origin/main      # base off FRESH origin/main, not the local checkout's HEAD
   gwq add cb/<feature>                      # worktree for the existing branch
   ```
   - gwq's `-b` flag branches off the *current HEAD*, which is usually NOT `main` here — so create the branch explicitly off `origin/main` first, then `gwq add` the existing branch. This also sidesteps the old "stale local `main`" gotcha.
   - If the branch already exists: `git branch -D cb/<feature>` first (when safe) or pick a new name.
4. **Capture the path** with `gwq get <feature>` — it prints the absolute path on stdout. Hold it in a shell variable; don't hand-build paths.
   ```bash
   wt_path="$(gwq get <feature>)"
   ```
5. **Open the worktree** depending on whether the user is inside zellij:
   - **If `$ZELLIJ` is set** (the common case from `mosh nuc`): spawn a new zellij tab named after the feature, cwd'd to the worktree, then split for the dev server when appropriate (see [Auto-start dev server](#auto-start-dev-server)).
     ```bash
     zellij action new-tab --name <feature> --cwd "$wt_path"
     ```
   - **Otherwise** (plain shell): `cd "$wt_path"` so the current shell follows.
6. **Confirm**: one-line "Worktree `cb/<feature>` ready at `<wt_path>`" plus, if you opened a server pane, what's running there.

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
zellij action new-pane --direction down --cwd "$wt_path" --name server -- bash -lc '<detected-command>'
zellij action move-focus up
```

If the user invoked `/wt <feature> --no-dev` (or context says no server is wanted), skip the split.

## Never move `main` off the main dir

The single hard invariant of this skill: **`main` must always stay checked out in the primary repo dir, and must never be deleted, moved, or relocated to a worktree.** Everything below is built to make that impossible.

- **Never run `gh pr merge --delete-branch` from inside a worktree.** gwq's old crate ancestor deleted the local `main` ref this way; even with gwq, deleting the PR branch while standing in its worktree is the footgun. Do merges and any branch deletion **from the main checkout** (the repo's primary dir, e.g. `/home/cjber/drive/agl/<repo>`), never from `~/.worktrees/...`. `gh pr merge` acts on the remote PR regardless of cwd, so there is no reason to run it from a worktree.
- **Don't delete the remote branch by hand.** GitHub auto-deletes the PR head branch on merge (repo setting). Locally you just `git fetch --prune` to drop the now-stale remote-tracking ref — see the prune flow below.
- **Recovery:** if `main` ever goes missing locally, `git branch main origin/main` from the primary dir restores it.

## Prune merged worktrees

Pruning is **a full local removal of each merged worktree (worktree dir + local branch) plus a remote-tracking prune** — the remote branch itself is already gone (auto-deleted on merge), so we never push a delete.

**Run the checked-in script — do NOT re-type an inline loop:**

```bash
bash /home/cjber/.claude/skills/wt/prune.sh /home/cjber/drive/agl/<repo>
```

(The repo-path argument is optional; it defaults to `$PWD`. The script is idempotent — safe to run before every worktree create.)

Everything the old inline snippet did lives in `prune.sh`, plus the fixes for the two ways the inline version kept breaking:
- **No gwq for removal.** `gwq remove` re-invokes `git` from PATH and dies silently in Claude Code's PATH-stripped pipeline subshells ("failed to list worktrees"), so runs reported success while removing nothing. The script uses plain `git worktree remove` + `git branch -D` and exports a sane PATH up front.
- **No side effects inside a pipeline.** The worktree list is collected to a temp file first, then acted on — nothing mutates inside a `| while read` subshell.

What the script enforces (unchanged contract):
- **GitHub-authoritative merged detection, ONE `gh` call.** A branch is removable iff its name is in the `gh pr list --state merged` head set, or it is a literal fast-forward ancestor of `origin/main` (no-PR local branch). No tree-equivalence heuristics — the old `git cherry` approach flagged unmerged branches as merged. Per-branch `gh pr view` calls get secondary-rate-limited to empty; never do that either.
- **Open-PR guard:** a branch with an open PR is always kept, even if a same-named merged PR exists.
- **Three main-safety guards:** refuses to run from a worktree, skips the main checkout dir, skips `main`/`master`.
- **Skip rules** (worktree kept if any apply): dirty working tree, open PR, not a `cb/` branch, directory missing, not merged.
- **Second pass:** merged `cb/` local branches with no worktree at all are also deleted (they accumulate otherwise).
- Ends with `git worktree prune` to mop up orphaned admin refs.

## How `gwq get`/`gwq cd` work under Claude Code

`gwq cd <feature>` is a **shell function** (installed by `source <(gwq completion zsh)` in `.zshrc`, active because `cd.launch_shell = false`) that resolves the path and `cd`s the *current* shell. Claude Code's non-interactive Bash subshell never sources that function, so `gwq cd` won't move the Bash tool's CWD.

The fix is to use `gwq get` (which just prints the path) inside a `cd`:
```bash
cd "$(gwq get <feature>)"
```
The Bash tool preserves the new CWD across subsequent calls — same outcome as the interactive shell, no path arithmetic.

`gwq get <pattern>` matches `<pattern>` against branch name or path. `<feature>` matches `cb/<feature>`. If multiple worktrees match, gwq opens a fuzzy finder — which hangs the non-TTY Bash tool, so pass a pattern unique enough to single-match (use the full `cb/<feature>` if needed). `gwq list` (run inside the repo) is the canonical lookup when unsure.

## Quick reference

```bash
# Create (branch off fresh origin/main, then add the worktree)
git fetch --quiet origin main && git branch cb/<feature> origin/main && gwq add cb/<feature>

# Resolve path / cd
gwq get <feature>                 # prints absolute path
cd "$(gwq get <feature>)"         # Claude Code Bash tool
gwq cd <feature>                  # interactive zsh (current-shell cd)

# List worktrees (current repo when inside it; --json for scripting; -g for all repos)
gwq list
gwq list --json

# Remove (full local removal = worktree dir + local branch). Run from the MAIN checkout.
gwq remove <feature>              # remove worktree, KEEP branch
gwq remove -b cb/<feature>        # also delete the local branch (names it explicitly — never main)
gwq remove -b --force-delete-branch cb/<feature>   # branch not merged

# Merge a PR — ALWAYS from the main checkout, never from a worktree, never --delete-branch
cd /home/cjber/drive/agl/<repo> && gh pr merge <pr#> --squash   # remote head branch auto-deletes on merge

# Clean up orphaned worktree admin refs (after a manual rm -rf)
gwq prune

# Status of all worktrees (git status across them)
gwq status

# Prune merged worktrees (idempotent, run from anywhere in the main checkout)
bash /home/cjber/.claude/skills/wt/prune.sh /home/cjber/drive/agl/<repo>
```

`wt` is aliased to `gwq` in `.zshrc` for muscle memory, so `wt add` / `wt get` / `wt cd` / `wt list` / `wt remove` / `wt prune` all work interactively. The verbs are gwq's, not the old tool's (`wt create`/`wt jump`/`wt cleanup` are gone — use `gwq add`/`gwq get`/`gwq prune`).

## Gotchas

- **Branch-addressed, not dir-addressed.** Address a worktree by its branch (or a unique substring), e.g. `gwq get <feature>` or `gwq remove -b cb/<feature>`. The directory is `cb-<feature>` (slash sanitized to dash) but you rarely name it directly.
- **`gwq -b` branches off current HEAD, not `main`.** Always `git branch cb/<feature> origin/main` first, then `gwq add cb/<feature>`. Don't use `gwq add -b cb/<feature>` from a non-main checkout — it inherits the wrong base.
- **`gwq cd`/`gwq get` won't move Claude Code's CWD via the alias** — use `cd "$(gwq get <feature>)"` in the Bash tool.
- **A bare `gwq get`/`gwq remove`/`gwq cd` with no/ambiguous pattern opens a fuzzy finder** that hangs the non-TTY Bash tool. Always pass a single-match pattern in scripts.
- **Always use the `cb/` prefix** on the branch.
- **Worktrees live at** `~/.worktrees/github.com/<owner>/<repo>/cb-<feature>` (gwq's host/owner/repo/branch hierarchy under `basedir`).
- **`.env*` / `.envrc` are copied** into each new nebula worktree via gwq `copy_files` (config). To add copy targets for another repo, add a `[[repository_settings]]` block in `~/.config/gwq/config.toml`.
- **Never merge or delete branches from inside a worktree.** `gh pr merge --delete-branch` (or any branch delete) run from a worktree is the footgun that can drop the local `main` ref. Always `cd` to the main checkout first; `gh pr merge` works on the remote PR from anywhere, so the worktree buys you nothing. The remote head branch auto-deletes on merge; locally `git fetch --prune` cleans the stale ref.
- **Pruning is gh-authoritative, not a guess.** Use `prune.sh` — a merged worktree is removed only when its branch name is in the one-call `gh pr list --state merged` head set (or the branch is a literal ancestor of `origin/main`). The old tree-equivalence/`git cherry` heuristic produced false positives on still-open, far-ahead branches, and per-branch `gh pr view` calls get rate-limited to empty — never resurrect either.
- **Old-tool fallout:** `worktree-bin remove --delete-branch` could delete the local `main` ref. gwq can't — it deletes only the explicitly-named branch of the worktree it's removing. If `main` ever goes missing locally, restore with `git branch main origin/main`.
