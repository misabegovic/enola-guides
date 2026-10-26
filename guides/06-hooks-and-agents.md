# Hooks and agents

enola is most useful when nobody has to remember to run it. An agent
gets three things: the MCP server, so it can ask the graph; the
instructions and hooks `enola install` writes, so it asks before
searching and is graded when it stops; and, optionally, a skill. This
guide sets up each and says what changes in the agent's work.

## What the agent does differently

| When | Without enola | With the server and `install --hooks` |
|---|---|---|
| The session starts | nothing | the architecture is pinned as the session's baseline, and the agent is told enola's tools are there |
| It needs to know what depends on X | greps for the name, and misses a caller reached through an interface or a package in between | asks `impact_analysis` or `explore`; in Claude Code its first two tree searches are refused with a pointer to the tool that answers |
| It is about to edit a file | reads the file | can ask `constraints_for` and `plan_check` which laws bind it and what the edit would breach |
| The turn ends | reports it is done | the stop hook grades the change and speaks only when it introduced a regression, a finding no policy enforces, or could not be compared |

## Register the MCP server

The server is the `enola` binary run with no arguments; the agent
starts it. Register it once per machine:

| Agent | Register with |
|---|---|
| Claude Code 2.1.287 or later | `claude mcp add-json enola '{"command":"enola","alwaysLoad":true}'` |
| an older Claude Code | `claude mcp add enola enola` |
| Codex | `codex mcp add enola -- enola` |
| Copilot in VS Code | `code --add-mcp '{"name":"enola","command":"enola"}'` |
| Cursor | `{ "mcpServers": { "enola": { "command": "enola" } } }` in `.cursor/mcp.json`, or `~/.cursor/mcp.json` for every project |
| opencode | nothing: `enola install --targets opencode` registers it in `.opencode/opencode.json` |
| Pi | nothing: Pi has no MCP client, so `enola install --targets pi` writes `.pi/extensions/enola.js`, which serves every tool as `enola_<tool>` |

`alwaysLoad` loads enola's tools when the session starts. Without it,
Claude Code lists them by name only (deferred) and the agent spends a turn
loading them through ToolSearch while a file search is already in reach;
the session-start hook tells it how, in one call. With a config file,
pass it in `args`
(`'{"command":"enola","args":["mcp-arch.yaml"],"alwaysLoad":true}'`).
After `enola upgrade`, restart the session so the server process is the
new binary.

## The hooks

```bash
enola install --hooks --targets claude --dry-run   # preview, write nothing
enola install --hooks --targets claude
```

writes enola's instructions into the file your agent already reads
(`.claude/rules/enola.md`, `.cursor/rules/enola.mdc`, `AGENTS.md`,
`.github/instructions/enola.instructions.md`, ...) and wires the hooks:

- **session start** pins the architecture as the session's baseline, the
  "before" every later grade compares against;
- **stop** grades what the session changed against that baseline when the
  agent finishes a turn, and speaks only when the change introduced a
  regression or a finding no policy enforces, or when it could not compare
  at all (then the remedy is to re-pin, not to doubt the change). It says
  each distinct report once per session.

In Claude Code two more: a `PreToolUse` hook refuses the session's first
two file searches over a tree (the `Grep` and `Glob` tools, or a `find`,
a recursive `grep` or an `rg` over a directory in the shell) with a
pointer to the enola tool that answers the question, and a `PostToolUse`
hook records that an enola tool was used, which ends the refusals. A
`grep` of files the agent names, or of piped output, is a read and goes
through; a search run again after a refusal goes through. With
`alwaysLoad` set, the refusals rarely fire.

`install` without `--targets` writes for every agent it knows (Claude
Code, Cursor, Codex, Copilot, Pi, opencode). It previews every change and
asks before writing (`--yes` where there is no terminal), never creates a
shared file such as `AGENTS.md` that was not already there, and
`enola uninstall` reverses it byte for byte. `--global` writes the
user-level files instead (`~/.claude/settings.json` and
`~/.claude/rules/enola.md` for Claude Code), for every repository you
open.

