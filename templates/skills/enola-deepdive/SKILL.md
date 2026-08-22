---
name: enola-deepdive
description: Use before shaping or planning a change; asks the graph three questions (impact, governing decisions, existing findings) and writes the answers into the plan with the receipt they came from
---

# enola-deepdive: ask the graph before writing the plan

1. Name the symbols the change would touch. For each:
   `kb enola impact <Symbol>` (or `impact_analysis` over MCP). Record fan-in,
   fan-out and the named callers. A symbol with 157 dependents is a
   different plan from one with 3.
2. For the paths: `kb enola govern <path>` (`governing_intent`). The pages
   returned are the decisions already covering the area; the plan amends
   one of them, it does not contradict it in silence.
3. For the area: `query_insights` filtered to it. Cycles, layer crossings,
   dead routes and hotspots are already computed and some are already
   judged in the ledger; inherit them.
4. Write the three answers into the plan, each with the receipt
   (`kb enola receipt <member>`) it was read from.
5. If the graph is absent or the receipts are stale (`kb enola diff`), say
   so in the plan and proceed; never fill the numbers from memory.
