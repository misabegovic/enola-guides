---
name: enola-drift
description: Use on a schedule or before publishing; regenerates the cluster, compares committed receipts to live ones, and names the members whose pages want a re-read
---

# enola-drift: which members moved

1. `kb enola generate` to regenerate the cluster and record receipts.
2. `kb enola diff`: each member whose fingerprint or commit moved is
   listed. Those are the members whose pages may describe a structure that
   no longer exists.
3. `kb enola coverage` (`coverage_report`): which cross-repository edges
   resolved and which did not. An edge that stopped resolving is a
   consumer a page may still claim.
4. For each moved member: `kb enola govern <member path>` and re-read the
   pages returned against the new facts. Amend what changed; leave what
   did not.
5. Commit the receipts with the page amendments, in one commit.

This is a comparison of receipts, not of findings. Findings between two
runs are the grade's job (`enola-grade-before-push`).
