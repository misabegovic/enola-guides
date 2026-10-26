# enola-guides

[enola](https://github.com/enola-labs/enola) snapshots a codebase's
architecture (modules, calls, routes, tables, dependencies) and grades
each change against a pinned baseline. It catches what file-by-file
linters cannot: a new cycle across four files, a job that starts calling
a controller, a second part writing a table that was one part's own. And
it reports only what the change added, not the hundreds of findings the
repository already had.

These are guides to using it: a first graded change in ten minutes, laws
your team states as sentences, the check on every pull request, and the
hooks and tools a coding agent uses during a session, for Rails, Ember,
Python, TypeScript, Go and Rust. Every command, flag and output in them
was run against **enola v0.4.35**, and CI snapshots and grades the worked
examples on every change. The guides are by Muhamed Isabegovic and are
not part of enola-labs.

## Install enola

```bash
curl -fsSL https://raw.githubusercontent.com/enola-labs/enola/main/install.sh | sh
enola --version
```

or `pipx install enola-cli` (the PyPI name; the command is `enola`).
[Start here](guides/01-start-here.md) has the rest, including how to pin
a version. enola is not on npm: the npm package `enola` is something
else.

## Read in this order

**New to enola**

- [What enola is, and the words these guides use](guides/00-concepts.md):
  the pieces, a glossary, and how it sits beside the tools you already
  run. Five minutes.
- [Start here](guides/01-start-here.md): install, snapshot, baseline, a
  graded change, the agent hooks, a first law. Ten minutes.

**Your stack**: what enola measures in each, the recipe that names its
parts, and where it reads less than the code says.

- [Rails](guides/02-rails.md) · [Ember](guides/03-ember.md) ·
  [Python](guides/15-python.md) · [TypeScript and JavaScript](guides/16-typescript.md) ·
  [Go](guides/17-go.md) · [Rust](guides/18-rust.md)

**Laws and CI**

- [Writing laws](guides/04-writing-laws.md): parts, the sentences, modes,
  dates, exemptions and suppressions, what a refusal means.
- [Constraints in CI](guides/05-constraints-in-ci.md): the check on every
  pull request, on GitHub or any other CI.
- [Rolling out](guides/19-rolling-out.md): adopting it on a repository
  with years of history, what to commit, what it costs, how to turn each
  piece off.
- [Reading a verdict](guides/20-reading-a-verdict.md): every section of
  `enola check`'s output, every exit code, and the surprises.

**Agents**

- [Hooks and agents](guides/06-hooks-and-agents.md): registering the MCP
  server, the session hooks, what the agent does differently, the tools
  it reaches for.

**Deeper**

- [Providers](guides/07-providers.md): the Ruby pair, the census, the
  runtime capture, writing one.
- [Beyond one repository](guides/08-beyond-one-repo.md): the cluster, the
  seams between repositories, the laws across them, the history.

**Optional: a knowledge base of decisions.** For teams that keep
decision records beside their code and want each page anchored to the
code it governs. Nothing above needs it.

- [A knowledge base with enola](guides/09-a-knowledge-base-with-enola.md):
  pages that compile into the graph, receipts, a finding ledger.
- [Knowledge-base hooks](guides/10-hooks.md): the intent-first gate, the
  turn record, the stop-time debt, the session refresh.
- [The knowledge-base skills, as they run](guides/11-the-skills-as-they-run.md):
  deepdive, claim check, drift, citation hygiene, zoom-out.
- [The wrapper](guides/12-the-wrapper.md): the command those skills call,
  shipped as a template.
- *Preview:* [tabula](guides/13-tabula.md) and [taha](guides/14-taha.md),
  the same practice as one program and agents run on it. Neither is
  public yet.

## Worked examples

- [`examples/python-service`](examples/python-service),
  [`typescript-service`](examples/typescript-service),
  [`go-service`](examples/go-service) and
  [`rust-service`](examples/rust-service): the same four-layer service in
  each language, with its source, breaking the laws it states on purpose
  so you can watch each one fire.
- [`examples/rails-shop`](examples/rails-shop): thirteen laws in the Ruby
  DSL, one file each, from "jobs never invoke controller code" to
  "billing keeps to its own tables", with the Prism and Rubydex
  providers configured.
- [`examples/ember-app`](examples/ember-app): an Ember application bound
  to the conventions recipe in one block.
- [`examples/laws`](examples/laws/README.md): twenty-six laws, one
  directory each, from foreign keys on a tenant column to parts that may
  not cycle, each a complete declaration you copy and run.
- [`examples/knowledge-base`](examples/knowledge-base/README.md): two
  pages anchored to code, a cluster config, receipts and a finding
  ledger, for the optional track.

## Skills, hooks, templates and recipes

- [`templates/skills/`](templates/skills): skills for a coding agent.
  Four for any repository: `enola` (ask the graph before searching, grade
  after changing), `enola-laws` (write a law with a reason, lint it, read
  its verdict), `enola-grade-before-push` (a declined grade is not a
  pass) and `enola-intent-first` (read the governing decision before the
  file moves). Five more belong to the knowledge-base track and call its
  [wrapper](guides/12-the-wrapper.md) (`enola-guides copy templates/kb`):
  `enola-deepdive`, `enola-ingest-check`, `enola-drift`,
  `enola-citation-hygiene`, `enola-zoom-out`.
- [`templates/hooks/`](templates/hooks): the knowledge-base hooks of
  [guide 10](guides/10-hooks.md).
- [`templates/`](templates): the CI check script and its comment
  renderer, a cluster configuration, and a starter of four Rails laws.
- [`recipes/`](recipes/README.md): recipes to copy into your own
  `enola/recipes/` and bind in one block, each with the count its laws
  held at on a real repository; starting points a team reviews, never
  defaults the tool applies.

## These guides as a command

Everything above is also one command, `enola-guides`, with the same items
and the same output from every package. Take it from the ecosystem you
already use:

```bash
gem install enola-guides                                         # RubyGems
npm install -g enola-guides                                      # npm
pipx install enola-guides                                        # PyPI (or uv tool install)
cargo install enola-guides                                       # crates.io
go install github.com/misabegovic/enola-guides/cmd/enola-guides@latest
brew install misabegovic/tap/enola-guides                        # Homebrew
```

or a binary for Linux, macOS or Windows from the
[releases](https://github.com/misabegovic/enola-guides/releases). Then:

```bash
enola-guides list                    # every item; list guides, list laws, list skills, ...
enola-guides show guides/01-start-here
enola-guides copy laws/foreign-keys  # writes enola/constraints/foreign-keys.yaml
enola-guides copy skills/enola       # writes .claude/skills/enola/SKILL.md
enola-guides copy hooks/stop-debt    # writes .claude/hooks/stop-debt.sh
enola-guides copy examples/python-service   # a project to try the guides on
```

`copy` writes an item's files under a directory each kind has a default
for (`enola/constraints` for a law, `enola/recipes` for a recipe,
`.claude/skills` for a skill, `.claude/hooks` for a hook) or the one you
name, and never overwrites: it names the first file that exists and
writes nothing. The gem also carries the tree itself, so
`gem contents enola-guides` lists every file and a team can pin the
guidance it adopted in its `Gemfile`.
