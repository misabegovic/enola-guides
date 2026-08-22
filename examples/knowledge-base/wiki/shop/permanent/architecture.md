---
title: Shop architecture
enola_intent:
  governs:
    - app/jobs/**
    - app/models/**
  decisions:
    - jobs enqueue, models decide; a job never calls back into a job
---

# Shop architecture

Orders are written by `OrderService` only; the two other writers the
graph reported in 2026-08 were folded into it. `Order` has 41 dependents
(receipt shop@3f2a9c1, fingerprint 8d1e…c40a).

The cycle `app/jobs -> app/models -> app/jobs` through the mailer path is
real and accepted in the ledger; it is cut when the mailer moves under
`app/services`.
