# protocol any of

A protocol satisfied by one of several methods. Charge defines call, Refund
defines run, Reconcile defines neither; any_of accepts either door and names
the class with none, listing what would have satisfied it.

Declaration: `enola/constraints/entry.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
