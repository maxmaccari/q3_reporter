defmodule Q3Reporter.ModifyCheckerTest do
  use ExUnit.Case, async: false

  alias Q3Reporter.{Log, ModifyChecker}

  import Support.LogHelpers

  test "should open a file and subscribe to it changes" do
    path = create_log()

    assert {:ok, file} = ModifyChecker.open(path, &Log.mtime/1)

    assert :ok = ModifyChecker.subscribe(file)
    assert ModifyChecker.subscribed?(file)

    touch_log(path)
    assert_receive {:updated, ^file, _mtime}, 200

    assert :ok = ModifyChecker.unsubscribe(file)
    refute ModifyChecker.subscribed?(file)

    touch_log(path)
    refute_receive {:updated, ^file, _mtime}, 200

    :ok = ModifyChecker.stop(file)
    refute Process.alive?(file)

    delete_log(path)
  end
end
