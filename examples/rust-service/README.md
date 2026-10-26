# A Rust service

An Axum service in four layers, small enough to read in a minute, that
breaks its laws on purpose. [Guide 18](../../guides/18-rust.md) walks
through it.

| Layer | Directory |
|---|---|
| presentation | `src/web` |
| application | `src/checkout` |
| domain | `src/order` |
| infrastructure | `src/store` |

The laws are in `enola/constraints/`: the `layered` recipe bound to the
four directories, the domain's law over `imports` (the recipe's own domain
rules read `depends_on`, which this language's extractor does not write),
and the `supply-chain` recipe. What breaks:

- `shop/presentation-reaches-application-only`: `src/web/mod.rs` (`list_recent` reads the store).
- `the-domain-imports-no-storage`: `src/order/pricing.rs` (uses the store).

`supply-chain` is bound and, in enola v0.4.35, silent about `axum = "0.7"`, which Cargo reads as a caret range; [the guide](../../guides/18-rust.md#where-v0435-reads-less) says why, and `EXPECTED` records it so CI notices when enola reads it.

```bash
cd examples/rust-service
enola --generate .
enola constraints lint .
```

The breaches are findings in `.enola/insights.json` with source
`constraints`. `EXPECTED` lists the rule ids that must report one, and
`script/test-examples` fails when the set changes.
