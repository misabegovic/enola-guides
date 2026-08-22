---
name: enola-laws
description: Use when asked to add, change or explain an architecture law, when a constraints finding names a rule, or when a new directory or convention should be declared
---

# enola-laws: laws are sentences with a reason

Laws live in `enola/constraints/`, in Ruby (parsed, never executed) or YAML.
A law is a part, a sentence, a reason and a mode. Before writing one, read
the existing declaration and `enola constraints lint .` so the new part
does not shadow an existing one.

Writing a law:

1. Name the part by what it is (`part :billing, files: "app/billing/**"`),
   or by what its facts carry (`kind: :symbol, where: { symbol_kind: "getter" }`,
   `ancestor: "ApplicationRecord"`, `handles: [:post, :put, :patch, :delete]`).
2. Pick the sentence from the vocabulary (`must_not_call`, `must_not_reach`,
   `is_reached_only_by`, `stays_inside`, `must_define`, `names_must_match`,
   `must_not_cycle_with`, `must_not_reach_includers`, `storage_must_stay_home`,
   `must_keep_budget`, `must_have_consumer`, `must_be_unique_across`,
   `must_be_governed`, `at_most`, `must_carry`, `advises`).
3. Write `why` in one sentence a reviewer outside the team understands.
4. Start in `mode :ratchet`. `strict` is a team decision, never a default.
5. Run `enola constraints lint .`; every part must resolve to something and
   every rule must be in force, or the lint says which role is unbound.
6. Run `enola --generate . && enola check .` and read the verdicts the new
   law produces before presenting it. A law that reports hundreds of
   existing breaches is fine under ratchet; a law that reports none may be
   selecting nothing, which `constraints explain <file>` settles.

Reading a finding: the title names the rule, the member and the edge; the
first suggested action is the smallest cut the graph can see; "cannot be
evaluated" names the cause (no resolved ancestry, no runtime capture, no
counterparty, no compiled pages) and is never a pass.
