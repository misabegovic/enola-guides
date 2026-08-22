# clean rings

Four rings. An entity that calls a use case and a use case that calls an
adapter both point outward; the controller calling inward is the direction the
arrangement allows. The shipped clean recipe names the two outward reaches.

Declaration: `enola/constraints/clean.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
