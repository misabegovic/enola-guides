# taha: agents under a mandate

[taha](https://github.com/misabegovic/taha), short for tabula harness, is a
command-line tool that runs coding agents on a [tabula](13-tabula.md)
project and keeps them on track. You say what you want; taha routes it
through tabula's intent pages (a pitch, a plan, a decision record, then
the build), runs the agent, settles routine questions with a council of
reviewers, and stops to ask you before anything is published. taha
decides nothing tabula can decide: every gate it applies is a tabula
verdict, and a bug in taha can at worst stop a run, never let a failed
check through.

This guide is where taha meets enola. taha's own
[first hour](https://github.com/misabegovic/taha/blob/main/docs/first-hour.md)
fixes one bug in a sample project in ten stops with no model and no
account, and [the menu](https://github.com/misabegovic/taha/blob/main/docs/menu.md)
lists every command by goal; start there.

## Install

taha is not on npm yet, and the name `taha` on npm belongs to another
package, so `npm install -g taha` installs something else. Install from a
clone, with Node 22.19 or newer, on Linux or macOS (Windows through WSL):

```bash
git clone https://github.com/misabegovic/taha && cd taha
npm install
npm link
taha help
```

taha runs the tabula `TABULA_BIN` names, else the newer of the tabula its
platform package carries and the one on your PATH. A clone has no platform
package, so [install tabula](13-tabula.md#install) first.

## What a run is

One piece of work, an issue or a PRD slug, is one durable conversation
kept in SQLite under `state/`, so a crash or a restart never repeats an
act. The run claims the piece with `tabula claim`, attaches `tabula serve`
over the project, and journals every committed step into the project's
journal. Before a piece can finish `done` or open a pull request,
`tabula evaluate` must read every acceptance bullet met; a PRD bullet
written as `grade: enola check clean` is how enola's verdict becomes one
of them.

What the run may do is written in a mandate, `wiki/mandates/default.md`:
the acts it may take (`allow`, `ask`, `never`), its budget, whether it is
`supervised` or `autonomous`, the repositories in scope, the test command,
and when it expires. GitHub is reached through one connector whose only
writes are a branch, a push, a draft pull request and a comment; each is
journaled before it runs, a pull request is always a draft, and taha has
no way to mark one ready or merge it. Anything public waits in the inbox
for you:

```bash
taha                       # what runs, what waits on you, what is next
taha approve <finding>     # a yes to what waits
taha steer <run> <words>   # change a run in flight
taha stop <run>            # stop at the next safe point
```

## Adopting a repository that enola already measures

```bash
cd ~/src/shop
taha adopt --inside        # or --beside --repo shop, to write nothing into it
taha doctor
```

`adopt --inside` adds the project's files to the repository, records the
repository's own checks so a push waits for them, and, for the code map,
writes `mcp-arch.yaml` and runs `cardo --generate` in the repository.
`adopt --beside` writes nothing into the repository and leaves the
snapshot to you. `taha doctor` prints one line each for the layout, the
mandate, the state folder, the schedule and the code map, and exits 0
when all of them read `ready`.

taha calls the engine as `cardo`, by that name on your PATH; it does not
fall back to `enola`. The cardo a [tabula release](13-tabula.md#install)
carries is unpacked into tabula's cache, and `tabula doctor` prints where
(the `engine` line). Until cardo has an install of its own, link that copy
onto your PATH for taha:

```bash
ln -s "$HOME/.cache/tabula/engine/<digest>/cardo" ~/.local/bin/cardo
```

An `mcp-arch.yaml` the repository already has is left as it is, so the
providers [guide 02](02-rails.md#the-two-providers) configures keep
running.

## Where enola's laws stay

taha adds no law of its own. The laws are the repository's
`enola/constraints/`, written by hand or compiled from tabula's
architecture pages, and they are graded by the repository's CI with
`enola check` as [guide 05](05-constraints-in-ci.md) describes, whoever
or whatever wrote the change. taha's part is to make an agent's run reach
that CI only as a draft, after tabula's checks, with you asked first.
