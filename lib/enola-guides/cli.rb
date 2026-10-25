# frozen_string_literal: true

require "fileutils"
require "json"

module Enola
  module Guides
    # List, show and copy the enola guides, examples, laws, skills, hooks,
    # recipes and templates. The behaviour is specified in spec/cli/README.md
    # and shared by every package's implementation.
    module CLI
      KINDS = %w[guide example law skill hook recipe template].freeze
      BUNDLE = File.expand_path("../../bundle/bundle.json", __dir__)

      module_function

      def run(args, out, err)
        c = JSON.parse(File.read(BUNDLE, encoding: "utf-8"))
        fail = lambda do |code, message|
          err.write("enola-guides: #{message}\n")
          code
        end
        args = ["help"] if args.empty?
        command, id, given = args
        case command
        when "help", "-h", "--help"
          out.write(c["usage"])
          0
        when "version", "--version"
          out.write("enola-guides #{c["version"]}\n")
          0
        when "list"
          kind = ""
          unless id.nil?
            kind = id.end_with?("s") ? id[0...-1] : id
            return fail.call(2, "no kind #{id}; the kinds are #{KINDS.join(", ")}") unless KINDS.include?(kind)
          end
          c["items"].each { |it| out.write("#{it["id"]}\t#{it["title"]}\n") if kind.empty? || it["kind"] == kind }
          0
        when "show", "copy"
          return fail.call(2, "#{command} needs an item id; enola-guides list names them") if id.nil?

          found = c["items"].find { |it| it["id"] == id }
          return fail.call(2, "no item #{id}; enola-guides list names them") if found.nil?

          if command == "show"
            out.write(c["files"][found["show"]])
            return 0
          end
          dir = (given || found["default_dir"]).sub(%r{/+\z}, "")
          targets = found["files"].map { |f| (dir == ".") ? f["to"] : "#{dir}/#{f["to"]}" }
          existing = targets.find { |target| File.exist?(target) || File.symlink?(target) }
          return fail.call(1, "#{existing} exists; nothing was written") if existing

          found["files"].zip(targets).each do |f, target|
            FileUtils.mkdir_p(File.dirname(target))
            File.write(target, c["files"][f["path"]], mode: "w", encoding: "utf-8")
            File.chmod(f["mode"], target)
            out.write("wrote #{target}\n")
          end
          0
        else
          fail.call(2, "no command #{command}; enola-guides help lists them")
        end
      end
    end
  end
end
