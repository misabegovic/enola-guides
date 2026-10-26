# Writing laws

A law is a sentence about parts of your application, its reason, and how
strictly it holds. Laws live in `enola/constraints/`, in Ruby (`.rb`,
parsed and never executed) or in YAML, and compile to the same
declaration. This guide is the Ruby surface; every sentence names a rule
form the YAML also accepts, and enola's
[constraints reference](https://github.com/enola-labs/enola/blob/main/docs/CONSTRAINTS.md)
gives each form in YAML. [`examples/laws`](../examples/laws/README.md)
has twenty-six complete laws, one directory each, to copy.

Ruby or YAML is a choice of reading, not of power: both compile to the
same thing, a repository may hold both, and a `.rb` law needs no Ruby on
the machine. In a repository with no Ruby, though, the first `.rb` file is
the first Ruby the snapshot sees and makes the next verdict partial
([start here](01-start-here.md#6-declare-your-first-law) shows what that
does), so write YAML there.

## Parts

```ruby
Enola.architecture "shop" do
  rails
  part :billing, files: ["app/billing/**"], public: ["app/billing/public/**"]
  part :records, ancestor: "ApplicationRecord"
  part :getters, files: "app/**", kind: :symbol, where: { symbol_kind: "getter" }
  part :mutating_actions, files: "app/controllers/**", handles: [:post, :put, :patch, :delete]
  part :decided, governed_by: "docs/decisions/*.md"
  part :api, files: "config/**", kind: :route
  part :tables, files: "app/models/**", kind: :storage
end
```

`rails` declares the conventional parts (controllers, models, jobs,
mailers, policies, serializers, view components, helpers, services,
concerns) from the directories Rails keeps them in. A `part` takes
`files` (bounded globs), `kind` (symbol, module, route, storage,
dependency, and the reference kinds test_ref, file_ref, lint), `named` (one prefix, one
suffix or an exact name), `where` (a conjunction over measured props),
`owns: :methods` (a member's methods count as the member's when an edge
is walked), `ancestor` (every class under it, over resolved ancestry),
`public` (the files that are the part's surface), `handles` (the code a
route of those methods reaches), and `governed_by` (the files a knowledge
page anchors, with `status:` or `supersedes:` qualifiers). A part name
written in snake_case is the component `snake-case`.

Quote every value in a `where:` hash, booleans and numbers included:
`where: { pinned: "false" }`. In v0.4.35 the Ruby surface reads only
strings and symbols there and drops any other value without a word, so
`pinned: false` selects every package, pinned or not. `constraints lint`
shows each part's selector as it resolved (`where pinned=false`), which is
how to see that a condition arrived.

## Sentences

| Sentence | What it states |
|---|---|
| `a.must_not_call :b` | no `calls` edge from a into b (`via :imports` on its own line in the law for another edge kind) |
| `a.must_not_call "params", receiver: :none` | no receiver-less call to a literal |
| `a.must_not_reach :b` | no path from a to b over any edge kind |
| `a.may_only_call :b, :c` | a's edges land only in b and c |
| `a.is_reached_only_by :b` | only b reaches a |
| `a.stays_inside except: :b` | a's non-public members are reached only from inside a, or from b |
| `a.must_reach :b` / `a.must_be_reached_by :b` | an edge exists, outbound or inbound |
| `a.must_follow :b, :c` | a's members that reach b also reach c |
| `a.must_define :call` / `a.must_define_one_of :call, :run` | every class member defines the method, or one of them |
| `a.names_must_match "*Job"` / `a.names_must_match "with_*", requires: "without_*"` | a naming convention, or a pair |
| `a.names_must_not_match "get_*"` | a forbidden prefix, suffix or name |
| `a.must_be_empty` | the part matches nothing |
| `a.at_most 12` | a cap on the membership (`growth 2` lets it exceed the baseline's count by two) |
| `a.must_carry prop: "decorators", value: "cached"` | every member carries a prop (narrow with `when_calling` or `when_carrying`) |
| `a.must_not_cycle_with :b, :c` | no dependency cycle among the parts |
| `a.must_not_reach_includers` | a mixin never reaches a class that includes it |
| `a.storage_must_stay_home` | every table a member reaches is the part's own |
| `a.must_keep_budget metric: :queries, max: 20` | no frame in a exceeds the budget a runtime capture measured |
| `a.must_have_consumer` | every route in a has a client somewhere in the cluster |
| `a.must_be_unique_across by: :table` | no table is owned by two repositories |
| `a.must_be_governed` | every file in a is anchored by a knowledge page |
| `a.advises "look in app/utils first"` | guidance delivered where the edit happens, never a verdict |

`via` is a word of the law, not of the sentence: write `via :imports` on
its own line inside `law ... do`. In v0.4.35 a `via:` keyword written on
the sentence (`a.must_not_call b, via: :imports`) is dropped without a
word and the law reads `calls`; the breach's witness ends in `via calls`
or `via imports`, which is how to see which one arrived.

A breach is named by its witness, the edge or fact that breaks the law.
An edge law's witness is the edge between two modules
(`module-edge: shop/domain -> shop/api -> shop/api via imports`), so a second import
along an edge that already breaks the law is the same breach, not a new
one, and a ratchet law does not fail it.

## Modes, dates and carve-outs

Every law carries `why` (`because:` in YAML): the reason is what a reader
of a breach needs to judge it. `mode` decides how strictly it holds:

| Mode | A breach is reported as | What fails `check` |
|---|---|---|
| `ratchet` (the default) | `Constraint <id> violated`, confidence 1.00 | only a breach the change added |
| `advisory` | `Advisory constraint <id> violated`, confidence 0.90 | nothing, under the default confidence floor of 1.00 |
| `strict` | `Strict constraint <id> violated` | every breach, including those the baseline already had, even with no `-fail-on` |

Start every law in ratchet. A law that fails only what a change adds can
be adopted on a repository that breaks it in a hundred places; strict is
for a law decided to hold now, after the backlog is gone. Advisory stays
silent in the gate only while the gate's confidence floor is above 0.90:
`-min-confidence 0.8` lets an advisory breach fail the build.
[Constraints in CI](05-constraints-in-ci.md) says how the template sets
the floor.

`since "2026-08-01"` dates a law against the architecture history: a
breach the revision at that date already carried is reported, one
introduced after it is graded.

- Where the history holds no revision that old, git dates the breach
  instead, by the author date of the line that witnesses it (cached in
  `.enola/blame_cache.json`).
- A breach git cannot date (no git, an uncommitted line, a shallow clone
  whose boundary is newer than the date) grades as if the law had no
  date, and the run says so once. A CI checkout that runs dated laws
  fetches enough history.

When a breach should not fail the build, there are four answers, and the
earliest one that is true is the right one:

1. **Fix it.** The code is wrong and the law stands.
2. **Exempt it.** The witness is decided to be outside the law, for good
   and with a reason. The exemption is written on the law, names the
   exact witness string the breach is titled with, and carries an owner,
   a reason and a date:

   ```ruby
   law "controllers reach the schema through one door" do
     controllers.must_not_call schema
     why "a second door is a second place to forget authentication"
     exempt "Api::GraphqlController#execute -> AppSchema.execute via calls",
            because: "the one sanctioned entry point", owner: "platform", since: "2026-08-22"
   end
   ```

   ```yaml
   exempt:
     - witness: "Api::GraphqlController#execute -> AppSchema.execute via calls"
       owner: platform
       because: "the one sanctioned entry point"
       since: "2026-08-22"
   ```

   An exempted witness is reported in its own `Exempted by declaration`
   section on every run and never fails. An exemption that matches
   nothing is itself a finding: the breach is gone, or the witness was
   mistyped. [`examples/laws/one-door`](../examples/laws/one-door) carries
   one.
3. **Suppress it.** The breach is real, but a strict law must not block
   while it is worked off. A suppression is a signed, temporary entry in
   `.enola/suppressions.yaml`, committed (keep it out of `.gitignore`)
   and never written by enola:

   ```yaml
   entries:
     - rule: company-fk             # or finding_title_prefix: "…"; exactly one
       owner: alice
       reason: "legacy tables migrate in Q4"
       date: "2026-08-10"
   ```

   A suppressed breach is reported under `Suppressed` and never fails;
   an invalid file is rejected whole.
4. **Leave it in the baseline.** A ratchet law already ignores a breach
   the baseline had. Nobody decided anything; that is the reason to use
   one of the forms above for anything somebody did decide.

`enola constraints ledger .` (below) shows, per law, how much is excused
by each of these and by whom.

## Recipes

A recipe is a named bundle of laws over roles, bound to your directories
in one block. enola ships `layered`, `clean`, `ports-and-adapters`,
`cqrs`, `event-driven`, `modular-monolith`, `rails-conventions`,
`rails-strict`, `vanilla-rails`, `ruby-conventions` and `supply-chain`;
[`recipes/`](../recipes/README.md) has more to copy into your own
`enola/recipes/`.

```yaml
# enola/constraints/layers.yaml
use_recipe:
  - recipe: layered
    as: shop
    mode: ratchet
    bind:
      presentation: { match: ["shop/api/**"] }
      application: { match: ["shop/services/**"] }
      domain: { match: ["shop/domain/**"] }
      infrastructure: { match: ["shop/repositories/**"] }
```

Each rule the recipe expands is reported under the binding's name
(`shop/presentation-reaches-application-only`), and `constraints lint`
says how many rules each binding expanded. `layered`, `clean` and
`ports-and-adapters` are alternative arrangements: bind the one your code
follows. `enola constraints init` binds every recipe whose roles it
finds, so on a large Rails application it can bind several at once, and
`rails-conventions` beside `rails-strict` states some laws twice, in two
modes; `init --recipe NAME` binds one.

A recipe's rules name one edge kind each, and `via:` matches that kind
exactly. `layered`'s two domain rules
(`domain-knows-no-infrastructure`, `domain-knows-no-presentation`) read
`depends_on`, which the Python, TypeScript, Go and Rust extractors do not
write; they write `imports`. On those trees the two rules are silent
whatever the domain imports, and the language guides state the domain's
law over `imports` beside the recipe. The three rules over `calls` hold
as written.

## Laws over dependencies

Every direct dependency a manifest declares (`Gemfile`, `package.json`,
`go.mod`, `Cargo.toml`, `pyproject.toml`, `requirements.txt`,
`pubspec.yaml`) is a `kind: dependency` fact named by its Package URL
(`pkg:gem/rails`), carrying the constraint as written, the version the
lockfile resolved and `pinned`. `pinned` is absent, not false, when a
lockfile sits beside the manifest that enola cannot read, so a law over it
stays silent rather than wrong. The shipped `supply-chain` recipe is the
law that every dependency is pinned:

```yaml
use_recipe:
  - recipe: supply-chain
    as: supply
    bind:
      unpinned-dependencies: {}
```

or the same in Ruby:

```ruby
part :unpinned, kind: :dependency, where: { type: "package", pinned: "false" }

law "dependencies are pinned" do
  unpinned.must_be_empty
  why "a range is a different program on every build"
  mode :ratchet
end
```

A repository with no manifest enola reads gets a finding that the
selector cannot be evaluated, never a silent pass. What a repository means
to depend on, with a purpose for each, goes under `dependencies:` in its
`enola-intent.yaml`, and the intent check reports the difference between
that list and what the manifests declare.

## Reading what a law did

```bash
enola constraints lint .
enola constraints explain app/billing/charge.rb
enola check .
```

`lint` validates every declaration and shows what each part resolved to;
`explain` answers, for one file, which parts admit it, by which selector,
and which edges it makes; `check` grades the working tree against the
pinned baseline (`enola baseline pin .` first, or it exits 2 with `no
pinned baseline`). A law added since the baseline is listed under `Newly
declared` with every breach it already has; that list is how to see what
a new law will say before it can fail anything. A breach leads its
suggested actions with the smallest cut the graph can see: the far
part's public member with the same name, its public surface, the part
the offender's other edges mostly reach, the lightest edge of a cycle,
the owner's member that already reaches a table. When the facts support
no cut, the action says so.

## When a law refuses

A law that the snapshot cannot answer is reported as unevaluable with its
cause and emits no verdict: `no_resolved_ancestry` (no Rubydex provider
ran), `no_runtime_capture` (no capture for a budget), `no_counterparty`
(one repository where the law needs two), `no_frame_in_members` (a
capture whose frames all lie outside the part, as a capture keyed by spec
files does), `no_compiled_pages` (no knowledge pages in the snapshot), `unmeasured_property` (a `where` over a
prop no extractor emits, with the nearest measured names suggested). Fix
the snapshot, not the law.

## How much of the law is excused

```bash
enola constraints ledger .
```

reports each law's breaches beside the ones its exemptions and
suppressions excuse, each excuse with its owner, reason and age, and
names the excuses that now match nothing. A law that holds only because
everything is exempt shows as exactly that. `--json` writes the same as
one document.

## Mining laws you already keep

```bash
enola constraints mine .
```

proposes candidate laws from what the snapshot shows holds today (a
namespace every task already lives in, a prefix every public tool already
carries), each with the count it was mined at, so a team can adopt what
it practises before it writes what it wants.

## Where next

- [Constraints in CI](05-constraints-in-ci.md): the laws graded on every
  pull request.
- [Rolling out](19-rolling-out.md): which laws to start with on a
  repository that already breaks them, and when to enforce.
- [Reading a verdict](20-reading-a-verdict.md): every section a breach can
  land in.
