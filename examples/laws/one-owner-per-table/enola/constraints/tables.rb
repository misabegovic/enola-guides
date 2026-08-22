Enola.architecture "shop" do
  part :tables, files: "app/models/**", kind: :storage

  law "one owner per table" do
    tables.must_be_unique_across by: :table
    why "two writers to one table disagree in the end"
  end
end
