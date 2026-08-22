# Beyond one repository

A product is rarely one repository. enola indexes a cluster into one
union graph, links the seams between its members, and lets a law speak
about them.

## The cluster

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
    expected_version: "0.4.0"
```

```bash
enola --generate enola-cluster.yaml
```

Every repository's facts land in one store, labelled by repository. Two
things to know: **regenerate the whole cluster, never one member**, since
a snapshot scoped to one repository replaces the union rather than
updating its slice; and keep the output directory distinct from each
member's own `.enola/`, because the output path is resolved per member
as the engine walks them.

## What the linker draws

- **Cross-repository dependencies**: a client's HTTP calls matched to a
  server's routes, GraphQL operations matched to a schema, shared code by
  import, each as a `repo -> repo` edge carrying the endpoints or imports
  that justify it.
- **Route coverage**: every server route marked as matched or unmatched by
  the loaded clients, and every client call marked as matched or unmatched
  by the loaded servers. `enola coverage` lists both.
- **Declared seams**: a repository may declare what it consumes from
  another on a knowledge page, and the intent check verdicts the
  declaration against what was measured, refusing when the counterparty is
  absent.

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
breaches introduced after it. `enola history push` shares the record
through a directory store so a team's machines agree on the past.
