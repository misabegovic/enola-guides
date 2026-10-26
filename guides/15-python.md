# A Python service

What enola measures in a Python codebase, the laws a Python team states,
and the one place the shipped recipes need a hand. The worked example is
[`examples/python-service`](../examples/python-service): a FastAPI
service in four packages that breaks three laws on purpose, snapshotted
by CI on every change to this repository.

## Install

```bash
pipx install enola-cli       # or: uv tool install enola-cli; the command is enola
enola --version
```

`enola` was taken on PyPI, so the project is `enola-cli`; it is the same
binary as the install script and the GitHub release. Install it as a
tool, outside your project's environment; a bare `pip install` into the
system Python is refused on current Debian and Ubuntu. Pin it with
`enola-cli==0.4.35` when you need the release these guides were checked
against. Then the loop from [start here](01-start-here.md):

```bash
enola --explain .
enola --generate .
enola baseline pin .
```

## What enola measures

A tree is Python when it carries `pyproject.toml`, `setup.py`,
`requirements.txt`, `Pipfile` or one of the tool configs, at the root or
up to three levels down. Parsed with tree-sitter, never imported:

- **Modules are directories.** `shop/api` and `shop/domain` are modules;
  a law's `match:` globs select files, and the module edges between
  directories are what cycles and layers read.
- **Imports** are `imports` edges, each tagged `internal`, `external` or
  `stdlib`. Calls are `calls` edges from a function to what it calls,
  with the calls made inside a loop recorded on the caller for N+1
  hunting.
- **Routes** from FastAPI and Flask, at their composed runtime path:
  `include_router(r, prefix="/p")` folds `/p` onto every route `r`
  declares, across files.
- **Storage** from SQLAlchemy models, each with its table name.
- **Module-level code** (what runs at import time) is kept on a
  `file_ref`, an edge carrier rather than architecture.
- **Tests** (`tests/`, `test_*.py`, `conftest.py`) are reference-only.

What it leaves out on purpose: a route whose path is not a literal, a
mount with a computed prefix (its routes keep their bare paths), routes a
plugin registers at import time, and dispatch through `getattr`.

## The laws

The `layered` recipe names four roles. Bind them to your packages:

```yaml
use_recipe:
  - recipe: layered
    as: shop
    mode: ratchet
    bind:
      presentation: { match: ["shop/api/**"] }
      application: { match: ["shop/services/**"] }
      domain: { match: ["shop/domain/**"] }
      infrastructure: { match: ["shop/repositories/**"] }
```

Its three rules over `calls` hold on Python as written: the API reaches
the services only, services never call back into the API, repositories
never drive the services (`infrastructure-does-not-drive-the-domain`,
which despite its name forbids infrastructure calling the application
layer). In the example, a route that reads a
repository directly breaks the first one:

```text
Constraint shop/presentation-reaches-application-only violated: shop/api/orders.list_recent -> shop/repositories/orders.recent_orders via calls
```

**Its two domain rules read `depends_on`, and Python's extractor writes
`imports`,** so on a Python tree they are silent whatever the domain
imports. `via:` names one edge kind exactly ([writing laws](04-writing-laws.md#recipes)
says why). State the domain's law over the edge Python has:

```yaml
components:
  - name: domain
    match: ["shop/domain/**"]
  - name: storage
    match: ["shop/repositories/**"]
rules:
  - id: the-domain-imports-no-storage
    forbid: domain
    to: storage
    via: imports
    mode: ratchet
    because: "The domain is the part that outlives the database; a domain that imports a table cannot be tested or reasoned about without it."
```

```text
Constraint the-domain-imports-no-storage violated: module-edge: shop/domain -> shop/repositories -> shop/repositories via imports
```

`ports-and-adapters`, `clean` and `modular-monolith` are the other
arrangements enola ships; read which `via:` each rule names before
binding one, and run `enola constraints lint .` after a snapshot to see
what every part resolved to.

## Dependencies

Each direct dependency in `pyproject.toml` or `requirements.txt` is a
fact (`pkg:pypi/fastapi`), pinned when the constraint is `==` or a
lockfile resolves it. The `supply-chain` recipe is the law that every one
is pinned:

```yaml
use_recipe:
  - recipe: supply-chain
    as: supply
    mode: ratchet
    bind:
      unpinned-dependencies: {}
```

```text
Constraint supply/dependencies-are-pinned violated: pkg:pypi/fastapi is measured in supply/unpinned-dependencies
```

## Explainers worth gating on

- **`import-closure`** answers what `import shop` actually executes,
  including the `__init__.py` files no import names, and names the
  initialisations responsible for most of it: a barrel written for
  convenience that makes importing the public API load a scraping
  library. The barrels it names are gateable with
  `-fail-on import-closure`.
- **`query-loops`** reports a call that reaches storage inside a loop
  over input, the N+1 candidates.
- **`cycles`** between packages, which Python allows and an import at
  function scope hides from a reader.

For CI, [constraints in CI](05-constraints-in-ci.md) and enola-action
apply unchanged; the Rubydex step is for Ruby and can be dropped.

## Where next

- [Writing laws](04-writing-laws.md): every sentence, the modes, and the
  carve-outs.
- [Constraints in CI](05-constraints-in-ci.md): the check on every pull
  request.
- [Rolling out](19-rolling-out.md): adopting it on a codebase that already
  breaks the laws you want.
- [Reading a verdict](20-reading-a-verdict.md): every section of the
  output.
