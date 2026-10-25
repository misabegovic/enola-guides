# Providers

A provider contributes facts to the graph that no extractor measures: the
result of running another tool, a capture of the app at run time, a
language engine's resolution. enola runs the configured providers at
snapshot time, validates everything they emit against the fact schema,
refuses a provider's whole output on the first invalid line, and records
in the receipt what each provider contributed and what it skipped.

## Configure

```yaml
# mcp-arch.yaml
providers:
  - name: rubydex
  - name: prism
  - name: eslint
    command: ["node", "/path/to/enola_eslint_provider.mjs"]
    expected_version: "0.1.0"
```

An external provider is an executable the seam runs twice: once with
`--version`, once with the repository path, reading JSONL facts from its
stdout and a one-line census from its stderr. A provider with no
`command` is one the binary carries itself: `rubydex` and `prism`. An
`expected_version` pins what the provider must answer, and a provider that
answers anything else is skipped by name; pin a script to its own
`PROVIDER_VERSION`, and leave a built-in unpinned, since the binary pins
its library. A configured provider whose tool is missing is a named skip
in the receipt, never an error: the machine not having a tool must not
fail the snapshot, it must be visible.

## The Ruby pair

**Prism** adds the call edges a lexical walk can see: a call whose
receiver is the enclosing class, and `new` on a written constant. Named
with no `command` it runs inside the binary and reads the index Rubydex
built in the same run, so it needs no Ruby. The reference script,
`examples/providers/ruby/prism/enola_prism_provider.rb` in the enola tree,
reads with Ruby's own parser on a Ruby 3.3 or newer; pin it to
`expected_version: "0.2.0"`. The two are close, not identical: the
built-in also writes the calls a class body makes (`validates`,
`before_action`), and writes the constant Rubydex resolved where the
script writes the one in the source.

**Rubydex** resolves constants through nesting and inheritance, types the
receiver of a call when it resolves to a constant, and linearises each
class's ancestry with mixins in resolution order. It runs inside the
binary against an engine library at the version enola pins: the install
script and `enola upgrade` fetch it, and after `pip install enola-cli`,
`go install` or a source build `enola providers fetch rubydex` does,
verifying the published checksum and caching it under your user cache
directory. `enola providers list` reports it. It indexes a tree with a
`Gemfile`; without one the census names the skip. It indexes the workspace and, when `bundle` is on PATH, the
gem paths the bundle reports, so a base class a gem declares resolves
(and the 357 view components under a gem's base class become a fact). No
gem enters your Gemfile.

Its facts carry their own resolution level, `resolved`, so a law can ask
for exactly them: the `ancestor:` component key reads the resolved
chain, and the `independent` form (a mixin never reaches its includers)
refuses by name without it.

## Signatures and the autoload map

Two more reference providers in enola's `examples/providers/ruby/` read
what a Ruby tree declares rather than what it runs. Each is a plain-Ruby
script, pinned to its own `PROVIDER_VERSION` (`0.1.0` for both):

```yaml
providers:
  - name: rbs
    command: ["ruby", "/path/to/enola_rbs_provider.rb"]
    expected_version: "0.1.0"
  - name: zeitwerk
    command: ["ruby", "/path/to/enola_zeitwerk_provider.rb"]
    expected_version: "0.1.0"
```

- **rbs** reads RBS files, Sorbet `.rbi` files and inline `sig { }`
  blocks with a hand parser rather than the `rbs` gem, so its facts do not
  depend on which gem a machine has. It writes method contracts
  (`rbs-signature:`) and type declarations (`rbs-decl:`) at level
  `declared`, and the engine marks each extracted method a contract names
  `typed: true` with the files that declared it. A law can then require a
  declared signature on a public API. A declaration is a claim about the
  code, and the level says who made it.
- **zeitwerk** maps every file under an autoload root to the constant
  Zeitwerk expects it to define, from the path alone, without booting
  the app: `app/models/billing/invoice_item.rb` to
  `Billing::InvoiceItem`, concerns collapsed. Its facts are
  `convention-derived`. A path it cannot camelize with confidence (a
  dash, an uppercase letter) emits nothing and is counted, since without
  boot no inflector override is known.

## Reuse

Provider facts enter the same cache as the extractors' facts, so a
provider whose inputs did not move is not run again. A script whose
output partitions by file says so with `files: per-file` and the
`extensions:` it reads; the seam then hands it only the files that
changed and keeps the rest. A provider that reads across files must not
declare that, because the cache would serve facts computed against a tree
that has since changed. The built-in Rubydex provider keeps one entry for
the whole index, keyed by the library version, the Ruby files with their
digests and `Gemfile.lock`, and rebuilds it on any change rather than
patching it. The receipt's `reuse` block says, per provider, what was
reused and what was computed, and for the index which part of the key did
not match.

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
reference; each is under two hundred lines. Give it a `PROVIDER_VERSION`
it prints for `--version`, raise it whenever its facts change, and pin
that version in the configuration: a pin that no longer matches skips the
provider by name rather than mixing two versions' facts in one graph.
