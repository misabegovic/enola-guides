---
name: enola-laws
description: Use when asked to add, change or explain an architecture law, when a constraints finding names a rule, or when a new directory or convention should be declared
---

# enola-laws: laws are sentences with a reason

Laws live in `enola/constraints/`, in Ruby (parsed, never executed) or YAML.
A law is a part, a sentence, a reason and a mode. Before writing one, read
the existing declaration and `enola constraints lint .` so the new part
does not shadow an existing one.

Write the law in the language the repository's laws already use. In a
repository with no Ruby, write YAML: the first `.rb` file is a new Ruby
source to the extractor, the baseline has no Ruby facts, and the grade
turns partial, reporting breaches the law finds on existing code as
regressions.

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
6. Grade it against a baseline pinned before the law existed: `enola check .`
   (pin first with `enola baseline pin .` if `check` says there is none, then
   add the law). The breaches it finds on existing code are listed under
   "Newly declared": the law's starting point, not regressions. Read them
   before presenting it. With no baseline at all, `enola --generate .` then
   `enola constraints ledger .` lists each rule's breaches. A law that
   reports hundreds of existing breaches is fine under ratchet; a law that
   reports none may be selecting nothing, which
   `enola constraints explain <a file it should select>` settles.
7. `mode :advisory` reports at confidence 0.90, below the 1.00 a check
   fails at, so it never fails a build unless the check lowers its floor
   with `-min-confidence`. `mode :strict` fails on every breach, old or new;
   its only override is a signed entry in `.enola/suppressions.yaml`.

Reading a finding: the title names the rule, the member and the edge; the
first suggested action is the smallest cut the graph can see; "cannot be
evaluated" names the cause (no resolved ancestry, no runtime capture, no
counterparty, no compiled pages) and is never a pass.
