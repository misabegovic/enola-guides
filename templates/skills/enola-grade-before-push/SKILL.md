---
name: enola-grade-before-push
description: Use before pushing or presenting a change that touched how modules depend on each other, and whenever the session-end hook reports a finding or says it could not compare
---

# enola-grade-before-push: the delta is the deliverable

1. Pin once, early: `enola baseline pin .` (or `set_baseline` over MCP) before
   editing. A baseline pinned after the edit grades nothing.
2. After the change: `enola check .` (it snapshots the tree itself), or
   `generate_snapshot` then `diff_snapshot`. Exit 0 is clean, 1 a
   regression the policy fails, 2 a gate that could not run (no pinned
   baseline, a bad flag), 3 declined.
3. Read the verdict in this order: findings introduced (fix or justify before
   pushing), findings resolved (say so in the description), edges added.
   "Newly declared" lists what a law this change added reports on code it
   did not touch: the law's starting point, not a regression.
4. A DECLINED verdict (exit 3) is not a pass. The snapshots are not
   comparable: a different enola version or different ignore globs. Re-pin
   the baseline and grade again.
5. A partial verdict is not a full one. A producer ran on one side only (a
   provider, or an extractor for a language the baseline had none of, such
   as a first `.rb` law file in a Python repository): only the facts both
   sides share were graded, and the verdict names what it left out. Re-pin
   with the same producers, or say in the description what was not graded.
6. Put the grade in the pull request description in one sentence: what the
   change did to the architecture, and what it did not.

Never push a change whose grade you have not read, and never call a
declined or partial grade clean.
