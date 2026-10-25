# Contributing

Thank you for helping. These guides make one promise: every command, flag,
key and output they show was run against the enola release named in
`ENOLA_VERSION` before it was written down. A change keeps that promise.

## Before you open a pull request

```bash
script/test
```

runs every check CI runs that needs no registry. It downloads the pinned
enola into `~/.cache/enola-guides` the first time.

## Changing a guide

- Run what you write. Paste the output you got, or a line of it, rather
  than what you expect.
- Say where enola reads less than the code says, in the guide, where it
  bites, with the version. A limitation stated is worth more than one
  discovered in production.
- Link rather than repeat: enola's own docs, tabula's and taha's are the
  reference; a guide is the path through them.
- Keep the voice: plain sentences, the reason beside the rule, no
  marketing.

## Adding an example

An example with source carries an `EXPECTED` file listing, one per line,
the rule ids that must report a breach. `script/test-examples` snapshots it
with the pinned enola and fails when the set changes, in either direction.
Every law carries a `because:`; start every law in `ratchet`.

## The command

`enola-guides` has five implementations held to one behaviour
(`spec/cli/README.md`). Change the spec and the goldens first
(`script/test-clis --update go=<binary>`), then each implementation until
`script/test-clis` passes for all five. New content needs no code: it is
in `bundle/bundle.json` after `script/bundle`.

## Moving to a new enola release

1. Set `ENOLA_VERSION`.
2. Run `script/test` and read every failure: a law that stopped firing, an
   example that now reports something new, a template that no longer runs.
3. Fix the guide, not the test, unless enola is right and the guide was
   wrong; then say what changed in `CHANGELOG.md`.

## Commits and versions

A commit message is one sentence saying what is now true, with the version
in parentheses when it releases one. `VERSION` is the one version; see
`RELEASING.md`.

By contributing you agree that your contribution is licensed under the
Apache License, Version 2.0, as the rest of the repository is.
