defmodule Q3Reporter.Core.Ranking do
  alias Q3Reporter.Core.Game

  @type t :: %{
          nickname: String.t(),
          kills: integer(),
          deaths: integer()
        }

  @spec from_games(list(Game.t())) :: list(t())
  def from_games(games) do
    games
    |> Enum.map(& &1.players)
    |> List.flatten()
    |> Enum.reduce(%{}, &update_ranking/2)
    |> Map.to_list()
    |> Enum.map(fn {nickname, {kills, deaths}} ->
      %{nickname: nickname, kills: kills, deaths: deaths}
    end)
    |> Enum.sort(&sort_rankings/2)
  end

  defp update_ranking(player, ranking) do
    Map.update(
      ranking,
      player.nickname,
      {player.kills, player.deaths},
      &update_stats(&1, player.kills, player.deaths)
    )
  end

  defp update_stats({player_kills, player_deaths}, inc_kills, inc_deaths) do
    {player_kills + inc_kills, player_deaths + inc_deaths}
  end

  defp sort_rankings(%{kills: kills} = r1, %{kills: kills} = r2), do: r1.deaths < r2.deaths

  defp sort_rankings(r1, r2), do: r1.kills > r2.kills
end
