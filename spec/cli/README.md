# The enola-guides command

Five implementations, one behaviour: Go (`cmd/enola-guides`, also what
Homebrew builds), Rust (`packages/rust`), Node (`packages/npm`), Python
(`packages/python`) and Ruby (`exe/enola-guides`). Each reads the same
`bundle/bundle.json`, and `script/test-clis` runs every one through
[`cases`](cases) and compares stdout, stderr, the exit code and the files
written with the goldens under [`golden/`](golden), byte for byte.

## Commands

| Command | Does | Exit |
|---|---|---|
| `enola-guides`, `help`, `-h`, `--help` | prints the usage | 0 |
| `version`, `--version` | prints `enola-guides <version>` | 0 |
| `list [kind]` | prints `<id>\t<title>` per item, in bundle order, of one kind when named (`guide`, `example`, `law`, `skill`, `hook`, `recipe`, `template`, singular or plural) | 0, or 2 for an unknown kind |
| `show <id>` | prints the item's `show` file exactly | 0, or 2 for an unknown or missing id |
| `copy <id> [dir]` | writes each of the item's files at `<dir>/<to>` with its mode, creating directories, and prints `wrote <path>` per file; `dir` defaults to the item's `default_dir` | 0; 1 when any target exists, naming the first and writing nothing; 2 for an unknown or missing id |

Anything else is exit 2. Every error is one line on stderr starting
`enola-guides: `. A path is printed as `<dir>/<to>` with `dir` as given,
less a trailing `/`, and as `<to>` alone when `dir` is `.`.

## Messages

```text
enola-guides: no kind <kind>; the kinds are guide, example, law, skill, hook, recipe, template
enola-guides: no item <id>; enola-guides list names them
enola-guides: <command> needs an item id; enola-guides list names them
enola-guides: <path> exists; nothing was written
enola-guides: no command <command>; enola-guides help lists them
```

The usage is the bundle's `usage`, written by `script/bundle` from
[`usage.txt`](usage.txt) with `{version}` replaced.
