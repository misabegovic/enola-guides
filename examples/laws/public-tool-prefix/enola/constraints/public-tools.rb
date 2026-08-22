Enola.architecture "app" do
  part :public_tools, files: "app/public_tools/**", kind: :symbol, where: { symbol_kind: "class" }

  law "public tools carry the Public prefix" do
    public_tools.names_must_match "Public*"
    why "an externally exposed tool class is greppable by its prefix and cannot shadow an internal one"
  end
end
