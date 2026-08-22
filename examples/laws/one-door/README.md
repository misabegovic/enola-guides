# one door

A boundary with one sanctioned crossing: controllers may not reach the GraphQL
schema, except the single execute action, named as an exemption with its owner
and reason so the carve-out is a decision and not a hole.

Declaration under `enola/constraints/`. Copy it, run `enola constraints lint .`,
then `enola --generate . && enola check .`.
