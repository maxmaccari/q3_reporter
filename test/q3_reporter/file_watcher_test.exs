defmodule Q3Reporter.FileWatcherTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.FileWatcher

  import Support.LogHelpers

  describe "FileWatcher" do
    setup context do
      path = create_log()

      on_exit(fn ->
        delete_log(path)
      end)

      Map.put(context, :path, path)
    end

    test "open a file and subscribe to it changes", %{path: path} do
      assert {:ok, file} = FileWatcher.open(path)

      assert :ok = FileWatcher.subscribe(file)
      touch_log(path)
      assert_receive {:file_updated, ^file, _mtime}, 200

      assert FileWatcher.subscribed?(file)

      assert :ok = FileWatcher.unsubscribe(file)
      touch_log(path)
      refute_receive {:file_updated, ^file, _mtime}, 200

      :ok = FileWatcher.close(file)
      refute Process.alive?(file)
    end
  end
end
