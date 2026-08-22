# resolved ancestry

Ancestry a provider resolved, and a component selected by it. `superclass:`
reads the parent as the source spelled it, one level, so a class written as
`Base` inside `module Billing` is never seen as an ApplicationRecord. The
rubydex provider emits each class's linearised ancestor chain as resolved
implements edges, and `ancestor: ApplicationRecord` selects the grandchild
through them, so a rule over the hierarchy judges the hierarchy. Without the
provider the selector is refused with a named cause rather than holding
vacuously, which is what the channels lacking the provider score.

Declaration: `enola/constraints/records.yaml`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