In a **folder of repositories** (a directory whose subfolders are git
repositories, such as a backend beside its clients), `--hooks` installs
only Claude Code's steering hooks: the session-start note, the search
refusal and the use recorder. A baseline needs one repository, so there
is no stop hook there; run `install --hooks` inside each repository whose
changes should be graded.

Two agents get more than instructions, because they lack what the others
have. **Pi** gets the extension above, with or without `--hooks`, since
without it Pi has no enola tools at all. **opencode** has no hook
configuration of this shape, so `--targets opencode` registers the server
in `.opencode/opencode.json` and, with `--hooks`, installs
`.opencode/plugin/enola.js`, which names the enola tool in the
descriptions of `grep`, `glob` and `list` and refuses a session's first
searches (`ENOLA_OPENCODE_GATE=off` keeps the rest and drops the
refusals).

### Did they fire?

Restart the agent session after installing, then:

```bash
enola doctor
```

reports whether the hooks actually fired in this repository (when each
last ran and what it concluded), whether the pinned baseline can still be
graded against, whether the Rubydex library is in place, and whether a
newer release is out. Before any session has started it says `NEITHER
HOOK HAS EVER RUN`; after a restart, that line means the agent is not
reading the configuration. A hook that is configured but never fires
looks exactly like one that fires and stays quiet, and `doctor` is the
only thing that tells them apart. Each hook has a 60-second timeout; on a
repository where a snapshot takes longer (see
[rolling out](19-rolling-out.md#1-measure-it-on-your-repository)), the stop hook can time
out.

### The Claude Code plugin

enola's repository is also a Claude Code plugin marketplace:

```text
/plugin marketplace add enola-labs/enola
/plugin install enola@enola
```

The plugin registers the MCP server, the session-start and stop hooks, and
two skills: one routing an architecture question to the tool that answers
it, and `/enola:setup`, which checks for the CLI and runs the install
script when it is missing. It configures and does not install, so `enola`
must be on PATH. It carries neither the search refusal nor the
tool-loading line `install --hooks` adds. Choose the plugin or
`install --hooks`, not both: both register the same hooks, and the
session would be pinned and graded twice.

## What to commit

`install` writes the absolute path of the `enola` that ran it into the
hook commands (`/home/you/.local/bin/enola hook stop`). Committed, that
path is wrong on every other machine, and a hook that cannot start never
breaks a session, so nobody notices. Commit what the team shares and let
each developer install the rest:

| Commit | Do not commit |
|---|---|
| `enola/constraints/`, `enola/recipes/` | `.enola/`, except `.enola/suppressions.yaml` |
| `mcp-arch.yaml`, `enola-intent.yaml` | the hook entries in `.claude/settings.json`, `.codex/hooks.json` |
| `.enola/suppressions.yaml` | |
| `.claude/rules/enola.md` and the other instruction files (they carry no paths) | |

Each developer then runs `enola install --hooks --global` once, which
puts the hooks in their own user settings with their own path, for every
repository they open.

## Turning it off

- One agent, or all: `enola uninstall` (`--targets` to choose, `--global`
  for the user-level files) reverses what `install` wrote.
- The search refusal alone: in opencode, `ENOLA_OPENCODE_GATE=off`; in
  Claude Code it has no switch, so register the server with `alwaysLoad`
  (it then rarely fires) or remove the `PreToolUse` entry.
- The update check: `ENOLA_NO_UPDATE_CHECK=1`.
- The snapshot history under `~/.enola/`: `history: { enabled: false }`
  in `mcp-arch.yaml` stops recording it, and `enola gc` reports what it
  holds and trims it.

## The MCP tools an agent should reach for

| Before a change | |
|---|---|
| `explore` | what is in here and what touches it; the one to reach for first |
| `impact_analysis` | what transitively depends on this, before touching it |
| `endpoint_impact` | who calls this HTTP endpoint, and which screens sit behind the callers |
| `traverse`, `find_path`, `show_symbol`, `query_facts` | how something is wired, instead of reconstructing it from files; `find_path` takes sets (`from_nodes`, `to_nodes`) to ask how any of one group reaches any of another in one search, and `show_symbol` takes several names in one call |
| `governing_intent` | which decision pages govern this file or symbol, and which code a page governs |
| `constraints_for`, `plan_check` | which declared laws bind a path, and what a planned edit would breach before it exists |
| `set_baseline` | pin the architecture as it is, once, early |

| After a change | |
|---|---|
| `generate_snapshot`, `diff_snapshot` | what the change actually did: findings introduced or resolved, coupling added; `generate_snapshot` takes `repo_paths` to index several repositories as one graph |
| `query_insights` | the explainers' findings, rather than re-deriving them |
| `snapshot_receipt`, `compare_receipts` | what a graph was generated over and where its limits are, and whether two snapshots are comparable enough to trust a diff between them |
| `architecture_blame`, `architecture_history` | when a dependency entered the architecture, and how it changed over time |

| Looking for trouble | |
|---|---|
| `find_orphans` | what nothing references any more |
| `package_metrics` | how stable and how abstract a package is, and its distance from the main sequence |
| `analyze_performance` | where the cost grows with the input |
| `coverage_report` | which cross-repository edges resolved and which were missed |

## The same questions from a shell

A hook, a review bot or a person without an agent asks the graph through
the CLI. Each command reads the current snapshot, says when it was written
and whether it matches the working tree, and takes `--json`:

```bash
enola impact 'kind:symbol OrdersController' .   # what depends on it, by hop depth
enola endpoint 'GET /api/v2/orders' .           # the controller, models, tables and callers behind a route
enola plan --paths app/jobs/receipt_job.rb .    # the laws governing a path and its blast radius, before the edit
enola flows .                                   # the ways into the program, ranked by what each reaches
enola constraints ledger .                      # per law, the breaches reported beside the ones excused
enola dashboard --open .                        # the snapshot in a read-only local browser view
```

`plan --patch` evaluates the verdicts a diff would produce over a scratch
copy before it lands; `flows --through <symbol>` lists only the flows
that reach a symbol. Every flag takes one dash or two (`-paths` and
`--paths` are the same). `enola help <command>` prints any command's
page, and `--help` never runs the command it describes.

## The skill

[`templates/skills/enola/SKILL.md`](../templates/skills/enola/SKILL.md) is
the skill to drop into your agent's skills directory
(`enola-guides copy skills/enola`). It says when to use the graph (a
change whose impact is not obvious, a change to how modules depend on
each other, a hook or CI finding), which tool answers which question, and
how to read a finding: it names the structural change and the rule it
crossed, and a "could not compare" means the baseline is stale, not that
the change is wrong. `install` already writes most of that into the
agent's instructions (`.claude/rules/enola.md`); add the skill when you
want it loaded only for architecture work, rather than in every session.
Three more skills for any repository sit beside it: `enola-laws`,
`enola-grade-before-push` and `enola-intent-first`.

## Intent first, optionally

Teams that keep decision records can compile them into the graph: a page
carrying an `enola_intent:` block with anchors (repository and path)
becomes an intent fact, `governing_intent` answers which pages govern a
file, and the `governed_by` component key and `require_governed` form turn
that into laws (see [writing laws](04-writing-laws.md)). A pre-edit hook
that reads `governing_intent` for the file about to change and puts the
decision trail in front of the agent is
[the intent-first gate](10-hooks.md#the-intent-first-gate-pretooluse-on-edit-and-write);
the [knowledge-base track](09-a-knowledge-base-with-enola.md) builds the
rest. Nothing above needs it.

## Where next

- [Rolling out](19-rolling-out.md): the hooks, the CI check and the laws
  adopted on a team, and what each costs.
- [Knowledge-base hooks](10-hooks.md): the intent-first gate and the
  stop-time debt, for a team that keeps decision records.
