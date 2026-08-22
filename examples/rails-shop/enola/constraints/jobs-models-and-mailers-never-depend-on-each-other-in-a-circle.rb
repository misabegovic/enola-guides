Enola.architecture "shop" do
  rails

  law "jobs, models and mailers never depend on each other in a circle" do
    jobs.must_not_cycle_with :models, :mailers
    why "parts that reach each other in a circle cannot be taken apart"
    mode :advisory
  end
end
