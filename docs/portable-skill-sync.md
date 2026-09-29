# Portable skill sync

Dotter deploys the canonical `dev` skill body to Claude, Codex, and the shared
`~/.agents` skill directory. Its post-deploy hook installs the Codex and shared
copies as whole-directory symlinks because Codex skill discovery supports that
layout, while Dotter's normal directory expansion creates per-file symlinks.
Personal skills live in the shared `~/skills` clone. The post-deploy hook links
those directories into Claude, Codex, and `~/.agents`; do not maintain agent-specific
copies of the same skill. In particular, `pr`, `issue`, and `review` have one
canonical body. PRs target `main` by default; stacking requires an explicit request.

Third-party skills live in `~/.agents/skills`, with agent-directory symlinks as
needed. Install updates into that shared source rather than copying skill bodies
into each agent's directory. Preserve references and helper scripts when migrating
an existing installation.

Only static skill instructions, references, templates, and deterministic helper
scripts belong in this repository. Never add `.env` files, credentials, tokens,
agent histories or sessions, orchestration state, local plans, production
notebooks or exports, raw traces/prompts/user content, caches, machine-specific
IDs, or absolute home paths. Use `$HOME`, repository-relative paths, and redacted
examples instead of personal usernames, emails, workspace/user IDs, or live
resource identifiers.

Before committing a skill sync:

1. Run `dotter deploy --dry-run` and inspect every target.
2. Search the staged diff for absolute home paths, emails, secret-like values,
   production payloads, and identity-bearing IDs.
3. Run the repository's secret scanner or pre-commit hooks.
4. Confirm only intended portable source files are tracked; Dotter targets and
   runtime state must remain untracked.

Nebula's `renovate`, `calibrate`, `improve`, `align`, and domain skills remain
project-local and versioned with the behavior they govern. Dotter must not copy
their production evidence ledgers or notebooks. Their portable cross-agent
handoff is the shared `pr`/`dev` contract: task PRs target `main`, and the
shared development stack runs from `main`.
