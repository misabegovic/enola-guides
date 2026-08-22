# rails strict arrangement

The strict Rails arrangement: the Rails laws, no circle among the parts, and
concerns that stay independent of their includers. Jobs and models reach each
other, which is the circle; Taggable reaches Invoice, which includes it.

Declaration: `enola/constraints/strict.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
