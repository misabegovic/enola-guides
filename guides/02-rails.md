# A Rails application

What enola sees in a Rails app, what the two Ruby providers add, and how
to go from the first snapshot to laws the team wrote.

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

Two things the extractor does not settle are settled by providers, which
enola runs at snapshot time beside its own extraction:

- **Prism** reads every file with Ruby's own parser and adds the call edges
  a lexical walk can see. It needs a Ruby 3.3 or newer on PATH (Prism is a
  default gem), nothing else:

  ```yaml
  providers:
    - name: prism
      command: ["ruby", "/path/to/enola_prism_provider.rb"]
      expected_version: "0.1.0"
  ```

- **Rubydex** resolves constants through nesting and inheritance, types the
  receiver of a call, and linearises every class's ancestry with mixins in
  order. It runs inside the enola binary against an engine library fetched
  once, with no Ruby involved, and reads your bundle's gem paths when
  `bundle` is on PATH so `ApplicationRecord` and `ViewComponent::Base`
  resolve:

  ```bash
  enola providers fetch rubydex
  ```

  ```yaml
  providers:
    - name: rubydex
      expected_version: "0.4.0"
  ```

The configuration lives in `enola.yaml` (or `mcp-arch.yaml`) at the
repository root. With both providers a law can say "every class under
`ApplicationRecord`" and mean the resolved chain, not the text after `<`.
The [providers guide](07-providers.md) covers the census, the named skips,
and the runtime capture.

## Name the parts

`enola constraints init .` writes `enola/constraints/init.yaml` binding the
recipes whose roles your tree has. For a Rails app that is
`rails-conventions`:

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

## Read a verdict

```bash
enola baseline pin .
# change something
enola --generate . && enola check .
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
