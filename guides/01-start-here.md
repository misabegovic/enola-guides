# Start here: the first useful answer in ten minutes

enola answers one question no linter can: **what did this change do to the
architecture?** It builds a graph of your code (modules, symbols, routes,
tables, and how they depend on each other), keeps that graph as a snapshot,
and grades a change by comparing the snapshot before it with the snapshot
after it. A dependency cycle that spans four files, a job that started
calling a controller, a table a second part began writing to: those are
invisible to tools that look at one file at a time, and they are what enola
reports. The words this guide uses (snapshot, baseline, law, verdict) are
defined in [what enola is](00-concepts.md).

This guide takes you from nothing to a graded change and a first law.
Everything here is checked against enola v0.4.35. Any newer release should
work; when you need the exact one, pin it as step 1 shows.

## 1. Install

No Go toolchain, no compiler, one binary:

```bash
curl -fsSL https://raw.githubusercontent.com/enola-labs/enola/main/install.sh | sh
enola --version
```

The script installs the newest release into `~/.local/bin` and fetches
the Rubydex library enola uses to resolve Ruby constants and ancestry
(more in [providers](07-providers.md)). The same binary is on PyPI as
`enola-cli` (`enola` was taken); install it as a tool, not into a
project's environment, and pin the version there when you need this
guide's exactly:

```bash
pipx install enola-cli==0.4.35      # or: uv tool install enola-cli==0.4.35
enola providers fetch rubydex       # once; the install script does this for you
```

