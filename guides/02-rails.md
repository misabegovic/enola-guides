# A Rails application

What enola sees in a Rails app, what the two Ruby providers add, and how
to go from the first snapshot to laws the team wrote. The worked example
is [`examples/rails-shop`](../examples/rails-shop): thirteen laws in the
Ruby DSL, one file each, with both providers configured.

## What the snapshot holds

From the Ruby extractor alone:

- **Symbols** for every class, module and method, with their calls,
  constant references and one-level superclass.
- **Routes** from `config/routes.rb` and every engine's route file,
  `resources` expanded, each route carrying its method and path and a
  `handled_by` edge to the controller action that serves it.
- **Storage** facts for every `ApplicationRecord` descendant: the model,
  its table (declared or derived), its columns and foreign keys when the
  schema is present.
- **Associations** with their macro, target and whether the target was
  declared (`class_name:`) or derived from the name.
- **Module edges** between directories, weighted by the symbol edges
  behind them, which is what cycle detection reads.

Run `enola --explain .` and then `enola --generate .`; the receipt in
`.enola/receipt.json` lists what each extractor parsed and skipped.

## The two providers

The Ruby extractor reads one file at a time, so it cannot tell which
class a constant names once nesting and inheritance are involved, or what
a class inherits through its mixins. Two providers settle that at snapshot
time, beside enola's own extraction. Both are built into the binary and
run against the Rubydex library, with no Ruby on the machine:

- **Rubydex** resolves constants through nesting and inheritance, types the
  receiver of a call, and linearises every class's ancestry with mixins in
  order. It reads your bundle's gem paths when `bundle` is on PATH so
  `ApplicationRecord` and `ViewComponent::Base` resolve.
- **Prism** adds the call edges a lexical walk can see: a call on the
  enclosing class, and `new` on a written constant. Named with no
  `command`, it reads the index Rubydex built in the same run.

```yaml
providers:
  - name: rubydex
  - name: prism
```

The install script and `enola upgrade` fetch the library the binary pins;
after `pip install enola-cli`, `go install` or a source build, run
`enola providers fetch rubydex` once. Leave `expected_version` off a
built-in: the binary already pins the library, and a pin that disagrees
with it skips the provider.

The configuration lives in `mcp-arch.yaml` at the repository root, the
one file name enola reads without being told. Rubydex indexes a tree that
has a `Gemfile`. With both providers a law can say "every class under
`ApplicationRecord`" and mean the resolved chain, not the text after `<`.
The [providers guide](07-providers.md) covers the census, the named skips,
the Prism script for a Ruby of your own, and the runtime capture.

## Name the parts

`enola constraints init .` writes `enola/constraints/recipes.yaml` binding
every shipped recipe all of whose roles your tree has a directory for. For
`rails-conventions` that means `app/controllers`, `app/jobs`, `app/models`,
`app/mailers`, `app/policies`, `app/serializers` and `app/components`; an
app missing one gets the recipe named with the directories it lacked and
not bound, so write the binding yourself and leave the missing role out:

```yaml
use_recipe:
  - recipe: rails-conventions
    as: rails
    mode: ratchet
    bind:
      controllers: { match: ["app/controllers/**"] }
      jobs: { match: ["app/jobs/**"] }
      models: { match: ["app/models/**"] }
      mailers: { match: ["app/mailers/**"] }
      policies: { match: ["app/policies/**"] }
      serializers: { match: ["app/serializers/**"] }
      view-components: { match: ["app/components/**"] }
```

Two roles are optional and off until you bind them: `helpers` and
`services`. Binding them brings three more laws (services and models
never reach helpers; the controller's request API stays out of models and
services). `rails-strict` is the same set with the concerns law added and
nothing advisory. `vanilla-rails` is for an app that keeps Rails plain and
wants its extra directories to stay empty with a stated reason each.

