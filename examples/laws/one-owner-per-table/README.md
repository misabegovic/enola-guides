# one owner per table

unique_across compares the members of different repositories; with the storage
facts of one repository there is nobody to share a table with, so the rule
refuses by name rather than reporting every table as unique. The verdict that
names two owners needs the cluster, which the harness measures per repository
by design.

Declaration: `enola/constraints/tables.rb`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
