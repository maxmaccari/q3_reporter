defmodule Q3Reporter.FileWatcherTest do
  use ExUnit.Case

  alias Q3Reporter.FileWatcher
  alias Q3Reporter.FileWatcher.Supervisor

  import Support.FileWatchHelpers

  describe "FileWatcher" do
    setup context do
      create_example()

      FileWatcher.start_link()

      on_exit(fn ->
        delete_example()

        DynamicSupervisor.stop(Supervisor)
      end)

      Map.put(context, :path, example_path())
    end

    test "open a file and subscribe to it changes", %{path: path} do
      assert {:ok, file} = FileWatcher.open(path)

      assert :ok = FileWatcher.subscribe(file)
      touch_example()
      assert_receive {:file_updated, ^file, _mtime}, 200

      assert FileWatcher.subscribed?(file)

      assert :ok = FileWatcher.unsubscribe(file)
      touch_example()
      refute_receive {:file_updated, ^file, _mtime}, 200

      :ok = FileWatcher.close(file)
      refute Process.alive?(file)
    end
  end
end