Two more recipes ship with enola and suit any Ruby tree. `ruby-conventions`
forbids the `get_`, `set_` and `is_` prefixes other languages bring along;
`supply-chain` forbids an unpinned dependency (see
[writing laws](04-writing-laws.md#laws-over-dependencies)).

`enola constraints lint .` shows every part with what it resolved to and
every rule a binding left unexpanded, which is how you check the tree
before the first verdict.

## The laws a Rails team writes

The recipe's laws, each with the reason it carries:

- jobs do not reach controllers (advisory, because the sanctioned path
  through `ApplicationController.renderer` reads as a crossing);
- models do not reach controllers;
- policies only answer, never enqueue;
- mailers do not enqueue;
- serializers do not reach controllers;
- view components do not enqueue and do not reach controllers;
- maintenance tasks do not reach controllers;
- with `helpers` bound: services and models never reach helpers;
- with `services` bound: the request API (`params`, `session`, `render`,
  `redirect_to`, `cookies`, `flash`) stays in controllers, stated as
  receiver-less calls so `request.params` on a typed receiver is not a
  breach.

Write your own beside them in Ruby, in any file under `enola/constraints/`:

```ruby
Enola.architecture "shop" do
  rails
  part :billing, files: ["app/billing/**", "app/models/invoice.rb"]
  part :orders, files: ["app/orders/**", "app/models/order.rb"],
                public: ["app/orders/public/**"]

  law "billing keeps to its own tables" do
    billing.storage_must_stay_home
    why "a part that writes another part's table owns a bug it cannot see"
    mode :ratchet
  end

  law "a mutating action is authorized" do
    part :mutating_actions, files: "app/controllers/**",
                            handles: [:post, :put, :patch, :delete]
    mutating_actions.must_reach :policies
    why "every write passes a policy before it touches a record"
    mode :ratchet
  end
end
```

The first law reads the storage facts: a member of `billing` reaching
`Order` is a breach that names the table `orders`, and the suggested cut
names the `orders` part's public member that already uses the model. The
second selects the code behind POST, PUT, PATCH and DELETE routes through
the `handled_by` edges and demands a call into the policies, so the law
follows the routes rather than a list of actions.

## Packwerk

A repository that splits into packwerk packages gets the `packwerk`
explainer once enola finds the packages. It reads `package_paths` from
`packwerk.yml` and, when the file sets none, looks only at the root and
`packages/*`, where packwerk itself searches every directory; with packs
under `packs/` or `components/`, name them:

```yaml
# packwerk.yml
package_paths:
  - packs/*
```

The snapshot log says how many packages it found. The explainer compares
each `package.yml`'s declared
dependencies with what the package's code references, and reports both
sides. An undeclared reference names its file and line at confidence 0.9,
because a Ruby constant reaches its package by name; one already in
`package_todo.yml` is counted, not reported. A declared dependency the code
never references is reported at 0.7, since a constant reached through
`constantize`, a YAML class name or only a spec draws no edge. Gate on it
with `enola check -fail-on packwerk -min-confidence 0.9` once the todo
files say what you mean.

## Read a verdict

```bash
enola baseline pin .
# change something
enola check .
```

A constraint breach names the rule, the member, the edge and the reason,
leads its suggested actions with the smallest change the graph can see,
and says whether it is a decided-rule breach (exact membership over a
measured edge) or an advisory. `enola constraints explain app/jobs/x.rb`
answers what a file is a member of, by which selector, and which edges it
makes, which is the question to ask before arguing with a verdict.

## When the answer is "cannot evaluate"

A law over resolved ancestry without the Rubydex provider, a budget
without a runtime capture, a law across repositories in a one-repository
snapshot: each is reported as unevaluable with its cause and emits no
verdict. That is the design. A law nobody could measure must not read as
kept.

## Where next

- [`examples/laws`](../examples/laws/README.md): the Rails laws among the
  twenty-six (`rails-request-boundaries`, `rails-mutations-are-authorized`,
  `rails-strict-arrangement`, `foreign-keys`, `one-door`), each ready to
  copy.
- [Writing laws](04-writing-laws.md): every sentence, the modes, and the
  carve-outs.
- [Providers](07-providers.md): the census, the runtime capture, and a
  Prism script for a Ruby of your own.
- [Constraints in CI](05-constraints-in-ci.md): the check on every pull
  request.
