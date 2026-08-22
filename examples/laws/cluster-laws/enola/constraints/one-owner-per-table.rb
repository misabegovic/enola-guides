Enola.architecture "platform" do
  part :tables, files: "app/models/**", kind: :storage

  law "one owner per table" do
    tables.must_be_unique_across by: :table
    why "a table two repositories both model is written by two codebases that never see each other's validations or callbacks"
    mode :advisory
  end
end
