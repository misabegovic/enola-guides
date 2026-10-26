# Base-type presets

`base-types/` holds one YAML file per stack, and they are the lists
`tabula explain` splits a repository's base types with: the names a stack's
framework and language own, the release each list was read from, and the
stack's test paths. `tabula explain` is the only reader.

They are not the law presets the guides describe (the `rails` preset of the
Ruby declaration surface declares an application's parts); the folder is
called `base-types` so the two are not mistaken for each other.

Each file names its `stack`, the explain `languages` it serves, its `lists`
(each a `framework` or a `library` list with the `release` it was read from,
and `names`, `roots` or `modules`), and its `test_paths`. A stack that was
measured and held under its bar has no file. A change to a list is a commit
here, a refreshed copy in tabula's `presets/base-types/` with its provenance
note, and a tabula commit.

tabula carries a byte-identical copy of these files and reads this directory
instead when `ENOLA_GUIDES_DIR` names the root of an enola-guides checkout or
installed gem. `env -u GEM_HOME -u GEM_PATH ruby test/presets_test.rb` checks
that every file parses, names its stack and its releases, and is shipped.
