# readers read the store only

The allow form: a part's calls may land only in the named parts. Here readers
that must stay replayable may reach the store and nothing else.

Declaration under `enola/constraints/`. Copy it, run `enola constraints lint .`,
then `enola --generate . && enola check .`.
