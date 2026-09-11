
## This machine: the NAS

You are running on cjber's NAS (user `cillian`, home `/home/cillian`), usually
as a background session handed off while the main PC is off. Handoff briefs
live in `~/code/handoff/`.

- 4 cores, 7.5 GB RAM, shared with Plex, Home Assistant and other services.
  Keep parallelism low: at most one subagent at a time, no concurrent heavy
  test or build runs.
- The Postgres and Redis already running here belong to other services. Never
  connect to them. For nebula, use an isolated stack:
  `uv run dev-cluster up --runtime docker`, then `uv run dev-cluster run -- <cmd>`,
  and `uv run dev-cluster down` when the work is done.
- Poll CI with one-off `gh pr checks <n>` calls. Long background
  `sleep` + `--watch` loops have been killed here mid-run.
- `~/code/nebula` may be in use by another session. Work in a separate
  worktree (`git worktree add ~/code/wt-<slug> <branch>`) and remove it once
  its PR merges.
- The share marks new files executable. `core.fileMode false` is set
  globally, so git ignores it; do not commit mode changes.
- Git signing, gh, gcloud and codex are already configured; do not redo them.
