# A starter law for a Rails application: `rails` binds jobs, models,
# controllers and policies to their app/ directories. In a repository with
# no Ruby, write laws in YAML instead (guide 04): a first .rb file is new
# Ruby to the extractor, and the next grade against an older baseline is
# partial.

Enola.architecture "app" do
  rails

  law "the request api stays in controllers" do
    models.must_not_call "params", receiver: :none
    why "params without a receiver is the controller's; a model reading it only works inside a request"
    mode :ratchet
  end
end
