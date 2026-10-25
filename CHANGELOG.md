# Changelog

## 0.6.0 (2026-10-25)

tabula and taha. Guide 13 is tabula for an enola user: a release that
carries cardo inside the binary and finds it last, after `engine.binary`
and any `enola` on PATH; the tour; laws said on an architecture page and
compiled into plain enola YAML that upstream v0.4.34 lints clean; a PRD
bullet graded with `grade: enola check clean`; its hooks beside enola's;
and which hand-built piece of guides 09 to 12 each verb replaces. Guide
14 is taha: installing from a clone (the npm name `taha` is another
package's), a run under a mandate, adopting a repository enola already
measures, and the `cardo` it calls by name. Guides 09 to 12 keep the
hand-built path and say where tabula takes it over.

## 0.5.0 (2026-10-25)

What enola shipped between v0.4.4 and v0.4.34, each command and key run
against v0.4.34 before it was written down:

- Guide 05: enola-action@v2, with the install step that gives it the
  Rubydex library it does not fetch itself, its outputs, and `-format`
  `sarif`, `annotations` and `summary`; `-reviewers`. A CI job runs the
  workflow the guide prints.
- Guide 06: the opencode and Pi install targets, the Claude Code plugin
  and what it leaves out, all twenty-two MCP tools, and the questions the
  CLI answers without an agent (`impact`, `endpoint`, `plan`, `flows`,
  `constraints ledger`, `dashboard`).
- Guide 07: the rbs and zeitwerk providers, provider reuse, and pinning a
  provider of your own.
- Guide 08: `cluster init` and folders indexed as clusters, why the
  output directory needs its own name (it is resolved inside each
  member), `matched_routes`, `caller`, `unreached_by_clients`, `coverage
  --unresolved`, declaring an in-house HTTP client, and sharing the
  history.
- Guide 04: laws over dependencies and the `supply-chain` recipe, the
  ledger, `no_frame_in_members`, and how `since` falls back to git.
  In v0.4.34 a Ruby `where:` drops a value that is not a string or a
  symbol, so the guide quotes booleans and numbers.
- Guide 02: the `packwerk` explainer and the `package_paths` it needs
  when packs live outside `packages/`, and the `ruby-conventions` recipe.

## 0.4.0 (2026-10-25)

Checked against enola v0.4.34. enola skips a provider whose
`expected_version` disagrees with what it answers, and the guides pinned
Prism at `0.1.0` (the script answers `0.2.0` since v0.4.5) and Rubydex at
`0.4.0` (the binary carries `0.4.1` since v0.4.33), so their Ruby
configurations produced no provider facts. Every configuration now names
the built-in `rubydex` and `prism` providers with no pin; neither needs
Ruby. Also fixed, each wrong before this release too:

- The configuration file is `mcp-arch.yaml`; enola never read
  `enola.yaml`, so `examples/rails-shop` now ships `mcp-arch.yaml`.
- `templates/enola-check.sh` defaults to v0.4.34 (it named `0.5.0`, which
  does not exist), installs the binary under the name the release archive
  gives it, configures the built-in providers in a tree with a `Gemfile`,
  and grades with the configuration it generated with; grading the bare
  path read no providers and reported every Ruby run as a partial verdict.
- `templates/enola-findings.rb` renders a partial verdict and names each
  producer it left ungraded.
- `constraints init` writes `enola/constraints/recipes.yaml`.
- A provider that ran on one side only gives a partial verdict, not a
  decline; the session-start hook pins a baseline, and in Claude Code a
  `PreToolUse` hook refuses the first two file searches.
- `doctor` reports the hooks and the baseline, not the Rubydex library.
- The recipes README lists `ruby-conventions` and `supply-chain` among
  upstream's built-ins.

A CI workflow lints every example against the pinned enola release, runs
the check template end to end on a Rails fixture, and checks every
relative link.

## 0.3.1 (2026-08-23)

The recipes README says where the catalogue ships: built into munola,
written by `munola init`; the upstream channels carry upstream's built-ins
only.

## 0.3.0 (2026-08-23)

The recipe catalogue munola binds: `data-ownership`, `api-boundaries`,
`background-work` and the `tenant-foreign-key` template beside
`ember-conventions`, each law an existing enola form with the number it held
at on a real monolith in the catalogue table; every file lints clean bound
to a Rails tree.

## 0.2.1 (2026-08-23)

enola v0.4.4 released the constraints program the guides describe
(enola-labs/enola#247 merged); the README says released rather than landing,
and the install guide names v0.4.4 as the minimum.

## 0.2.0 (2026-08-22)

What a knowledge base gets. Four guides (a knowledge base with enola,
hooks, the skills as they run, the wrapper), four hook templates
(intent-first gate, turn record, stop-time debt, session refresh), five
skills as a knowledge base runs them (deepdive, ingest check, drift,
citation hygiene, zoom out) and a worked example knowledge base with two
anchored pages, receipts and a finding ledger.

## 0.1.2 (2026-08-22)

One law per file: the Rails shop, the cluster laws, the maintenance-task laws
and the starter each put every law in a file of its own that declares the parts it
speaks about, so a reader finds a law by its name and a reviewer sees one
law per diff.

## 0.1.1 (2026-08-22)

The laws catalogue: `examples/laws/`, twenty-six complete declarations one
directory each, nineteen proven by enola's benchmark suite and seven
generalised from daily use (foreign keys, maintenance tasks, a public tool
prefix, one door to a schema, readers that read the store only, cluster
laws), each with a README and verified with `constraints lint`.

## 0.1.0 (2026-08-22)

First content. Eight guides (start here, a Rails application, an Ember
application, writing laws, constraints in CI, hooks and agents,
providers, beyond one repository), two worked examples (a Rails shop in
the Ruby DSL with Prism and Rubydex as providers; an Ember app bound to
the conventions recipe), four agent skills (enola, enola-laws,
enola-grade-before-push, enola-intent-first), the CI check template with
its renderer, a cluster configuration, a constraints starter, and two
recipes. Written against the release of enola that carries the
constraints vocabulary (enola-labs/enola#247).

## 0.0.0

Placeholder to claim the name.
