# A TypeScript or JavaScript service

What enola measures in a TypeScript or JavaScript codebase, the laws a
Node team states, and the two places the code's shape decides what a law
can see. The worked example is
[`examples/typescript-service`](../examples/typescript-service): an
Express service in four directories that breaks three laws on purpose,
snapshotted by CI on every change to this repository. Front ends have a
guide of their own for Ember ([guide 03](03-ember.md)); Angular, Vue,
Nuxt, Svelte and Next.js are read by the same extractor.

## Install

enola is not on npm. Install the binary once per machine:

```bash
curl -fsSL https://raw.githubusercontent.com/enola-labs/enola/main/install.sh | sh
enola --version
```

or `pip install enola-cli`, or a binary from the
[releases](https://github.com/enola-labs/enola/releases) for Linux, macOS
and Windows. Then the loop from [start here](01-start-here.md).

## What enola measures

- **Modules are directories**; `import … from` is an `imports` edge,
  tagged `internal` or `external`, and a call is a `calls` edge from the
  function that makes it.
- **Server routes** from Express (mounts composed across files), NestJS
  (controller prefixes composed), InversifyJS, and file-based routing in
  Next.js, Nuxt and SvelteKit.
- **Client calls** (`fetch`, axios, Angular's `HttpClient`, a wrapper
  another file exports) as client routes, which the cluster linker
  matches to a server's routes ([guide 08](08-beyond-one-repo.md)); an
  in-house client is declared under `clients:`.
- **Storage** from Prisma, TypeORM and Drizzle, each with its physical
  table name; a Drizzle query flags the function doing I/O.
- **GraphQL** operations and schema-first servers, **Kafka** and AsyncAPI
  contracts.

## The laws

Bind the `layered` recipe to your directories:

```yaml
use_recipe:
  - recipe: layered
    as: shop
    mode: ratchet
    bind:
      presentation: { match: ["src/routes/**"] }
      application: { match: ["src/services/**"] }
      domain: { match: ["src/domain/**"] }
      infrastructure: { match: ["src/db/**"] }
```

```text
Constraint shop/presentation-reaches-application-only violated: src/routes.listRecent -> src/db.recentOrders via calls
```

**A handler's calls belong to the handler only when it has a name.** An
inline arrow, `router.get("/recent", async (req, res) => …)`, puts its
calls on the file's `file_ref`, which the edge rules do not walk, so the
same breach written inline reports nothing. Name the handler (an
exported function the router registers) and the route also carries a
`handled_by` edge to it, which is what `enola endpoint` and the
route-scoped laws follow.

**The recipe's two domain rules read `depends_on`, and the TypeScript
extractor writes `imports`,** so they are silent on a TypeScript tree.
State the domain's law over imports:

```yaml
components:
  - name: domain
    match: ["src/domain/**"]
  - name: storage
    match: ["src/db/**"]
rules:
  - id: the-domain-imports-no-storage
    forbid: domain
    to: storage
    via: imports
    mode: ratchet
    because: "The domain is the part that outlives the database; a domain that imports a schema cannot be tested or reasoned about without it."
```

```text
Constraint the-domain-imports-no-storage violated: src/domain -> src/db/schema -> src/db/schema via imports
```

In v0.4.34 an Express `router.post("/", …)` mounted at `/orders`
produces no route, while `router.post("/create", …)` comes out as
`POST /orders/create`; a law or a coverage count over a router's root
path does not see it yet.

## Dependencies

Each direct dependency in `package.json` is a fact (`pkg:npm/express`),
pinned when its constraint is one exact version or `package-lock.json` or
`yarn.lock` resolves it. A `pnpm-lock.yaml` or `bun.lockb` beside the
manifest leaves `pinned` absent, since enola cannot read it, and a law
over `pinned` then says nothing rather than something false. The example
has no lockfile, so its `^4.19.2` is a breach of `supply-chain`:

```text
Constraint supply/dependencies-are-pinned violated: pkg:npm/express is measured in supply/unpinned-dependencies
```

## A provider of your own

eslint's findings join the graph through the reference provider in
enola's `examples/providers/js/eslint/`, a Node script under two hundred
lines that reads the results file your lint step writes; configure it as
[providers](07-providers.md) shows.
