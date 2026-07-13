---
name: monitor
description: Health overview skill — queries Sentry, Langfuse, Metabase, PostHog, and GitHub from the command line (curl + gh, credentials from the repo .env) to produce a consolidated health report for the last 12 hours.
allowed-tools: Bash, Read
---

# Platform Health Monitor

Queries Sentry, Langfuse, Metabase, PostHog, and GitHub to produce a consolidated
health report covering the last 12 hours.

**No MCP servers.** Every source is hit directly over its REST API with `curl`
(or `gh` for GitHub). Credentials come from the repo's git-ignored `.env`
(`/home/cjber/drive/agl/nebula/.env`) — never hard-code secrets in this file.

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
| PostHog host | `https://us.posthog.com` (US region; `.env` says `app.posthog.com` but the API lives on `us.`) |
| PostHog project id | `224690` (`$EVAL_CRED_POSTHOG_PROJECT_ID`, team `nebula.gg`) |
| GitHub repo | `agent-labs-dev/nebula` |

### Known credential gaps (check these first, report as UNAVAILABLE if unfixed)

- **PostHog**: `EVAL_CRED_POSTHOG_API_KEY` is a narrowly-scoped *eval* key. It
  authenticates but returns **403 on every project endpoint** (`events`,
  `insights`, `query`, `error_tracking`). Sections 2/3/4/7 (activity, funnel,
  billing, landing) and PostHog frontend errors need a **personal API key with
  `query:read` + `insight:read` scopes** on project 224690. Until then, mark
  those sections UNAVAILABLE — do not fabricate numbers.
- **Metabase `interaction_evaluation`**: as of 2026-07-09 the table is stale
  (latest `evaluation_date` = 2026-04-29, 0 rows in 7d). Query
  `MAX(evaluation_date)` first; if it's old, mark Section 5 STALE rather than
  reporting empty results as healthy.

## Step 0 — Load credentials

Stage the needed vars into shell variables (do this once at the top of each
Bash block — shell state does not persist between tool calls):

```bash
cd /home/cjber/drive/agl/nebula
set -a
# shellcheck disable=SC2046
eval "$(grep -E '^(LANGFUSE_HOST|LANGFUSE_PUBLIC_KEY_PROD|LANGFUSE_SECRET_KEY_PROD|SENTRY_AUTH_TOKEN|SENTRY_ORG_SLUG|SENTRY_PROJECT|METABASE_API_KEY|EVAL_CRED_METABASE_URL|EVAL_CRED_POSTHOG_API_KEY|EVAL_CRED_POSTHOG_PROJECT_ID)=' .env | sed -E 's/^([A-Z_]+)=\"?(.*[^\"])\"?$/\1=\2/')"
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

2. **Top active issues by volume** (backend load; 24h is the finest stats bucket):
```bash
curl -s -G -H "Authorization: Bearer $SENTRY_AUTH_TOKEN" \
  --data-urlencode "query=is:unresolved" --data-urlencode "statsPeriod=24h" \
  --data-urlencode "sort=freq" --data-urlencode "limit=12" "$S/issues/" \
  | jq -r '.[] | "\(.count)x  \(.title)"'
```

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

1. **Interaction quality** (check freshness first — see credential gaps):
```sql
SELECT interaction_label, COUNT(*) AS total,
       ROUND(AVG(interaction_score)::numeric,2) AS avg_score,
       SUM(observation_error_count) AS obs_errors,
       ROUND(SUM(trace_total_cost_usd)::numeric,4) AS cost
FROM interaction_evaluation
WHERE evaluation_date >= CURRENT_DATE - INTERVAL '1 day'
GROUP BY interaction_label ORDER BY total DESC
```

2. **Trigger executions** (status + failed errors + skip reasons):
```sql
SELECT status, COUNT(*) FROM trigger_execution
WHERE started_at > (EXTRACT(EPOCH FROM NOW())*1000)::bigint - 43200000
GROUP BY status ORDER BY 2 DESC
```
Follow up with `WHERE status='failed' ... GROUP BY LEFT(error_message,140)` and
`WHERE status='skipped' ... GROUP BY skip_reason` for samples.

3. **Task status:**
```sql
SELECT status, COUNT(*) AS total, COUNT(DISTINCT user_id) AS users,
       SUM(CASE WHEN trigger_id IS NOT NULL THEN 1 ELSE 0 END) AS trig
FROM task
WHERE created_at > (EXTRACT(EPOCH FROM NOW())*1000)::bigint - 43200000
  AND deleted_at IS NULL
