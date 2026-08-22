# paired names

A naming pair: every with_ method has a without_ twin. with_history has its
twin, with_guests does not, archive is outside the pattern and never asked.

Declaration: `enola/constraints/pairs.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
