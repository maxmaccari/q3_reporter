defmodule Q3Reporter.Core.Ranking do
  alias Q3Reporter.Core.{Game, Player}

  @spec from_games(list(Game.t())) :: [{String.t(), integer()}]
  def from_games(games) do
    games
    |> Enum.map(& &1.players)
    |> List.flatten()
    |> Enum.reduce(%{}, fn %Player{nickname: nickname, kills: kills}, ranking ->
      Map.update(ranking, nickname, kills, &(&1 + kills))
    end)
    |> Map.to_list()
    |> Enum.sort(&(elem(&2, 1) <= elem(&1, 1)))
  end

  def from_games(games, :map) do
    for {entry, index} <- games |> from_games() |> Enum.with_index(), into: %{} do
      {index + 1, entry}
    end
  end
end
