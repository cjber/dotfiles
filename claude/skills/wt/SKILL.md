---
name: wt
description: Create a git worktree under ~/.worktrees/<repo>/<feature-name> on a cb/-prefixed branch. Inside zellij, also open a new tab named after the feature and (when a dev command is detectable from package.json/Makefile/pyproject) split a side pane running the server. Use when the user invokes /wt or asks for a worktree, sandbox copy, or feature branch.
argument-hint: "[feature-name]"
---

# `/wt` — Create a worktree

Spin up a feature worktree under `~/.worktrees/<repo>/<feature-name>` with a `cb/`-prefixed branch off `main`. Then `cd` into it so the rest of the session works against the isolated copy.

## Default flow

When the user invokes `/wt`, do this without re-asking:

1. **Prune merged worktrees first** — see [Prune merged worktrees](#prune-merged-worktrees) below. Run it silently before creating; it's a no-op when there's nothing to remove.
2. **Pick a feature name** — kebab-case, no slashes. Derive from the approved plan, the current task, or recent conversation.
3. **Create the worktree:**
   ```bash
   wt create <feature-name> cb/<feature-name> --from main
   ```
   - First positional arg = **directory name** (must NOT contain `/`).
   - Second positional arg = **branch name** (`cb/` prefix per the user's convention).
4. **Capture the path** by running `worktree-bin jump <feature-name>` — it prints the absolute path on stdout. Hold this in a shell variable for the next steps; don't hand-build `~/.worktrees/<repo>/<feature-name>` paths.
5. **Open the worktree** in a way that depends on whether the user is inside zellij:
   - **If `$ZELLIJ` is set** (the common case from `mosh nuc`): spawn a new zellij tab named after the feature, cwd'd to the worktree. Then split it for the dev server when appropriate — see [Auto-start dev server](#auto-start-dev-server) below.
     ```bash
     wt_path=$(worktree-bin jump <feature-name>)
     zellij action new-tab --name <feature-name> --cwd "$wt_path"
     ```
   - **Otherwise** (plain shell, no multiplexer): `cd "$wt_path"` so the current shell follows.
6. **Confirm**: one-line "Worktree `cb/<feature-name>` ready at `<wt_path>`" plus, if you opened a server pane, what's running there.

## Auto-start dev server

When opening a new zellij tab, detect the repo's dev command and start it in a split pane so the user sees the server come up alongside their shell. Layout: shell on the left (focused), server on the right.

**Detection priority** (use the first match found at the worktree root):

| Detected | Dev command | Note |
|---|---|---|
| `bun.lockb` present, **or** `package.json` with `"packageManager": "bun@…"` | `bun dev` (or `bun start` if no `dev` script) | nebula-cli, nebula-desktop |
| `package.json` with a `dev` script | `pnpm dev` | covers Next.js (nebula-web, nebula-docs), most Node monorepos |
| `package.json` with `expo` dep and a `start` script | `pnpm start` | nebula-mobile |
| `Makefile` with a `dev` target | `make dev` | most python services that wrap uv/uvicorn |
| `pyproject.toml` with `uvicorn`/`fastapi` in deps | `uv run uvicorn <module>:app --reload` (look up module name from `[tool.uvicorn]` or `main.py`) | nebula backend |
| None of the above | skip the split — just open the shell tab |

Check bun *before* pnpm — some repos have both lockfiles in transition and bun is the actual tool.

Run the detected command in a split pane:
```bash
zellij action new-pane --direction right --cwd "$wt_path" --name server -- bash -lc '<detected-command>'
```

Then switch focus back to the left (shell) pane:
```bash
zellij action move-focus left
```

If the user explicitly invoked `/wt <feature> --no-dev` (or you can tell from context that a server isn't wanted), skip the auto-start and just open the tab.

## Prune merged worktrees

`wt cleanup` only removes **orphaned git refs** (dir was `rm -rf`'d but the `git worktree` ref remained). It does NOT remove healthy worktrees whose branch has already been merged. Run this loop from the **main checkout** (not a worktree) to drop those.

**Important details:**
- Use **absolute paths** for `git`/`awk`/`basename` etc. The Bash tool's pipeline subshells sometimes strip PATH, so bare `git` inside a `while read` body silently fails.
- **Detect squash-merges** — `--is-ancestor` only catches fast-forward / true merges. Most PRs are squash-merged on GitHub, leaving the local branch tip with a tree that's identical to a commit on `main` but a different parent chain. The trick: synthesize a one-parent commit from the branch's tree and ask `git cherry` whether `main` already contains an equivalent (`-` in cherry output = already there).

```bash
/usr/bin/git fetch --quiet origin main
/usr/bin/git worktree list --porcelain | /usr/bin/awk '/^worktree /{p=$2} /^branch /{print p, $2}' \
  | while read path ref; do
      [ "$path" = "$(/usr/bin/git rev-parse --show-toplevel)" ] && continue   # skip main checkout
      branch=${ref#refs/heads/}
      [ -d "$path" ] || continue                                              # missing dir → wt cleanup handles it
      [ -z "$(/usr/bin/git -C "$path" status --porcelain 2>/dev/null)" ] || continue   # skip dirty
      tip=$(/usr/bin/git rev-parse "$branch" 2>/dev/null) || continue
      mb=$(/usr/bin/git merge-base origin/main "$branch" 2>/dev/null) || continue
      merged=0
      if [ "$mb" = "$tip" ]; then
        merged=1                                                               # fast-forward / true merge
      else
        synth=$(/usr/bin/git commit-tree "$branch^{tree}" -p "$mb" -m _ 2>/dev/null)
        /usr/bin/git cherry origin/main "$synth" 2>/dev/null | /usr/bin/grep -q '^-' && merged=1   # squash-merged
      fi
      [ $merged -eq 1 ] && wt remove "$(/usr/bin/basename "$path")" --delete-branch
    done
wt cleanup   # mop up any newly-orphaned refs
```

**Skip rules** (a worktree is kept if any apply):
- Directory missing (handled by `wt cleanup` afterwards).
- Working tree is dirty (uncommitted changes).
- Branch tip is neither an ancestor of `origin/main` nor tree-equivalent to a commit on it.

Always run from the main checkout — `git worktree list` shows everything from anywhere, but `wt remove` resolves feature names relative to the current repo's worktree root, so staying in main avoids edge cases.

`.env`, `.envrc`, and `.vscode` are auto-copied; git config is inherited. If the project ships a `.worktree-config.toml`, its `on-create` hooks also run automatically.

## How `wt jump` works under Claude Code

`wt jump` (the **shell function** installed by `eval "$(worktree-bin init zsh)"`) does two things: runs `worktree-bin jump <feature>` to capture the worktree path on stdout, then `cd`s to it. Claude Code's non-interactive Bash subshell never sources the function, so the bare alias `wt jump` exits silently with no `cd`.

The fix is to do the same thing the function does, explicitly: `cd "$(worktree-bin jump <feature>)"`. The binary still resolves the path, you still `cd` into it, and Claude Code's Bash tool preserves the new `cwd` across subsequent calls. Same outcome as an interactive shell, no path arithmetic on your end.

Use `wt list --current` first if you don't know the feature name.

## Why `wt jump cb/<branch-name>` fails (even in your interactive shell)

`wt jump` only takes the **feature name (directory name)**, never a branch. The binary's argument is the dir under `~/.worktrees/<repo>/`, and dirs can't contain `/` — so `wt jump cb/foo` always returns "No worktree found matching 'cb/foo'".

It used to feel like it worked when the dir name and branch name were the same (no prefix). Now that branches use `cb/<name>` while dirs are plain `<name>`, the two have diverged.

**Find the right name to jump to:**
```bash
wt list --current   # feature name on the left, branch in (parens) on the right
```

Pass the **left column** to `wt jump`:
```bash
wt jump miniapp-launch-polish   # ✓ — dir name
wt jump cb/miniapp-launch-polish   # ✗ — branch name
```

## Quick reference

```bash
# Create
wt create <feature> cb/<feature> --from main

# Jump — interactive shell uses the alias; Claude Code captures the binary stdout
wt jump <feature>                           # interactive zsh
cd "$(worktree-bin jump <feature>)"         # Claude Code Bash tool

# List worktrees for the current repo
wt list --current

# Remove (use the feature name, not the branch)
wt remove <feature>
wt remove <feature> --delete-branch   # also delete the git branch

# Clean up orphaned git worktree refs (after a manual rm -rf)
wt cleanup

# Prune merged worktrees (run from main checkout) — see "Prune merged worktrees" section

# Back to the main checkout (interactive shell only — Claude Code: cd to the main repo path)
wt back
```

## Gotchas

- **Feature name cannot contain `/`** — that's the directory. The `cb/` prefix lives on the **branch** arg only.
- **Two positional args** — `wt create <feature> <branch> --from main`. One arg drops you into an interactive prompt that fails under Claude Code's non-TTY Bash tool.
- **`wt jump` (the alias) and `wt back` won't move Claude Code's CWD** — wrap the binary instead: `cd "$(worktree-bin jump <feature>)"` or `cd "$(worktree-bin back)"`.
- **Always use `cb/` prefix** on the branch.
- **Worktrees live at** `~/.worktrees/<repo>/<feature-name>` — the path uses the feature name, not the branch.
- **`wt jump` takes a feature name, never a branch** — see the section above. `wt list --current` is the canonical lookup.
