Enola.architecture "shop" do
  rails

  law "frames keep their query budget" do
    controllers.must_keep_budget metric: :queries, max: 20
    why "a frame past twenty queries is a page that will not scale; refused by name until a capture exists"
    mode :advisory
  end
end
