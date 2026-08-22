# Recipes

A recipe is a named bundle of architecture laws over roles. A repository
binds it in its `enola/constraints/` declaration and the laws apply to the
code the roles select. The recipes here are starting points: copy one into
your repository's `enola/recipes/`, read every `because:`, change what your
team decides differently, and review it like any other file. A convention
nobody on the team wrote is not a convention.

## Binding a recipe

Roles carry selector defaults (`match`, `kind`, `name_pattern`, `where`), so
a binding is the recipe's name and the mode:

```yaml
use_recipe:
  - recipe: ember-conventions
    as: app
    mode: ratchet
```

Override a role's selector when your tree differs, key by key:

```yaml
use_recipe:
  - recipe: ember-conventions
    as: app
    mode: ratchet
    bind:
      components: { match: ["frontend/app/components/**"] }
```

A role marked `optional: true` carries no default because its selector is
yours to name: the law that references it expands away until you bind it.
`enola constraints lint` lists the rules left unexpanded for that reason.

Modes: `ratchet` reports what already breaks the law and fails only what a
change adds; `advisory` reports and never fails; `strict` fails on every
breach. Start with ratchet.

## The recipes

- `ember-conventions.yaml`: nine Ember conventions a team can adopt as laws,
  selected by what the code carries (a decorator, a written field, a base
  class's module) rather than by where it sits. Two optional roles are
  yours to bind: `task-factories` (the functions that make tracked tasks or
  tracked functions in your app) and `fixture-setup` (the entry points of
  your fixture library in tests).

Laws whose far end is a helper of your own (a promise-unwrapping getter
helper, an async-relationship reader) belong in your repository's recipe
beside these, with your names in them.
