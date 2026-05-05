---
name: wt
description: Create a new git worktree under ~/.worktrees/<repo>/<feature-name> with a cb/-prefixed branch. Use when the user invokes /wt or asks for a worktree, fresh sandbox copy, or feature branch isolation.
argument-hint: "[feature-name]"
---

# `/wt` — Create a worktree

Spin up a feature worktree under `~/.worktrees/<repo>/<feature-name>` with a `cb/`-prefixed branch off `main`. Then `cd` into it so the rest of the session works against the isolated copy.

## Default flow

When the user invokes `/wt`, do this without re-asking:

1. **Pick a feature name** — kebab-case, no slashes. Derive from the approved plan, the current task, or recent conversation.
2. **Create the worktree:**
   ```bash
   wt create <feature-name> cb/<feature-name> --from main
   ```
   - First positional arg = **directory name** (must NOT contain `/`).
   - Second positional arg = **branch name** (`cb/` prefix per the user's convention).
3. **Enter it** with a literal `cd` to the absolute path:
   ```bash
   cd ~/.worktrees/<repo>/<feature-name>
   ```
   The repo name is the basename of the main checkout (`basename "$(git rev-parse --show-toplevel)"` from inside the main repo).
4. **Confirm**: one-line "✓ Worktree at `<path>` on branch `cb/<feature-name>`. Ready."

`.env`, `.envrc`, and `.vscode` are auto-copied; git config is inherited. If the project ships a `.worktree-config.toml`, its `on-create` hooks also run automatically.

## Why not `wt jump` from Claude Code

`wt jump` is a **shell function** installed by `eval "$(worktree-bin init zsh)"`. It captures the binary's stdout (the worktree path) and `cd`s to it. Claude Code's Bash tool runs each command in a non-interactive subshell where that function isn't sourced, so `wt jump` exits silently with no `cd`.

Claude Code's Bash tool **does** preserve `cwd` across calls, so a plain `cd <absolute-path>` is the reliable pattern.

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

# Jump (interactive shell only — Claude Code uses cd)
wt jump <feature>

# List worktrees for the current repo
wt list --current

# Remove (use the feature name, not the branch)
wt remove <feature>
wt remove <feature> --delete-branch   # also delete the git branch

# Clean up orphaned git worktree refs (after a manual rm -rf)
wt cleanup

# Back to the main checkout (interactive shell only — Claude Code: cd to the main repo path)
wt back
```

## Gotchas

- **Feature name cannot contain `/`** — that's the directory. The `cb/` prefix lives on the **branch** arg only.
- **Two positional args** — `wt create <feature> <branch> --from main`. One arg drops you into an interactive prompt that fails under Claude Code's non-TTY Bash tool.
- **`wt jump` / `wt back` won't move Claude Code's CWD** — use `cd <absolute-path>` from a Claude Code Bash call.
- **Always use `cb/` prefix** on the branch.
- **Worktrees live at** `~/.worktrees/<repo>/<feature-name>` — the path uses the feature name, not the branch.
- **`wt jump` takes a feature name, never a branch** — see the section above. `wt list --current` is the canonical lookup.
