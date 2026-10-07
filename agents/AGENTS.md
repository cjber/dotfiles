## Response length

Keep responses focused, brief, and concise. Keep disclaimers and caveats short,
and spend most of the response on the main answer. When asked to explain
something, give a high-level summary unless an in-depth explanation is
specifically requested.

Match the length of written documents and files to what the task needs: cover
the substance, but do not pad with filler sections, redundant summaries, or
boilerplate.

## Compact instructions

On compaction, preserve the current goal, user decisions, changed files, failing
checks, exact error messages, and the next verification step. Drop superseded
plans, routine command output, repeated instructions, and completed exploration.

## Working preferences

These are my own preferences and apply in every repository. A repository's own
rules win where they are stricter. Keep personal preferences in this file or in
memory, and out of checked-in files that teammates share.

### Git and pull requests

- Commit and push finished work to its branch or PR as soon as it is verified.
  Sign every commit (`git commit -S`). Merging waits for my say-so at the time.
- Work on a branch or worktree off the default branch. One PR per repository per
  effort: later fixes go onto the same open PR. PRs open ready for review.
- Leave a teammate's PR branch to them; coordinate instead of committing onto it.
- Write multi-line commit messages with `git commit -S -F - <<'EOF'`.
- Outside `agent-labs-dev` repositories, commits use `cjberragan@gmail.com`.
  Check `git config user.email` before the first commit.

### Files and shell

- `rm` is aliased to `rm -i` and hangs a tool call. List the exact target, then
  `command rm -- <path>`. Delete named paths only, never a glob, and pass this
  rule to any subagent that writes files.
- Production is read-only for agents: no writes, and decrypting counts as one.

### Local resource ownership

- On this Linux workstation, run memory-heavy checks, builds and temporary E2E
  stacks through `~/scripts/agent-heavy COMMAND [ARGS...]`. It admits two jobs
  under shared cgroup limits, reserves memory and waits for low memory pressure.
  Use `--light` for jobs needing at most 2 GiB, and `--exclusive` for large builds
  or stacks. Run coupled server/client checks in one invocation; nesting is
  rejected. Use `~/scripts/agent-container [DOCKER OPTIONS] -- IMAGE [COMMAND]`
  inside the job for capped, labelled containers with automatic cleanup. Prefer
  direct processes when an SDK cannot use the helper. See
  `~/dotfiles/docs/agent-resources.md` for limits, Docker integration and status.
- New coding sessions use `~/scripts/agent-session COMMAND [ARGS...]` through
  kiln and Linux shell aliases. Their child processes inherit session limits.
- Use `--no-daemon` for agent Gradle builds. Reuse an existing development stack
  or emulator when compatible. Start a temporary stack only for the check that
  needs it, with cleanup on exit and cancellation. Confirm owned processes and
  containers have stopped before reporting completion.
- Keep user-requested persistent dev servers outside the temporary-job runner.
  Record how to stop them. Stop only resources owned by the current task; process
  age or an orphaned parent alone does not prove a process is unused.

### Writing

- Hyphens, commas and colons only: no em or en dashes in anything written.
- Write copy for a first-time reader. It describes the thing as it is, without
  its own history, internal priority labels or dates.

### Approach

- Nebula supports desktop, mobile and CLI. Web is no longer a supported platform. Scope Nebula implementation and verification to the supported clients unless explicitly asked to work on web.
- Take the obvious default and proceed; ask only when the answer changes what
  gets built. Prefer the simple, direct plan, and remove what is unused.
- Fix a bug where the wrong value is first produced, then audit what depended on
  it. A clear bug found along the way gets fixed, not only filed.
- Skills are my own maintained versions in `~/skills`. Port a good idea from a
  third-party skill there with attribution; load `skill-writing` before editing
  a skill or steering file.
- For nontrivial design or speed and quality work, run the other model as a
  second arm (Codex from Claude, Claude from Codex), started early and in the
  background, with stdin redirected.
