#!/bin/bash
# PostToolUse on Edit|Write|MultiEdit|Bash: record what this turn did, so
# the stop-time debt hook can account for it. With "reset" as the first
# argument (UserPromptSubmit): a new user message begins a new piece of
# work, so clear the record and the gate's acknowledgements.
set -u
state="${TMPDIR:-/tmp}/intent-first-$(id -u)"
mkdir -p "$state"
input=$(cat 2>/dev/null || true)
sid=$(jq -r '.session_id // "nosession"' <<<"$input" 2>/dev/null)
turn="$state/${sid}.turn"

if [ "${1:-}" = "reset" ]; then
  rm -f "$state/${sid}"-*.ack "$turn" "$state/${sid}.debt-blocked" "$state/${sid}.push-blocked"
  exit 0
fi

record() { printf '%s\n' "$1" >> "$turn"; }

tool=$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)
if [ "$tool" = "Bash" ]; then
  cmd=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null)
  [ -n "$cmd" ] || exit 0
  printf '%s' "$cmd" | grep -qE '(^|[[:space:];&|])git[[:space:]]+push' && record "push"
  printf '%s' "$cmd" | grep -qE 'enola[[:space:]]+check' && record "check"
  exit 0
fi

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' <<<"$input" 2>/dev/null)
[ -n "$file" ] || exit 0
top=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
rel="${file#"$top"/}"
case "$rel" in
  wiki/*.md|docs/decisions/*.md|docs/adrs/*.md) record "spec	$rel" ;;
  *) record "code	$rel" ;;
esac
exit 0
