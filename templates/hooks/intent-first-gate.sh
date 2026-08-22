#!/bin/bash
# PreToolUse on Edit|Write|MultiEdit: block the first write into each
# repository per piece of work, once, with the governing pages and the
# pre-edit contract on stderr. The retry proceeds; the gate forces the
# reading, never the verdict. Re-armed by record.sh on every user message.
#
# Where a shell-command classifier would go: a Bash tool call whose text
# carries a write shape (sed -i, a redirect, tee, cp or mv into the tree,
# an interpreter fed a heredoc) is a write too. What counts depends on your
# tree; gate it the same way once you have decided.
set -u
input=$(cat 2>/dev/null || true)
sid=$(jq -r '.session_id // "nosession"' <<<"$input" 2>/dev/null)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null)
[ -n "$file" ] || exit 0

top=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
case "$file" in
  "$top"/.enola/*|"$top"/wiki/_views/*|"$top"/wiki/_state/*) exit 0 ;;
esac
rel="${file#"$top"/}"
repo=$(basename "$top")

state="${TMPDIR:-/tmp}/intent-first-$(id -u)"
mkdir -p "$state"
ack="$state/${sid}-${repo}.ack"
[ -e "$ack" ] && exit 0
touch "$ack"

govern=""
if command -v enola >/dev/null 2>&1; then
  govern=$(cd "$top" && timeout 30 enola plan -paths "$rel" . 2>/dev/null | sed -n '/^Plan report/,$p' | head -40)
fi
[ -n "$govern" ] || govern="(enola plan unavailable: no binary or no snapshot for this checkout; named skip, consult the decision records by hand)"

cat >&2 <<EOF
intent-first gate (${repo}): first write for this piece of work.

Before ${rel} moves, read what governs it and check the intended change
against it. If the change deviates from what the governing page records,
amend the page first; if nothing governs this work, say so and ask
whether it should be shaped.

${govern}

Retrying proceeds. This gate re-arms on every user message; within one
piece of work it will not fire again for ${repo}.
EOF
exit 2
