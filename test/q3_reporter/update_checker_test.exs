defmodule Q3Reporter.UpdateCheckerTest do
  use ExUnit.Case

  alias Q3Reporter.{Log, UpdateChecker}

  import Support.LogHelpers

  test "should open a file and subscribe to it changes" do
    path = create_log()

    assert {:ok, file} = UpdateChecker.open(path, &Log.mtime/1)

    assert :ok = UpdateChecker.subscribe(file)
    assert UpdateChecker.subscribed?(file)

    touch_log(path)
    assert_receive {:updated, ^file, _mtime}, 200

    assert :ok = UpdateChecker.unsubscribe(file)
    refute UpdateChecker.subscribed?(file)

    touch_log(path)
    refute_receive {:updated, ^file, _mtime}, 200

    :ok = UpdateChecker.stop(file)
    refute Process.alive?(file)

    delete_log(path)
  end
end
