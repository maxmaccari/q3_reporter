defmodule Q3Reporter.Parser do
  alias Q3Reporter.Parser.{Game, LogInterpreter}

  def parse(log_content) do
    lines =
      log_content
      |> String.split("\n")
      |> Enum.map(fn line -> line |> String.split_at(7) |> elem(1) end)

    Enum.reduce(lines, [], &parse_line/2)
  end

  defp parse_line(line, []) do
    case LogInterpreter.interpret_line(line) do
      nil -> []
      :new_game -> Game.new([])
    end
  end

  defp parse_line(line, [game | games]) do
    case LogInterpreter.interpret_line(line) do
      nil ->
        [game | games]

      :new_game ->
        Game.new([game | games])

      {:connect_player, id} ->
        Game.connect_player(games, game, id)

      {:change_player_nickname, id, new_name} ->
        Game.change_player_info(games, game, id, :nickname, new_name)

      {:kill, :world, killed_id} ->
        Game.world_kill(games, game, killed_id)

      {:kill, killer_id, killed_id} ->
        Game.player_kill(games, game, killer_id, killed_id)
    end
  end
end
