#!/bin/bash
# Stop: block the end of the turn once when this turn pushed without a
# grade, and once when code moved under decision records and no record
# moved. Reads the per-session record written by record.sh.
set -u
state="${TMPDIR:-/tmp}/intent-first-$(id -u)"
input=$(cat 2>/dev/null || true)
sid=$(jq -r '.session_id // "nosession"' <<<"$input" 2>/dev/null)
turn="$state/${sid}.turn"
[ -f "$turn" ] || exit 0

if grep -q '^push$' "$turn" && ! grep -q '^check$' "$turn" && [ ! -e "$state/${sid}.push-blocked" ]; then
  touch "$state/${sid}.push-blocked"
  cat >&2 <<'EOF'
push without a grade: this turn pushed and ran no enola check.

Before finishing: run `enola check <repo>` against the pinned baseline
and read the grade. A declined grade is not a pass; re-pin and grade
again. This check blocks once per turn.
EOF
  exit 2
fi

if grep -q '^code' "$turn" && ! grep -q '^spec' "$turn" && [ ! -e "$state/${sid}.debt-blocked" ]; then
  touch "$state/${sid}.debt-blocked"
  summary=$(awk -F'\t' '$1 == "code" { print "  " $2 }' "$turn" | sort -u | head -15)
  cat >&2 <<EOF
intent debt: code moved this turn, and no decision record did.

Changed without a record moving:
${summary}

Before finishing: either amend the governing record to match what was
built, or state explicitly, in your reply, why the records as written
already cover the change. This check blocks once per turn.
EOF
  exit 2
fi
exit 0
