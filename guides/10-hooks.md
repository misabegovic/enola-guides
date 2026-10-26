# Knowledge-base hooks: the graph at the moments that matter

A hook fires at a moment nobody has to remember: a session starting, the
first edit into a repository, a turn ending, a push. Each one here reads
the graph at that moment, blocks at most once, and forces a reading,
never a verdict. The scripts are in [`templates/hooks/`](../templates/hooks);
they are written for Claude Code's hook protocol (JSON on stdin, exit 2
to block with the message on stderr) and translate to any agent with
hooks.

Part of the [optional knowledge-base track](09-a-knowledge-base-with-enola.md):
these hooks hold an agent to a team's decision records. enola's own
session hooks, which pin a baseline and grade each turn in any
repository, come from `enola install --hooks` and are in
[hooks and agents](06-hooks-and-agents.md#the-hooks); install those first,
then these beside them.

What the four need:

- **A governed repository.** A repository is governed when one of
  `ENOLA_DECISION_DIRS` exists at its root (space-separated; default
  `wiki docs/decisions docs/adrs`). A Markdown file under one of them is a
  decision record; anything else in that repository is code. In a
  repository with none of those directories the gate, the record and the
  code-moved debt do nothing, so installing them globally is safe.
- `jq` on PATH for all four, and `python3` for the session refresh.
- For the session refresh, the knowledge base's receipts and cluster
  config ([guide 09](09-a-knowledge-base-with-enola.md)): `RECEIPTS`
  (default `wiki/_state/enola/receipts.json`) and `CLUSTER` (default
  `enola-cluster.yaml`).

Copy them into `.claude/hooks/`:

```bash
enola-guides copy hooks/intent-first-gate
enola-guides copy hooks/record
enola-guides copy hooks/stop-debt
enola-guides copy hooks/session-refresh
```

> With [tabula](13-tabula.md) (in preview, not yet public),
> `tabula install --harness claude` writes the gate, the record, the debt
> and the session hooks this guide wires by hand, and `--uninstall`
> removes exactly what it wrote. The hand-wired scripts below are the same
> ideas, short enough to read.

## The intent-first gate (PreToolUse on Edit and Write)

The first write into each repository per piece of work is blocked once.
The block carries two things: the pages that govern the file
(`governing_intent`, or `enola plan -paths <file>` when the MCP is not
in reach) and the pre-edit contract (the declared laws binding the path
and the blast radius over the current snapshot). The agent reads, then
retries, and the retry proceeds. The gate re-arms on every user message,
so each ask gets its own forced stop and no piece of work gets two.

What it refuses to do: decide. If the governing page contradicts the
intended change, the contract says amend the page first; the hook only
makes the page impossible to miss. When no page governs the file, it
says so and asks whether the work should be shaped. When the graph is
absent, it says so and lets the write through; a missing graph is a
named skip, never a wall.

`templates/hooks/intent-first-gate.sh` gates Edit and Write. The gate the
guides' author runs also classifies shell commands as writes (a `sed -i`, a
redirect, a `cp` into the repository); the template marks where that
classifier goes and leaves it out, because the rules for what counts as a
write depend on your tree.

## The stop-time debt (Stop)

When the turn ends, two debts can block it once each:

- **Code moved, no spec moved.** Files changed in a governed repository
  this turn and no decision record in it did. The block asks for either the
  amendment or an explicit sentence, in the reply, saying why the pages
  as written already cover the change.
- **A push went out with no grade.** A `git push` happened this turn and
  no `enola check` ran. This one applies in every repository. The block asks for the
  grade, read, before finishing.

Both read a small per-session record the PostToolUse hook writes
(`templates/hooks/record.sh`): which files moved, whether a push
happened, whether a check ran. The debt hook is the mechanical half of
two rules a team can otherwise only ask people to remember.

## The union refresh (SessionStart)

When the session starts, compare the paired repository's HEAD with the
commit the committed receipt records. When they differ, regenerate that
member's slice of the union in the background and say so in one line;
when they agree, say that. The agent's first structural question then
reads a graph that matches the checkout it is about to edit.

## Wiring

Claude Code, in `.claude/settings.json`, beside the entries
`enola install --hooks` wrote (it already registers `enola hook
session-start` and `enola hook stop`; do not add them a second time):

```json
{
  "hooks": {
    "SessionStart": [{"matcher": "startup|resume", "hooks": [
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/session-refresh.sh\""}]}],
    "PreToolUse": [{"matcher": "Edit|Write|MultiEdit", "hooks": [
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/intent-first-gate.sh\""}]}],
    "PostToolUse": [{"matcher": "Edit|Write|MultiEdit|Bash", "hooks": [
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/record.sh\""}]}],
    "UserPromptSubmit": [{"hooks": [
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/record.sh\" reset"}]}],
    "Stop": [{"hooks": [
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/stop-debt.sh\""}]}]
  }
}
```

## What it feels like

An agent asked to change a billing service edits nothing until it has
read the decision that put charges through one service; it grades the
change before the push and writes the grade into the pull request; and
when it ends the turn having changed code under a decision without
touching the decision, it is asked to account for that once. None of
this needs the agent to know enola exists.

## Where next

[The knowledge-base skills](11-the-skills-as-they-run.md), which these
hooks enforce, and [the wrapper](12-the-wrapper.md) they call.
