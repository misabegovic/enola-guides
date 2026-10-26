# frozen_string_literal: true

require_relative "lib/enola-guides"

Gem::Specification.new do |spec|
  spec.name = "enola-guides"
  spec.version = Enola::Guides::VERSION
  spec.authors = ["Muhamed Isabegovic"]
  spec.email = ["m.isabegovic@hotmail.com"]

  spec.summary = "Guides, worked examples, skills and templates for enola, tabula and taha."
  spec.description = <<~TEXT
    How to adopt enola, the tool that grades what a change did to a codebase's
    architecture: guides for Rails, Ember, Python, TypeScript, Go and Rust,
    worked examples, agent skills, CI templates and recipes, and the
    knowledge base built on it with tabula and taha.
  TEXT
  spec.homepage = "https://github.com/misabegovic/enola-guides"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.bindir = "exe"
  spec.executables = ["enola-guides"]

  spec.files = [
    "LICENSE",
    "NOTICE",
    "README.md",
    "lib/enola-guides.rb",
    "lib/enola-guides/cli.rb",
    "exe/enola-guides",
    "bundle/bundle.json",
    "CHANGELOG.md",
    *Dir.glob("guides/**/*"),
    *Dir.glob("examples/**/*"),
    *Dir.glob("templates/**/*"),
    *Dir.glob("recipes/**/*"),
    *Dir.glob("presets/**/*")
  ]
end
