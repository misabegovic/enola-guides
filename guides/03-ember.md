# An Ember application

The same loop for the front end: what enola measures in an Ember app, and
how the conventions a team already writes in its style guide become laws.

## What the snapshot holds

The TypeScript and Ember extractors read `.ts`, `.js`, `.gts` and `.gjs`
and record, per class member, the things a convention talks about:

- the **decorators** a member carries (`action`, `cached`, `tracked`, `task`),
- the **fields it writes** (`args`, its own state, or any field at all),
- whether a member **takes parameters**,
- the **module a base class was imported from** (`@ember/controller` rather
  than the bare identifier `Controller`, which Stimulus also uses),
- the **kind** of each member (getter, constructor, method),
- **imports** by module path, including subpath imports from packages,
- and for test files, the calls a test makes, as `test_ref` facts a
  component can name by kind.

That is why the conventions below are laws and not lint rules: a component
is selected by what its facts carry, and a rule is set membership over
measured edges.

## The conventions, as a recipe

[`recipes/ember-conventions.yaml`](../recipes/ember-conventions.yaml) in
this repository carries nine conventions an Ember team recognises, with
the reason for each: no `@action` decorator, no framework controllers, no
render-modifier imports, constructors do not fetch, component tests carry
no fixtures, no legacy property accessor, arguments are not mutated, a
modifier takes its element, derivations do not write. Every role carries
its selector as a default, so the binding is short. Copy the recipe into
your repository and bind it:

```bash
mkdir -p enola/recipes enola/constraints
cp $(gem contents enola-guides | grep ember-conventions.yaml) enola/recipes/
```

```yaml
# enola/constraints/ember.yaml
use_recipe:
  - recipe: ember-conventions
    as: app
    mode: ratchet
```

Two roles are optional and yours to name, because their far end is a
helper of your own: `task-factories` (the functions that build tracked
tasks in your app) and `fixture-setup` (the entry points of your fixture
library). Until you bind them the two laws that need them are left
unexpanded, and `enola constraints lint .` says so:

```yaml
    bind:
      task-factories: { match: ["app/utils/**"], name_pattern: "*.trackedFunction" }
      fixture-setup: { match: ["tests/helpers/**"] }
```

Copying the recipe, rather than pointing at this gem's copy, is the point:
the team reads the reasons, deletes a law it disagrees with, and reviews
the file on a pull request. A convention that appears from a tool is not
a convention.

## An Ember app inside a larger repository

When the app lives under a directory such as `frontend/`, override the
path-rooted roles key by key; the roles selected by a decorator or a
written field need nothing:

```yaml
use_recipe:
  - recipe: ember-conventions
    as: app
    mode: ratchet
    bind:
      components: { match: ["frontend/app/components/**"] }
      integration-tests: { match: ["frontend/tests/integration/**"] }
      constructors: { match: ["frontend/app/**"], name_pattern: "*.constructor" }
      fetchers: { match: ["frontend/app/services/**"] }
      legacy-accessor: { match: ["frontend/app/utils/**"], name_pattern: "*.get" }
      element-modifiers: { kind: symbol, match: ["frontend/app/components/**", "frontend/app/modifiers/**"] }
```

Or keep a house recipe in `enola/recipes/` with your paths as the
defaults, which is what a team with several conventions of its own ends
up doing anyway. A repository's recipe replaces a shipped one of the same
name, and lint notes it.

## Conventions the recipe cannot carry for you

Some laws hinge on a helper only your app has: a getter that unwraps a
promise through your helper must carry `@cached`, a reader of an async
relationship must pass it through your resolving helper. Write those in
your own recipe or inline, with your names:

```yaml
components:
  - name: promise-getters
    kind: symbol
    match: ["app/**"]
    where: { symbol_kind: getter }
rules:
  - id: promise-getters-are-cached
    require: promise-getters
    when_edge_to: ["*.unwrapPromise"]
    via: calls
    must_prop_contain: { prop: decorators, value: cached }
    mode: ratchet
    because: "A getter that unwraps a promise recomputes on every read unless it memoizes, and the renderer re-renders on each new value."
```

And a guide rule for what no fact can decide, delivered where the edit
happens:

```yaml
  - id: reach-for-an-existing-helper
    guide: components
    message: "Before writing a helper here, look in app/helpers and app/utils first."
    mode: notify
    because: "Duplication is a judgement about what two implementations mean, which no fact answers."
```

## What a breach looks like

`no-action-decorator violated: Dashboard.toggle is measured in actions`,
with the file and line, the reason from the recipe, and the suggested
action. A pull request that adds four breaches and fixes none reports
four findings; the 1,700 the codebase already carries stay out of the
way under `ratchet` and stop growing.
