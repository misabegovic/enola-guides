---
title: Public surface
enola_intent:
  governs:
    - app/controllers/api/**
  decisions:
    - every route under /api has at least one consumer in shop-ui
---

# Public surface

Fourteen routes under `/api`, all matched by a consumer in `shop-ui`
(coverage report, receipt shop@3f2a9c1). A route that stops matching is
a finding of `unused-routes`, judged in the ledger before any removal.
