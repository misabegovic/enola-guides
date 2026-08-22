# instantiation

What Ruby code constructs, as a fact. `new` on a literal constant is an
instantiates relation from the calling member to the class, which is the one
call whose result has a knowable type; `new` on a variable receiver names no
class and records nothing. A construction whose result is immediately sent a
message is the one-shot ceremony, named on the calling member as Class.method,
so a component can select the members that perform it and a rule can forbid
it. A construction bound to a local first is not the ceremony.

Declaration: `enola/constraints/ceremony.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
