# Beyond one repository

A product is rarely one repository. enola indexes a cluster into one
union graph, links the seams between its members, and lets a law speak
about them.

## The cluster

For a folder whose subfolders are the repositories, one command writes the
configuration:

```bash
enola cluster init ~/src/shop      # writes ~/src/shop/cluster.yaml
enola --generate ~/src/shop/cluster.yaml
```

A folder that is not itself a git repository and holds two or more of
them is indexed as a cluster without being asked: `--generate` and the
`generate_snapshot` tool say they detected the repositories, write
`cluster.yaml` there, and link them (`--no-cluster` indexes the folder as
one repository instead). Paths in the file resolve relative to it. When
the members do not share a folder, or the cluster carries settings of its
own, write the file yourself:

```yaml
# enola-cluster.yaml
repos:
  - ../backend
  - ../mobile
  - ../admin
  - .
ignore:
  - "**/node_modules/**"
  - "**/vendor/**"
  - "**/dist/**"
output:
  dir: .enola-cluster
providers:
  - name: rubydex
  - name: prism
```

```bash
enola --generate enola-cluster.yaml
```

Every repository's facts land in one store, labelled by repository, and
every member receives the whole union. Two things to know: **regenerate
the whole cluster, never one member**, since a snapshot scoped to one
repository replaces the union rather than updating its slice; and name
an output directory distinct from `.enola/`. The directory is resolved
inside each member (`backend/.enola-cluster`, `mobile/.enola-cluster`),
so with the default name the union overwrites each member's own
snapshot and the baseline pinned beside it.

## What the linker draws

- **Cross-repository dependencies**: a client's HTTP calls matched to a
  server's routes, GraphQL operations matched to a schema, shared code by
  import, each as a `repo -> repo` edge carrying the endpoints or imports
  that justify it.
- **Route coverage**: every server route marked as matched or unmatched by
  the loaded clients, and every client call marked as matched or unmatched
  by the loaded servers. A client call names the server routes it resolved
  to (`matched_routes`) and the symbol whose body makes it (`caller`), so
  "who calls this endpoint" is a query, and `enola endpoint 'GET
  /api/v2/orders' enola-cluster.yaml` asks it directly. In a Next.js or
  React client a call the app never sends is marked so, and a route whose
  every call is like that carries `unreached_by_clients`: called in the
  source, never sent.
- **What it missed**: `enola coverage` reports per service how many
  outbound calls it detected, resolved and left unresolved, and
  `--unresolved` lists each unresolved call with its file and line. An
  unresolved call is a repository you have not loaded, a third-party
  endpoint, or a blind spot; a service whose calls all go through an
  in-house wrapper reads as isolated until the wrapper is declared.
- **Declared seams**: a repository may declare what it consumes from
  another on a knowledge page, and the intent check verdicts the
  declaration against what was measured, refusing when the counterparty is
  absent.

## Your own HTTP client

When every call goes through something like
`http.sendRequest(serviceName, path, options)`, nothing says HTTP and the
calls are invisible. Declare the client in the configuration and the
TypeScript extractor reads its calls as client routes like any other:

```yaml
clients:
  - name: sdk-http
    language: typescript
    receiver_types: [IHttpRequestService]
    methods:
      - name: sendRequest
        service_arg: 0
        path_arg: 1
        options_arg: 2
        verb_option: method
        default_verb: GET

service_aliases:
  resource-api: gateway
```

A declaration teaches the extractor to read a call site; it never draws an
edge. The linker still links only to a loaded repository that serves the
path, and `service_aliases` only chooses among repositories that already
do. `linking.match_literal_against_params: true` lets a server path
parameter absorb a literal client segment, under conditions strict enough
that two candidate patterns match nothing. `service_aliases` and the
linking setting change the snapshot ID, so a baseline taken before either
is not comparable.

## Laws across the seam

```ruby
Enola.architecture "platform" do
  part :tables, files: "app/models/**", kind: :storage
  part :api, service: :backend, files: "config/**", kind: :route

  law "one owner per table" do
    tables.must_be_unique_across by: :table
    why "two writers to one table disagree in the end"
    mode :advisory
  end

  law "every api route has a consumer" do
    api.must_have_consumer
    why "a route nobody calls is a surface nobody maintains"
    mode :advisory
  end
end
```

`service:` scopes a part to one repository by its label. Both laws refuse
by name in a single-repository snapshot (`no_counterparty`): a table
nobody else could share is not unique, and a route with no client in a
snapshot that loaded no clients is not unconsumed. `forbid` between parts
in two services works with nothing new once the linker has drawn the edge.

## Grading the cluster

```bash
enola baseline pin enola-cluster.yaml
# change a member
enola --generate enola-cluster.yaml && enola check enola-cluster.yaml
```

A cluster baseline is comparable only when every member ran with the
same enola, the same providers and the same ignore globs; a member that
dropped out makes the pair incomparable and `check` declines, which is
the right answer when a whole repository's verdicts went quiet at once.

## The history

Every snapshot appends a revision to the architecture history under
`~/.enola/graphs`, so `enola log`, `enola blame` and `enola diff` answer
when a dependency entered the architecture and what the cluster looked
like at a date, and a law with `since "2026-08-01"` grades only the
breaches introduced after it (git dates a breach the history is too young
to know, as [writing laws](04-writing-laws.md) says). `enola history push` shares the record
through a directory store and `enola history pull` imports what other
machines pushed, so a team's machines agree on the past; with
`history.shared_dir` in the configuration the store can be left off both,
and `blame` and `diff` answer over the shared record. `history gc
--keep-last N` prints what it would prune and prunes only with `--apply`.
`history.dir` moves the local record, for instance into a directory you
commit.
