# Changelog

## 0.9.0 (2026-10-26)

Checked against enola v0.4.35, and read again as someone who has never
heard of enola: a developer landing on the README, one following guide 01
literally on a Python service, and a tech lead deciding whether to adopt
it. What they tripped on is fixed, and every command it changed was run
against v0.4.35.

- The README says what enola is and how to install it before anything
  else, and groups the guides into tracks: new to enola, your stack, laws
  and CI, agents, deeper, and an optional knowledge-base track.
- Three new guides. [00, what enola is](guides/00-concepts.md): the
  pieces, a glossary, who makes what, and enola beside linters and
  dependency-rule tools. [19, rolling out](guides/19-rolling-out.md):
  measured costs (Mastodon and a 20,000-file Rails monolith), one recipe
  instead of five, report then enforce, owners, what to commit, turning
  it off. [20, reading a verdict](guides/20-reading-a-verdict.md): every
  section and exit code, partial and declined, the surprises.
- Guide 01: install pinned through `pipx`, the npm `enola` warning, the
  MCP server registered with `alwaysLoad`, `doctor` before a restart, a
  first law in YAML that fires on any layout with the output it gives,
  and why a first `.rb` law in a repository with no Ruby makes the verdict
  partial and grades an old breach as new.
- Guide 04: modes as a table with the confidence each reports at; fix,
  exempt, suppress or leave in the baseline, with the syntax in Ruby and
  YAML; a recipes section; `check` needs a pinned baseline.
- Guide 05: the action pinned with `version:`, Rubydex installed pinned;
  the template's variables, requirements, exit codes and comment.
- Guide 06: registering the MCP server per agent, what the agent does
  differently, v0.4.35's narrower search refusal and folder-of-repositories
  install, what to commit (the hooks carry an absolute path) and how to
  turn each piece off.
- `templates/enola-check.sh`: a regression under enforcement is a verdict
  with a comment, not "did not run"; the confidence floor stays at 1.00 so
  advisory laws never fail; a shallow clone fails on CI instead of passing
  quietly; the comment is edited by its numeric id; without Ruby the
  comment is enola's own summary; `.enola-version` pins the release.
  `script/test-check-template` covers each.
- The knowledge-base hooks leave a repository with no decision records
  alone (`ENOLA_DECISION_DIRS`) and are wired from `.claude/hooks/`, where
  `enola-guides copy` writes them. The five knowledge-base skills call a
  wrapper that now ships, `templates/kb/kb`, tested by `script/test-kb`.
  `examples/knowledge-base`'s cluster config parses on v0.4.35.
- Fixed: the `enola --generate . && enola check .` line in guide 02, the
  skills and the twenty-six law READMEs fails with no pinned baseline;
  `constraints init` binds a recipe only when every role has a directory;
  a Ruby `via:` keyword on a sentence is dropped (write `via :imports` in
  the law); `enola gc` trims the local history; the Ember recipe is copied
  with `enola-guides copy`, not `gem contents`; undefined names (munola,
  the brain) are gone; `list recipes` no longer lists the recipes README.
- What v0.4.35 still reads less than the code, each re-checked: an
  Express `router.post("/")` under a mount, an inline Axum `.nest`, a
  bare Cargo version read as pinned, an inline TypeScript handler,
  `layered`'s `depends_on` rules on Python, TypeScript, Go and Rust, and a
  Ruby `where:` value that is not a string.
- tabula and taha are marked as a preview: neither is public yet.
- `script/check-links` checks `#anchors` too.

## 0.8.0 (2026-10-25)

One command, `enola-guides`, in every ecosystem: RubyGems, npm, PyPI,
crates.io, Go and Homebrew, and binaries for Linux, macOS and Windows on
the GitHub release. `list`, `show` and `copy` read one catalogue,
`bundle/bundle.json`, generated from the tree by `script/bundle`: 74 items
across guides, examples, laws, skills, hooks, recipes and templates. The
five implementations (Go, Rust, Node, Python, Ruby) are held to the same
22 cases, byte for byte, by `script/test-clis`, and CI runs them against
each package as installed from the artifact a release would publish, and
installs the Homebrew formula from a local tap. `VERSION` is the one
version; a tag `vX.Y.Z` publishes everywhere through trusted publishing
(`RELEASING.md`). A `NOTICE` names enola. `CONTRIBUTING.md`, `SECURITY.md`,
a code of conduct, issue and pull-request templates and Dependabot for the
actions and the crate; `script/test` runs every check CI runs that needs
no registry.

## 0.7.0 (2026-10-25)

Python, TypeScript, Go and Rust. Guides 15 to 18 and a worked example in
each language: the same four-layer service with its source, binding the
`layered` and `supply-chain` recipes and breaking its laws on purpose.
`script/test-examples` snapshots every example with the pinned enola and
fails when the laws reporting a breach are not exactly the ones its
`EXPECTED` file lists. What the examples showed on v0.4.34, each said
where it bites:

- `layered`'s two domain rules read `depends_on`, which none of the four
  extractors writes, so each example states the domain's law over
  `imports`.
- A TypeScript handler written inline puts its calls on the file, where
  the edge rules do not walk; a named handler is walked.
- An Express `router.post("/")` under a mount produces no route.
- An Axum router nested inline keeps its bare paths.
- A Cargo version with no operator counts as pinned.

Guide 01 states its first law in YAML as well as Ruby, and the README
no longer reads as Rubyists first.

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
