defmodule Q3Reporter.Parser.Game do
  defstruct players: [], total_kills: 0

  alias Q3Reporter.Parser.Game

  def new_game(games \\ []) when is_list(games) do
    [ %Game{} | games]
  end

  def connect_player(games, %Game{} = game, id)
    when is_list(games) and is_binary(id) do
    players = connect_player(game.players, id)

    [%{game | players: players} | games]
  end

  def change_player_info(games, %Game{players: players} = game, id, info, new_name)
    when is_list(games) and is_binary(id) and is_atom(info) and is_binary(new_name) do

    players = change_player(players, id, fn player ->
      %{player | info => new_name}
    end)

    [%{game | players: players} | games]
  end

  def world_kill(games, %Game{players: players} = game, killed_id)
    when is_list(games) and is_binary(killed_id) do
    players = change_player(players, killed_id, fn player ->
      %{player | kills: player.kills - 1, deaths: player.deaths + 1}
    end)
    total_kills = game.total_kills + 1

    [%{game | players: players, total_kills: total_kills} | games]
  end

  def player_kill(games, %Game{players: players} = game, killer_id, killed_id) when
    is_list(games) and is_binary(killer_id) and is_binary(killed_id) do
    players =
      players
      |> change_player(killer_id, fn player ->
        %{player | kills: player.kills + 1}
      end)
      |> change_player(killed_id, fn player ->
        %{player | deaths: player.deaths + 1}
      end)

    total_kills = game.total_kills + 1

    [%{game | players: players, total_kills: total_kills} | games]
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

  defp change_player(players, id, fun) do
    Enum.map(players, fn (player) ->
      if player.id == id, do: fun.(player), else: player
    end)
  end
end
