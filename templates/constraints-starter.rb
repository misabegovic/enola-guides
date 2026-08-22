# A first declaration for a Rails application. Copy to enola/constraints/
# and keep the laws you agree with; every law carries its reason, and
# ratchet mode fails only what a change adds.
Enola.architecture "app" do
  rails

  law "background jobs never invoke controller code" do
    jobs.must_not_call controllers
    why "rendering from a job goes through ApplicationController.renderer"
    mode :ratchet
  end

  law "models do not reach controllers" do
    models.must_not_call controllers
    why "a model that knows the request cannot be used off the request"
    mode :ratchet
  end

  law "policies only answer" do
    policies.must_not_call jobs
    why "authorization is asked many times per request and sometimes speculatively"
    mode :ratchet
  end

  law "the request api stays in controllers" do
    models.must_not_call "params", receiver: :none
    why "params without a receiver is the controller's; a model reading it only works inside a request"
    mode :ratchet
  end
end
