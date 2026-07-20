---
name: monitor
description: Health overview skill — queries Sentry, Langfuse, Metabase, and GitHub from the command line (curl + gh, credentials from the repo .env) to produce a consolidated health report for the last 12 hours.
allowed-tools: Bash, Read
---

# Platform Health Monitor

Queries Sentry, Langfuse, Metabase, and GitHub to produce a consolidated
health report covering the last 12 hours.

**No MCP servers.** Every source is hit directly over its REST API with `curl`
(or `gh` for GitHub). Credentials come from the repo's git-ignored `.env`
(`/home/cjber/drive/agl/nebula/.env`) — never hard-code secrets in this file.

**PostHog and Metabase `interaction_evaluation` are intentionally not
queried** — see "Retired sources" below.

## Prerequisites

- `curl`, `jq`, and `gh` on PATH (all present on this machine; install missing
  ones with `paru -S <pkg>`). `gh` must be authenticated (`gh auth status`).
- The repo `.env` must contain the credential vars listed below. They are read
  at runtime; nothing is stored in the skill.

## Static Configuration (verified 2026-07-09)

| Source | Value |
|--------|-------|
| Sentry region | `https://us.sentry.io` |
| Sentry org slug | `agent-labs-f4` (`$SENTRY_ORG_SLUG`) |
| Sentry project | `nebula` (`$SENTRY_PROJECT`) |
| Langfuse host | `https://us.cloud.langfuse.com` (`$LANGFUSE_HOST`) — use the **PROD** key pair |
| Metabase URL | `https://metabase.nebula.gg` (`$EVAL_CRED_METABASE_URL`) |
| Metabase database id | **`2`** (`nebula-read-only`) — NOT 40 |
| GitHub repo | `agent-labs-dev/nebula` |

### Retired sources (do not query — checked 2026-07-20)

- **PostHog**: `EVAL_CRED_POSTHOG_API_KEY` is a narrowly-scoped *eval* key
  that returns **403 on every project endpoint** (`events`, `insights`,
  `query`, `error_tracking`). This has been true on every run since
  2026-07-09 with no fix in sight — a personal key with `query:read` +
  `insight:read` scopes on project `224690` would unblock it, but until one
  is added to `.env`, don't spend a query round-trip confirming the 403
  again. If a working key ever lands, user activity / signup funnel /
  billing / top-of-funnel traffic sections can be reinstated.
