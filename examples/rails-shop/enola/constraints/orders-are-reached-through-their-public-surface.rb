Enola.architecture "shop" do
  part :orders, files: ["app/orders/**", "app/models/order.rb"], public: ["app/orders/public/**"]

  law "orders are reached through their public surface" do
    orders.stays_inside
    why "the public directory is the contract; everything else may change"
    mode :ratchet
  end
end
