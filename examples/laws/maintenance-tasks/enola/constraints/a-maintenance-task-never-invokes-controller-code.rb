Enola.architecture "app" do
  part :tasks, files: "app/tasks/**"
  part :controllers, files: "app/controllers/**"

  law "a maintenance task never invokes controller code" do
    tasks.must_not_call controllers
    why "a task runs from the runner or the console with no request around it, so controller code reached from one has nothing to read"
  end
end
