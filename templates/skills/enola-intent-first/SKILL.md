---
name: enola-intent-first
description: Use before editing code in a repository whose team keeps decision records compiled into enola, so the decision governing the file is read before the file moves
---

# enola-intent-first: read the decision before touching the code

When a repository compiles its knowledge pages into the graph (pages with
an `enola_intent:` block and anchors), the graph answers which decisions
govern a file.

Before the first edit to a file:

1. `governing_intent` (MCP) or `enola plan -paths <file> .` for the page
   trail and the declared constraints that bind the path, with the blast
   radius over the current snapshot.
2. Read the governing page. If the intended change contradicts it, amend
   the page first, then edit the code; a deviation narrated afterwards is
   drift.
3. If nothing governs the file and the area is one the team documents,
   say so and ask whether it should be shaped before building.

A hook can enforce the reading: on the first edit into a repository per
piece of work, block once, inject the trail, and let the retry proceed.
The enforcement is the reading, never the verdict.
