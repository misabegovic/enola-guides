# mixins stay independent

A module never reaches the classes that include it. Taggable calls Post, which
includes it; Auditable calls Ledger, which does not. Who includes whom comes
from the resolved ancestry the rubydex provider emits, so the rule refuses
with a named cause on a snapshot without it and names Taggable on one with it.

Declaration: `enola/constraints/concerns.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
