# A knowledge base with enola

A team that keeps decisions beside its code (a wiki, ADRs, a design log)
can compile them into the graph. Then a file answers which decision
governs it, a decision answers which code it covers, a structural claim
in prose can be re-checked mechanically, and a finding judged once stays
judged. This guide is that practice, as it runs day to day on a
twenty-repository knowledge base.

## Pages compile into the graph

A markdown page carrying an `enola_intent:` block is an intent fact when
the snapshot is taken, and every anchor on it is an edge to a file:

```yaml
---
title: Charges run through one service
enola_intent:
  page:
    type: decision
    status: accepted
    scope:
      - shop
    relations:
      - rel: supersedes
        to: wiki/adrs/charges-in-controllers.md
    anchors:
      - repo: shop
        path: app/billing/charge.rb
      - repo: shop
        path: app/billing/refund.rb
---
```

Derive the block rather than hand-maintain it: if your pages already cite
the code they describe (`sources:` lines naming repository paths), the
anchors are those citations, and a small script stamps the block from
them and checks the derivation in CI. enola validates the block; keeping
it truthful to your conventions is yours.

Index the knowledge base as a member of the cluster, last, so its pages
compile over the code they anchor:

```yaml
repos:
  - ../shop
  - ../mobile
  - .
```

## Ask the graph what governs a file

```bash
enola plan -paths app/billing/charge.rb .
```

and over MCP, `governing_intent` for a file or a symbol: the pages whose
anchors cover it, with their relation trails (what supersedes what, what
depends on what), and for a page, which code its anchors cover. A file no
page governs is an answer too, and the difference between "no page
governs this" and "the graph was not asked" must stay visible: a missing
snapshot is a named skip, never silence.

This is the call behind the [intent-first gate](10-hooks.md): before an
agent's first edit into a repository, the governing pages are read.

## Laws over the pages

Because anchors are facts, laws can read them (see [writing
laws](04-writing-laws.md)):

```ruby
part :billing, files: "app/billing/**"
part :old_way, governed_by: "wiki/adrs/*.md status:superseded"
part :new_way, governed_by: "wiki/adrs/charges-in-one-service.md"

law "billing is documented" do
  billing.must_be_governed
  why "code under a decision needs the page that decided it"
end

law "the new way never reaches the old" do
  new_way.must_not_call :old_way
  why "a superseded decision's code is on its way out, not a dependency"
end
```

## Receipts are the committed state

Graph artifacts (`.enola/`, the cluster's output directory) are
machine-local and ignored. What enters version control is the receipt:
one entry per repository with the snapshot's fingerprint, the commit it
was taken at, the enola version and the providers that ran. Keep them in
one file the knowledge base owns:

```json
{"repos": {"shop": {"git_commit": "…", "content_digest": "sha256:…", "enola_version": "0.5.0"}}}
```

Two rules follow. **Regenerate the whole cluster, never one member**: a
snapshot scoped to one repository replaces the union rather than
updating its slice, and everything that reads the union then answers
from a narrower world without saying so. **Not comparable is not a
pass**: when a member's snapshot changed enola version or provider set,
the grade declines; re-pin and regenerate rather than reading silence as
clean.

## Citations with a grammar

A structural claim in prose ("`internal/facts` has 157 dependents")
cites the receipt it was read from, in one fixed shape, so a script can
re-check it against the committed receipts and flag the ones whose
digest moved. The shape is yours to choose; what matters is that there
is one, that one extractor parses it, and that a periodic sweep lists
every citation with a verdict (verified, stale, malformed). A claim
nobody can re-check is a sentence, not a fact.

## Findings are judged once

The explainers report candidates, not verdicts: a cycle at 0.7
confidence, a god class, an unused route. Before a finding grounds a
page, confirm it against the code and record the judgment in a ledger
beside the receipts, one entry per finding signature: accepted (and
where it landed), rejected, or permanent noise. The next session reads
the ledger instead of re-deciding, and the periodic sweep reports a
ledger entry whose finding no longer exists, which is the code moving
past a recorded judgment.

## Pulled, with one push

Skills fetch the graph while already reasoning about something: a
deepdive asks `impact_analysis` and `governing_intent`, an ingest checks
a claim with `query_facts` while the source is open, a drift sweep
regenerates and diffs receipts. Nothing lands on a board because the
graph said so. The one exception is the session-end hook, which speaks
only when the session's change introduced a structural regression, or
when it could not grade at all; a gate nobody remembers to run is no gate.

## The wrapper

Every skill calls a thin command the knowledge base owns rather than
the binary: `kb enola generate | receipt | diff | findings | judge | impact
| govern | citations | baseline | check | coverage | doctor`. It resolves
the binary, the cluster config and the receipts file, and when any is
absent it prints one line saying so and exits 0. That is what keeps a
skill from failing on a machine without enola, and what keeps "the graph
was not asked" distinguishable from "the graph agreed". The [wrapper
guide](12-the-wrapper.md) has its shape.
