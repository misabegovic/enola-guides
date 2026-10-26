# naming conventions

Ruby naming conventions: no get_, set_ or is_ prefixes; a predicate ends in a
question mark and has_ is fine. Three offenders and two clean names in one
class.

Declaration: `enola/constraints/naming.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola constraints ledger .` for each law's
count of breaches. With a baseline pinned before the copy (`enola baseline pin .`),
`enola check .` lists each breach under `Newly declared`.
