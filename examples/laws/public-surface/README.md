# public surface

A path-defined public surface. Ruby has no visibility keyword the extractor
can read at the file level, so a component names the files that are its public
surface; reaching a public file from outside is fine and reaching an internal
one is the breach.

Declaration: `enola/constraints/surface.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
