# Reading a verdict

`enola check` prints one verdict: what a change did to the architecture,
graded against a baseline. This guide is every part of it, every exit
code, and the outputs that surprise a first reader. The examples are from
[guide 01](01-start-here.md#6-declare-your-first-law)'s walkthrough on
[`examples/python-service`](../examples/python-service), at its last
step (a new `shop/api/admin` package reading storage directly), on enola
v0.4.35.

## In plain words first

```bash
enola check --summary -fail-on constraints .
```

writes the same verdict for a reader who does not know the explainer
names, in fixed sections: the result, what you changed, what got worse,
what got better, what moved without getting better or worse, what the run
could not see, and what to run next.

```text
Result: fails
  Fails the build (constraints).

What you changed
  Added 1 folder of code and 1 function or type (shop/api/admin).
  shop/api/admin/report now uses shop/repositories/orders.

Got worse
  Fails the build. Breaks the project's rule
  "shop/presentation-reaches-application-only".
    at shop/api/admin/report.py:4
  Fails the build. Breaks the project's rule "the-api-never-imports-storage".
    at shop/api/admin
```

Every form exits with the same code, so `--summary` is safe in a
script. The rest of this guide is the full form, which is
what a CI log and the template's comment carry.

## Exit codes

| Code | Word | Means | Do |
|---|---|---|---|
| 0 | clean | nothing the policy enforces was introduced | nothing; with no `-fail-on` every run is 0 unless a `strict` law is broken |
| 1 | regression | the change introduced a finding the policy fails on | read `Regressions (fail)` |
| 2 | error | the gate could not run: no pinned baseline, a bad flag, an inverted pair | fix the command; it graded nothing |
| 3 | declined | the baseline is not comparable with the current snapshot | re-pin, or fix what made them differ; it graded nothing |

`-warn-only` turns a 1 into a 0 and keeps everything else: a declined run
is still 3 and an error still 2, so a check that could not run never
reads as a pass.

## The header

```text
FAIL — 2 structural regressions introduced.
could not see: 1 file and 1 directory excluded by ignore globs; 3 imports targets outside the graph
law: 8 rules · 6 breaches · none excused
```

- **`PASS` or `FAIL`** is the verdict under the policy you set with
  `-fail-on` and `-min-confidence`. With no `-fail-on`, it says
  `nothing enforced: no policy set` and passes, unless a `strict` law is
  broken: strict fails every run it is broken in, new breach or old.
  `-warn-only` reports it as `PASS (--warn-only)`.
- **`could not see`** is what this run did not measure: files your ignore
  globs leave out, import targets outside the repository (a library, the
  standard library). It is a limit of the run, not a finding.
- **`law:`** counts the laws in force, their breaches anywhere in the
  tree, and how many are excused by exemptions or suppressions.
  `enola constraints ledger .` has the same per law.

## The sections

| Section | What is in it | Fails the build? |
|---|---|---|
| `Regressions (fail)` | findings the change introduced, from an explainer in `-fail-on`, at or above `-min-confidence` (default 1.00) | yes, unless `-warn-only` |
| `New findings (advisory — below the failure policy)` | findings the change introduced that the policy does not cover: another explainer, or a confidence under the floor | no |
| `New findings (reported — no failure policy set)` | the same, when there is no policy at all | no |
| `Newly declared (N)` | breaches of a law this change adds, re-forms or un-exempts, on code the change did not touch: where the law starts from | no |
| `Exempted by declaration` | breaches a law's `exempt:` carves out, on every run, with owner and reason | no |
| `Suppressed` | breaches `.enola/suppressions.yaml` excuses | no |
| `Resolved by this change (N)` | findings the baseline had and the change removed | no |
| `What changed`, `Added`, `New coupling` | the structural delta: symbols, dependencies and edges added or removed | no; new coupling is reported, never failed, because an added call is what ordinary work looks like |

A finding reads `[explainer] confidence — title`, then where it is:

```text
  - [constraints] 1.00 — Constraint the-api-never-imports-storage violated: module-edge: shop/api/admin -> shop/repositories -> shop/repositories via imports
      forbidden imports edge
```

The title names the law and the witness: for an edge law, the edge
between two modules, then the module it lands in.

Under 1.00 a finding is a candidate to verify, not a verdict; the output
says so under every list that holds one.

## Partial

```text
FAIL (partial verdict) — 1 structural regression introduced.

Partial verdict — the two snapshots were produced by different producer sets, so only
facts from producers present in BOTH snapshots were graded. This is NOT a full verdict.
  Graded over the shared producer set (3 families: manifests, mdintent, python).
  Excluded from grading: ruby (baseline lacks it) — 4 facts on the current side not graded.
  A regression among an excluded producer's facts cannot be graded here and is NOT reported.
```

A producer is an extractor or a provider. When one ran on one side only
(a provider whose tool was missing on the CI runner, a language that
appeared in the change, the first Markdown file in a repository that had
none), enola grades what both sides share and names what it left out. Two consequences:

- A regression among the excluded facts is not reported.
- A law's breach can be counted against the shared producers differently
  on each side, so a breach the baseline already had can appear as
  introduced. The output above came from adding a first `.rb` law to a
  Python repository: the `.rb` file is the first Ruby the snapshot sees,
  and the old breach of the new law was graded as a regression. Re-pin
  after a change that adds a language or a provider, then grade.

## Declined

```text
DECLINED — refusing to grade: the baseline is not comparable to the current snapshot.
This is NOT a statement about your change.

Baseline comparability:
  - ignore globs differ between baseline and current — the set of files parsed changed, so some deltas may be exclusion changes rather than code changes
```

Exit 3. The two snapshots were made under different enola versions,
ignore globs or repositories, so their difference would describe how they
were made rather than what you edited. Re-pin the baseline, or, in CI,
generate both sides with the same binary and configuration. Never read a
declined run as a pass; the template and the action both report it as
"did not run".

## Outputs that surprise a first reader

- **`reached no verdict on N imports target(s) naming nothing measured`**,
  at 0.40, beside a law over `imports`. Some imports name something
  outside the graph (a library, the standard library), and the law cannot
  say whether those cross it. It is advisory and fails nothing.
- **A second breach along the same edge is not new.** An edge law's
  witness is the edge between two modules, so a ratchet law already
  broken by `shop/domain -> shop/repositories` does not fail another
  import along it.
- **`Advisory constraint … violated` failed the build.** Advisory breaches
  report at 0.90; a `-min-confidence` under that, such as `0.8`, lets them
  fail. Keep constraints at the default floor, or run a second `check` for
  the explainers you want at a lower one.
- **`no pinned baseline`, exit 2.** `check` grades against the pinned
  baseline; run `enola baseline pin .` first, or pass `--baseline
  previous` to compare with the snapshot taken before this one.
- **`no mcp-arch.yaml … using built-in defaults`** on every command. No
  configuration file is needed; the line says none was found.
- **`--explain` shows no breaches.** It describes the repository; laws are
  graded by `check`.
- **A hundred `[engine]` lines.** Progress goes to stderr;
  `2>/dev/null` leaves the verdict.
- **A law that matched nothing.** `enola constraints lint .` lists each
  part with its member count; a part with none makes every law over it
  hold trivially, and lint's count is where to see it.

## Other shapes

`-format` writes the same verdict as `text` (the default), `json` (what the
CI template renders), `sarif` for code scanning, `annotations` for a CI's
line annotations (`-host github` or `-host buildkite`), `summary` and
`summary-json`. `-reviewers` adds who owns the modules the change
touched, read from git authorship; it never fails the run.

## Where next

- [Writing laws](04-writing-laws.md#modes-dates-and-carve-outs): modes,
  exemptions and suppressions, the answers to a breach.
- [Constraints in CI](05-constraints-in-ci.md): the same verdict on every
  pull request.
