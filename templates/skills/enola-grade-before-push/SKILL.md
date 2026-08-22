---
name: enola-grade-before-push
description: Use before pushing or presenting a change that touched how modules depend on each other, and whenever the session-end hook reports a finding or says it could not compare
---

# enola-grade-before-push: the delta is the deliverable

1. Pin once, early: `enola baseline pin .` (or `set_baseline` over MCP) before
   editing. A baseline pinned after the edit grades nothing.
2. After the change: `enola --generate . && enola check .`, or
   `generate_snapshot` then `diff_snapshot`.
3. Read the verdict in this order: findings introduced (fix or justify before
   pushing), findings resolved (say so in the description), edges added.
4. A DECLINED verdict is not a pass. It means the snapshots are not
   comparable: a different enola version, a provider that ran on one side
   only, changed ignore globs. Re-pin the baseline and grade again.
5. Put the grade in the pull request description in one sentence: what the
   change did to the architecture, and what it did not.

Never push a change whose grade you have not read, and never call a
declined grade clean.
