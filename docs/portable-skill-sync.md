# Portable skill sync

Dotter deploys the canonical `dev` skill body to Claude, Codex, and the shared
`~/.agents` skill directory. The shared Claude/agent `pr` skill and Codex-native
`pr` skill have separate tracked bodies because their orchestration mechanics
differ, but they implement the same staging/promotion contract. Edit both `pr`
bodies when that contract changes, then run `dotter deploy`.

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
handoff is the shared `pr`/`dev` contract: task PRs target `cb/staging`, composed
pre-main proof runs from staging, and promotion to `main` stays separate.
