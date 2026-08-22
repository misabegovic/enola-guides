Enola.architecture "shop" do
  part :service_objects, files: "app/services/**", kind: :symbol, where: { symbol_kind: "class" }, owns: :methods

  law "reach for an existing service" do
    service_objects.advises "look in app/services before writing a new one"
    why "duplication is a judgement no fact answers; advice where the edit happens is what can be offered honestly"
  end
end
