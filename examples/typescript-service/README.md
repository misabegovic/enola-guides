# A TypeScript service

A Express service in four layers, small enough to read in a minute, that
breaks its laws on purpose. [Guide 16](../../guides/16-typescript.md) walks
through it.

| Layer | Directory |
|---|---|
| presentation | `src/routes` |
| application | `src/services` |
| domain | `src/domain` |
| infrastructure | `src/db` |

The laws are in `enola/constraints/`: the `layered` recipe bound to the
four directories, the domain's law over `imports` (the recipe's own domain
rules read `depends_on`, which this language's extractor does not write),
and the `supply-chain` recipe. What breaks:

- `shop/presentation-reaches-application-only`: `src/routes/orders.ts` (`listRecent` reads the database).
- `the-domain-imports-no-storage`: `src/domain/pricing.ts` (imports the schema).
- `supply/dependencies-are-pinned`: `express: ^4.19.2` in `package.json`, a range with no lockfile.

```bash
cd examples/typescript-service
enola --generate .
enola constraints lint .
```

The breaches are findings in `.enola/insights.json` with source
`constraints`. `EXPECTED` lists the rule ids that must report one, and
`script/test-examples` fails when the set changes.