GROUP BY status ORDER BY total DESC
```

### PostHog (REST — `Authorization: Bearer $EVAL_CRED_POSTHOG_API_KEY`)

**Only works with a `query:read`-scoped key** (see credential gaps). When
available, use the HogQL query endpoint (simpler than InsightVizNode over curl):
```bash
PH="https://us.posthog.com/api/projects/$EVAL_CRED_POSTHOG_PROJECT_ID/query/"
curl -s -H "Authorization: Bearer $EVAL_CRED_POSTHOG_API_KEY" -H "Content-Type: application/json" \
  -d '{"query":{"kind":"HogQLQuery","query":"SELECT event, count() FROM events WHERE timestamp > now() - interval 12 hour AND event IN ('\''chat.message.sent'\'','\''auth.login.success'\'','\''auth.signup.started'\'','\''auth.signup.completed'\'','\''billing.checkout.completed'\'','\''billing.subscription.cancelled'\'') GROUP BY event"}}' \
  "$PH" | jq -r '.results[] | @tsv'
```
Frontend exceptions: `SELECT properties.$exception_type, count() FROM events
WHERE event='$exception' AND timestamp > now() - interval 12 hour GROUP BY 1
ORDER BY 2 DESC`. If the key returns 403/permission_denied, report UNAVAILABLE.

### GitHub (`gh` CLI)
```bash
gh issue list --repo agent-labs-dev/nebula --state open --limit 100 \
  --json number,title,labels,createdAt,updatedAt
```
Group by label; flag P0/P1/bug and issues with no update in 30+ days.

## Step 2 — Compile health report

Analyze all results and produce a structured report with inline ASCII
visualizations. Mark any UNAVAILABLE/STALE source explicitly — never present a
missing source as healthy.

### Overall Status

| Status | Criteria |
|--------|----------|
| **HEALTHY** | No new Sentry issues, Langfuse error count < 5, no failed triggers, avg interaction score > 0.7, signup funnel > 30%, frontend exceptions < 50 |
| **DEGRADED** | 1-3 new Sentry issues, OR Langfuse errors 5-20, OR some failed triggers, OR avg score 0.5-0.7, OR signup funnel 15-30%, OR frontend exceptions 50-150 |
| **UNHEALTHY** | 4+ new Sentry issues, OR Langfuse errors > 20, OR many failed triggers, OR avg score < 0.5, OR signup funnel < 15%, OR frontend exceptions > 150 |

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
Sentry issues by volume; Langfuse error count + top exception types; PostHog
frontend exceptions (if available). Horizontal bar chart of error sources
(scale bars to the largest value, `█` filled / `░` empty, max 20 chars):
```
Error Sources (12h)
  Langfuse (LLM)     ████████████████████  74
  Sentry (new)       █░░░░░░░░░░░░░░░░░░░░   4
  PostHog (frontend) ────── unavailable
```

**2. User Activity (PostHog)** — sparkline bars scaled to the largest value.
**3. Signup Funnel (PostHog)** — narrowing ASCII funnel + conversion %.
**4. Billing (PostHog)** — checkouts/credit buys `[+]`, cancellations `[-]`, net.
**7. Top-of-Funnel Traffic (PostHog)** — page views / CTA / signups with CTR.
(2/3/4/7 are UNAVAILABLE while PostHog is on an eval-scoped key.)

**5. Interaction Quality (Metabase)** — table of labels (total, avg score,
obs_errors, cost); `[!]` on avg < 0.7; 10-char score bars. Report STALE if the
freshness check shows old data.

**6. Triggers & Tasks (Metabase)** — trigger status stacked bar
(success/skipped/failed), sample failed errors, top 5 skip reasons, task status
with user counts.
```
Trigger Executions (12h) — 946 total
  [██████████████████░░░░░░░░░░░░░░░░░░░░░░] success 444 (47%) · skip 497 (53%) · fail 5 (0.5%)
```

**8. GitHub Issues** — total count; grouped by label; flag P0/P1/bug; flag
stale (30+ days) and likely-resolved/duplicate issues; recommend closures with
reasoning (cross-reference Sentry/trigger data).

**9. Action Items** — specific recommendations: link Sentry issues needing
attention, underperforming interaction labels, trigger failure patterns, funnel
drop-offs (<30%), billing churn (cancellations > checkouts), frontend exception
trends, relevant GitHub issues, and any credential/pipeline gaps found (e.g.
PostHog key scope, stale eval table).
