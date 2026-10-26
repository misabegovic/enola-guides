# receiverless request api

A literal far end narrowed to receiver-less calls. params alone is the
controller's; request.params is an object the caller handed in. receiver: none
matches the first and not the second.

Declaration: `enola/constraints/bare.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola constraints ledger .` for each law's
count of breaches. With a baseline pinned before the copy (`enola baseline pin .`),
`enola check .` lists each breach under `Newly declared`.
