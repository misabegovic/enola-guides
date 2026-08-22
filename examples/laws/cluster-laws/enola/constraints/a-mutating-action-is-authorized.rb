Enola.architecture "platform" do
  part :mutating_actions, service: :backend, files: "app/controllers/**", handles: [:post, :put, :patch, :delete]
  part :policies, service: :backend, files: "app/policies/**"

  law "a mutating action is authorized" do
    mutating_actions.must_reach :policies
    why "an action behind a POST, PUT, PATCH or DELETE route changes state, and the policy call is the one place the change is authorized"
    mode :advisory
  end
end
