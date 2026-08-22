# routes have consumers

A law across repositories refuses by name inside one. require_consumer asks
whether a client elsewhere in the cluster calls each route; a single-
repository snapshot cannot answer, so the rule emits the named refusal and no
verdict, which is the whole point: a route with no client in a snapshot that
loaded no clients must not read as unconsumed.

Declaration: `enola/constraints/consumers.rb`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
