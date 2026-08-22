# The skills, as they run

A skill is a named piece of practice an agent follows. Each of these asks
the graph one specific question at one specific moment; the value is the
moment, not the prompt. They are described here as they run on a
twenty-repository knowledge base, and shipped under
[`templates/skills/`](../templates/skills) to copy.

## Before shaping work: the deepdive (`enola-deepdive`)

Shaping a change starts with three graph questions, answered before a
line of the plan is written:

- `impact_analysis` on every symbol the work would change: fan-in,
  fan-out, named callers. A symbol with 157 dependents is a different
  plan from one with 3.
- `governing_intent` on the paths: which decisions already cover the
  area, so the plan amends a page rather than contradicting it.
- `query_insights` for the area: what the explainers already computed (a
  cycle someone must have introduced, a layer crossed, a dead route), so
  the plan inherits judged findings instead of rediscovering them.

The plan cites the receipt it read from, so a later reader can re-check
the numbers.

## Before building: the grade (`enola-grade-before-push`)

`set_baseline` once, early; after the change, `generate_snapshot` and
`diff_snapshot`; the delta (introduced, resolved, edges added) goes into
the pull request in one sentence. A declined comparison is not a pass.
This is also the [stop-time debt](10-hooks.md) hook's demand.

## While ingesting a source: the claim check (`enola-ingest-check`)

A page that states a structural fact (a stack, a public surface, a
route, a table) checks it while the source is open: `query_facts` for
the fact, `impact_analysis` for the count. A wrong claim ingested today
is cited by a page tomorrow and reasoned from by an agent next week, so
verification is cheapest now. For an incremental ingest, each changed
path runs through `governing_intent`: the pages whose anchors cover a
changed file are exactly the synthesis that may have drifted, and a
changed file no page governs is a gap the ingest may be about to fill.

## The periodic sweep: drift (`enola-drift`)

On a schedule, or before publishing: regenerate the cluster, diff the
committed receipts (fingerprint and commit per member), and read
`coverage_report` for which cross-repository edges resolved and which did
not. Receipts that moved name the members whose pages want a re-read.
Not a comparison of findings between two runs; that is the grade's job.

## Knowledge hygiene: citations and the ledger (`enola-citation-hygiene`)

Every receipt citation in prose gets a verdict against the committed
receipts: verified, stale (the digest moved), malformed. Stale ones are
re-read, not rewritten. The finding ledger is swept the same way: an
accepted finding whose evidence no longer exists in the graph is the
code moving past a judgment, and the page that cites it is re-read.

## Stepping back: the blast radius (`enola-zoom-out`)

When deep in a change, one call answers how it sits in the whole:
`impact_analysis` for the symbols in hand, `find_path` between the
part being changed and the parts that consume it, `governing_intent`
for the decisions around it. The answer is one paragraph of technical
fit the agent can stand on, beside the product fit it reasons out.

## Writing and explaining laws (`enola-laws`)

Covered in [writing laws](04-writing-laws.md): lint before verdict,
`constraints explain` before arguing with a verdict, ratchet before
strict.

## What makes these skills and not prompts

Each names the call, the moment, and the refusal: what the agent does
when the graph is absent (say so, proceed, never pretend), when the
comparison declines (re-pin, never read as clean), when a finding is a
candidate (confirm against the code, judge once, record). That is the
practice the hooks enforce and the skills describe; the two are one
contract read from two sides.
