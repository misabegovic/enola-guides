# Releasing

One version, every package. `VERSION` holds it; `script/sync-version` writes
it into the gem, npm, PyPI and crate manifests, and CI fails when one
disagrees.

## A release

1. Set `VERSION`, run `script/sync-version` and `script/bundle`, and add the
   version's entry to `CHANGELOG.md` (`## X.Y.Z (YYYY-MM-DD)`; the GitHub
   release notes are that entry).
2. Merge through a pull request; CI builds every package, installs each one
   and runs the shared cases against it.
3. Tag the merge commit and push the tag:

   ```bash
   git tag vX.Y.Z && git push origin vX.Y.Z
   ```

The `Release` workflow then checks the tag against `VERSION`, builds every
package once, and publishes them: RubyGems, npm, PyPI and crates.io through
trusted publishing, a GitHub release carrying the Go binaries and
`SHA256SUMS`, the Go module proxy asked for the tag, and the formula pushed
to the Homebrew tap. Each job is separate, so one registry failing leaves
the others published and the failed job can be re-run alone. A job whose
registry has the version already skips it with a notice instead of
failing, so a version first published by hand, or a re-run after a
partial failure, ends green.

## One-time setup

Each registry trusts this repository's `release.yml` and nothing else. No
token is stored except the tap's.

- **RubyGems**: the trusted publisher for `enola-guides` (owner
  `misabegovic`, repository `enola-guides`, workflow `release.yml`, no
  environment) is already in place.
- **npm**: trusted publishing can only be added to a package that exists,
  so publish the first version by hand from a build
  (`script/build-packages`, then `npm publish dist/enola-guides-X.Y.Z.tgz
  --access public`), then add a trusted publisher on npmjs.com under the
  package's settings: GitHub Actions, `misabegovic/enola-guides`, workflow
  `release.yml`.
- **PyPI**: add a pending trusted publisher at
  pypi.org/manage/account/publishing for project `enola-guides`: owner
  `misabegovic`, repository `enola-guides`, workflow `release.yml`,
  environment `pypi`. Create the `pypi` environment in this repository's
  settings.
- **crates.io**: publish the first version by hand (`cargo publish
  --manifest-path packages/rust/Cargo.toml --allow-dirty` after copying
  `bundle/bundle.json`, `LICENSE` and `NOTICE` into `packages/rust/`), then
  add a trusted publisher under the crate's settings: repository
  `misabegovic/enola-guides`, workflow `release.yml`.
- **Homebrew**: create the repository `misabegovic/homebrew-tap` with a
  `Formula/` directory, and store a fine-grained token that can write to
  it, and nothing else, as this repository's `HOMEBREW_TAP_TOKEN` secret.
  Users then run `brew install misabegovic/tap/enola-guides`.
- **Go**: nothing. The module is this repository; the proxy serves any tag.
