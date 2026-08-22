#!/bin/bash
# Grades this pull request's architectural delta against its base branch and
# reports what the change added: declared constraints, queries in loops, layer
# violations, dependency cycles. Findings are reported, never blocking:
# -warn-only keeps the exit code at 0. Removing it makes this a gate, which
# is a team decision.
#
# Three seams are yours to fill, marked FILL IN below: how the pinned binary
# is fetched, how the pull request's base branch is read on a push build,
# and how the comment is posted. Everything between them runs the same on
# any CI and on a laptop.
set -euo pipefail

ENOLA_VERSION="${ENOLA_VERSION:-0.5.0}"
WATCHED_EXPLAINERS="constraints,query-loops,layers,cycles"
WATCHED_FLAGS=(-fail-on "$WATCHED_EXPLAINERS" -min-confidence 0.8 -warn-only)

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
case "$arch" in x86_64 | amd64) arch=amd64 ;; arm64 | aarch64) arch=arm64 ;; *) skip "unsupported arch $arch" ;; esac
ENOLA="${HOME:-$work}/.cache/enola/${ENOLA_VERSION}/enola"
if [ ! -x "$ENOLA" ]; then
  mkdir -p "$(dirname "$ENOLA")"
  asset="enola-${ENOLA_VERSION}-${os}-${arch}.tar.gz"
  curl -fsSL "https://github.com/enola-labs/enola/releases/download/v${ENOLA_VERSION}/${asset}" -o "$work/$asset" || notrun "could not download enola ${ENOLA_VERSION}"
  curl -fsSL "https://github.com/enola-labs/enola/releases/download/v${ENOLA_VERSION}/${asset%.tar.gz}.sha256" -o "$work/${asset%.tar.gz}.sha256" || notrun "could not download the checksum for enola ${ENOLA_VERSION}"
  (cd "$work" && sha256sum -c "${asset%.tar.gz}.sha256" >/dev/null) || notrun "checksum mismatch for ${asset}"
  tar -xzf "$work/$asset" -C "$(dirname "$ENOLA")"
  chmod +x "$ENOLA"
fi
say "enola ${ENOLA_VERSION} at ${ENOLA}"

# Providers the agent can run. Each absence is a named line, never silence,
# and the same providers feed both snapshots so they stay comparable.
provider_entries=""
if ruby -e 'require "prism"' 2>/dev/null; then
  provider_entries="${provider_entries}  - name: prism
    command: [\"ruby\", \"$(dirname "$0")/enola_prism_provider.rb\"]
    expected_version: \"0.1.0\"
"
else
  say "prism provider not configured (no ruby with prism on PATH)"
fi
rubydex_fetch="$("$ENOLA" providers fetch rubydex 2>&1 | tail -n 1 || true)"
if "$ENOLA" providers list 2>/dev/null | grep -q '^  rubydex  0\.'; then
  provider_entries="${provider_entries}  - name: rubydex
    expected_version: \"0.4.0\"
"
else
  say "rubydex provider not configured (${rubydex_fetch:-providers fetch printed nothing})"
fi

GENERATE_TARGET="$PWD"
if [ -n "$provider_entries" ]; then
  GENERATE_TARGET="$work/enola-generate.yaml"
  printf 'repos:\n  - %s\nproviders:\n%s' "$PWD" "$provider_entries" > "$GENERATE_TARGET"
fi

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
[ -n "$base_sha" ] || skip "no merge-base with origin/${base_branch}"

dirty=$(git status --porcelain -uno)
[ -z "$dirty" ] || notrun "working tree not clean, cannot generate the baseline in place"

head_ref=$(git symbolic-ref -q --short HEAD || git rev-parse HEAD)
current_ref="$head_ref"
git -c advice.detachedHead=false checkout -q "$base_sha" || notrun "could not check out the merge-base"
"$ENOLA" --generate "$GENERATE_TARGET" >/dev/null 2>&1 || notrun "baseline snapshot failed at ${base_sha:0:11}"
git checkout -q "$head_ref"
current_ref=""
"$ENOLA" --generate "$GENERATE_TARGET" >/dev/null 2>&1 || notrun "snapshot generation failed on this checkout"

set +e
verdict=$("$ENOLA" check -baseline previous "${WATCHED_FLAGS[@]}" -json "$PWD" 2>/dev/null)
check_exit=$?
set -e
[ "$check_exit" -eq 0 ] || notrun "verdict unavailable (check exited ${check_exit}: not comparable or gate error)"

command -v ruby >/dev/null 2>&1 || notrun "ruby is not on this agent, so the verdict could not be rendered"
summary=$(printf '%s' "$verdict" | ruby "$(dirname "$0")/enola-findings.rb")
status=$(printf '%s' "$summary" | head -n 1)
details=$(printf '%s' "$summary" | tail -n +3)

case "$status" in
  CLEAN)
    body="No new architectural findings against \`${base_sha:0:11}\`."
    ;;
  DECLARED)
    body="enola check: this change declares rules that existing code already breaks, and introduces no new findings on the code it touched (against \`${base_sha:0:11}\`). **Nothing is blocked.**

$details"
    ;;
  *)
    body="enola check found new architectural findings against \`${base_sha:0:11}\`. **Nothing is blocked** while the team gets used to the check.

$details"
    ;;
esac

# FILL IN 3: post one comment per pull request, edited in place. Without a
# forge credential, print it.
if [ -n "${PR_NUMBER:-}" ] && command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  marker="<!-- enola-check -->"
  existing=$(gh pr view "$PR_NUMBER" --json comments -q ".comments[] | select(.body | startswith(\"$marker\")) | .id" 2>/dev/null | head -n 1)
  if [ -n "$existing" ]; then
    gh api -X PATCH "repos/{owner}/{repo}/issues/comments/$existing" -f body="$marker
$body" >/dev/null && say "updated the existing enola comment"
  elif [ "$status" != "CLEAN" ]; then
    gh pr comment "$PR_NUMBER" --body "$marker
$body" >/dev/null && say "posted a new enola comment"
  fi
else
  printf '%s\n' "$body"
fi
