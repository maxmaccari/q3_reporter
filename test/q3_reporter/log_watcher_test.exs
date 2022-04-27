defmodule Q3Reporter.LogWatcherTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.LogWatcher

  import Support.LogHelpers

  describe "LogWatcher" do
    setup context do
      path = create_log()

      on_exit(fn ->
        delete_log(path)
      end)

      Map.put(context, :path, path)
    end

    test "open a file and subscribe to it changes", %{path: path} do
      assert {:ok, file} = LogWatcher.open(path)

      assert :ok = LogWatcher.subscribe(file)
      touch_log(path)
      assert_receive {:file_updated, ^file, _mtime}, 200

      assert LogWatcher.subscribed?(file)

      assert :ok = LogWatcher.unsubscribe(file)
      touch_log(path)
      refute_receive {:file_updated, ^file, _mtime}, 200

      :ok = LogWatcher.close(file)
      refute Process.alive?(file)
    end
  end
end
