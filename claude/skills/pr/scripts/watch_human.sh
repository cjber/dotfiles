#!/usr/bin/env bash
# Full real-time Codex progress tail — run this yourself in a separate
# terminal. Zero Claude tokens: this never passes through the assistant,
# you watch it directly. Part of the /pr skill's permanent tooling (not
# run-state, which stays in $STATE per the skill's tmp-only orchestration rule).
#
# Usage: watch_human.sh <STATE_DIR>
set -euo pipefail
STATE="${1:?usage: watch_human.sh <STATE_DIR>}"

tail -f -n +1 "$STATE/codex-events.jsonl" | jq --unbuffered -r '
  if .type == "thread.started" then "THREAD " + .thread_id
  elif .type == "turn.started" then "-> turn started"
  elif .type == "turn.completed" then "<- turn completed"
  elif .type == "item.started" and .item.type == "command_execution" then "  $ " + (.item.command[0:220])
  elif .type == "item.completed" and .item.type == "command_execution" then
    (if .item.exit_code == 0 then "  ok" else "  FAILED exit=" + (.item.exit_code|tostring) end)
  elif .type == "item.completed" and .item.type == "agent_message" then "MSG " + .item.text
  elif .type == "item.started" and .item.type == "todo_list" then "TODO:\n" + ([.item.items[] | "   - " + (if .completed then "[x] " else "[ ] " end) + .text] | join("\n"))
  else empty end
'
