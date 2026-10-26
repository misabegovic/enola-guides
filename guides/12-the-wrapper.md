# The wrapper

Skills call a command the knowledge base owns, not the binary. The
wrapper is thin: it knows where the binary, the cluster config and the
receipts file live, it records receipts after a generate, and when
anything is absent it prints one line saying so and exits 0. That is the
whole design, and it is what lets every skill run on a machine without
enola without failing, while keeping "the graph was not asked" a
different sentence from "the graph agreed".

[`templates/kb/kb`](../templates/kb/kb) is one, in Python 3 with the
standard library only. From the knowledge base's root:

```bash
enola-guides copy templates/kb     # writes bin/kb; put bin/ on PATH
kb enola doctor
```

It reads three settings from the environment: `ENOLA_BIN` (the binary,
default `enola` on PATH), `KB_CLUSTER` (the cluster config, default
`enola-cluster.yaml`, else `cluster.yaml`) and `KB_KNOWLEDGE` (the pages
directory, default `wiki`; receipts go in
`wiki/_state/enola/receipts.json` and the ledger in `findings.json`
beside them). [`examples/knowledge-base`](../examples/knowledge-base/README.md)
is a knowledge base it runs against. Part of the
[optional knowledge-base track](09-a-knowledge-base-with-enola.md).

> With [tabula](13-tabula.md) there is no wrapper to write: `govern`,
> `impact` and `evaluate` ask the engine themselves and say "not asked"
> rather than pass, which is the named skip this guide builds.

## The operations

| Op | Answers |
|---|---|
| `generate` | snapshot the cluster, then record every member's receipt |
| `receipt [member]` | what was recorded |
| `diff` | which members' live receipts drifted from the recorded ones |
| `findings [--repo] [--all]` | the explainers' findings across the cluster, attributed to the member their evidence names, with judged ones hidden |
| `judge <signature> accepted\|rejected\|noise [--reason TEXT] [--landed PAGE]` | record a verdict in the ledger |
| `impact <symbol>` | fan-in, fan-out, named callers, read from the on-disk facts |
| `govern <path or page>` | the pages governing a file, or the code a page anchors |
| `citations` | every receipt citation in prose with its verdict |
| `baseline pin\|show\|clear [member]` | the "before" a change is graded against |
| `check [member]` | the grade, reported, never gating |
| `coverage` | which cross-repository edges resolved |
| `doctor` | whether the hooks fire |

## The shape, in any language

The template is this, and a wrapper of your own in another language keeps
the same branches:

```
resolve binary   -> absent: print "enola: not installed, the graph was not asked"; exit 0
resolve config   -> absent: print the path looked for; exit 0
resolve receipts -> absent on a read op: print; exit 0
run the op       -> on generate, read each member's .enola/receipt.json
                    and write fingerprint, commit, version, providers
                    into the receipts file
exit codes       -> the binary's, except check: report, exit 0
```

Three things to keep:

- **Receipts are the only committed state.** `generate` writes them;
  nothing else does. `diff` compares them to the live ones; it is not a
  comparison of findings.
- **Findings read from disk, not the MCP server.** `impact` and
  `findings` parse the fact and insight files, so scheduled and headless
  runs keep working when no server is up.
- **`check` reports; it never gates.** The binary exits 1 on a
  regression and the wrapper does not propagate it: no graph-dependent
  step may stop work, so the verdict is surfaced for a person to weigh.
  Exit 3 from the binary means the snapshots were not comparable; the
  wrapper prints that as "not asked", never as a pass.

A citation in prose has one grammar, `receipt <member>@<commit>,
fingerprint <4 hex>…<4 hex>` (`receipt rails-shop@3f2a9c1, fingerprint
8d1e…c40a`), and `citations` reports anything else that starts
`receipt X@` as malformed. Members are labelled by their directory name.

## The ledger beside the receipts

```json
{"findings": {"constraints|Constraint background-jobs-never-invoke-controller-code violated: ReceiptJob#perform -> OrdersController via calls": {"verdict": "accepted", "at": "2026-08-22", "reason": "real; the receipt renders through the controller", "landed": "wiki/shop/permanent/architecture.md"}}}
```

One entry per finding signature, `<explainer>|<title>`, written on
judgment. There is no
pending state: unjudged findings are observations, not a to-do list, and
nothing enumerates them as work.

## Why not call the binary directly

Every skill would then carry the absent-binary branch, the config
resolution and the receipt bookkeeping, and they would drift. The
wrapper is where those live once, which is why the skills say
`kb enola impact` and never a path to the binary.

## Where next

[tabula](13-tabula.md), in preview: the same practice as one program.
