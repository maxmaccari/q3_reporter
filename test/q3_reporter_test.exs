defmodule Q3ReporterTest do
  use ExUnit.Case, asyc: true

  import Support.LogHelpers

  alias Q3Reporter
  alias Q3Reporter.Core.Results

  alias Q3Reporter.Log.FileAdapter

  describe "Parse logs" do
    @path Path.join(__DIR__, "./fixtures/example.log")

    test "should return game contents with valid file and default mode" do
      assert {:ok, results} = Q3Reporter.parse(@path, mode: :by_game, log_adapter: FileAdapter)
      assert %Results{entries: [%{}], mode: :by_game} = results
    end

    test "should return raking contents with valid file and ranking mode" do
      assert {:ok, results} = Q3Reporter.parse(@path, mode: :ranking, log_adapter: FileAdapter)
      assert %Results{entries: [%{}], mode: :ranking} = results
    end

    test "should return error with invalid file path" do
      assert {:error, _msg} = Q3Reporter.parse("invalid", log_adapter: FileAdapter)
    end
  end

  describe "Watch for log updates" do
    test "should receive :update messages when mtime changes" do
      path = create_log()

      assert {:ok, pid} = Q3Reporter.start_watch_log_updates(path)

      touch_log(path)

      assert_receive {:updated, ^pid, _mtime}
    end

    test "should stop update checker server" do
      path = create_log()

      assert {:ok, pid} = Q3Reporter.start_watch_log_updates(path)
      assert :ok = Q3Reporter.stop_watch_log_updates(pid)
      assert :error = Q3Reporter.stop_watch_log_updates(pid)

      touch_log(path)

      refute_receive {:updated, ^pid, _mtime}
    end
  end
end
