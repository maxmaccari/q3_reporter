defmodule Q3Reporter.Core.Interpreter do
  @moduledoc false

  alias Q3Reporter.Core.{Game, Player}

  import Q3Reporter.Core.Interpreter.LineInterpreter

  @spec interpret(String.t()) :: list(Game.t())
  def interpret(log) do
    interpret([], log)
  end

  def interpret(games, log) do
    games = Enum.reverse(games)

    log
    |> String.split("\n")
    |> Enum.map(&interpret_line/1)
    |> Enum.reduce(games, &apply_action/2)
    |> Enum.reverse()
  end

  defp apply_action({:init_game, time}, games),
    do: [Game.new() |> Game.initialize(time) | games]

  defp apply_action({:shutdown_game, time}, [game | rest]),
    do: [Game.shutdown(game, time) | rest]

  defp apply_action({:client_connect, player_id}, [game | rest]) do
    game =
      game
      |> Game.add_player(Player.new(player_id))
      |> Game.connect_player(player_id)

    [game | rest]
  end

  defp apply_action({:client_disconnect, player_id}, [game | rest]),
    do: [Game.disconnect_player(game, player_id) | rest]

  defp apply_action({:client_nickname_changed, player_id, nickname}, [game | rest]),
    do: [Game.change_player_nickname(game, player_id, nickname) | rest]

  defp apply_action({:kill, killer_id, killed_id}, [game | rest]),
    do: [Game.kill_player(game, killer_id, killed_id) | rest]

  defp apply_action(_ignore, games), do: games
end
