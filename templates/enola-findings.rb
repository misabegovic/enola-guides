# frozen_string_literal: true

require "json"

LISTED = 10
EXAMPLES_PER_RULE = 3
RULES_LISTED = 12

def rule_of(finding)
  finding["title"][/constraint (\S+) violated/i, 1] || finding["source"] || "?"
end

def constraint?(finding)
  finding["source"] == "constraints"
end

def breach_of(finding)
  finding["title"].sub(/\A.*violated: /, "")
end

def render_flat(findings)
  findings.first(LISTED).each do |finding|
    puts "- **#{finding["source"] || "?"}** — #{finding["title"]}"
    fact = finding.dig("evidence", 0, "fact")
    puts "  `#{fact}`" if fact
  end
  puts "- _...and #{findings.size - LISTED} more_" if findings.size > LISTED
end

def render_grouped(findings, phrase)
  groups = findings.group_by { |finding| rule_of(finding) }
  ordered = groups.sort_by { |rule, breaches| [constraint?(breaches.first) ? 0 : 1, -breaches.size, rule] }
  ordered.first(RULES_LISTED).each do |rule, breaches|
    puts "- **#{rule}** — #{breaches.size} #{phrase.call(breaches.size, constraint?(breaches.first), strict?(breaches.first))}"
    breaches.first(EXAMPLES_PER_RULE).each do |finding|
      puts "  - #{breach_of(finding)}"
    end
    puts "  - _...and #{breaches.size - EXAMPLES_PER_RULE} more_" if breaches.size > EXAMPLES_PER_RULE
  end
  puts "- _...and #{ordered.size - RULES_LISTED} more rules_" if ordered.size > RULES_LISTED
end

def strict?(finding)
  finding["title"].start_with?("Strict constraint")
end

NEW_PHRASE = lambda do |count, constraint, strict = false|
  if strict
    (count == 1) ? "place breaks it; a strict law fails on every breach, new or not" : "places break it; a strict law fails on every breach, new or not"
  elsif constraint
    (count == 1) ? "new place breaks it" : "new places break it"
  else
    (count == 1) ? "new finding" : "new findings"
  end
end
EXISTING_PHRASE = ->(count, _constraint, _strict = false) { (count == 1) ? "existing place already breaks it" : "existing places already break it" }

verdict = JSON.parse($stdin.read)
policy = verdict["policy"] || {}
gated = policy["fail_explainers"] || []
floor = policy["min_confidence"] || 1.0
warn_only = policy["warn_only"]
watched = verdict["failures"] || []
# Findings that fail nothing: a watched explainer's below the confidence
# floor (an advisory law, an estimate), and every other explainer's.
below, other = (verdict["advisories"] || []).partition { |finding| gated.include?(finding["source"]) }
declared = verdict["declared"] || []

excluded = verdict.dig("intersection_grading", "excluded") || []

def render_partial(excluded)
  puts "**Partial verdict** — graded only the facts both snapshots share. A regression among these producers' facts is not reported:"
  puts
  excluded.each do |producer|
    puts "- **#{producer["name"]}** (#{producer["kind"]}), missing from the #{producer["lacked_by"]} snapshot"
  end
end

if watched.empty? && below.empty? && other.empty? && declared.empty?
  if excluded.empty?
    puts "CLEAN"
  else
    puts "PARTIAL"
    puts
    render_partial(excluded)
  end
  exit 0
end

puts((watched.empty? && below.empty? && other.empty?) ? "DECLARED" : "FINDINGS")
puts

if excluded.any?
  render_partial(excluded)
  puts
end

if watched.any?
  verdict_line = warn_only ? "They would fail the check once it enforces; nothing blocks today." : "They fail the check."
  puts "**Watched** — new findings from the explainers this check gates on (#{gated.join(", ")}), at confidence #{format("%.2f", floor)} or above. #{verdict_line}"
  puts
  render_grouped(watched, NEW_PHRASE)
end

if below.any?
  puts if watched.any?
  puts "**Below the floor** — new findings from the same explainers under confidence #{format("%.2f", floor)}: an advisory law (0.90) or a finding the explainer estimates. Reported, never failing."
  puts
  render_grouped(below, NEW_PHRASE)
end

if declared.any?
  puts if watched.any? || below.any?
  puts "**Declared** — rules this change declares, re-forms or un-exempts, reported on code the change did not touch. The baseline each rule starts from, not new findings."
  puts
  render_grouped(declared, EXISTING_PHRASE)
end

if other.any?
  puts if watched.any? || below.any? || declared.any?
  puts "**Also noticed** — outside the watched explainers."
  puts
  render_flat(other)
end
