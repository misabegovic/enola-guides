Enola.architecture "app" do
  part :maintenance_tasks, files: "app/tasks/**", kind: :symbol, where: { symbol_kind: "class" }

  law "every maintenance task lives in the Maintenance namespace" do
    maintenance_tasks.names_must_match "Maintenance::*"
    why "the task runner resolves task constants from that namespace, so a task declared outside it never appears in the runner and cannot be run by anyone"
  end
end
