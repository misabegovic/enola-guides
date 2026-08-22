# maintenance tasks

Two laws for a maintenance-tasks directory: a naming convention the runner
depends on, and a boundary against controller code that has no request to
read. Both were mined from a codebase where they already held, which is the
right moment to declare a law.

Declaration under `enola/constraints/`. Copy it, run `enola constraints lint .`,
then `enola --generate . && enola check .`.
