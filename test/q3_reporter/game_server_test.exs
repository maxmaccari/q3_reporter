defmodule Q3Reporter.GameServerTest do
  use ExUnit.Case

  alias Q3Reporter.{Core, GameServer, Log}
  alias Q3Reporter.Core.Results

  import Support.LogHelpers

  @content __DIR__ |> Path.join("../fixtures/example.log") |> File.read!()

  defp watcher(_path), do: {:ok, nil}

  defp loader(path) do
    case Log.read(path) do
      {:ok, content} ->
        {:ok, Core.log_to_games(content)}

      error ->
        error
    end
  end

  test "should open a log file and subscribe to it changes" do
    path = create_log()
    push_log(path, @content, NaiveDateTime.new!(2022, 1, 1, 0, 0, 0))

    assert {:ok, pid} = GameServer.start(path, watcher: &watcher/1, loader: &loader/1)

    assert Process.alive?(pid)

    assert %Results{
             entries: [
               %{
                 game: "Game 1",
                 ranking: [%{}],
                 total_kills: 0
               }
             ],
             mode: :by_game
           } = GameServer.results(path)

    assert :ok = GameServer.subscribe(path)
    assert GameServer.subscribed?(path)

    send(pid, {:updated, :ignored, :ignored})

    assert_receive {:game_results, ^path, :by_game, %Results{entries: [%{}], mode: :by_game}}

    assert :ok = GameServer.unsubscribe(path, :by_game)
    refute GameServer.subscribed?(path, :by_game)

    GameServer.stop(path)
    refute Process.alive?(pid)
  end
end
