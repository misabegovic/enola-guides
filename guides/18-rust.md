# A Rust service

What enola measures in a Rust crate, the laws a Rust team states, and two
places where v0.4.34 reads less than the code says. The worked example is
[`examples/rust-service`](../examples/rust-service): an Axum service in
four modules that breaks two laws on purpose, snapshotted by CI on every
change to this repository.

## Install

enola is not on crates.io. Install the binary once per machine:

```bash
curl -fsSL https://raw.githubusercontent.com/enola-labs/enola/main/install.sh | sh
enola --version
```

or `pip install enola-cli`, or a binary from the
[releases](https://github.com/enola-labs/enola/releases). Then the loop
from [start here](01-start-here.md).

## What enola measures

- **Crate and module directories are modules**; `use crate::store::…` is
  an `imports` edge, a call is a `calls` edge, a constructor call an
  `instantiates` edge, and a method in an `impl` a symbol with its
  receiver.
- **Routes** from Axum, `.nest("/p", other::router())` folded onto every
  route the nested router declares across files, and from
  `#[utoipa::path]` attributes, one route per declared verb.
- **Complexity and loops** per function.

## The laws

```yaml
use_recipe:
  - recipe: layered
    as: shop
    mode: ratchet
    bind:
      presentation: { match: ["src/web/**"] }
      application: { match: ["src/checkout/**"] }
      domain: { match: ["src/order/**"] }
      infrastructure: { match: ["src/store/**"] }
```

```text
Constraint shop/presentation-reaches-application-only violated: src/web.list_recent -> src/store.recent_orders via calls
```

**The recipe's two domain rules read `depends_on`, and Rust's extractor
writes `imports`,** so they are silent on a Rust crate. State the
domain's law over the `use` edge:

```yaml
components:
  - name: domain
    match: ["src/order/**"]
  - name: storage
    match: ["src/store/**"]
rules:
  - id: the-domain-imports-no-storage
    forbid: domain
    to: storage
    via: imports
    mode: ratchet
    because: "The domain is the part that outlives the database; a domain module that uses the store cannot be tested or reasoned about without it."
```

```text
Constraint the-domain-imports-no-storage violated: src/order -> crate::store::latest_total -> src/store via imports
```

## Where v0.4.34 reads less

- **A nested router built inline keeps its bare paths.**
  `.nest("/orders", Router::new().route("/recent", …))` records
  `GET /recent`, while the same router returned from a function,
  `.nest("/orders", orders())`, records `GET /orders/recent`. The example
  uses the function form.
- **A Cargo version with no operator counts as pinned.** `axum = "0.7"` is
  a caret range in Cargo, but without a `Cargo.lock` enola marks it
  `pinned: true`, so `supply-chain` does not report it; `"^0.7"`, `"~0.7"`
  and `">=0.7"` are read as ranges. Commit `Cargo.lock` for a binary
  crate, which pins every dependency whatever its constraint says. The
  example keeps the bare `"0.7"`, and its `EXPECTED` file records that
  the law is silent, so CI notices the day enola reads it.
