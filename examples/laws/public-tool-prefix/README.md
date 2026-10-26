# public tool prefix

A naming law on an externally exposed surface: every class in the public tools
directory carries the prefix, so the surface stays greppable and a public
class can never shadow an internal one.

Declaration under `enola/constraints/`. Copy it, run `enola constraints lint .`,
then `enola --generate . && enola constraints ledger .` for each law's
count of breaches. With a baseline pinned before the copy (`enola baseline pin .`),
`enola check .` lists each breach under `Newly declared`.
