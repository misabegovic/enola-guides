# Rolling out

How a team adopts enola on a repository that already has years of
history and already breaks most of the laws it would like to state,
without failing everything on day one and without a check nobody reads.
The order below is the one that works: measure, choose a few laws, report
for a while, then enforce.

## 1. Measure it on your repository

```bash
enola --generate .
enola baseline pin .
time enola check .
```

The first snapshot says what enola sees (the receipt names what it
skipped), and `check` with no change tells you what every later check
costs. On two repositories, with enola v0.4.35 on one Linux machine:

| Repository | Files | Snapshot, cold | Peak memory | `check`, no change | `.enola/` |
|---|---|---|---|---|---|
| Mastodon (Ruby and TypeScript), shallow clone | 10,185 | 4.5 s | 315 MB | 3.4 s | 42 MB |
| the same, with the `rubydex` and `prism` providers | | 7.6 s | 600 MB | | 82 MB |
| a private Rails monolith | 20,102 | 33 s | 1.3 GB | 27 s | 189 MB |
| the same, with the `rubydex` and `prism` providers | | 45 s | 2.0 GB | 33 s | 318 MB |

A warm snapshot reuses what did not change (2.8 s on Mastodon). The CI
template generates two snapshots per run, the base's and the head's.
Cache `~/.cache/enola` between CI runs so the Rubydex library is fetched
once per release. enola's session hooks have a 60-second timeout; a
repository near that should leave the stop hook out and grade in CI.

## 2. Choose a few laws, in ratchet

`enola constraints init` binds every shipped recipe whose roles your
directories have. On the monolith above that was five at once (`clean`,
`layered`, `rails-conventions`, `rails-strict`, `ruby-conventions`): 38
rules and 5,029 breaches, several of them the same law stated twice in
two modes. Binding one recipe instead gave 12 rules and 146 breaches:

```bash
enola constraints init --recipe rails-conventions .
enola --generate . && enola constraints ledger .
```

```text
law: 12 rules (5 ratchet, 7 advisory) · 146 breaches · none excused
```

Start with one recipe, or with two or three laws the team already
believes, each with its `because:`. Keep every one in `ratchet`: it
reports what already breaks the law and fails only what a change adds,
so 146 breaches, or 5,029, are the starting line rather than a red build.
`constraints ledger` is the number to watch shrink.

## 3. Report on every pull request

Add the check in report-only mode, as [constraints in
CI](05-constraints-in-ci.md) shows (`warn-only: true` on the action,
`-warn-only` in the template). Grading is against each pull request's
base, so a pull request reports only what it added. A pull request that
adds a law shows that law's existing breaches under `Newly declared`,
which is where a team argues about a law before it can fail anything.

Run it like that for a few weeks and read the comments. A law whose
reports nobody acts on is a law to delete or rewrite; a finding that is
wrong is worth an issue upstream with the witness it named.

## 4. Enforce, one step at a time

- Remove `warn-only` with `fail-on: constraints` alone: the laws you
  chose fail only what a change adds.
- Leave `-min-confidence` at its default of 1.00. At 0.90 or below, an
  `advisory` law fails too; [writing laws](04-writing-laws.md#modes-dates-and-carve-outs)
  has the table.
- Add another explainer (`cycles`, `layers`) to `fail-on` only after its
  reports have been read the same way.
- Make a law `strict` only when its backlog is zero and it should stay
  zero; until then a strict law fails every pull request for breaches it
  did not make. Date a law with `since` to grade only what was introduced
  after a day.
- When a breach is decided rather than fixed, write an exemption on the
  law, with an owner and a reason. A suppression is for a strict law
  being worked off, and it expires in practice only when someone deletes
  it.

## 5. Give the laws owners

Laws are code the whole team is held to. Put
`enola/constraints/`, `enola/recipes/` and `.enola/suppressions.yaml`
under `CODEOWNERS`, so a new law, a new exemption and a new suppression
each get a reviewer who owns the rule. Every exemption and suppression
carries an owner and a date already; `enola constraints ledger .` lists
them with their age, and an exemption whose witness no longer matches
anything is reported, so excuses do not outlive their reason.

## 6. Agents

Each developer registers the MCP server and runs
`enola install --hooks --global` once ([hooks and
agents](06-hooks-and-agents.md)). Commit the laws, the recipes, the
suppression ledger and the instruction files; do not commit hook entries,
which carry a path to one machine's binary
([what to commit](06-hooks-and-agents.md#what-to-commit)).

## 7. Keep enola current

Pin the version in CI and move it on purpose: set the new version, run
the check on a branch, and read what changed before merging. A new
release can read more of your code, so a law can start reporting breaches
it could not see before; ratchet keeps those out of every pull request's
grade, since the baseline and the head are graded by the same binary. A
baseline pinned by another version is not comparable and `check`
declines, which is the signal to re-pin.

## Turning it off

Every piece comes out on its own and leaves nothing behind:

- CI: delete the step.
- Agents: `enola uninstall` (`--global` for the user-level install)
  reverses `install` byte for byte.
- Laws: delete `enola/constraints/`; nothing else reads it.
- Local state: delete `.enola/` and `~/.enola/`.

## Where next

- [Reading a verdict](20-reading-a-verdict.md): the output a team reads
  on every pull request.
- [Writing laws](04-writing-laws.md): the laws after the first few.
