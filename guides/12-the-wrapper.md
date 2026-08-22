# The wrapper

Skills call a command the knowledge base owns, not the binary. The
wrapper is thin: it knows where the binary, the cluster config and the
receipts file live, it records receipts after a generate, and when
anything is absent it prints one line saying so and exits 0. That is the
whole design, and it is what lets every skill run on a machine without
enola without failing, while keeping "the graph was not asked" a
different sentence from "the graph agreed".

## The operations

| Op | Answers |
|---|---|
| `generate` | snapshot the cluster, then record every member's receipt |
| `receipt [member]` | what was recorded |
| `diff` | which members' live receipts drifted from the recorded ones |
| `findings [--repo] [--all]` | the explainers' findings across the cluster, attributed to the member their evidence names, with judged ones hidden |
| `judge <signature> accepted\|rejected\|noise` | record a verdict in the ledger |
| `impact <symbol>` | fan-in, fan-out, named callers, read from the on-disk facts |
| `govern <path or page>` | the pages governing a file, or the code a page anchors |
| `citations` | every receipt citation in prose with its verdict |
| `baseline pin\|show\|clear [member]` | the "before" a change is graded against |
| `check [member]` | the grade, reported, never gating |
| `coverage` | which cross-repository edges resolved |
| `doctor` | whether the hooks fire |

## The shape, in any language

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

## The ledger beside the receipts

```json
{"findings": {"cycles|app/jobs -> app/models -> app/jobs": {"verdict": "accepted", "at": "2026-08-22", "reason": "real; the mailer path", "landed": "wiki/shop/permanent/architecture.md"}}}
```

One entry per finding signature, written on judgment. There is no
pending state: nothing enumerates unjudged findings as work, because a
finding nobody bet on is an observation.

## Why not call the binary directly

Every skill would then carry the absent-binary branch, the config
resolution and the receipt bookkeeping, and they would drift. The
wrapper is where those live once, which is why the guides say `kb enola
impact` where the brain that runs this says `brain.py enola impact`.
