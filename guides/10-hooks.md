# Hooks: the graph at the moments that matter

A hook fires at a moment nobody has to remember: a session starting, the
first edit into a repository, a turn ending, a push. Each one here reads
the graph at that moment, blocks at most once, and forces a reading,
never a verdict. The scripts are in [`templates/hooks/`](../templates/hooks);
they are written for Claude Code's hook protocol (JSON on stdin, exit 2
to block with the message on stderr) and translate to any agent with
hooks.

## enola's own pair

```bash
enola install --hooks
```

wires two: **session start** restores the snapshot and serves it over
MCP; **stop** grades the session's delta against the pinned baseline and
speaks only when the change introduced a regression or could not be
compared. `enola doctor` reports when each last fired and what it
concluded; a hook that never fires is the failure to look for.

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

`templates/hooks/intent-first-gate.sh` gates Edit and Write. The brain's
own gate also classifies shell commands as writes (a `sed -i`, a
redirect, a `cp` into the repository); the template marks where that
classifier goes and leaves it out, because the rules for what counts as a
write depend on your tree.

## The stop-time debt (Stop)

When the turn ends, two debts can block it once each:

- **Code moved, no spec moved.** Files changed in a governed repository
  this turn and no governing page did. The block asks for either the
  amendment or an explicit sentence, in the reply, saying why the pages
  as written already cover the change.
- **A push went out with no grade.** A `git push` to a repository
  happened this turn and no `enola check` ran. The block asks for the
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

Claude Code, in `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{"matcher": "startup|resume", "hooks": [
      {"type": "command", "command": "enola hook session-start"},
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/hooks/session-refresh.sh\""}]}],
    "PreToolUse": [{"matcher": "Edit|Write|MultiEdit", "hooks": [
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/hooks/intent-first-gate.sh\""}]}],
    "PostToolUse": [{"matcher": "Edit|Write|MultiEdit|Bash", "hooks": [
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/hooks/record.sh\""}]}],
    "UserPromptSubmit": [{"hooks": [
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/hooks/record.sh\" reset"}]}],
    "Stop": [{"hooks": [
      {"type": "command", "command": "enola hook stop"},
      {"type": "command", "command": "\"${CLAUDE_PROJECT_DIR:-.}/hooks/stop-debt.sh\""}]}]
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
