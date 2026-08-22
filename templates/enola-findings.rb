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
    puts "- **#{rule}** — #{breaches.size} #{phrase.call(breaches.size, constraint?(breaches.first))}"
    breaches.first(EXAMPLES_PER_RULE).each do |finding|
      puts "  - #{breach_of(finding)}"
    end
    puts "  - _...and #{breaches.size - EXAMPLES_PER_RULE} more_" if breaches.size > EXAMPLES_PER_RULE
  end
  puts "- _...and #{ordered.size - RULES_LISTED} more rules_" if ordered.size > RULES_LISTED
end

NEW_PHRASE = lambda do |count, constraint|
  if constraint
    (count == 1) ? "new place breaks it" : "new places break it"
  else
    (count == 1) ? "new finding" : "new findings"
  end
end
EXISTING_PHRASE = ->(count, _constraint) { (count == 1) ? "existing place already breaks it" : "existing places already break it" }

verdict = JSON.parse($stdin.read)
watched = verdict["failures"] || []
other = verdict["advisories"] || []
declared = verdict["declared"] || []

if watched.empty? && other.empty? && declared.empty?
  puts "CLEAN"
  exit 0
end

puts((watched.empty? && other.empty?) ? "DECLARED" : "FINDINGS")
puts

if watched.any?
  puts "**Watched** — the explainers this check tracks, on code this change touched. Nothing blocks today."
  puts
  render_grouped(watched, NEW_PHRASE)
end

if declared.any?
  puts if watched.any?
  puts "**Declared** — rules this change declares, re-forms or un-exempts, reported on code the change did not touch. The baseline each rule starts from, not new findings."
  puts
  render_grouped(declared, EXISTING_PHRASE)
end

if other.any?
  puts if watched.any? || declared.any?
  puts "**Also noticed** — outside the watched explainers."
  puts
  render_flat(other)
end
