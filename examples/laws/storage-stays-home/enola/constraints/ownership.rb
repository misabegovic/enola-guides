Enola.architecture "shop" do
  part :billing, files: ["app/billing/**", "app/models/invoice.rb"]
  part :orders, files: ["app/orders/**", "app/models/order.rb"], public: ["app/orders/public/**"]

  law "billing keeps to its own tables" do
    billing.storage_must_stay_home
    why "a part that writes another part's table owns a bug it cannot see"
  end
end
