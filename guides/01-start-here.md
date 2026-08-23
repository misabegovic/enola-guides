# Start here: the first useful answer in ten minutes

enola answers one question no linter can: **what did this change do to the
architecture?** It builds a graph of your code (modules, symbols, routes,
tables, and how they depend on each other), keeps that graph as a snapshot,
and grades a change by comparing the snapshot before it with the snapshot
after it. A dependency cycle that spans four files, a job that started
calling a controller, a table a second part began writing to: those are
invisible to tools that look at one file at a time, and they are what enola
reports.

This guide takes you from nothing to a graded change. Everything here is
written for enola v0.4.4 or later, the release that carries the constraints
vocabulary this repository's recipes and templates target; if your
`enola --version` is older, upgrade first.

## 1. Install

No Go toolchain, no compiler, one binary:

```bash
curl -fsSL https://raw.githubusercontent.com/enola-labs/enola/main/install.sh | sh
enola --version
```

If your application is Ruby, fetch the Rubydex engine once so enola can
resolve constants and ancestry through Ruby's own rules (more in
[providers](07-providers.md)):

```bash
enola providers fetch rubydex
enola providers list
```

## 2. Look before you configure

One read-only command, nothing written:

```bash
enola --explain .
```

It prints the architecture it detected (pattern, cycles, layer
violations), the coupling hotspots with their blast radius, and the code
health findings. Nothing here is a setting: enola detects every language
in the tree and indexes all of them into one graph.

## 3. Take the first snapshot

```bash
enola --generate .
```

This writes `.enola/` in the repository (add it to `.gitignore`): the
facts, the findings the explainers computed, and a receipt saying which
extractors and providers ran and what they skipped. Read the receipt's
census when something looks missing: a file enola did not parse is named
there, never silently dropped.

## 4. Pin a baseline, change something, grade it

```bash
enola baseline pin .
# ... edit code ...
enola --generate .
enola check .
```

`check` compares the current snapshot with the pinned one and prints what
the change did: findings introduced, findings resolved, edges added. It
exits 0 unless you tell it what fails the build:

```bash
enola check -fail-on constraints,cycles,layers .
```

Two outcomes are not verdicts, and the output says so: **DECLINED** means
the two snapshots are not comparable (a different enola version, a
provider that ran on one side only, changed ignore globs), so re-pin the
baseline rather than reading it as a pass; **unevaluable** on a rule means
the snapshot could not answer that rule (no resolved ancestry, no runtime
capture, one repository where two are needed), named with its cause.

## 5. Tell your agents

```bash
enola install --hooks
enola doctor
```

`install` writes enola's instructions into the files your coding agents
already read and, with `--hooks`, adds a session-start hook that restores
the snapshot and a session-end hook that grades the session's delta. It
previews every change and asks before writing; `enola uninstall` reverses
it byte for byte. `doctor` reports whether the hooks actually fired, which
version you run, and whether the Rubydex library is in place. Your agent
gets a map it can query instead of grepping; the [hooks and agents
guide](06-hooks-and-agents.md) says what to put in its skill.

## 6. Declare your first law

```bash
enola constraints init .
enola constraints lint .
```

`init` writes a starter declaration bound to the recipes whose roles your
tree has (controllers, models, jobs for a Rails app) and refuses to
overwrite one that exists. `lint` shows what each part resolved to. Then
write one law of your own in Ruby, in `enola/constraints/`:

```ruby
Enola.architecture "shop" do
  rails

  law "background jobs never invoke controller code" do
    jobs.must_not_call controllers
    why "rendering from a job goes through ApplicationController.renderer"
    mode :ratchet
  end
end
```

`ratchet` reports what already breaks the law and fails only what a
change adds, which is the mode to start every law in. The [writing laws
guide](04-writing-laws.md) has the whole vocabulary.

## Where next

- [A Rails application](02-rails.md): what enola measures in one, the
  providers that sharpen it, the recipe that names its parts.
- [An Ember application](03-ember.md): the same for the front end.
- [Constraints in CI](05-constraints-in-ci.md): the check step, with a
  template you copy.
- [Beyond one repository](08-beyond-one-repo.md): the cluster, and the laws
  that only make sense across it.
