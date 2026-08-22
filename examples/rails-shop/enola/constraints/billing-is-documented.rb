Enola.architecture "shop" do
  part :billing, files: ["app/billing/**", "app/models/invoice.rb"]

  law "billing is documented" do
    billing.must_be_governed
    since "2026-09-01"
    why "code under a decision needs the page that decided it"
    mode :ratchet
  end
end
