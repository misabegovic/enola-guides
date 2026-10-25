# tabula: the knowledge base, kept by a tool

Guides 09 to 12 build a knowledge base by hand: pages anchored to code, a
wrapper, four hooks, five skills, receipts and a ledger. [tabula](https://github.com/misabegovic/tabula)
is that practice as one program. It keeps the pages, checks them against
a contract, compiles their laws into enola constraints, grades a plan
against the code with enola, and holds every agent that works on the
code to the page that governs it. This guide is what an enola user needs
to know to start; tabula's own documentation under `docs/wiki/` goes
further, and every verb prints the command to run next and why.

## What it adds to enola

enola measures what the code is and grades what a change did to it.
tabula holds what the code should be, in pages a person writes:

- **Architecture pages** (`.tabula`, `kind: architecture`) draw parts and
  arrows and state laws as sentences; `tabula architecture --write`
  compiles them into `enola/constraints/` in the repository, so the
  repository's own `enola check` enforces them with no tabula in CI.
- **PRDs** (`kind: initiative`) carry acceptance bullets, each settled by
  an observation: a test to run, a count over the facts, or
  `grade: enola check clean`. `tabula evaluate` settles every bullet as
  met, not met, not checked or does not apply, with no model involved,
  and writes the verdict into the decision record beside the PRD with a
  receipt.
- **The loop**: search before reading, claim before working, find the
  governing page before editing, grade before finishing, report what
  happened. Hooks refuse an edit until the agent has recorded the page it
  is working from.

## Install

A tabula release carries cardo, the build of enola it is developed
against, inside the binary. Download the archive for your platform from
the [releases](https://github.com/misabegovic/tabula/releases), check it
against `SHA256SUMS`, and put `tabula` on your PATH:

```bash
sha256sum -c SHA256SUMS
tar -xzf tabula-0.0.1-linux-amd64.tar.gz
install -m 755 tabula-0.0.1-linux-amd64/tabula ~/.local/bin/tabula
tabula doctor
```

v0.0.1 is built for linux-amd64 only. On any other platform, build from a
clone with `cargo build --release` (the repository pins its Rust
toolchain); a plain build carries no engine and uses the one on your PATH.

The carried cardo is unpacked into tabula's cache the first time a verb
needs it, its digest checked, and it is **found last**: `engine.binary` in
`tabula.config.yml` comes first, then `cardo`, `cardo-current` and `enola`
on your PATH. An upstream `enola` you installed for the other guides is
therefore the engine tabula runs, with a warning on every line that
carries its result. `tabula doctor` says which engine answered and how it
was found (`engine` and `carried` lines); set `engine.binary` to choose
one, or `engine.carried: never` to leave the carried copy out. tabula
never installs or upgrades an engine of its own accord.

## The first run

```bash
mkdir shop-brain && cd shop-brain
tabula init --tour
tabula tour
```

`init --tour` writes an empty project (a `wiki/`, an `AGENTS.md` stating
the contract, `tabula.config.yml`) and a small inherited shop with the
facts an engine already read from it, so the tour runs without one.
`tabula tour` names the one command to run next, read off the project
each time: write a page, find it with `search`, `explain` the shop from
its facts, `picture` its architecture page, then `evaluate` a PRD the
shop does not meet yet, fix one line, and evaluate it again.

For your own code, name the repositories in `tabula.config.yml`
(`projects_root`, `active_repos`) and let the engine draft a first page:

```bash
tabula explain shop --generate
```

writes a page a newcomer can read, every sentence a claim with its file
and line, and, when the repository has no architecture page yet, a draft
at `wiki/shop/architecture/explained.tabula` that forbids nothing.

## Laws, from a page to `enola check`

```bash
tabula say shop/architecture/shop.tabula "orders never calls gateway." \
  --because "billing alone talks to the payment gateway."
tabula architecture shop/architecture/shop.tabula --write
```

`say` writes the law under the page's `***laws***` and reads it back with
what the code shows today, a count and never a verdict. `--write` puts
the compiled rules in the repository:

```yaml
# enola/constraints/shop.yaml
# Compiled by `tabula architecture` from the page `shop/architecture/shop.tabula`; edit the page, not this file.
components:
  - name: orders
    match: ["shop/orders.py"]
  - name: gateway
    match: ["shop/gateway.py"]
rules:
  # orders never calls gateway.
  - id: orders-never-calls-gateway
    forbid: orders
    to: gateway
    via: calls
    mode: ratchet
    since: 2026-10-25
    because: >-
      billing alone talks to the payment gateway.
```

That file is plain enola YAML, and upstream enola v0.4.34 lints it clean.
Commit it in the repository and grade it there exactly as
[constraints in CI](05-constraints-in-ci.md) describes. A sentence with no
strength word is `ratchet`; `, as a warning.` is `advisory` and
`, without exception.` is `strict`. A rule no sentence can say is written
in enola's own form under `laws/` at the project root, and `tabula
export` copies it into the repository with the compiled pages.

## A plan graded against the code

```text
***specs***

- An order's total counts every line, discounts included.

  ***acceptance***

  - A discount line lowers the total.
    test: ~/projects/shop/tests/test_totals.py -- python3 -B -m unittest tests.test_totals
  - The change crosses no law.
    grade: enola check clean
```

`tabula evaluate shop/prds/totals-add-up.tabula` runs the test and asks the
engine for `check --json --fail-on=constraints` on every repository the
PRD anchors. A regression, whole or partial, is not met; no baseline,
incomparable snapshots or no engine is "not checked", never a pass. A
bullet not met exits 5, and the fix is in the code: tabula's rule is that
the bullet, its observation and the checked block are never edited to
make a verdict pass.

## Agents

```bash
tabula install --harness claude      # or agents, pi, codex
```

opens tabula's doors to one harness: for Claude Code, hooks in
`.claude/settings.json`, a `tabula` MCP server in `.mcp.json` and a
skill, each file recorded in `wiki/_state/install.json` so `--uninstall`
removes exactly what it wrote. The `agents` harness covers anything that
reads `AGENTS.md` (opencode, goose, Cline, OpenHands, Amp). tabula's
repository is also a Claude Code plugin marketplace, under
`editors/claude-code`, carrying the same server, hooks and skill plus the
`.tabula` language server.

The skill's rule is one line: search before reading, claim before
working, evaluate before finishing. The loop it runs is
`tabula run loop --flow`: search, claim, find the governing page with
`govern`, record it with `align` (or write the intent first), check the
blast radius with `impact`, pin a baseline, edit from the aligned
bullets, grade, report, release. The edit gate refuses a write until
`align` has recorded the page the change is generated from, and a write
from the shell is caught by git's status, not by reading the command.

tabula's hooks and enola's (`enola install --hooks`) do different jobs
and sit side by side in `.claude/settings.json`: enola's pin a baseline,
grade the session and turn the first searches toward the graph; tabula's
hold the agent to the page. Install enola's first. In v0.4.34, running
`enola install --hooks` again after tabula's are in place adds enola's
stop hook a second time, inside tabula's stop entry, so the session is
graded twice per turn; if you re-run it, remove the copy.

## Which hand-built piece tabula replaces

| Guides 09 to 12 | With tabula |
|---|---|
| a script stamping `enola_intent:` onto a page | intent lives under `intent:` on the page; `tabula export` writes the frontmatter mirror the engine's `mdintent` extractor reads |
| laws in the Ruby DSL beside the page | `***laws***` sentences on the architecture page, compiled by `tabula architecture --write` (the Ruby DSL still works beside them) |
| a receipts file and a citation sweep | receipts under `wiki/_state/receipts/`, re-checked by `tabula verify`; `tabula check` for citations, links and scope |
| a findings ledger | the inbox, where only a person confirms or dismisses a finding, beside `enola constraints ledger` |
| the wrapper (`kb enola …`) and its named skip | the verbs themselves: `govern`, `impact`, `evaluate`, each saying "not asked" rather than passing |
| the intent-first gate | `tabula hook gate`, which refuses until `align` records the governing page |
| stop-time debt | a stop hook that blocks until the change is aligned or reverted |
| hand-wired hook settings | `tabula install --harness claude`, or the plugin |
| the five knowledge-base skills | the one `tabula` skill and the loop's govern, impact, baseline and grade steps |

The hand-built path stays documented because it is what tabula does,
written small enough to read and run without it.

## Next

- tabula's [tutorials and how-tos](https://github.com/misabegovic/tabula/tree/main/docs/wiki):
  explain your own repository, add a constraint to a repository, run
  tabula in CI, connect a harness over MCP.
- [taha](14-taha.md): agents that run on a tabula project under a
  mandate, stopping to ask before anything is published.
