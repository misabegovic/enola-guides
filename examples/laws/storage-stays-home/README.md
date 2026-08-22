# storage stays home

A part keeps to the tables it owns. Billing reaches its own invoices table and
the orders table the orders part owns; only the second is a breach, named with
the table, and the cut names the orders part's public member that already
reaches the model. The storage facts come from the Rails model extraction, so
the law reads what the graph measured rather than a list someone wrote.

Declaration: `enola/constraints/ownership.rb`.

Verify it on your own tree: copy `enola/` into the repository, run
`enola constraints lint .`, then `enola --generate . && enola check .`.
