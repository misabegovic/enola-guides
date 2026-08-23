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

The catalogue munola ships built in: `munola init` writes these recipes
into a project's `enola/recipes/` and binds those whose roles resolve,
and the munola binary embeds the parameter-free ones, generated from
these files at release. The `enola` and `enola-rb` gems carry upstream's
own built-ins only (`rails-conventions`, `rails-strict`, `vanilla-rails`
and the six arrangements); a team on those channels copies a file from
here by hand. Each law is
an existing enola form; each recipe is here because its laws held on a real
Rails monolith at a number a team can act on, given beside it.

| Recipe | States | Held at |
|---|---|---|
| `rails-conventions` (upstream) | jobs, models, serializers and components never render; policies and mailers never enqueue; request API stays in controllers | five of seven laws with zero exceptions, three advisory at 134 crossings |
| `rails-strict` (upstream) | the above plus no cycles among the Rails roles and independent concerns | 0 of 127 concerns breach |
| `vanilla-rails` (upstream) | the directories the vanilla arrangement leaves empty stay empty | an arrangement a team chooses |
| `ember-conventions.yaml` | nine Ember conventions selected by what the code carries | the neutral eight hold; the house ones stay out |
| `data-ownership.yaml` | readers read the store only | advisory; bind your query objects |
| `api-boundaries.yaml` | the public API is reached only by controllers; a mutating action reaches a policy | 736 unauthorized mutations reported, advisory |
| `background-work.yaml` | maintenance tasks live in their namespace and never reach controllers | 0 of 3,250 task call edges reach a controller |
| `tenant-foreign-key.yaml` | a table carrying the tenant column carries the foreign key | 3,720 declared, 0 new |

Two data-ownership laws, one owner per table and storage stays home, are
declarations rather than recipe rules for now: they live as worked examples
under [`examples/laws/`](../examples/laws/README.md) because recipe expansion
in the current release does not rebind the part a graph law names. They join
`data-ownership.yaml` when it does.

- `ember-conventions.yaml`: nine Ember conventions a team can adopt as laws,
  selected by what the code carries (a decorator, a written field, a base
  class's module) rather than by where it sits. Two optional roles are
  yours to bind: `task-factories` (the functions that make tracked tasks or
  tracked functions in your app) and `fixture-setup` (the entry points of
  your fixture library in tests).

- `data-ownership.yaml`: readers (your query objects, bound by you) reach
  the store and nothing else.
- `api-boundaries.yaml`: the API layer is entered through controllers, and a
  mutating action reaches a policy; bind `mutating-actions` to the part your
  routes reach with POST, PUT, PATCH or DELETE.
- `background-work.yaml`: maintenance tasks live in the `Maintenance`
  namespace the runner resolves, and never reach controllers.
- `tenant-foreign-key.yaml`: a template; replace `TENANT_COLUMN` and
  `TENANT_TABLE` (munola's generator does) and every table carrying the
  column must carry the key.

Laws whose far end is a helper of your own (a promise-unwrapping getter
helper, an async-relationship reader) belong in your repository's recipe
beside these, with your names in them.
