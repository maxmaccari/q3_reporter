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
    case interpret_line(line) do
      nil -> []
      :new_game -> Game.new_game([])
    end
  end

  defp parse_line(line, [game | games]) do
    case interpret_line(line) do
      nil -> [game | games]
      :new_game -> Game.new_game([game | games])
      {:connect_player, id} -> Game.connect_player(games, game, id)
      {:change_player_nickname, id, new_name} ->
        Game.change_player_info(games, game, id, :nickname, new_name)
      {:kill, :world, killed_id} ->
        Game.world_kill(games, game, killed_id)
      {:kill, killer_id, killed_id} ->
        Game.player_kill(games, game, killer_id, killed_id)
    end
  end

  defp interpret_line("InitGame:" <> _) do
    :new_game
  end

  defp interpret_line("ClientConnect: " <> id) do
    {:connect_player, id}
  end

  defp interpret_line("ClientUserinfoChanged: " <> info) do
    [id, rest] = String.split(info, " ", parts: 2, trim: true)
    new_nickname = rest |> String.split("\\") |> Enum.at(1)

    {:change_player_nickname, id, new_nickname}
  end

  defp interpret_line("Kill: " <> info) do
    [killer_id, killed_id, _] = String.split(info, " ", parts: 3)
    killer_id = if killer_id == "1022", do: :world, else: killer_id

    {:kill, killer_id, killed_id}
  end

  defp interpret_line(_) do
    nil
  end
end
