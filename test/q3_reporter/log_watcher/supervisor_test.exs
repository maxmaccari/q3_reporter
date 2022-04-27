defmodule Q3Reporter.LogWatcher.SupervisorTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.LogWatcher

  import Support.LogHelpers

  describe "LogWatcher.Supervisor" do
    setup context do
      path = create_log()

      on_exit(fn ->
        delete_log(path)
      end)

      Map.put(context, :path, path)
    end

    test "start_child/1 start Server with the file path", %{path: path} do
      assert {:ok, file} = LogWatcher.Supervisor.start_child(path)
      assert Process.alive?(file)
    end
  end
end
