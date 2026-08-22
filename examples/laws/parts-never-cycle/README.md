# parts never cycle

Parts that may not depend on each other in a circle. Jobs reach models and
models reach jobs, so the two form a cycle at the part level; mailers sit
downstream of models only. The rule contracts the module graph to one node per
declared part, admits the symbol-rollup edges Ruby has, and names the circle;
the downstream part is not in it.

Declaration: `enola/constraints/cycles.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
