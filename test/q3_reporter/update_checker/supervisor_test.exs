defmodule Q3Reporter.UpdateChecker.SupervisorTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.UpdateChecker

  import Support.LogHelpers

  test "should start Server for the given file path" do
    path = random_log_path()
    assert {:ok, pid} = UpdateChecker.Supervisor.start_child(path: path)
    assert Process.alive?(pid)
  end
end
