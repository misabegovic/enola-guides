---
title: Public surface
enola_intent:
  governs:
    - app/controllers/api/**
  decisions:
    - every route under /api has at least one consumer in ember-app
---

# Public surface

Fourteen routes under `/api`, all matched by a consumer in `ember-app`
(coverage report; receipt rails-shop@3f2a9c1, fingerprint 8d1e…c40a). A route that stops matching is
a finding of `unused-routes`, judged in the ledger before any removal.
