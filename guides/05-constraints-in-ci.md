# Constraints in CI

The check that grades every pull request against its base branch, reports
what the change added, and never fails the build until the team decides it
should. [`templates/enola-check.sh`](../templates/enola-check.sh) is the
script; this guide is why it looks the way it does.

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
4. **Configure the providers the agent has.** Prism when a Ruby with it is
   on PATH, Rubydex after `enola providers fetch rubydex` (the library is
   cached beside the binary), eslint when the lint step uploaded its
   results. Each absence is a named line in the log, never a silent drop,
   and the same providers feed both snapshots so they stay comparable.
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

When the two snapshots differ in enola version, in the providers that ran,
or in the ignore globs, `check` declines to grade. The script reports that
as "did not run" on CI (a failed step, so it cannot go quiet) and as a skip
locally. Read it as "not asked", and fix what made the pair incomparable.

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
