# enola-guides

How to use [enola](https://github.com/enola-labs/enola), the tool that
grades what a change did to a codebase's architecture, checked against
v0.4.34: laws written as sentences in Ruby or YAML, recipes a team
reviews, providers that run beside enola's own extractors, the check in
CI, the hooks and MCP tools an agent uses during a session, and the
knowledge base built on top of it with [tabula](guides/13-tabula.md) and
[taha](guides/14-taha.md). Guides for Rails, Ember, Python, TypeScript,
Go and Rust, worked examples that CI snapshots and grades on every change,
skills and templates, packaged so a team can pin the guidance it adopted.

```bash
gem install enola-guides
gem contents enola-guides
```

## Start with an example

[`examples/rails-shop`](examples/rails-shop): a Rails application declaring
thirteen laws in the Ruby DSL, one file each, from "jobs never invoke controller code" to
"billing keeps to its own tables" and "a mutating action is authorized",
with Prism and Rubydex configured as providers beside the extractors.
[`examples/ember-app`](examples/ember-app): an Ember application bound to
the conventions recipe in one block. [`examples/knowledge-base`](examples/knowledge-base/README.md):
two pages anchored to code, a cluster config, receipts and a finding ledger,
the smallest knowledge base the skills and hooks run against. [`examples/python-service`](examples/python-service),
[`examples/typescript-service`](examples/typescript-service),
[`examples/go-service`](examples/go-service) and
[`examples/rust-service`](examples/rust-service): the same four-layer
service in each language, with its source, breaking the laws it states on
purpose so you can watch each one fire. [`examples/laws`](examples/laws/README.md):
twenty-six laws, one directory each, from foreign keys on a tenant column
to parts that may not cycle, each a complete declaration you copy and run.

## Guides

1. [Start here](guides/01-start-here.md): install, snapshot, baseline, a
   graded change, the hooks, a first law. Ten minutes.
2. [A Rails application](guides/02-rails.md): what enola measures, the
   Prism and Rubydex providers, the recipe, the laws a Rails team writes.
3. [An Ember application](guides/03-ember.md): the Ember facts, the
   conventions as a recipe, an app inside a larger repository.
4. [Writing laws](guides/04-writing-laws.md): parts, the twenty-one
   sentences, modes, dates, exemptions, what a refusal means.
5. [Constraints in CI](guides/05-constraints-in-ci.md): the check step.
6. [Hooks and agents](guides/06-hooks-and-agents.md): the session hooks,
   the MCP tools, the skills.
7. [Providers](guides/07-providers.md): the seam, the Ruby pair, the
   census, the runtime capture.
8. [Beyond one repository](guides/08-beyond-one-repo.md): the cluster, the
   seams, the laws across them, the history.
9. [A knowledge base with enola](guides/09-a-knowledge-base-with-enola.md):
   what a wiki of decisions gets when its pages anchor to code and every
   number it states was read from a receipt.
10. [Hooks](guides/10-hooks.md): the four agent hooks a knowledge base runs
    (intent-first gate, turn record, stop-time debt, session refresh).
11. [The skills, as they run](guides/11-the-skills-as-they-run.md): deepdive
    before shaping, claim check while ingesting, drift on a schedule,
    citation hygiene, the blast radius.
12. [The wrapper](guides/12-the-wrapper.md): the thin command the skills
    call, the named skip, the receipts and the ledger.
13. [tabula](guides/13-tabula.md): the knowledge base kept by a tool that
    carries cardo, its laws compiled into `enola/constraints/`, PRDs
    graded with `enola check`, and which hand-built piece each verb
    replaces.
14. [taha](guides/14-taha.md): agents run on a tabula project under a
    mandate, gated by tabula's verdicts, asking before anything is
    published.
15. [A Python service](guides/15-python.md),
16. [a TypeScript or JavaScript service](guides/16-typescript.md),
17. [a Go service](guides/17-go.md), and
18. [a Rust service](guides/18-rust.md): what enola measures in each
    language, the `layered` recipe bound to a service, the law over
    `imports` its domain rules need, dependencies, and where v0.4.34 reads
    less than the code says.

## Skills

The skills under [`templates/skills/`](templates/skills) are the ones used
day to day with enola's MCP in an agent session: `enola` (ask the graph
before grepping, grade after changing), `enola-laws` (write a law as a
sentence with a reason, lint it, read what it verdicts),
`enola-grade-before-push` (the delta is the deliverable, a declined grade
is not a pass), `enola-intent-first` (read the governing decision before
the file moves), and the five a knowledge base runs: `enola-deepdive`,
`enola-ingest-check`, `enola-drift`, `enola-citation-hygiene`,
`enola-zoom-out`, each described as it runs in
[guide 11](guides/11-the-skills-as-they-run.md). Copy a directory into
your agent's skills folder; the hooks they pair with are under
[`templates/hooks/`](templates/hooks).

## Templates and recipes

[`templates/`](templates): the CI check script and its comment renderer,
a cluster configuration, a constraints starter. [`recipes/`](recipes/README.md) (the catalogue munola binds, each recipe with the number its laws held at):
recipes a repository copies into its own `enola/recipes/` and binds in one
line, starting with the Ember conventions and a house-recipe template;
starting points the team reviews, never defaults the tool applies.
