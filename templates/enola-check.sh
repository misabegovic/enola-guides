#!/bin/bash
# Grades this pull request's architectural delta against its base branch and
# reports what the change added: declared constraints, queries in loops, layer
# violations, dependency cycles. By default findings are reported, never
# blocking (-warn-only). ENOLA_CHECK_ENFORCE=1 makes this a gate: the step
# then exits with enola check's own code, 1 when the change introduced a
# finding the policy fails. Turning it on is a team decision.
#
# What fails at all is enola's policy, unchanged here: a new finding from a
# watched explainer at confidence 1.00, and a strict law's breach whether new
# or not. An advisory law reports at 0.90 and never fails; neither does a
# finding an explainer only estimates (an inferred layer, a query reached
# through an interface). ENOLA_CHECK_MIN_CONFIDENCE lowers that floor, and
# advisory laws then fail with the rest.
#
# Requirements: the full history of the base branch and the change (on
# GitHub `fetch-depth: 0`, on GitLab `GIT_DEPTH: 0`), a clean working tree,
# curl, tar and sha256sum. Optional: ruby, to render the findings grouped by
# rule (without it the comment is enola's own `check --summary`), and gh,
# to post the comment (without it the comment is printed).
#
# On CI (CI set) anything that keeps the delta from being graded fails the
# step, so the check cannot go quiet; on a laptop it skips with the reason.
# The one skip on CI is a build with nothing to grade: this commit is the
# base itself.
#
# Three seams are yours to fill, marked FILL IN below: how the pinned binary
# is fetched, how the pull request's base branch is read on a push build,
# and how the comment is posted. Everything between them runs the same on
# any CI and on a laptop.
set -euo pipefail

# The enola release this check runs: ENOLA_VERSION, else the first line of a
# committed .enola-version, so a repository pins it in one place.
ENOLA_VERSION="${ENOLA_VERSION:-$(head -n 1 .enola-version 2>/dev/null || true)}"
ENOLA_VERSION="${ENOLA_VERSION:-0.4.35}"
WATCHED_EXPLAINERS="${ENOLA_CHECK_WATCHED:-constraints,query-loops,layers,cycles}"
WATCHED_FLAGS=(-fail-on "$WATCHED_EXPLAINERS")
[ -z "${ENOLA_CHECK_MIN_CONFIDENCE:-}" ] || WATCHED_FLAGS+=(-min-confidence "$ENOLA_CHECK_MIN_CONFIDENCE")
[ "${ENOLA_CHECK_ENFORCE:-0}" = 1 ] || WATCHED_FLAGS+=(-warn-only)

say() { echo "enola check: $1"; }

skip() {
  say "skipped: $1. The architectural delta was not graded this build."
  exit 0
}

# On CI a missing prerequisite fails the step so the check cannot go quiet;
# locally it skips.
notrun() {
  if [ -n "${CI:-}" ]; then
    say "did not run: $1. The architectural delta was not graded this build."
    exit 1
  fi
  skip "$1"
}

work=$(mktemp -d)
current_ref=""
cleanup() {
  if [ -n "$current_ref" ]; then
    git checkout -q "$current_ref" 2>/dev/null || true
  fi
  rm -rf "$work"
}
trap cleanup EXIT

# FILL IN 1: fetch the pinned binary. Cached per version and platform so a
# laptop downloads once. Verify the checksum the release publishes.
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
case "$arch" in x86_64 | amd64) arch=amd64 ;; arm64 | aarch64) arch=arm64 ;; *) notrun "no enola build for $arch" ;; esac
ENOLA="${HOME:-$work}/.cache/enola/${ENOLA_VERSION}/enola"
if [ ! -x "$ENOLA" ]; then
  mkdir -p "$(dirname "$ENOLA")"
  asset="enola-${ENOLA_VERSION}-${os}-${arch}.tar.gz"
  curl -fsSL "https://github.com/enola-labs/enola/releases/download/v${ENOLA_VERSION}/${asset}" -o "$work/$asset" || notrun "could not download enola ${ENOLA_VERSION}"
  curl -fsSL "https://github.com/enola-labs/enola/releases/download/v${ENOLA_VERSION}/${asset%.tar.gz}.sha256" -o "$work/${asset%.tar.gz}.sha256" || notrun "could not download the checksum for enola ${ENOLA_VERSION}"
  (cd "$work" && sha256sum -c "${asset%.tar.gz}.sha256" >/dev/null) || notrun "checksum mismatch for ${asset}"
  tar -xzf "$work/$asset" -C "$work"
  mv "$work/${asset%.tar.gz}" "$ENOLA"
  chmod +x "$ENOLA"
fi
say "enola ${ENOLA_VERSION} at ${ENOLA}"

# Providers the agent can run. Each absence is a named line, never silence,
# and the same providers feed both snapshots so they stay comparable. Both
# Ruby providers run inside the binary once the Rubydex library is fetched;
# no Ruby is needed. The binary pins the library, so neither entry carries an
# expected_version.
provider_entries=""
if [ -f Gemfile ]; then
  rubydex_fetch="$("$ENOLA" providers fetch rubydex 2>&1 | tail -n 1 || true)"
  if "$ENOLA" providers list 2>/dev/null | grep -q '^  rubydex  0\.'; then
    provider_entries="  - name: rubydex
  - name: prism
"
  else
    say "rubydex and prism providers not configured (${rubydex_fetch:-providers fetch printed nothing})"
  fi
fi

