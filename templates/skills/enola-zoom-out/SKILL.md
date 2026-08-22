---
name: enola-zoom-out
description: Use when deep in a change and the question is how it sits in the whole; answers the technical blast radius in one paragraph from the graph, beside the product fit reasoned out
---

# enola-zoom-out: the blast radius in one paragraph

1. `kb enola impact <Symbol>` for the symbols in hand: fan-in, named callers.
2. `find_path` from the part being changed to the parts that consume it:
   the route the change travels.
3. `kb enola govern <path>`: the decisions around it.
4. Write one paragraph of technical fit: what depends on this, through
   what, under which decisions. Put it beside the product fit, which the
   graph cannot answer.
5. If the paragraph names a dependent the plan did not, the plan is
   incomplete; return to `enola-deepdive`.
