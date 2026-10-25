# Hooks and agents

enola is most useful when nobody has to remember to run it. Two hooks and
one skill do that.

## The hooks

```bash
enola install --hooks
```

writes enola's instructions into the files your coding agents already
read (Claude Code, Cursor, Copilot, Codex, Pi) and wires two hooks:

- **session start** pins the architecture as the session's baseline, the
  "before" every later grade compares against;
- **stop** grades what the session changed against that baseline when the
  agent finishes a turn, and speaks only when the change introduced a
  structural regression, or when it could not compare at all (then the
  remedy is to re-pin, not to doubt the change).

In Claude Code the session-start hook also says how to load enola's
deferred tools in one ToolSearch call, and a `PreToolUse` hook refuses the
session's first two file searches (`Grep`, `Glob`, or `grep`, `rg`, `find`
in a shell) with a pointer to the enola tool that answers the question;
the refusals stop once any enola tool is used.

It previews every change and asks before writing, never creates a shared
file such as `AGENTS.md` that was not already there, and `enola uninstall`
reverses it byte for byte.

```bash
enola doctor
```

reports whether the hooks actually fired in this repository (when each
last ran and what it concluded), which version you run, whether a newer
release changed the extractors, and whether the Rubydex library is in
place. A hook that is configured but never fires looks exactly like one
that fires and stays quiet; `doctor` is the only thing that tells them
apart.

## The MCP tools an agent should reach for

| Before a change | |
|---|---|
| `impact_analysis` | what transitively depends on this, before touching it |
| `explore`, `traverse`, `find_path` | how something is wired, instead of reconstructing it from files |
| `governing_intent` | which decision pages govern this file or symbol |
| `constraints_for`, `plan_check` | which declared laws bind a path, and what a planned edit would breach |
| `set_baseline` | pin the architecture as it is, once, early |

| After a change | |
|---|---|
| `generate_snapshot`, `diff_snapshot` | what the change actually did: findings introduced or resolved, coupling added |
| `query_insights` | the explainers' findings, rather than re-deriving them |
| `architecture_blame`, `architecture_history` | when a dependency entered the architecture |

## The skill

[`templates/skills/enola/SKILL.md`](../templates/skills/enola/SKILL.md) is
the skill to drop into your agent's skills directory. It says when to use
the graph (a change whose impact is not obvious, a change to how modules
depend on each other, a hook or CI finding), which tool answers which
question, and how to read a finding: it names the structural change and
the rule it crossed, and a "could not compare" means the baseline is
stale, not that the change is wrong. Keep it short; the agent's job is to
ask the graph, not to read about it.

## Intent first, optionally

Teams that keep decision records can compile them into the graph: a page
carrying an `enola_intent:` block with anchors (repository and path)
becomes an intent fact, `governing_intent` answers which pages govern a
file, and the `governed_by` component key and `require_governed` form turn
that into laws (see [writing laws](04-writing-laws.md)). A pre-edit hook
that reads `governing_intent` for the file about to change, and injects
the decision trail into the agent's context, is the practice this
repository's authors run; it is a hook of a few lines over the MCP tool.
