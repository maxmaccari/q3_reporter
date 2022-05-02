defmodule Q3ReporterTest do
  use ExUnit.Case, asyc: true

  import Support.LogHelpers
  import Support.ErrorAdapters

  alias Q3Reporter
  alias Q3Reporter.Core.{Game, Results}

  alias Q3Reporter.Log.FileAdapter

  describe "Parse logs to Results" do
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
      assert {:error, "'invalid' not found..."} =
               Q3Reporter.parse("invalid", log_adapter: FileAdapter)

      assert {:error, "You don't have permission to open 'invalid'..."} =
               Q3Reporter.parse("invalid", log_adapter: error_adapter(:eacces))

      assert {:error, "There's no enough memory to open 'invalid'..."} =
               Q3Reporter.parse("invalid", log_adapter: error_adapter(:enomem))

      assert {:error, "Error trying to open 'invalid'"} =
               Q3Reporter.parse("invalid", log_adapter: error_adapter(:unknown))
    end
  end

  describe "Parse logs to Games" do
    @path Path.join(__DIR__, "./fixtures/example.log")

    test "should return games with valid file" do
      assert {:ok, [%Game{}]} = Q3Reporter.log_to_games(@path, FileAdapter)
    end

    test "should return error with invalid file path" do
      assert {:error, _msg} = Q3Reporter.log_to_games("invalid", FileAdapter)
    end
  end

  describe "Watch for log updates" do
    test "should receive :update messages when mtime changes" do
      path = create_log()

      assert {:ok, pid} = Q3Reporter.watch_log_updates(path)

      touch_log(path)

      assert_receive {:updated, ^pid, _mtime}
    end

    test "should stop update checker server" do
      path = create_log()

      assert {:ok, pid} = Q3Reporter.watch_log_updates(path)
      assert :ok = Q3Reporter.stop_watch_log_updates(pid)
      assert :error = Q3Reporter.stop_watch_log_updates(pid)

      touch_log(path)

      refute_receive {:updated, ^pid, _mtime}
    end
  end

  describe "Watch for games updates" do
    test "should receive :game_results messages when mtime changes" do
      path = create_log()

      assert :ok = Q3Reporter.watch_games(path)
      assert :ok = Q3Reporter.watch_games(path, :ranking)

      touch_log(path)

      assert_receive {:game_results, ^path, :by_game,
                      %Q3Reporter.Core.Results{entries: [], mode: :by_game}}

      assert_receive {:game_results, ^path, :ranking,
                      %Q3Reporter.Core.Results{entries: [], mode: :ranking}}
    end

    test "should return error if log doesn't exist" do
      assert {:error, :enoent} = Q3Reporter.watch_games("invalid")
    end

    test "should allow stop watching for game results" do
      path = create_log()

      assert :ok = Q3Reporter.watch_games(path)
      assert :ok = Q3Reporter.stop_watch_games(path)

      touch_log(path)

      refute_receive {:game_results, ^path, :by_game, _}
    end
  end
end
