#!/usr/bin/env bash
# Bounded, periodic ASCII digest of a running `codex exec` for the assistant's
# Monitor tool: one notification per interval (not one per raw event), summarizing
# new narration/failures plus 5hr/weekly rate-limit and token/context usage pulled
# from Codex's own internal rollout session file (the exec --json stdout stream
# does not carry usage data at all). Part of the /pr skill's permanent tooling.
#
# Usage: watch_digest.sh <STATE_DIR> [POLL_SECONDS=90] [START_LINE=0]
#   START_LINE lets you resume a digest against an already-running codex exec
#   without replaying its full history (pass the current `wc -l` of
#   codex-events.jsonl at the moment you (re)attach).
set -euo pipefail
STATE="${1:?usage: watch_digest.sh <STATE_DIR> [POLL_SECONDS] [START_LINE]}"
POLL="${2:-90}"
last_line="${3:-0}"
TID=""
ROLLOUT=""

while true; do
  if grep -q CODEX_EXIT "$STATE/codex-stderr.log" 2>/dev/null; then
    echo "CODEX FINISHED: $(grep CODEX_EXIT "$STATE/codex-stderr.log")"
    break
  fi

  if [ -z "$TID" ] && [ -f "$STATE/codex-events.jsonl" ]; then
    TID=$(jq -r 'select(.type=="thread.started").thread_id' "$STATE/codex-events.jsonl" 2>/dev/null | head -1)
  fi
  if [ -n "$TID" ] && [ -z "$ROLLOUT" ]; then
    ROLLOUT=$(find ~/.codex/sessions -iname "*${TID}*" 2>/dev/null | head -1)
  fi

  total=$(wc -l < "$STATE/codex-events.jsonl" 2>/dev/null || echo 0)
  new=$((total - last_line))

  digest=""
  if [ "$total" -gt "$last_line" ]; then
    digest=$(tail -n "+$((last_line + 1))" "$STATE/codex-events.jsonl" | jq --unbuffered -r '
      if .type == "item.completed" and .item.type == "agent_message" then "MSG  " + .item.text
      elif .type == "item.completed" and .item.type == "command_execution" and .item.exit_code != 0 then
        "FAIL cmd (exit=" + (.item.exit_code|tostring) + "): " + (.item.command[0:180])
      elif .type == "item.started" and .item.type == "todo_list" then
        "TODO:\n" + ([.item.items[] | "  - " + (if .completed then "[x] " else "[ ] " end) + .text] | join("\n"))
      else empty end
    ')
    last_line=$total
  fi

  rl_line="rate limits: (unavailable yet)"
  tok_line=""
  if [ -n "$ROLLOUT" ] && [ -f "$ROLLOUT" ]; then
    rl_json=$(jq -c 'select(.payload.rate_limits != null) | .payload' "$ROLLOUT" 2>/dev/null | tail -1)
    if [ -n "$rl_json" ]; then
      rl_line=$(echo "$rl_json" | jq -r '
        def fmt_reset: (now) as $n | (.resets_at - $n) as $d |
          if $d < 3600 then (($d/60)|floor|tostring) + "m"
          elif $d < 86400 then (($d/3600)|floor|tostring) + "h"
          else (($d/86400)|floor|tostring) + "d" end;
        "5hr " + (.rate_limits.primary.used_percent|tostring) + "% used (resets in " + (.rate_limits.primary|fmt_reset) + ")  |  " +
        "week " + (.rate_limits.secondary.used_percent|tostring) + "% used (resets in " + (.rate_limits.secondary|fmt_reset) + ")"
      ' 2>/dev/null)
      tok_line=$(echo "$rl_json" | jq -r '
        "tokens: " + (.info.total_token_usage.total_tokens|tostring) + " total this session, " +
        (.info.last_token_usage.total_tokens|tostring) + " last turn, ctx window " +
        (.info.model_context_window|tostring)
      ' 2>/dev/null)
    fi
  fi

  {
    echo "+----------------------------------------------------------------+"
    printf "| CODEX DIGEST  [+%s new event(s), %s total]\n" "$new" "$total"
    echo "+----------------------------------------------------------------+"
    printf "| %s\n" "$rl_line"
    [ -n "$tok_line" ] && printf "| %s\n" "$tok_line"
    echo "+----------------------------------------------------------------+"
    if [ -n "$digest" ]; then
      echo "$digest"
    else
      echo "(no narration/failures this interval)"
    fi
  }

  sleep "$POLL"
done
