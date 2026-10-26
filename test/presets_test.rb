# frozen_string_literal: true

require "yaml"
require "rubygems"

root = File.expand_path("..", __dir__)
spec = Dir.chdir(root) { Gem::Specification.load(File.join(root, "enola-guides.gemspec")) }
shipped = spec.files
failures = []

files = Dir.glob(File.join(root, "presets", "base-types", "*.yml")).sort
failures << "presets/base-types holds no stack file" if files.empty?

files.each do |path|
  rel = path.sub("#{root}/", "")
  stack = File.basename(path, ".yml")
  problems = []
  problems << "is not among the gemspec's files" unless shipped.include?(rel)
  begin
    doc = YAML.safe_load(File.read(path))
  rescue StandardError => e
    failures << "#{rel}: does not parse (#{e.message.lines.first.strip})"
    next
  end
  unless doc.is_a?(Hash)
    failures << "#{rel}: is not a mapping"
    next
  end
  problems << "names stack #{doc["stack"].inspect}, not #{stack}" unless doc["stack"] == stack
  languages = doc["languages"]
  problems << "names no explain languages" unless languages.is_a?(Array) && !languages.empty? && languages.all? { |l| l.is_a?(String) && !l.empty? }
  lists = doc["lists"]
  if lists.is_a?(Array) && !lists.empty?
    lists.each_with_index do |list, i|
      unless list.is_a?(Hash)
        problems << "list #{i} is not a mapping"
        next
      end
      problems << "list #{i} has kind #{list["kind"].inspect}, not framework or library" unless %w[framework library].include?(list["kind"])
      problems << "list #{i} names no release" unless list["release"].is_a?(String) && !list["release"].strip.empty?
      held = %w[names roots modules].sum { |k| list[k].is_a?(Array) ? list[k].size : 0 }
      problems << "list #{i} holds no names, roots or modules" if held.zero?
      %w[names roots modules generated].each do |k|
        problems << "list #{i} #{k} is not a list of strings" if list.key?(k) && !(list[k].is_a?(Array) && list[k].all? { |n| n.is_a?(String) && !n.empty? })
      end
    end
  else
    problems << "holds no lists"
  end
  paths = doc["test_paths"]
  if paths
    problems << "test_paths names nothing to describe" unless paths.is_a?(Hash) && paths["describe"].is_a?(Array) && !paths["describe"].empty?
  end
  problems.each { |p| failures << "#{rel}: #{p}" }
end

if failures.empty?
  puts "presets: #{files.size} stack files parse, name their stack and the release of each list, and are shipped"
else
  warn failures.join("\n")
  exit 1
end
