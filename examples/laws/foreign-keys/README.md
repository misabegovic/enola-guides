# foreign keys

A foreign-key law reads the storage facts the schema yields: every table
carrying a tenant column must declare the foreign key to the tenant table. The
require form verdicts what a member fact carries, with a when antecedent
narrowing to the tables the law is about, so a table without the column is
never asked.

Declaration under `enola/constraints/`. Copy it, run `enola constraints lint .`,
then `enola --generate . && enola check .`.
