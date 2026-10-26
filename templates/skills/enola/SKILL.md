---
name: enola
description: Use before a change whose impact across the codebase is not obvious, after a change to how modules depend on each other, or when the enola hook or CI check reports a finding
---

# enola: the architecture before and after a change

This project has enola, which serves a map of the codebase's structure over
MCP: modules, symbols, routes, storage, and how they depend on each other.
The map is built from a snapshot of the code at a commit, and a change is
graded by comparing the snapshot before it with the snapshot after it.

The tools below are enola's MCP tools. If none of them is in reach, the
server is not registered; in Claude Code that is
`claude mcp add-json enola '{"command":"enola","alwaysLoad":true}'` (Claude
Code 2.1.287 or later; on an older one `claude mcp add enola enola`), then a
new session. If they are listed by name only (deferred), load them with
ToolSearch before the first one. The CLI answers the same questions
without the server: `enola impact`, `enola plan`, `enola check`.

Before changing code whose impact is not obvious:

- `impact_analysis`: what transitively depends on this, before you touch it.
- `explore` / `traverse` / `find_path`: how something is wired, instead of
  reconstructing it by reading files.
- `constraints_for` / `plan_check`: which declared laws bind the path, and
  what the planned edit would breach.
- `governing_intent`: which decision pages govern this file, when the team
  keeps them.
- `set_baseline`: record the architecture as it is BEFORE you start editing,
  so the change can be graded afterwards. Do this once, early.

After a change to how modules depend on each other, run `generate_snapshot`
and then `diff_snapshot` to see what the change did: findings introduced or
resolved, coupling added, symbols added or removed. A dependency cycle or
coupling nobody asked for is a reason to fix the change before presenting
it, not something to mention afterwards.

Prefer these over re-deriving structure by grepping. They are exact, and
they cost a fraction of the file reading they replace.

If the session-end hook or the CI check reports a finding, read it the same
way: it names the structural change and the rule it crossed, and its first
suggested action is the smallest cut the graph can see. If it reports
instead that it declined to grade, the two snapshots were not produced the
same way (a different enola version, different ignore globs); nothing is
wrong with your change, run `set_baseline` again and re-check. A partial
verdict graded only what both snapshots share; it names what it left out.

`enola install` writes `.claude/rules/enola.md`, which tells the agent much
of this on every session. Keep that rule or this skill, not both.
