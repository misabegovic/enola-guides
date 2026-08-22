Enola.architecture "shop" do
  part :mutating_actions, files: "app/controllers/**", handles: [:post, :put, :patch, :delete]
  part :policies, files: "app/policies/**"

  law "a mutating action is authorized" do
    mutating_actions.must_reach :policies
    why "every write passes a policy before it touches a record"
  end
end
