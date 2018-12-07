defmodule Q3Reporter.Parser do
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
      {:new_game, game} -> [game]
    end
  end

  defp parse_line(line, [game | games]) do
    case interpret_line(line) do
      nil -> [game | games]
      {:new_game, new_game} ->
        [ new_game | [game | games]]
      {:connect_player, id} ->
        players = connect_player(game.players, id)

        [%{game | players: players} | games]
      {:change_player_nickname, id, new_name} ->
        players = change_player(game.players, id, fn player ->
          %{player | nickname: new_name}
        end)

        [%{game | players: players} | games]

      {:kill, :world, killed_id} ->
        players = change_player(game.players, killed_id, fn player ->
          %{player | kills: player.kills - 1, deaths: player.deaths + 1}
        end)
        total_kills = game.total_kills + 1

        [%{game | players: players, total_kills: total_kills} | games]
      {:kill, killer_id, killed_id} ->
        players =
          game.players
          |> change_player(killer_id, fn player ->
            %{player | kills: player.kills + 1}
          end)
          |> change_player(killed_id, fn player ->
            %{player | deaths: player.deaths + 1}
          end)

        total_kills = game.total_kills + 1

        [%{game | players: players, total_kills: total_kills} | games]
    end
  end

  defp interpret_line("InitGame:" <> _) do
    new_game = %{
      players: [],
      total_kills: 0
    }

    {:new_game, new_game}
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

  defp change_player(players, id, fun) do
    Enum.map(players, fn (player) ->
      if player.id == id, do: fun.(player), else: player
    end)
  end

  defp connect_player(players, id) do
    case Enum.find(players, fn player -> player.id == id end) do
      nil ->
        new_player = %{
        id: id,
        nickname: "",
        kills: 0,
        deaths: 0
      }
      [new_player | players]
      _player -> players
    end
  end
end
