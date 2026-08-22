# enola-guides

How to use what is landing in [enola](https://github.com/enola-labs/enola)
([enola-labs/enola#247](https://github.com/enola-labs/enola/pull/247)): a
Ruby DSL for writing architecture constraints, Prism and Rubydex as
providers that run together with enola's own extractors, recipes a team
reviews, laws that read the whole graph, and an MCP your agent uses during
a session. Guides, worked examples, skills and templates, packaged as a
gem so a team can pin the guidance it adopted. Rubyists first; consumed by
[enola-rb](https://github.com/misabegovic/enola-rb), the gem that runs
enola. Expanding as the practice does.

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
the conventions recipe in one block. [`examples/laws`](examples/laws/README.md):
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

## Skills

The skills under [`templates/skills/`](templates/skills) are the ones used
day to day with enola's MCP in an agent session: `enola` (ask the graph
before grepping, grade after changing), `enola-laws` (write a law as a
sentence with a reason, lint it, read what it verdicts),
`enola-grade-before-push` (the delta is the deliverable, a declined grade
is not a pass), `enola-intent-first` (read the governing decision before
the file moves). Copy a directory into your agent's skills folder.

## Templates and recipes

[`templates/`](templates): the CI check script and its comment renderer,
a cluster configuration, a constraints starter. [`recipes/`](recipes/README.md):
recipes a repository copies into its own `enola/recipes/` and binds in one
line, starting with the Ember conventions and a house-recipe template;
starting points the team reviews, never defaults the tool applies.
