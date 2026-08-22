# Providers

A provider contributes facts to the graph that no extractor measures: the
result of running another tool, a capture of the app at run time, a
language engine's resolution. enola runs the configured providers at
snapshot time, validates everything they emit against the fact schema,
refuses a provider's whole output on the first invalid line, and records
in the receipt what each provider contributed and what it skipped.

## Configure

```yaml
# enola.yaml
providers:
  - name: prism
    command: ["ruby", "/path/to/enola_prism_provider.rb"]
    expected_version: "0.1.0"
  - name: rubydex
    expected_version: "0.4.0"
  - name: eslint
    command: ["node", "/path/to/enola_eslint_provider.mjs"]
    expected_version: "0.1.0"
```

An external provider is an executable the seam runs twice: once with
`--version`, once with the repository path, reading JSONL facts from its
stdout and a one-line census from its stderr. A provider with no
`command` is one the binary carries itself; today that is Rubydex. A
configured provider whose tool is missing is a named skip in the receipt,
never an error: the machine not having a tool must not fail the snapshot,
it must be visible.

## The Ruby pair

**Prism** reads with Ruby's own parser and adds the call edges a lexical
walk can see. Any Ruby 3.3 or newer carries it as a default gem, so the
provider needs nothing installed.

**Rubydex** resolves constants through nesting and inheritance, types the
receiver of a call when it resolves to a constant, and linearises each
class's ancestry with mixins in resolution order. It runs inside the
binary: `enola providers fetch rubydex` downloads the engine library once
at the version enola pins, verifies its published checksum and caches it
under your user cache directory; `enola providers list` and `enola doctor`
report it. It indexes the workspace and, when `bundle` is on PATH, the
gem paths the bundle reports, so a base class a gem declares resolves
(and the 357 view components under a gem's base class become a fact). No
gem enters your Gemfile.

Its facts carry their own resolution level, `resolved`, so a law can ask
for exactly them: the `ancestor:` component key reads the resolved
chain, and the `independent` form (a mixin never reaches its includers)
refuses by name without it.

## The census

Every provider states what it saw and what it skipped, and enola records
it per provider in the receipt:

```json
{"name": "rubydex", "version": "0.4.0", "fact_count": 666713,
 "census": {"files_seen": 43297, "declarations_parsed": 2698018,
            "constructs_skipped": 2244152,
            "skip_causes": [{"cause": "receiver resolves to no constant", "count": 1798420},
                            {"cause": "unresolved constant reference", "count": 28416}]}}
```

A skip has a cause; a provider never guesses. Read the census before
reading a verdict that surprises you.

## The runtime capture

The runtime provider reads captures an operator produced by running the
application: a booted-Rails capture (the final route table, reflected
associations, table bindings) and a query-counter capture (database
queries per frame under a spec run). Facts carry `runtime-observed` and
the channel they came from, and the engine cross-links them to the
measured ones. `examples/providers/ruby/runtime/capture_spec_queries.rb`
in the enola tree is the runner for the query capture: require it from
`spec_helper`, run the suite, and `.enola-runtime/queries.json` is written
with one frame per example. A `must_keep_budget metric: :queries, max: N`
law then verdicts on it, and refuses by name until a capture exists.

## Writing one

A provider is any program that prints JSONL facts in the store's schema
with a `resolution_level` on every fact and a prefix on every name so it
cannot collide with an extractor's identity, plus the one census line.
The Prism and eslint scripts in enola's `examples/providers/` are the
reference; each is under two hundred lines.
