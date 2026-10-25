# A Python service

A FastAPI service in four layers, small enough to read in a minute, that
breaks its laws on purpose. [Guide 15](../../guides/15-python.md) walks
through it.

| Layer | Directory |
|---|---|
| presentation | `shop/api` |
| application | `shop/services` |
| domain | `shop/domain` |
| infrastructure | `shop/repositories` |

The laws are in `enola/constraints/`: the `layered` recipe bound to the
four directories, the domain's law over `imports` (the recipe's own domain
rules read `depends_on`, which this language's extractor does not write),
and the `supply-chain` recipe. What breaks:

- `shop/presentation-reaches-application-only`: `shop/api/orders.py` (`list_recent` reads a repository).
- `the-domain-imports-no-storage`: `shop/domain/pricing.py` (imports a repository).
- `supply/dependencies-are-pinned`: `fastapi>=0.110` in `pyproject.toml`, a range with no lockfile.

```bash
cd examples/python-service
enola --generate .
enola constraints lint .
```

The breaches are findings in `.enola/insights.json` with source
`constraints`. `EXPECTED` lists the rule ids that must report one, and
`script/test-examples` fails when the set changes.
