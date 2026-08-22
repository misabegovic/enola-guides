Enola.architecture "shop" do
  part :billing, files: "app/billing/**"

  law "billing is governed" do
    billing.must_be_governed
    why "code under a decision needs the page that decided it"
  end
end
