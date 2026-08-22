Enola.architecture "shop" do
  part :api, files: "config/**", kind: :route

  law "the public api stays small" do
    api.at_most 120
    growth 5
    why "a route is a promise; the count may grow, but only on purpose"
    mode :ratchet
  end
end
