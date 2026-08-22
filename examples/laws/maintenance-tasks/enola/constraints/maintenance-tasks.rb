Enola.architecture "app" do
  part :maintenance_tasks, files: "app/tasks/**", kind: :symbol, where: { symbol_kind: "class" }
  part :tasks, files: "app/tasks/**"
  part :controllers, files: "app/controllers/**"

  law "every maintenance task lives in the Maintenance namespace" do
    maintenance_tasks.names_must_match "Maintenance::*"
    why "the task runner resolves task constants from that namespace, so a task declared outside it never appears in the runner and cannot be run by anyone"
  end

  law "a maintenance task never invokes controller code" do
    tasks.must_not_call controllers
    why "a task runs from the runner or the console with no request around it, so controller code reached from one has nothing to read"
  end
end
