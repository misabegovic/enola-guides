# A starter law for a Rails application: `rails` binds jobs, models,
# controllers and policies to their app/ directories. In a repository with
# no Ruby, write laws in YAML instead (guide 04): a first .rb file is new
# Ruby to the extractor, and the next grade against an older baseline is
# partial.

Enola.architecture "app" do
  rails

  law "policies only answer" do
    policies.must_not_call jobs
    why "authorization is asked many times per request and sometimes speculatively"
    mode :ratchet
  end
end
