defmodule Q3Reporter.LogWatcherTest do
  use ExUnit.Case, async: false

  alias Q3Reporter.LogWatcher

  import Support.LogHelpers

  test "should open a file and subscribe to it changes" do
    path = create_log()

    assert {:ok, file} = LogWatcher.open(path)

    assert :ok = LogWatcher.subscribe(file)
    assert LogWatcher.subscribed?(file)

    touch_log(path)
    assert_receive {:file_updated, ^file, _mtime}, 200

    assert :ok = LogWatcher.unsubscribe(file)
    refute LogWatcher.subscribed?(file)

    touch_log(path)
    refute_receive {:file_updated, ^file, _mtime}, 200

    :ok = LogWatcher.close(file)
    refute Process.alive?(file)

    delete_log(path)
  end
end
