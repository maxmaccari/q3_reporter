defmodule Q3Reporter.Ranking do
  def build(result) do
    result
    |> Enum.map(&Map.get(&1, :players))
    |> List.flatten()
    |> Enum.reduce(%{}, fn player, acc ->
      Map.update(acc, player.nickname, player.kills, &(&1 + player.kills))
    end)
    |> Map.to_list()
    |> Enum.sort(&(elem(&2, 1) <= elem(&1, 1)))
  end
end
