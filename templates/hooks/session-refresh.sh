#!/bin/bash
# SessionStart: when a cluster member's HEAD moved past the commit the
# committed receipts record, regenerate the cluster in the background and
# say so in one line; when they agree, say that. The agent's first
# structural question then reads a graph that matches the checkout.
#
# RECEIPTS is the knowledge base's committed receipts file; CLUSTER the
# cluster config; MEMBER the repository to compare (default: this one).
set -u
RECEIPTS="${RECEIPTS:-wiki/_state/enola/receipts.json}"
CLUSTER="${CLUSTER:-enola-cluster.yaml}"
MEMBER="${MEMBER:-.}"
command -v enola >/dev/null 2>&1 || { echo "enola hooks: no binary on PATH; the graph was not asked (named skip)"; exit 0; }
[ -f "$RECEIPTS" ] || { echo "enola hooks: no receipts at $RECEIPTS; the graph was not asked (named skip)"; exit 0; }

label=$(basename "$(cd "$MEMBER" && pwd -P)")
head=$(git -C "$MEMBER" rev-parse HEAD 2>/dev/null || true)
recorded=$(python3 - "$RECEIPTS" "$label" <<'PY' 2>/dev/null
import json, sys
r = json.load(open(sys.argv[1]))
print(((r.get("repos") or r).get(sys.argv[2]) or {}).get("git_commit") or "")
PY
)
if [ -n "$head" ] && [ "$head" != "$recorded" ]; then
  log="${TMPDIR:-/tmp}/enola-refresh-$(id -u).log"
  (nohup enola --generate "$CLUSTER" > "$log" 2>&1 &)
  echo "enola hooks: $label is at ${head:0:11}, the recorded receipt at ${recorded:0:11}; regenerating the cluster in the background (log $log)."
else
  echo "enola hooks: the recorded receipt matches $label at ${head:0:11}."
fi
exit 0
