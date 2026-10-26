# readers read the store only

The allow form: a part's calls may land only in the named parts. Here readers
that must stay replayable may reach the store and nothing else.

Declaration under `enola/constraints/`. Copy it, run `enola constraints lint .`,
then `enola --generate . && enola constraints ledger .` for each law's
count of breaches. With a baseline pinned before the copy (`enola baseline pin .`),
`enola check .` lists each breach under `Newly declared`.
