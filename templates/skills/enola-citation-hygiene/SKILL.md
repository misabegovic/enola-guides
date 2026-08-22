---
name: enola-citation-hygiene
description: Use during grooming; gives every receipt citation in prose a verdict against the committed receipts and sweeps the finding ledger for judgments the code has moved past
---

# enola-citation-hygiene: every citation gets a verdict

1. `kb enola citations`: each receipt citation in prose is verified, stale
   (the digest moved) or malformed.
2. Stale: re-read the cited page against the current facts and amend the
   sentence; never update the citation alone, the sentence is what may be
   wrong.
3. Malformed: fix the citation to the recorded form.
4. `kb enola findings --all`: for each accepted finding in the ledger,
   confirm its evidence still exists in the graph. Evidence gone means
   the code moved past the judgment; re-read the page that landed it and
   record the new state.
5. Rejected and noise verdicts stay; they keep the finding hidden on
   purpose.

A citation is a promise that a number was read, not remembered; this
skill keeps the promise current.
