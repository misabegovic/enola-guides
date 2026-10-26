# cluster laws

Laws that only a cluster snapshot can answer: a table owned by two
repositories, mutating actions selected through the routes they handle, and
routes no loaded client calls. Each refuses by name in a single-repository
snapshot rather than reporting silence as compliance.

One file per law under `enola/constraints/`, each file declaring the parts it speaks about. Copy it, run `enola constraints lint .`,
then `enola --generate . && enola constraints ledger .` for each law's
count of breaches. With a baseline pinned before the copy (`enola baseline pin .`),
`enola check .` lists each breach under `Newly declared`.
