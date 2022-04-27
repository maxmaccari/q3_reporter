defmodule Q3Reporter.LogWatcherTest do
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

  test "should open a file and subscribe to it changes", %{path: path} do
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
