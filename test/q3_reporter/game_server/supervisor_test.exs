defmodule Q3Reporter.GameServer.SupervisorTest do
  use ExUnit.Case

  alias Q3Reporter.GameServer.Supervisor

  import Support.LogHelpers

  setup context do
    path = create_log()

    on_exit(fn ->
      delete_log(path)
    end)

    Map.put(context, :path, path)
  end

  test "should start Server for the given file path", %{path: path} do
    assert {:ok, file} = Supervisor.start_child(path: path)
    assert Process.alive?(file)
  end
end
