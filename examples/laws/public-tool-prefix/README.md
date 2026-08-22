# public tool prefix

A naming law on an externally exposed surface: every class in the public tools
directory carries the prefix, so the surface stays greppable and a public
class can never shadow an internal one.

Declaration under `enola/constraints/`. Copy it, run `enola constraints lint .`,
then `enola --generate . && enola check .`.
