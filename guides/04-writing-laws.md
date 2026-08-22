# Writing laws

A law is a sentence about parts of your application, its reason, and how
strictly it holds. Laws live in `enola/constraints/`, in Ruby (`.rb`,
parsed and never executed) or in YAML, and compile to the same
declaration. This guide is the Ruby surface; every sentence names a rule
form the YAML also accepts.

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
`files` (bounded globs), `kind` (symbol, module, route, storage, and the
reference kinds test_ref, file_ref, lint), `named` (one prefix, one
suffix or an exact name), `where` (a conjunction over measured props),
`owns: :methods` (a member's methods count as the member's when an edge
is walked), `ancestor` (every class under it, over resolved ancestry),
`public` (the files that are the part's surface), `handles` (the code a
route of those methods reaches), and `governed_by` (the files a knowledge
page anchors, with `status:` or `supersedes:` qualifiers). A part name
written in snake_case is the component `snake-case`.

## Sentences

| Sentence | What it states |
|---|---|
| `a.must_not_call :b` | no `calls` edge from a into b (`via:` for another edge kind) |
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

Every law carries `why`. `mode` is `advisory` (report, never fail),
`ratchet` (report the existing, fail the new) or `strict` (fail every
breach); start in ratchet. `since "2026-08-01"` dates a law against the
architecture history: a breach the revision at that date already carried
is reported, one introduced after it is graded. `exempt` names a carve-out
with its owner and reason, and a carve-out nothing matches is itself a
finding.

## Reading what a law did

```bash
enola constraints lint .
enola constraints explain app/billing/charge.rb
enola --generate . && enola check .
```

`lint` validates every declaration and shows what each part resolved to;
`explain` answers, for one file, which parts admit it, by which selector,
and which edges it makes; `check` grades the change. A breach leads its
suggested actions with the smallest cut the graph can see: the far
part's public member with the same name, its public surface, the part
the offender's other edges mostly reach, the lightest edge of a cycle,
the owner's member that already reaches a table. When the facts support
no cut, the action says so.

## When a law refuses

A law that the snapshot cannot answer is reported as unevaluable with its
cause and emits no verdict: `no_resolved_ancestry` (no Rubydex provider
ran), `no_runtime_capture` (no capture for a budget), `no_counterparty`
(one repository where the law needs two), `no_compiled_pages` (no
knowledge pages in the snapshot), `unmeasured_property` (a `where` over a
prop no extractor emits, with the nearest measured names suggested). Fix
the snapshot, not the law.

## Mining laws you already keep

```bash
enola constraints mine .
```

proposes candidate laws from what the snapshot shows holds today (a
namespace every task already lives in, a prefix every public tool already
carries), each with the count it was mined at, so a team can adopt what
it practises before it writes what it wants.
