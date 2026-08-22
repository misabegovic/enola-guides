# The Ruby DSL, end to end, for a Rails shop. Parsed by enola, never
# executed. Every sentence below compiles to a rule form the YAML also
# accepts; `enola constraints lint .` shows what each part resolved to.
Enola.architecture "shop" do
  rails

  part :billing, files: ["app/billing/**", "app/models/invoice.rb"]
  part :orders, files: ["app/orders/**", "app/models/order.rb"], public: ["app/orders/public/**"]
  part :records, ancestor: "ApplicationRecord"
  part :mutating_actions, files: "app/controllers/**", handles: [:post, :put, :patch, :delete]
  part :service_objects, files: "app/services/**", kind: :symbol, where: { symbol_kind: "class" }, owns: :methods
  part :api, files: "config/**", kind: :route
  part :tables, files: "app/models/**", kind: :storage

  law "background jobs never invoke controller code" do
    jobs.must_not_call controllers
    why "rendering from a job goes through ApplicationController.renderer"
    mode :ratchet
  end

  law "the request api stays in controllers" do
    models.must_not_call "params", receiver: :none
    why "params without a receiver is the controller's; a model reading it only works inside a request"
    mode :ratchet
  end

  law "billing keeps to its own tables" do
    billing.storage_must_stay_home
    why "a part that writes another part's table owns a bug it cannot see"
    mode :ratchet
  end

  law "orders are reached through their public surface" do
    orders.stays_inside
    why "the public directory is the contract; everything else may change"
    mode :ratchet
  end

  law "a mutating action is authorized" do
    mutating_actions.must_reach :policies
    why "every write passes a policy before it touches a record"
    mode :ratchet
  end

  law "a concern never reaches the class that includes it" do
    concerns.must_not_reach_includers
    why "a mixin that knows its includer is half a class in hiding"
    mode :ratchet
  end

  law "jobs, models and mailers never depend on each other in a circle" do
    jobs.must_not_cycle_with :models, :mailers
    why "parts that reach each other in a circle cannot be taken apart"
    mode :advisory
  end

  law "a service answers to call" do
    service_objects.must_define :call
    why "one door per service, so a caller never reads it to find the verb"
    mode :ratchet
  end

  law "scopes come in pairs" do
    records.names_must_match "with_*", requires: "without_*"
    why "every with_ scope has a without_ sibling, or the query reads half a thought"
    mode :advisory
  end

  law "the public api stays small" do
    api.at_most 120
    growth 5
    why "a route is a promise; the count may grow, but only on purpose"
    mode :ratchet
  end

  law "frames keep their query budget" do
    controllers.must_keep_budget metric: :queries, max: 20
    why "a frame past twenty queries is a page that will not scale; refused by name until a capture exists"
    mode :advisory
  end

  law "billing is documented" do
    billing.must_be_governed
    since "2026-09-01"
    why "code under a decision needs the page that decided it"
    mode :ratchet
  end

  law "reach for an existing service" do
    service_objects.advises "look in app/services before writing a new one"
    why "duplication is a judgement no fact answers; advice where the edit happens is what can be offered honestly"
  end
end
