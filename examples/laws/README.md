# Laws, one directory each

Every directory holds a complete declaration you can copy into a repository's
`enola/` and run. Most are proven by enola's own benchmark suite; the rest are
generalised from laws in daily use on a multi-repository estate.

- [`governed-code`](governed-code/README.md): The knowledge pages compile into the graph as anchors, and a law demands that every file of a part has one.
- [`rails-forbidden-names`](rails-forbidden-names/README.md): A naming convention phrased as a prohibition.
- [`rails-mutations-are-authorized`](rails-mutations-are-authorized/README.md): The code behind a mutating route is selected by the route's method through the handled_by edge the Rails binder draws, and must reach a policy.
- [`rails-request-boundaries`](rails-request-boundaries/README.md): The Rails laws a team actually writes.
- [`rails-strict-arrangement`](rails-strict-arrangement/README.md): The strict Rails arrangement: the Rails laws, no circle among the parts, and concerns that stay independent of their includers.
- [`clean-rings`](clean-rings/README.md): Four rings.
- [`cqrs-queries-never-write`](cqrs-queries-never-write/README.md): A command-query split.
- [`instantiation`](instantiation/README.md): What Ruby code constructs, as a fact.
- [`mixins-stay-independent`](mixins-stay-independent/README.md): A module never reaches the classes that include it.
- [`naming-conventions`](naming-conventions/README.md): Ruby naming conventions: no get_, set_ or is_ prefixes; a predicate ends in a question mark and has_ is fine.
- [`one-owner-per-table`](one-owner-per-table/README.md): unique_across compares the members of different repositories; with the storage facts of one repository there is nobody to share a table with, so the rule refuses by name rather than reporting every table as unique.
- [`paired-names`](paired-names/README.md): A naming pair: every with_ method has a without_ twin.
- [`parts-never-cycle`](parts-never-cycle/README.md): Parts that may not depend on each other in a circle.
- [`protocol-any-of`](protocol-any-of/README.md): A protocol satisfied by one of several methods.
- [`public-surface`](public-surface/README.md): A path-defined public surface.
- [`receiverless-request-api`](receiverless-request-api/README.md): A literal far end narrowed to receiver-less calls.
- [`resolved-ancestry`](resolved-ancestry/README.md): Ancestry a provider resolved, and a component selected by it.
- [`routes-have-consumers`](routes-have-consumers/README.md): A law across repositories refuses by name inside one.
- [`storage-stays-home`](storage-stays-home/README.md): A part keeps to the tables it owns.
- [`vanilla-rails-stays-empty`](vanilla-rails-stays-empty/README.md): Plain Rails: the extra directories must stay empty, each with a stated reason.
- [`foreign-keys`](foreign-keys/README.md): A foreign-key law reads the storage facts the schema yields: every table carrying a tenant column must declare the foreign key to the tenant table.
- [`maintenance-tasks`](maintenance-tasks/README.md): Two laws for a maintenance-tasks directory: a naming convention the runner depends on, and a boundary against controller code that has no request to read.
- [`public-tool-prefix`](public-tool-prefix/README.md): A naming law on an externally exposed surface: every class in the public tools directory carries the prefix, so the surface stays greppable and a public class can never shadow an internal one.
- [`one-door`](one-door/README.md): A boundary with one sanctioned crossing: controllers may not reach the GraphQL schema, except the single execute action, named as an exemption with its owner and reason so the carve-out is a decision and not a hole.
- [`readers-read-the-store-only`](readers-read-the-store-only/README.md): The allow form: a part's calls may land only in the named parts.
- [`cluster-laws`](cluster-laws/README.md): Laws that only a cluster snapshot can answer: a table owned by two repositories, mutating actions selected through the routes they handle, and routes no loaded client calls.
