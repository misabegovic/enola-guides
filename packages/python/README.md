# enola-guides

The guides, worked examples, laws, agent skills, hooks, recipes and CI
templates for [enola](https://github.com/enola-labs/enola), the tool that
grades what a change did to a codebase's architecture, in one command:

```bash
enola-guides list                  # every item; list laws, list skills, ...
enola-guides show guides/15-python # read a guide in the terminal
enola-guides copy laws/foreign-keys # writes enola/constraints/foreign-keys.yaml
enola-guides copy skills/enola     # writes .claude/skills/enola/SKILL.md
```

`copy` never overwrites a file; it names the first one that exists and
writes nothing. The same command ships on RubyGems, npm, PyPI, crates.io,
Go and Homebrew, with the same items and the same output:
[github.com/misabegovic/enola-guides](https://github.com/misabegovic/enola-guides).
