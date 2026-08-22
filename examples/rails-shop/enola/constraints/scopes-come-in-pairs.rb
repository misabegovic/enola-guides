Enola.architecture "shop" do
  part :records, ancestor: "ApplicationRecord"

  law "scopes come in pairs" do
    records.names_must_match "with_*", requires: "without_*"
    why "every with_ scope has a without_ sibling, or the query reads half a thought"
    mode :advisory
  end
end
