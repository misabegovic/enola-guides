# rails request boundaries

The Rails laws a team actually writes. A model reads session and calls a
helper; a service reads params; another service calls only itself. The shipped
rails-conventions recipe, with its optional helpers and services roles bound,
names the model's helper call, the model's session read and the service's
params read, and leaves the clean service alone.

Declaration: `enola/constraints/rails.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
