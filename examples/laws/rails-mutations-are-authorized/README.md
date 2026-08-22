# rails mutations are authorized

The code behind a mutating route is selected by the route's method through the
handled_by edge the Rails binder draws, and must reach a policy. create does
and update does not; index handles a GET and is never asked. The handles key
is what lets the law speak about routes without naming a single action.

Declaration: `enola/constraints/authorization.rb`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
