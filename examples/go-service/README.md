# A Go service

A chi service in four layers, small enough to read in a minute, that
breaks its laws on purpose. [Guide 17](../../guides/17-go.md) walks
through it.

| Layer | Directory |
|---|---|
| presentation | `internal/web` |
| application | `internal/checkout` |
| domain | `internal/order` |
| infrastructure | `internal/store` |

The laws are in `enola/constraints/`: the `layered` recipe bound to the
four directories, the domain's law over `imports` (the recipe's own domain
rules read `depends_on`, which this language's extractor does not write),
and the `supply-chain` recipe. What breaks:

- `shop/presentation-reaches-application-only`: `internal/web/routes.go` (`listRecent` reads the store).
- `the-domain-imports-no-storage`: `internal/order/pricing.go` (imports the store).

`supply-chain` is bound and holds: a `require` in `go.mod` names an exact version.

```bash
cd examples/go-service
enola --generate .
enola constraints lint .
```

The breaches are findings in `.enola/insights.json` with source
`constraints`. `EXPECTED` lists the rule ids that must report one, and
`script/test-examples` fails when the set changes.
