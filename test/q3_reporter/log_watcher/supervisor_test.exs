defmodule Q3Reporter.LogWatcher.SupervisorTest do
  use ExUnit.Case

  alias Q3Reporter.LogWatcher

  import Support.LogHelpers

  setup context do
    path = create_log()

    on_exit(fn ->
      delete_log(path)
    end)

    Map.put(context, :path, path)
  end

  test "should start Server for the given file path", %{path: path} do
    assert {:ok, file} = LogWatcher.Supervisor.start_child(path)
    assert Process.alive?(file)
  end
end
