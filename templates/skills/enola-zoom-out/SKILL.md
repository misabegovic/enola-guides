---
name: enola-zoom-out
description: Use when deep in a change and the question is how it sits in the whole; answers the technical blast radius in one paragraph from the graph, beside the product fit reasoned out; knowledge-base track, needs the kb wrapper
---

# enola-zoom-out: the blast radius in one paragraph

Needs the knowledge base's `kb` wrapper on PATH: `enola-guides copy
templates/kb` writes it to `bin/kb`, and guide 12 describes it. Run from
the knowledge base's root, beside its `enola-cluster.yaml`. Where `kb` is
absent, say the graph was not asked; never fill its answers in from
memory.

1. `kb enola impact <Symbol>` for the symbols in hand: fan-in, named callers.
2. `find_path` from the part being changed to the parts that consume it:
   the route the change travels.
3. `kb enola govern <path>`: the decisions around it.
4. Write one paragraph of technical fit: what depends on this, through
   what, under which decisions. Put it beside the product fit, which the
   graph cannot answer.
5. If the paragraph names a dependent the plan did not, the plan is
   incomplete; return to `enola-deepdive`.
