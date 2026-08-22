# cqrs queries never write

A command-query split. A query that calls update_all writes; a read model that
issues a command is a feedback loop; a query that only counts is clean. The
shipped cqrs recipe names the two breaches by the mutating method and the
command reached.

Declaration: `enola/constraints/cqrs.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
