Enola.architecture "platform" do
  part :api, service: :backend, files: "config/**", kind: :route

  law "every api route has a consumer" do
    api.must_have_consumer
    why "a route nobody calls is a surface nobody maintains"
    mode :advisory
  end
end
