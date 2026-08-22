# enola-guides

Guides, templates and recipes for [enola](https://github.com/enola-labs/enola),
the architecture-graph tool, written for Ruby and Rails developers first.
Installed as a gem so a team can pin the guidance it adopted; consumed by
[enola-rb](https://github.com/misabegovic/enola-rb), the gem that runs enola.

Everything here is written against the release that carries the
constraints vocabulary: the built-in Rubydex provider, the twenty-one rule
forms with their Ruby sentences, recipes with role defaults, and laws that
read the whole graph.

## Guides

1. [Start here](guides/01-start-here.md): install, the first snapshot, a
   baseline, a graded change, the hooks, a first law. Ten minutes.
2. [A Rails application](guides/02-rails.md): what enola measures, the
   Prism and Rubydex providers, the rails-conventions recipe, the laws a
   Rails team writes.
3. [An Ember application](guides/03-ember.md): the Ember facts, the
   conventions as a recipe, an app inside a larger repository.
4. [Writing laws](guides/04-writing-laws.md): parts, the twenty-one
   sentences, modes, dates, exemptions, what a refusal means.
5. [Constraints in CI](guides/05-constraints-in-ci.md): the check step and
   why it looks the way it does.
6. [Hooks and agents](guides/06-hooks-and-agents.md): the session hooks,
   the MCP tools, the skill.
7. [Providers](guides/07-providers.md): the seam, the Ruby pair, the
   census, the runtime capture.
8. [Beyond one repository](guides/08-beyond-one-repo.md): the cluster, the
   seams, the laws across them, the history.

## Templates

- [`templates/enola-check.sh`](templates/enola-check.sh) and
  [`templates/enola-findings.rb`](templates/enola-findings.rb): the CI
  check and its comment renderer, three seams to fill in.
- [`templates/enola-cluster.yaml`](templates/enola-cluster.yaml): a cluster
  configuration.
- [`templates/constraints-starter.rb`](templates/constraints-starter.rb): a
  first declaration for a Rails application.
- [`templates/skills/enola/SKILL.md`](templates/skills/enola/SKILL.md): the
  agent skill.

## Recipes

[`recipes/`](recipes/README.md): architecture recipes a repository copies
into its own `enola/recipes/` and binds in one line, starting with the Ember
conventions and a house-recipe template. Each is a starting point the team
reviews, not a default the tool applies.
