Enola.architecture "shop" do
  part :billing, files: ["app/billing/**", "app/models/invoice.rb"]

  law "billing keeps to its own tables" do
    billing.storage_must_stay_home
    why "a part that writes another part's table owns a bug it cannot see"
    mode :ratchet
  end
end
