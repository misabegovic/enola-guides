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

## Any other CI: the template

[`templates/enola-check.sh`](../templates/enola-check.sh) and its renderer
[`templates/enola-findings.rb`](../templates/enola-findings.rb) are the
same check as a script. `enola-guides copy templates/enola-check` writes
both to `ci/`, side by side; run `ci/enola-check.sh` as a CI step.

What it needs from the CI:

- **The full history** of the base branch and the change: on GitHub
  `fetch-depth: 0`, on GitLab `GIT_DEPTH: 0`. A shallow clone has no
  merge-base, and on CI the script fails the step saying so rather than
  skipping.
- **A clean working tree**, since it checks out the merge-base to snapshot
  it.
- `curl`, `tar` and `sha256sum`. Optional: `ruby`, to group the comment
  per rule (without it the comment is enola's own `check --summary`), and
  `gh`, to post the comment (without it the comment is printed).

And what it reads:

| Variable | Default | What it does |
|---|---|---|
| `ENOLA_VERSION` | the first line of a committed `.enola-version`, else `0.4.35` | the release it downloads, checks against its checksum and caches |
| `ENOLA_CHECK_ENFORCE` | unset: report only | `1` makes it a gate that exits with `check`'s own code |
| `ENOLA_CHECK_WATCHED` | `constraints,query-loops,layers,cycles` | the explainers whose new findings it watches (`-fail-on`) |
| `ENOLA_CHECK_MIN_CONFIDENCE` | unset: enola's floor of 1.00 | lowers the floor; at 0.90 or below, advisory laws fail too |
| `PR_NUMBER` | unset | the pull request to read the base from and comment on |

## The shape

1. **Pin a release.** The script downloads one version of the binary,
   verifies its checksum, and caches it per version and platform. A
   floating version is how a check that passed yesterday fails today with
   no change of yours. A committed `.enola-version` pins it in one place.
2. **Grade against the pull request's base, not against main.** A stacked
   pull request whose parent declares new rules would otherwise report the
   parent's whole backlog as its own. Push-triggered builds often know the
   pull request number but not its base, so the script asks the forge for
   it and falls back to `main` only when there is no pull request at all.
3. **Two snapshots, one verdict.** Check out the merge-base, generate;
   check out the head, generate; `enola check -baseline previous`.
4. **Configure the providers the runner has.** In a tree with a `Gemfile`,
   the script fetches the Rubydex library the pinned binary names and
   configures the built-in `rubydex` and `prism` providers, which need no
   Ruby on the runner. A provider of your own (eslint, a runtime capture)
   is one more entry in the same block. Each absence is a named line in
   the log, never a silent drop, and the same configuration generates both
   snapshots and grades them, so they stay comparable.
5. **Watch a few explainers, report only, then enforce.** By default the
   step runs `check -fail-on constraints,query-loops,layers,cycles
   -warn-only`: it reports what those explainers added and exits 0.
   Setting `ENOLA_CHECK_ENFORCE=1` is the team's decision, made once the
   comments have been read for a while; [rolling out](19-rolling-out.md)
   says when. The floor stays at enola's 1.00, so an advisory law (0.90)
   and an estimate (an inferred layer, a query reached through an
   interface) are reported and never fail. A strict law fails on every
   breach, new or not.
6. **Render for a reader, grouped per rule.** The verdict's JSON becomes a
   comment with four sections in this order: **Watched** (the watched
   explainers' new findings at or above the floor, grouped per rule with a
   count and three examples, constraints first; under enforcement the
   headline is "This blocks the merge."), **Below the floor** (the watched
   explainers' findings under it, which never fail), **Declared** (rules
   this change declares, reported on code it did not touch, the baseline
   each rule starts from) and **Also noticed** (everything outside the
   watched set). One comment per pull request, found by a marker and
   edited in place; a clean run updates an existing comment and posts
   nothing new.

## Exit codes, and why "did not run" fails

| `check` exits | The step | The comment |
|---|---|---|
| 0, clean | passes | posted, or an existing one updated |
| 1, regression | passes while reporting only; fails under `ENOLA_CHECK_ENFORCE=1` | posted, naming what fails |
| 2, error (no baseline, a bad flag) | fails on CI as "did not run" | none |
| 3, declined (not comparable) | fails on CI as "did not run" | none |

On a laptop, 2 and 3 skip with the reason instead. "Did not run" means no
grade was produced, never a pass: fix what kept it from running, such as
a different enola version or different ignore globs on the two sides.

When only the producers differ (a provider whose tool was missing on one
side, or a language or the first Markdown file appearing in the change),
`check` grades the facts both snapshots share and says the verdict is
partial; the comment names each producer it left out and the side that
lacked it, because a regression among those facts is not reported. The
script generates both snapshots with the same configuration, so a partial
verdict on CI means the change added a kind of file the base did not
have, or a tool the runner lacks, not a misconfigured step.

Under `-warn-only` the JSON verdict's `status` reads `clean` even when
regressions were reported, and enola-action's `status` output follows it;
read the findings, not `status`, to know whether anything was found while
the check only reports.

## Other shapes of the verdict

`check` writes the same verdict in several shapes, chosen with `-format`:
`text` (the default), `json` (what the template renders), `sarif` for code
scanning, `annotations` for the CI's line annotations (`-host github` or
`-host buildkite`, with `-link` naming the pull request's files view on
Buildkite), and `summary`, a plain-language account for a reader who does
not know the explainer names. `summary-json` is that account as JSON. Each
shape grades nothing of its own, so every shape exits with the same
code. [Reading a verdict](20-reading-a-verdict.md)
has every section.

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

The template targets a generic CI with three places you fill in, each
marked `FILL IN`: how the binary is fetched (a release asset URL and its
checksum), how the pull request's base branch is read (an environment
variable on pull-request builds, a forge API call on push builds), and how
the comment is posted (a small script against the forge's comments API).
Everything between, the two snapshots and the verdict and the rendering,
is the same on every CI.

## Where next

- [Rolling out](19-rolling-out.md): which laws to start with, and when to
  enforce.
- [Reading a verdict](20-reading-a-verdict.md): every section of the
  output.