GENERATE_TARGET="$PWD"
if [ -n "$provider_entries" ]; then
  GENERATE_TARGET="$work/enola-generate.yaml"
  printf 'repos:\n  - %s\nproviders:\n%s' "$PWD" "$provider_entries" > "$GENERATE_TARGET"
fi

# A shallow clone has no merge-base to grade against; say how to get one
# rather than grading nothing.
[ "$(git rev-parse --is-shallow-repository 2>/dev/null)" != true ] ||
  notrun "this is a shallow clone; fetch the full history (fetch-depth: 0 on GitHub, GIT_DEPTH: 0 on GitLab)"

# FILL IN 2: the pull request's base branch. Pull-request builds usually
# carry it in an environment variable; push builds know the pull request
# number and must ask the forge. main only when there is no pull request.
base_branch="${PR_BASE_BRANCH:-}"
if [ -z "$base_branch" ] && [ -n "${PR_NUMBER:-}" ] && command -v gh >/dev/null 2>&1; then
  base_branch=$(gh pr view "$PR_NUMBER" --json baseRefName -q .baseRefName 2>/dev/null || true)
fi
base_branch="${base_branch:-main}"
git fetch origin "$base_branch" >/dev/null 2>&1 || true
base_sha=$(git merge-base HEAD "origin/${base_branch}" 2>/dev/null || true)
[ -n "$base_sha" ] || notrun "no merge-base with origin/${base_branch}"
[ "$base_sha" != "$(git rev-parse HEAD)" ] || skip "this commit is origin/${base_branch} itself, so there is no change to grade"

dirty=$(git status --porcelain -uno)
[ -z "$dirty" ] || notrun "working tree not clean, cannot generate the baseline in place"

head_ref=$(git symbolic-ref -q --short HEAD || git rev-parse HEAD)
current_ref="$head_ref"
git -c advice.detachedHead=false checkout -q "$base_sha" || notrun "could not check out the merge-base"
"$ENOLA" --generate "$GENERATE_TARGET" >/dev/null 2>&1 || notrun "baseline snapshot failed at ${base_sha:0:11}"
git checkout -q "$head_ref"
current_ref=""
"$ENOLA" --generate "$GENERATE_TARGET" >/dev/null 2>&1 || notrun "snapshot generation failed on this checkout"

# Exit 0 is clean and 1 a regression the policy fails: both are verdicts,
# rendered and posted. 3 is a declined comparison and 2 a gate that could
# not run: neither graded anything.
set +e
verdict=$("$ENOLA" check -baseline previous "${WATCHED_FLAGS[@]}" -json "$GENERATE_TARGET" 2>/dev/null)
check_exit=$?
set -e
case "$check_exit" in
  0 | 1) ;;
  3) notrun "enola declined to grade: the two snapshots are not comparable (enola check exited 3)" ;;
  *) notrun "enola check could not run (exited ${check_exit})" ;;
esac

if command -v ruby >/dev/null 2>&1; then
  summary=$(printf '%s' "$verdict" | ruby "$(dirname "$0")/enola-findings.rb")
  status=$(printf '%s' "$summary" | head -n 1)
  details=$(printf '%s' "$summary" | tail -n +3)
else
  # The verdict's own status reads "clean" under -warn-only whatever it
  # found, so the summary's sections decide: no "Got worse", nothing new.
  say "ruby is not on this agent; the comment is enola's own summary"
  plain=$("$ENOLA" check -baseline previous "${WATCHED_FLAGS[@]}" -format summary "$GENERATE_TARGET" 2>/dev/null || true)
  status=FINDINGS
  grep -q '^Got worse' <<<"$plain" || status=CLEAN
  details="\`\`\`
$plain
\`\`\`"
fi

if [ "$check_exit" -eq 1 ]; then
  blocking="**This blocks the merge.**"
elif [ "${ENOLA_CHECK_ENFORCE:-0}" = 1 ]; then
  blocking="**Nothing here fails the check.**"
else
  blocking="**Nothing is blocked** while the team gets used to the check."
fi

case "$status" in
  CLEAN)
    body="No new architectural findings against \`${base_sha:0:11}\`."
    ;;
  PARTIAL)
    body="enola check: no new findings against \`${base_sha:0:11}\` among the facts both snapshots share. **This is a partial verdict.**

$details"
    ;;
  DECLARED)
    body="enola check: this change declares rules that existing code already breaks, and introduces no new findings on the code it touched (against \`${base_sha:0:11}\`). $blocking

$details"
    ;;
  *)
    body="enola check found new architectural findings against \`${base_sha:0:11}\`. $blocking

$details"
    ;;
esac

# FILL IN 3: post one comment per pull request, edited in place. Without a
# forge credential, print it. The REST API edits a comment by its numeric
# id, so the lookup goes through the same API.
if [ -n "${PR_NUMBER:-}" ] && command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  marker="<!-- enola-check -->"
  existing=$(gh api "repos/{owner}/{repo}/issues/${PR_NUMBER}/comments" --paginate \
    --jq ".[] | select(.body | startswith(\"$marker\")) | .id" 2>/dev/null | head -n 1 || true)
  if [ -n "$existing" ]; then
    if gh api -X PATCH "repos/{owner}/{repo}/issues/comments/$existing" -f body="$marker
$body" >/dev/null; then
      say "updated the existing enola comment"
    else
      say "could not update the enola comment $existing"
    fi
  elif [ "$status" != "CLEAN" ]; then
    gh pr comment "$PR_NUMBER" --body "$marker
$body" >/dev/null && say "posted a new enola comment"
  fi
else
  printf '%s\n' "$body"
fi

exit "$check_exit"
