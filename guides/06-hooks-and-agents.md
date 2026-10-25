# Hooks and agents

enola is most useful when nobody has to remember to run it. Two hooks and
one skill do that.

## The hooks

```bash
enola install --hooks
```

writes enola's instructions into the files your coding agents already
read (Claude Code, Cursor, Copilot, Codex, Pi, opencode) and wires two
hooks:

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
reverses it byte for byte. `--targets claude,codex` narrows it to the
agents you name, `--dry-run` shows what it would write, and `--global`
writes the user-level files instead.

Two agents get more than instructions, because they lack what the others
have. **Pi** has no MCP client, so `--targets pi` writes
`.pi/extensions/enola.js`, which starts enola's server at session start
and registers every tool as `enola_<tool>`; it is written with or without
`--hooks`, since without it Pi has no enola tools at all. **opencode** has
no hook configuration of this shape, so `--targets opencode` registers the
server in `opencode.json` itself and, with `--hooks`, installs
`.opencode/plugin/enola.js`, which names the enola tool in the
descriptions of `grep`, `glob` and `list` and refuses a session's first
searches (`ENOLA_OPENCODE_GATE=off` keeps the rest and drops the
refusals).

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
must be on PATH. It carries neither the search refusal nor the tool-loading
line `install --hooks` adds; choose one of the two, since both register the
same hooks.

```bash
enola doctor
```

reports whether the hooks actually fired in this repository (when each
last ran and what it concluded), whether the pinned baseline can still be
graded against, and whether a newer release is out. `enola providers
list` is where the Rubydex library shows. A hook that is configured but never fires looks exactly like one
that fires and stays quiet; `doctor` is the only thing that tells them
apart.

## The MCP tools an agent should reach for

| Before a change | |
|---|---|
| `explore` | what is in here and what touches it; the one to reach for first |
| `impact_analysis` | what transitively depends on this, before touching it |
| `endpoint_impact` | who calls this HTTP endpoint, and which screens sit behind the callers |
| `traverse`, `find_path`, `show_symbol`, `query_facts` | how something is wired, instead of reconstructing it from files; `find_path` takes sets (`from_nodes`, `to_nodes`) to ask how any of one group reaches any of another in one search |
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

In Claude Code the tools are deferred, listed by name and loaded through
ToolSearch, which is why the session-start hook says how to load them in
one call. Claude Code 2.1.287 and later loads them up front with
`"alwaysLoad": true` on the server's entry in `.mcp.json`, and then the
search refusal rarely fires.

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
that reach a symbol. `enola help <command>` prints any command's page,
and `--help` never runs the command it describes.

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
