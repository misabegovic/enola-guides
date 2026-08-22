# A knowledge base with enola, minimal

The smallest knowledge base that gets what [guide 09](../../guides/09-a-knowledge-base-with-enola.md) describes:
two pages anchored to code with `enola_intent`, a cluster config, the
committed receipts, and the finding ledger. The skills under
[`templates/skills`](../../templates/skills) and the hooks under
[`templates/hooks`](../../templates/hooks) run against exactly these
files.

- `enola-cluster.yaml`: the members, with `knowledge` pointing at the wiki.
- `wiki/shop/permanent/architecture.md`: a page whose `enola_intent`
  anchors it to `app/jobs/**` and `app/models/**`, with one receipt
  citation.
- `wiki/shop/permanent/public-surface.md`: a page anchored to the
  controllers it describes.
- `wiki/_state/enola/receipts.json`: what `kb enola generate` recorded.
- `wiki/_state/enola/findings.json`: the ledger, one judged finding.

`governing_intent app/jobs/order_mailer_job.rb` returns the first page;
`kb enola citations` verifies its citation against the receipts file.
