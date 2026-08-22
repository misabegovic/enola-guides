Enola.architecture "shop" do
  part :service_objects, files: "app/services/**", kind: :symbol, where: { symbol_kind: "class" }, owns: :methods

  law "a service answers to call" do
    service_objects.must_define :call
    why "one door per service, so a caller never reads it to find the verb"
    mode :ratchet
  end
end
