# vanilla rails stays empty

Plain Rails: the extra directories must stay empty, each with a stated reason.
One service object exists; the other directories hold nothing. The recipe
names the service and says nothing about the empty ones.

Declaration: `enola/constraints/vanilla.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola constraints ledger .` for each law's
count of breaches. With a baseline pinned before the copy (`enola baseline pin .`),
`enola check .` lists each breach under `Newly declared`.
