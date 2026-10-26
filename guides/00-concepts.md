# What enola is, and the words these guides use

enola builds a graph of a codebase (modules, symbols, routes, tables,
dependencies, and the edges between them), keeps it as a snapshot, and
grades a change by comparing the snapshot before it with the snapshot
after it. It reports what the change did: a dependency cycle that now
spans four files, a job that started calling a controller, a second part
writing a table that was one part's own. Those are invisible to a tool
that reads one file at a time, and a report of everything already wrong
with a repository buries them; a report of what one change added does
not.

Read this page once, then [start here](01-start-here.md). Every term
below links to the guide that covers it.

## How the pieces fit

1. **Extractors** read the source, one per language, and write **facts**:
   one line per module, symbol, route, table or dependency, and one per
   edge between them (`imports`, `calls`, `depends_on`, `reads`, ...).
2. **Providers** add facts no extractor measures: Ruby's own resolution
   of constants and ancestry, a linter's results, a capture of the app at
   run time.
3. The facts of one run are a **snapshot**, written to `.enola/` with a
   **receipt** saying which extractors and providers ran and what they
   skipped.
4. **Explainers** read the snapshot and compute **findings**: cycles,
   layer violations, dead code, query loops, coupling hotspots, and the
   breaches of your laws. Each carries a confidence between 0 and 1.
5. A **baseline** is a snapshot pinned as "before". `enola check`
   compares the current snapshot with it and prints a **verdict**: the
   findings the change introduced and resolved, and whether any of them
   fails the build under the policy you set.

## Glossary

