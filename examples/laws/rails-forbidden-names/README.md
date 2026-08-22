# rails forbidden names

A naming convention phrased as a prohibition. require_name demands a pattern
and has no negative, so "no get_ prefixes on a model's public surface" could
not be declared. forbid_name takes the same bounded pattern dialect, tries it
against a method's bare name after its owner, and with surface: exported
judges the public surface only: the exported get_total is the breach, the
private get_lines is not the convention's surface, and total is outside the
pattern.

Declaration: `enola/constraints/naming.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
