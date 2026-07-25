# Cleanup Analysis — <project>

> Fill this from the **real files on disk**. Every removal candidate cites a real `path:line` AND the reachability paths you ruled out.
> Present this and WAIT for approval before deleting or editing anything.

## 1. Survey evidence

- Files/tree inspected: `<paths>` (from `ls` / `rg -n`)
- Search commands run AND their key output (paste actual hit lines / vulture / ruff output)
- One-line state: `<e.g. "mostly clean", "4 removal candidates, 2 are dynamic-dispatch false positives">`

## 2. Candidates, classified

| # | Candidate (`file:line`) | Category | Dynamic? | Public API? | Docs/entrypoint? | Config-ref? | Cross-boundary? | Bucket | Action |
|---|-------------------------|----------|----------|-------------|------------------|-------------|-----------------|--------|--------|

- **Category:** dead-code / unused-import / unused-var / unused-file / commented-out / orphaned-dep / complexity
- All **five** reachability columns must each be explicitly ruled **out** before a row can be **Proven dead**. Each cell must contain the ACTUAL evidence that ruled it out (the command run + key output, the registry/decorator body inspected, the route/config string grepped) — **not a bare yes/no**. A cell with no cited evidence counts as NOT ruled out, and the row defaults to KEEP.
- **Bucket:** proven-dead · live-via-indirect · public-API · deliberate-artifact · just-complex

### Kept deliberately (looked unused but isn't)
- `<file:line>` — why it's alive (dynamic dispatch / export / docs / config / DO-NOT-DELETE marker): `<...>`

## 3. Prioritized plan (value vs. risk)

| Order | Item (`file:line`) | Value | Risk | Behavior to preserve | Verification (how you'll run old-vs-new) |
|-------|--------------------|-------|------|----------------------|------------------------------------------|

## 4. Out of scope (explicitly not doing)

- `<public-API narrowing → separate deprecation; mass formatting → run the formatter; no behavior changes>`
