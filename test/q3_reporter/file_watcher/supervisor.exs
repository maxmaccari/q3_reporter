defmodule Q3Reporter.FileWatcher.SupervisorTest do
  use ExUnit.Case

  alias Q3Reporter.FileWatcher

  import Support.FileWatchHelpers

  describe "FileWatcher.Supervisor" do
    setup context do
      create_example()

      FileWatcher.start_link()

      on_exit(fn ->
        delete_example()
      end)

      Map.put(context, :path, example_path())
    end

    test "start_child/1 start Server with the file path", %{path: path} do
      assert {:ok, file} = FileWatcher.start_child(path)
      assert Process.alive?(file)
    end
  end
end
