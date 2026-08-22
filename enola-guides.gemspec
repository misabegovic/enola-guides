# frozen_string_literal: true

require_relative "lib/enola-guides"

Gem::Specification.new do |spec|
  spec.name = "enola-guides"
  spec.version = Enola::Guides::VERSION
  spec.authors = ["Muhamed Isabegovic"]
  spec.email = ["m.isabegovic@hotmail.com"]

  spec.summary = "Guides, presets and onboarding material for enola, Rubyists first."
  spec.description = <<~TEXT
    Ready-to-use templates, presets, skills and instructions for adopting
    enola, the architecture-graph tool, with Ruby and Rails developers as the
    primary audience. Ships guides, worked examples, agent skills, templates and recipes.
  TEXT
  spec.homepage = "https://github.com/misabegovic/enola-guides"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = [
    "LICENSE",
    "README.md",
    "lib/enola-guides.rb",
    "CHANGELOG.md",
    *Dir.glob("guides/**/*"),
    *Dir.glob("examples/**/*"),
    *Dir.glob("templates/**/*"),
    *Dir.glob("recipes/**/*")
  ]
end