| Term | What it means here | Covered in |
|---|---|---|
| **fact** | One measured thing (a module, a symbol, a route, a table, a dependency) or one edge between two. A snapshot is a file of them, `.enola/facts.jsonl`. | [Start here](01-start-here.md#3-take-the-first-snapshot) |
| **extractor** | The part of enola that reads one language's source and writes its facts. Every language in the tree is indexed into one graph; there is nothing to configure. | [Start here](01-start-here.md#2-look-before-you-configure) |
| **provider** | A program enola runs beside its extractors to add facts they cannot measure. `rubydex` and `prism` are built into the binary; anything else is an executable you configure. | [Providers](07-providers.md) |
| **census** | The one line a provider prints about what it read and what it skipped, kept in the receipt. | [Providers](07-providers.md#the-census) |
| **receipt** | `.enola/receipt.json`: which extractors and providers produced a snapshot, at which versions, and what they skipped. Two snapshots with different receipts may not be comparable. | [Start here](01-start-here.md#3-take-the-first-snapshot) |
| **explainer** | A named analysis over the snapshot (`cycles`, `layers`, `dead-code`, `query-loops`, `constraints`, ...) that produces findings. `enola check --help` lists them; they are what `-fail-on` names. | [Reading a verdict](20-reading-a-verdict.md) |
| **finding** | One thing an explainer reports, with a confidence. Below 1.00 it is a candidate to verify, not a verdict. | [Reading a verdict](20-reading-a-verdict.md) |
| **baseline** | The snapshot a change is graded against. `enola baseline pin .` pins the current one; in CI the template grades against the pull request's merge-base. | [Start here](01-start-here.md#4-pin-a-baseline-change-something-grade-it) |
| **verdict** | What `enola check` prints: PASS or FAIL, what the change introduced, and what it could not see. | [Reading a verdict](20-reading-a-verdict.md) |
| **law** | A rule you declare about parts of your code, with a reason and a mode. Written in Ruby (`law`) or YAML (`rules:`), kept in `enola/constraints/`, and reported as `Constraint <id> violated`. Law, rule and constraint name the same thing. | [Writing laws](04-writing-laws.md) |
| **part** | A named set of files or facts a law speaks about: `part` in Ruby, an entry under `components:` in YAML, a role in a recipe. | [Writing laws](04-writing-laws.md#parts) |
| **mode** | How strictly a law holds: `advisory` reports and never fails, `ratchet` fails only new breaches, `strict` fails every breach. Start in ratchet. | [Writing laws](04-writing-laws.md#modes-dates-and-carve-outs) |
| **breach** | One place a law is broken, named by its witness: the edge or fact that breaks it. | [Writing laws](04-writing-laws.md) |
| **recipe** | A named bundle of laws over roles, such as `layered` or `rails-conventions`, which a repository binds to its own directories in one block (`use_recipe:`). enola ships some; [`recipes/`](../recipes/README.md) has more to copy. | [Writing laws](04-writing-laws.md#recipes) |
| **exemption** | A carve-out written on the law itself, naming one witness with an owner, a reason and a date. | [Writing laws](04-writing-laws.md#modes-dates-and-carve-outs) |
| **suppression** | A signed, temporary excuse in `.enola/suppressions.yaml`, the only override for a strict breach. | [Writing laws](04-writing-laws.md#modes-dates-and-carve-outs) |
| **partial verdict** | A grade over only the facts both snapshots share, because a provider or extractor ran on one side only. It names what it left out. | [Reading a verdict](20-reading-a-verdict.md#partial) |
| **declined** | `check` refused to grade (exit 3) because the two snapshots are not comparable. Not a pass. | [Reading a verdict](20-reading-a-verdict.md#declined) |
| **unevaluable** | A law the snapshot cannot answer, reported with its cause instead of a verdict. | [Writing laws](04-writing-laws.md#when-a-law-refuses) |
| **hook** | A command an agent runs at a fixed moment (a session starting, a turn ending). `enola install --hooks` writes enola's. | [Hooks and agents](06-hooks-and-agents.md) |
| **MCP** | Model Context Protocol, the way a coding agent calls a tool server. `enola` with no arguments is that server; its tools are `explore`, `impact_analysis` and the rest. | [Hooks and agents](06-hooks-and-agents.md#register-the-mcp-server) |
| **cluster** | Several repositories indexed as one graph, so a call from a client can be matched to the route it reaches. | [Beyond one repository](08-beyond-one-repo.md) |
| **seam** | A link between two repositories in a cluster: a client call matched to a route, a topic one publishes and another consumes. | [Beyond one repository](08-beyond-one-repo.md) |
| **intent page** | A Markdown page carrying an `enola_intent:` block, anchored to the code it governs. Optional; the knowledge-base track builds on it. | [A knowledge base](09-a-knowledge-base-with-enola.md) |

## Who makes what

- **enola** is by Dejan Menges, at
  [enola-labs/enola](https://github.com/enola-labs/enola). Its own
  documentation is the reference; these guides are a path through it.
- **These guides** are by Muhamed Isabegovic and are not part of
  enola-labs. Each release says which enola it was checked against: this
  one is enola-guides 0.9.0, checked against enola v0.4.35.
- **tabula**, **taha** and **cardo** are separate projects by the guides'
  author: tabula keeps a knowledge base of intent pages, taha runs agents
  on it, and cardo is a build derived from enola that tabula carries.
  None of them is public yet, so [guide 13](13-tabula.md) and
  [guide 14](14-taha.md) are a preview. Nothing else in these guides
  needs them.

## Next to the tools you already run

Linters, type checkers and tests judge the current tree against rules they
bring, file by file. Keep them; enola does not replace any of them.

Tools that check dependency rules (packwerk for Ruby packs, import-linter
for Python, dependency-cruiser for JavaScript, ArchUnit for the JVM) are
closer, and several keep a list of known violations so only new ones fail.
If one of them already enforces what you need in one language, keep it.
What enola adds is one graph across every language and repository in the
product; facts beyond imports (routes, tables, client calls, a runtime
capture); findings it computes without being given a rule (cycles, dead
code, query loops, hotspots); and the same graph handed to a coding agent
as tools, so it can ask what a change would touch before making it.

## Where next

[Start here](01-start-here.md): install, a snapshot, a graded change and a
first law, in ten minutes.
