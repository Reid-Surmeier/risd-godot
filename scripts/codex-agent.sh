#!/usr/bin/env bash
# Starts one Codex (OpenAI) agent on a written brief, detached from the caller, so an orchestrating
# session can spawn it, watch it and collect it the same way every time, and so it keeps working if
# the orchestrator's own login or session drops.
# usage: scripts/codex-agent.sh <name> <worktree> <brief.md> [minutes]
# Leaves in ~/.local/state/codex-agents/<name>/:
#   brief.md      what it was asked          events.jsonl  its live event stream (tail to watch)
#   report.md     its final message          exit          its exit code; present only once it has stopped
# 124 in exit means the time limit ended it: the brief must have it write its report file first.
set -euo pipefail
NAME=${1:?name}; WT=$(realpath "${2:?worktree}"); BRIEF=$(realpath "${3:?brief.md}"); MIN=${4:-110}
OUT=${CODEX_AGENT_DIR:-$HOME/.local/state/codex-agents}/$NAME
codex login status >/dev/null 2>&1 || { echo "codex is not logged in: run 'codex login'" >&2; exit 3; }
mkdir -p "$OUT"; rm -f "$OUT/exit" "$OUT/report.md"; cp "$BRIEF" "$OUT/brief.md"
# Full access, as every earlier reviewer run here: it has to start Godot on the GPU and load the build in Chrome.
setsid nohup bash -c "timeout ${MIN}m codex exec -m '${CODEX_MODEL:-gpt-6.1-sol}' \
  -c model_reasoning_effort='\"${CODEX_EFFORT:-max}\"' --dangerously-bypass-approvals-and-sandbox \
  -C '$WT' --json -o '$OUT/report.md' - < '$OUT/brief.md' > '$OUT/events.jsonl' 2> '$OUT/stderr.log'; \
  echo \$? > '$OUT/exit'" >/dev/null 2>&1 &
echo "$OUT"
