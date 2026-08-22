Enola.architecture "platform" do
  part :tables, files: "app/models/**", kind: :storage
  part :mutating_actions, service: :backend, files: "app/controllers/**", handles: [:post, :put, :patch, :delete]
  part :policies, service: :backend, files: "app/policies/**"
  part :api, service: :backend, files: "config/**", kind: :route

  law "one owner per table" do
    tables.must_be_unique_across by: :table
    why "a table two repositories both model is written by two codebases that never see each other's validations or callbacks"
    mode :advisory
  end

  law "a mutating action is authorized" do
    mutating_actions.must_reach :policies
    why "an action behind a POST, PUT, PATCH or DELETE route changes state, and the policy call is the one place the change is authorized"
    mode :advisory
  end

  law "every api route has a consumer" do
    api.must_have_consumer
    why "a route nobody calls is a surface nobody maintains"
    mode :advisory
  end
end
