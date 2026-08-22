---
name: enola-ingest-check
description: Use while ingesting a source into the knowledge base; checks every structural claim against the graph while the source is open, and routes changed paths to the pages that govern them
---

# enola-ingest-check: verify the claim while the source is open

1. When a page is about to state a structural fact (a stack, a public
   surface, a route, a table, a count): `query_facts` for the fact,
   `kb enola impact <Symbol>` for the count. Write what the graph says,
   and cite the receipt.
2. For an incremental ingest, for each changed path:
   `kb enola govern <path>`. The pages returned are the synthesis that may
   have drifted; re-read them against the change. A changed path no page
   governs is a gap the ingest is about to fill, so anchor the new page to
   it with `enola_intent`.
3. A claim the graph cannot answer (product intent, history, a reason) is
   stated as the source's claim, not as a fact of the code.
4. If the graph is absent, the page says the claim is unverified; it does
   not silently become a fact.

A wrong claim ingested today is cited tomorrow and reasoned from next
week; verification is cheapest now.