enola is not on npm. The npm package called `enola` is an unrelated tool
that deletes files; do not `npm install -g enola`. Every release,
with a checksum per platform, is on
[enola's releases page](https://github.com/enola-labs/enola/releases).

Steps 2 to 6 work on any repository. To follow them exactly, with the
outputs shown here, use the worked Python example, one command away with
[`enola-guides`](../README.md#these-guides-as-a-command):

```bash
enola-guides copy examples/python-service && cd python-service && git init -q
```

It is a four-package service (`shop/api`, `shop/services`, `shop/domain`,
`shop/repositories`) that already declares three laws in
`enola/constraints/` and breaks each on purpose.

## 2. Look before you configure

One read-only command, nothing written:

```bash
enola --explain . 2>/dev/null
```

It prints what it found (languages, facts by kind, routes, tables,
dependencies), the architecture it detected (pattern, cycles, layer
violations), the coupling hotspots with their blast radius, and the code
health findings. Every command logs its progress on stderr, about a
hundred `[engine]` lines on a first run; `2>/dev/null` hides them. Nothing
here is a setting: enola detects every language in the tree and indexes
all of them into one graph, and the line `no mcp-arch.yaml ... using
built-in defaults` (on stderr) means exactly that. `--explain` does not grade your
laws; their breaches show in `enola check`, below.

## 3. Take the first snapshot

```bash
enola --generate .
```

This writes `.enola/` in the repository: the facts, the findings the
explainers computed, and a receipt saying which extractors and providers
ran and what they skipped. Read the receipt's census when something looks
missing: a file enola did not parse is named there, never silently
dropped. enola also records each snapshot in a history under `~/.enola/`,
which `enola gc` reports on and trims.

Keep `.enola/` out of git, except `.enola/suppressions.yaml` if you add
one later (see [writing laws](04-writing-laws.md#modes-dates-and-carve-outs)):

```gitignore
.enola/*
!.enola/suppressions.yaml
```

## 4. Pin a baseline, change something, grade it

Pin the architecture as it is now, the "before" every grade compares
against:

```bash
enola baseline pin .
```

Then change something. In the example, make the domain call the API, the
layer above it:

```bash
cat > shop/domain/recent.py <<'EOF'
from shop.api.orders import list_recent


def recent():
    return list_recent()
EOF
enola check -fail-on cycles .
```

`check` takes a fresh snapshot of the working tree, compares it with the
pinned one, and prints what the change did:

```text
FAIL — 1 structural regression introduced.
could not see: 1 file and 1 directory excluded by ignore globs; 3 imports targets outside the graph
law: 7 rules · 3 breaches · none excused

Regressions (fail):
  - [cycles] 1.00 — Cyclic dependency detected (3 modules)
      module "shop/api" is part of the cycle
```

The API already reached the domain through the services, so the domain
calling back closed a loop through three packages, which no single file
shows. The `law:` line counts the example's three laws (seven rules once
their recipes expand), and `could not see` names what the run did not
measure (an ignored directory, imports of libraries outside the
repository). Undo the change before going on: `rm shop/domain/recent.py`.

`check` exits 0 unless you set `-fail-on` (here, `cycles`), which names
the explainers whose new findings fail the build, or a law in `strict`
mode is broken. `PASS` or `FAIL` leads the output. Three other words need
reading before you trust it, and the output names each. **DECLINED**
(exit 3) means the two snapshots are not comparable (a different enola
version, changed ignore globs, another repository), so re-pin the
baseline rather than reading it as a pass. A **partial verdict**
(`PASS (partial verdict)` or `FAIL (partial verdict)`) means a provider
or extractor ran on one side only: enola grades the facts both sides
share and names what it left ungraded. **unevaluable** on a law means the
snapshot could not answer it, named with its cause.
[Reading a verdict](20-reading-a-verdict.md) has every section of the
output and every exit code.

## 5. Tell your agents

An agent uses enola through its MCP server, which is the `enola` binary
run with no arguments. Register it once; for Claude Code 2.1.287 or later,
with its tools loaded when the session starts:

```bash
claude mcp add-json enola '{"command":"enola","alwaysLoad":true}'
```

[Hooks and agents](06-hooks-and-agents.md#register-the-mcp-server) has the
line for Cursor, Codex, Copilot, opencode and Pi. Then the instructions
and the hooks:

```bash
enola install --hooks --targets claude --dry-run    # what it would write
enola install --hooks --targets claude
```

`install` writes enola's instructions into the files your coding agents
already read (`.claude/rules/enola.md` for Claude Code) and, with
`--hooks`, a session-start hook that pins the architecture as the
session's baseline and a stop hook that grades what the session changed.
Without `--targets` it writes for every agent it knows (Claude Code,
Cursor, Codex, Copilot, Pi, opencode). It always previews and asks before
writing; with no terminal it writes nothing and still exits 0, so a
script passes `--yes`. `enola uninstall` reverses it byte for byte.

Restart the agent session, then:

```bash
enola doctor
```

reports whether the hooks actually fired, what they concluded, and whether
the pinned baseline can still be graded against. Until a session has
started in the repository it says `NEITHER HOOK HAS EVER RUN`; that is
the expected answer before the restart, and the one to worry about after
it. The session-start hook leaves a baseline you pinned by hand in
place, so after step 4 every session is graded against that pin; run
`enola baseline clear .` to have each session graded from its own start.
The hooks are written with the absolute path of your `enola`, so
before committing `.claude/settings.json` read
[what to commit](06-hooks-and-agents.md#what-to-commit).

## 6. Declare your first law

A law is a sentence about two parts of your code, its reason, and how
strictly it holds. Write it in YAML in `enola/constraints/`; YAML is the
form every team can write, whatever the language. In the example, the
API should reach storage only through the services:

```yaml
# enola/constraints/first.yaml
components:
  - name: api
    match: ["shop/api/**"]
  - name: storage
    match: ["shop/repositories/**"]
rules:
  - id: the-api-never-imports-storage
    forbid: api
    to: storage
    via: imports
    mode: ratchet
    because: "a route goes through a service, so the service can change how orders are stored"
```

On your own repository, change the globs to two directories of yours.
Then:

```bash
enola constraints lint .     # is it valid, and what did each part match?
enola check .
```

`lint` prints each part with the members it matched (`api  5
member(s)`); a part that matched nothing is the first thing to fix.
`check` lists a law the change adds apart from what the change did, with
every breach the code already had:

```text
Newly declared (1) — a rule this change declares, re-forms or un-exempts
reports these on code the change did not touch. The baseline the rule starts
from, not regressions the change made:
  - [constraints] 1.00 — Constraint the-api-never-imports-storage violated: module-edge: shop/api -> shop/repositories -> shop/repositories via imports
```

The breach is named by its witness: the edge between two modules
(`shop/api -> shop/repositories`), then the module it lands in. A 0.40
finding beside it, `reached no verdict on 3 imports target(s)`, says some
imports name libraries outside the graph; it fails nothing
([reading a verdict](20-reading-a-verdict.md#outputs-that-surprise-a-first-reader)).

Pin again (`enola baseline pin .`) so the law and its one breach are the
new "before", and add an admin report that reads storage directly:

```bash
mkdir -p shop/api/admin && touch shop/api/admin/__init__.py
cat > shop/api/admin/report.py <<'EOF'
from shop.repositories.orders import recent_orders


def report():
    return len(recent_orders())
EOF
enola check -fail-on constraints .
```

```text
FAIL — 2 structural regressions introduced.
…
Regressions (fail):
  - [constraints] 1.00 — Constraint shop/presentation-reaches-application-only violated: shop/api/admin/report.report -> shop/repositories/orders.recent_orders via calls
  - [constraints] 1.00 — Constraint the-api-never-imports-storage violated: module-edge: shop/api/admin -> shop/repositories -> shop/repositories via imports
```

Your law and one of the example's (`layered`, bound as `shop`) both fail
on the new code and stay quiet about the old breach. That is `ratchet`:
it reports what already breaks the law and fails only what a change adds,
which is the mode to start every law in. Because a breach is the edge
between two modules, a second import along `shop/api ->
shop/repositories` would not be new; a new package reaching storage is.

**A shortcut, and when it applies.** `enola constraints init .`, after
a snapshot, writes a declaration binding every shipped recipe all of whose
roles it finds a directory for. Those are mostly Rails directories, so a
Rails application with controllers, models, jobs, mailers, policies,
serializers and view components gets `rails-conventions` and its
neighbours; most other trees get `nothing to bind`, with the directories
each recipe missed, and nothing is written (`--dry-run` prints the same
without writing, `--recipe NAME` binds one). Bind a recipe to your own
directories as [the Python guide](15-python.md) does, or write the law
yourself as above.

A Ruby team can write its laws in Ruby, parsed and never run:

```ruby
# enola/constraints/jobs.rb
Enola.architecture "shop" do
  rails   # declares controllers, models, jobs and the other Rails parts

  law "background jobs never invoke controller code" do
    jobs.must_not_call controllers
    why "rendering from a job goes through ApplicationController.renderer"
    mode :ratchet
  end
end
```

In a repository with no Ruby, do not start with a `.rb` law. It is the
first Ruby file the snapshot sees, so the next `check` is partial and
reports the law's old breaches as new. Use YAML. If you add one anyway,
list its breaches first (`enola --generate . && enola constraints ledger .`),
then pin again.

[Writing laws](04-writing-laws.md) has the whole vocabulary, and
[`examples/laws`](../examples/laws/README.md) has twenty-six to copy.

## Where next

- Your stack: [Rails](02-rails.md), [Ember](03-ember.md),
  [Python](15-python.md), [TypeScript](16-typescript.md), [Go](17-go.md),
  [Rust](18-rust.md).
- [Constraints in CI](05-constraints-in-ci.md): the check on every pull
  request, with a template you copy.
- [Rolling out](19-rolling-out.md): adopting it on a repository that
  already has years of history, without failing everything on day one.
- [Hooks and agents](06-hooks-and-agents.md): what an agent does
  differently with enola connected.
