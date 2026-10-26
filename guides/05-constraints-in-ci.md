# Constraints in CI

The check that grades every pull request against its base branch, reports
what the change added, and never fails the build until the team decides it
should. On GitHub that is one step, [enola-action](#on-github-enola-action);
on any other CI, or where you want the comment grouped per rule,
[`templates/enola-check.sh`](../templates/enola-check.sh) is the script and
most of this guide is why it looks the way it does.

## On GitHub: enola-action

```yaml
# .github/workflows/architecture.yml
on: pull_request
permissions:
  contents: read
jobs:
  architecture:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - uses: enola-labs/enola-action@v2
        with:
          version: 0.4.35
          fail-on: constraints
          warn-only: true
```

It resolves the pull request's exact base commit, generates both sides on
the runner, annotates the lines that introduced a finding, and writes the
delta to the job summary. `version` pins the release; left out, it is
`latest`, and a check that passed yesterday can fail today with no change
of yours. `pr-comment: true` also posts the report as one comment edited
in place (it needs `pull-requests: write`), and `sarif: true` writes a
SARIF 2.1.0 file for code scanning, exposed as the `sarif-file` output.
Its `status` output is one of `clean`, `partial_clean`, `regression`,
`partial_regression`, `usage_error` and `incomparable`, and `partial`
says whether the verdict graded only the producers both sides share.

The action downloads enola but not the Rubydex library. A repository with
Ruby installs both, pinned, and hands the action that binary; without it
the Ruby is graded without its providers on both sides alike, so the
verdict looks whole and quietly misses everything Rubydex resolves:

```yaml
      - name: Install enola 0.4.35 and the Rubydex library it pins
        run: |
          v=0.4.35; a=enola-$v-linux-amd64
          curl -fsSLO "https://github.com/enola-labs/enola/releases/download/v$v/$a.tar.gz"
          curl -fsSLO "https://github.com/enola-labs/enola/releases/download/v$v/$a.sha256"
          sha256sum -c "$a.sha256"
          tar -xzf "$a.tar.gz"
          mkdir -p "$RUNNER_TEMP/enola" && mv "$a" "$RUNNER_TEMP/enola/enola"
          "$RUNNER_TEMP/enola/enola" providers fetch rubydex
      - uses: enola-labs/enola-action@v2
        with:
          binary: ${{ runner.temp }}/enola/enola
          fail-on: constraints
          warn-only: true
```

Removing `warn-only` is the team's decision, made once the reports have
been read for a while; [rolling out](19-rolling-out.md) says when.

## The shape

1. **Pin a release.** The script downloads one version of the binary,
   verifies its checksum, and caches it per version and platform. A
   floating version is how a check that passed yesterday fails today with
   no change of yours.
2. **Grade against the pull request's base, not against main.** A stacked
   pull request whose parent declares new rules would otherwise report the
   parent's whole backlog as its own. Push-triggered builds often know the
   pull request number but not its base, so the script asks the forge for
   it and falls back to `main` only when there is no pull request at all.
3. **Two snapshots, one verdict.** Check out the merge-base, generate;
   check out the head, generate; `enola check -baseline previous`. The
   working tree must be clean for this, and the script says so when it is
   not rather than grading a mixed tree.
4. **Configure the providers the agent has.** In a tree with a `Gemfile`,
   the script fetches the Rubydex library the pinned binary names and
   configures the built-in `rubydex` and `prism` providers, which need no
   Ruby on the agent. A provider of your own (eslint, a runtime capture)
   is one more entry in the same block. Each absence is a named line in
   the log, never a silent drop, and the same configuration generates both
   snapshots and grades them, so they stay comparable.
5. **Watch a few explainers, warn only.**
   `-fail-on constraints,query-loops,layers,cycles -min-confidence 0.8 -warn-only`
   reports the findings those explainers added and keeps the exit code
   at 0. Removing `-warn-only` is the team's decision, made once the
   comments have been read for a while.
6. **Render for a reader, grouped per rule.** The verdict's JSON becomes a
   comment with three sections in this order: **Watched** (the explainers
   you track, grouped per rule with a count and three examples, constraints
   first), **Declared** (rules this change declares, reported on code it did
   not touch, the baseline each rule starts from), **Also noticed**
   (everything outside the watched set). One comment per pull request,
   edited in place; a clean run updates an existing comment and posts
   nothing new.

## Not comparable is not a pass

When the two snapshots differ in enola version or in the ignore globs,
`check` declines to grade. The script reports that as "did not run" on CI
(a failed step, so it cannot go quiet) and as a skip locally. Read it as
"not asked", and fix what made the pair incomparable.

When only the producers differ (a provider whose tool was missing on one
side), `check` grades the facts both snapshots share and says the verdict
is partial; the comment names each producer it left out and the side that
lacked it, because a regression among those facts is not reported. The
script generates both snapshots and grades them with the same
configuration, so a partial verdict on CI means a tool the agent lacks,
not a misconfigured step.

## Other shapes of the verdict

`check` writes the same verdict in several shapes, chosen with `-format`:
`text` (the default), `json` (what the template renders), `sarif` for code
scanning, `annotations` for the CI's line annotations (`-host github` or
`-host buildkite`, with `-link` naming the pull request's files view on
Buildkite), and `summary`, a plain-language account for a reader who does
not know the explainer names: whether it passes, what got worse, what got
better, what the run could not see, what to do next. `summary-json` is
that account as JSON. Each shape grades nothing of its own, so the exit
code is the verdict's whichever one printed it.

`-reviewers` adds who owns the modules the change touched, read from git
authorship, and suggests a reviewer when the author is a minor
contributor; it never fails the run.

## Reproduce locally

```bash
bash ci/enola-check.sh     # or wherever you keep it
```

The script is written to run on a laptop: without the forge's credentials
it skips the comment and prints the verdict, and it leaves the checkout on
the branch it found.

## Adapting the template

The template targets a generic CI with three seams you fill in: how the
binary is fetched (a release asset URL and its checksum), how the pull
request's base branch is read (an environment variable on pull-request
builds, a forge API call on push builds), and how the comment is posted
(a small script against the forge's comments API). Everything between,
the two snapshots and the verdict and the rendering, is the same on every
CI.
