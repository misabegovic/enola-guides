Enola.architecture "shop" do
  rails

  law "a concern never reaches the class that includes it" do
    concerns.must_not_reach_includers
    why "a mixin that knows its includer is half a class in hiding"
    mode :ratchet
  end
end