- **Metabase `interaction_evaluation`**: confirmed dead, not just delayed —
  tracked in [nebula#5778](https://github.com/agent-labs-dev/nebula/issues/5778)
  (table unfed since PR #3568). Don't query it or report it as a gap; the
  GitHub issue is the source of truth until that's fixed.

## Step 0 — Load credentials

Stage the needed vars into shell variables (do this once at the top of each
Bash block — shell state does not persist between tool calls):

```bash
cd /home/cjber/drive/agl/nebula
set -a
# shellcheck disable=SC2046
eval "$(grep -E '^(LANGFUSE_HOST|LANGFUSE_PUBLIC_KEY_PROD|LANGFUSE_SECRET_KEY_PROD|SENTRY_AUTH_TOKEN|SENTRY_ORG_SLUG|SENTRY_PROJECT|METABASE_API_KEY|EVAL_CRED_METABASE_URL)=' .env | sed -E 's/^([A-Z_]+)=\"?(.*[^\"])\"?$/\1=\2/')"
set +a
FROM=$(date -u -d '12 hours ago' +%Y-%m-%dT%H:%M:%SZ)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
```

Auth smoke-test (expect `200 200 200`): Sentry projects, Langfuse projects,
Metabase database list.

## Step 1 — Query all systems

### Sentry (REST — `Authorization: Bearer $SENTRY_AUTH_TOKEN`)

Base: `S="https://us.sentry.io/api/0/projects/$SENTRY_ORG_SLUG/$SENTRY_PROJECT"`

**Gotcha:** the issues endpoint `statsPeriod` only accepts `''`, `24h`, `14d`.
For a 12h window pass explicit `start`/`end` instead.

1. **New issues in window** (first-seen ≤ 12h ago):
```bash
curl -s -G -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  --data-urlencode "query=is:unresolved age:-12h" \
  --data-urlencode "start=$FROM" --data-urlencode "end=$NOW" \
  --data-urlencode "sort=freq" --data-urlencode "limit=100" "$S/issues/" \
  | jq -r '.[] | "\(.count)x  \(.title)  [\(.culprit)]"'
```

2. **Top issues by volume** (`sort=freq` with `statsPeriod=24h` still returns
each issue's **lifetime** `count`, not a 24h-scoped count — confirmed
2026-07-20. Always pull `lastSeen` alongside it and treat anything not seen
in the last 24h as dormant, not active, no matter how large its lifetime
count is — a stale issue with a huge lifetime count (e.g. one that fired
constantly for months and stopped) will otherwise look like today's biggest
problem):
```bash
curl -s -G -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  --data-urlencode "query=is:unresolved" --data-urlencode "statsPeriod=24h" \
  --data-urlencode "sort=freq" --data-urlencode "limit=12" "$S/issues/" \
  | jq -r '.[] | "\(.count)x  lastSeen=\(.lastSeen)  \(.title)"'
```

Report two buckets: **active now** (`lastSeen` within the 24h window) and
**dormant** (large lifetime count but stale `lastSeen`) — don't merge them
into one "top issues" list. Cross-reference the active ones against open
GitHub issues (`gh issue list --search "<key phrase from title>"`) — flag any
large, untracked, currently-active issue as an action item to file. Also
sanity-check the top *active* issue's latest event tags
(`GET /api/0/issues/{id}/events/latest/` → `.tags`) for `environment` before
treating it as a production problem — `environment=local` / `sentry.purpose=
migration` means it's dev-machine noise, not prod (see nebula#5807).

### Langfuse (REST — Basic auth, PROD key pair)

Errors are `level=ERROR` observations. `.meta.totalItems` is the count; group
`.data[]` by `.name` and by `.statusMessage` (normalise uuids/numbers) for the
top exception breakdown.
```bash
curl -s -u "$LANGFUSE_PUBLIC_KEY_PROD:$LANGFUSE_SECRET_KEY_PROD" -G \
  --data-urlencode "level=ERROR" --data-urlencode "fromStartTime=$FROM" \
  --data-urlencode "limit=100" "$LANGFUSE_HOST/api/public/observations" \
  | jq -r '"total=\(.meta.totalItems)", (.data[] | .name)' 
```

### Metabase (REST — `POST /api/dataset`, header `x-api-key: $METABASE_API_KEY`, database `2`)

Helper:
```bash
run_mb () { jq -n --arg q "$1" '{database:2,type:"native",native:{query:$q}}' \
  | curl -s -H "x-api-key: $METABASE_API_KEY" -H "Content-Type: application/json" \
    -d @- "$EVAL_CRED_METABASE_URL/api/dataset" \
  | jq -r 'if .data then (.data.rows[]|@tsv) else "ERR: "+(.error//tostring) end'; }
```

1. **Trigger executions** (status + failed errors + skip reasons):
```sql
SELECT status, COUNT(*) FROM trigger_execution
WHERE started_at > (EXTRACT(EPOCH FROM NOW())*1000)::bigint - 43200000
GROUP BY status ORDER BY 2 DESC
```
Follow up with `WHERE status='failed' ... GROUP BY LEFT(error_message,140)` and
`WHERE status='skipped' ... GROUP BY skip_reason` for samples. Within the skip
reasons, watch specifically for `fetch_failed_auth: <toolkit>: ... REVOKED`
or `... not found - user likely disconnected it` — a large count on one
account id means the same trigger is repeatedly firing into a dead
connection every cycle, not a one-off blip. Group by the account id
substring to see if it's concentrated.

2. **Task status:**
```sql
SELECT status, COUNT(*) AS total, COUNT(DISTINCT user_id) AS users,
       SUM(CASE WHEN trigger_id IS NOT NULL THEN 1 ELSE 0 END) AS trig
FROM task
WHERE created_at > (EXTRACT(EPOCH FROM NOW())*1000)::bigint - 43200000
  AND deleted_at IS NULL
GROUP BY status ORDER BY total DESC
```

### GitHub (`gh` CLI)
```bash
gh issue list --repo agent-labs-dev/nebula --state open --limit 100 \
  --json number,title,labels,createdAt,updatedAt
```
Group by label; flag P0/P1/bug and issues with no update in 30+ days.

## Step 2 — Compile health report

Analyze all results and produce a structured report with inline ASCII
visualizations. Mark any UNAVAILABLE/STALE source explicitly — never present a
missing source as healthy. Sources listed under "Retired sources" above don't
need an UNAVAILABLE line every run — one line noting they're retired (with
the tracking issue link) is enough; don't re-litigate the 403/staleness each
time.

### Overall Status

| Status | Criteria |
|--------|----------|
| **HEALTHY** | No new Sentry issues, Langfuse error count < 5, no failed triggers |
| **DEGRADED** | 1-3 new Sentry issues, OR Langfuse errors 5-20, OR some failed triggers |
| **UNHEALTHY** | 4+ new Sentry issues, OR Langfuse errors > 20, OR many failed triggers |

When a threshold trips on noise (e.g. Langfuse errors dominated by LLM
retry behavior), state the mechanical status AND the real driver.

Display the status prominently:
```
╔══════════════════════════════════╗
║  STATUS: HEALTHY / DEGRADED     ║
║  Period: last 12h (HH:MM-HH:MM)║
╚══════════════════════════════════╝
```

### Report Sections

Use ASCII art where indicated.

**1. Errors & Exceptions** — New Sentry issues (count + titles); top active
Sentry issues by volume, cross-referenced against open GitHub issues; Langfuse
error count + top exception types. Horizontal bar chart of error sources
(scale bars to the largest value, `█` filled / `░` empty, max 20 chars):
```
Error Sources (12h)
  Langfuse (LLM)     ████████████████████  74
  Sentry (new)       █░░░░░░░░░░░░░░░░░░░░   4
```

**2. Triggers & Tasks (Metabase)** — trigger status stacked bar
(success/skipped/failed), sample failed errors, top 5 skip reasons (flag any
concentrated `fetch_failed_auth` pattern per above), task status with user
counts.
```
Trigger Executions (12h) — 946 total
  [██████████████████░░░░░░░░░░░░░░░░░░░░░░] success 444 (47%) · skip 497 (53%) · fail 5 (0.5%)
```

**3. GitHub Issues** — total count; grouped by label; flag P0/P1/bug; flag
stale (30+ days) and likely-resolved/duplicate issues; recommend closures with
reasoning (cross-reference Sentry/trigger data).

**4. Action Items** — specific recommendations: link Sentry issues needing
attention (file untracked ones), trigger failure patterns, relevant GitHub
issues, and any new credential/pipeline gaps found.
