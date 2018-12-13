defmodule Q3Reporter.ResultPrinter do
  def print(%{ranking: false, json: false}, result) do
    result
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {game, id} ->
      players =
        game.players
        |> Enum.map(fn player ->
          "- #{player.nickname}:\n" <>
          "      Kills: #{player.kills}\n" <>
          "      Deaths: #{player.deaths}"
        end)
        |> Enum.join("\n    ")

      """
        Game #{id}:
          #{players}
          => Total Kills: #{game.total_kills}
      """
    end)
    |> Enum.reverse()
    |> Enum.join("\n")
    |> IO.puts()
  end

  def print(%{ranking: false, json: true}, result) do
    result
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {game, id} ->
      game =
        game.players
        |> Enum.map(fn player ->
          {player.nickname, %{"kills" => player.kills, "deaths" => player.deaths}}
        end)
        |> Enum.into(%{})
        |> Map.put("totalKills", game.total_kills)

      {"game#{id}", game}
    end)
    |> Enum.into(%{})
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end

  def print(%{ranking: true, json: false}, result) do
    result
    |> Enum.map(&Map.get(&1, :players))
    |> List.flatten()
    |> Enum.reduce(%{}, fn player, acc ->
      Map.update(acc, player.nickname, player.kills, &(&1 +player.kills))
    end)
    |> Map.to_list()
    |> Enum.sort(&(elem(&2, 1) <= elem(&1, 1)))
    |> Enum.map(fn {nickname, kills} -> "  #{nickname} => #{kills}" end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def print(%{ranking: true, json: true}, result) do
    ranking =
      result
      |> Enum.map(&Map.get(&1, :players))
      |> List.flatten()
      |> Enum.reduce(%{}, fn player, acc ->
        Map.update(acc, player.nickname, player.kills, &(&1 +player.kills))
      end)
      |> Map.to_list()
      |> Enum.sort(&(elem(&2, 1) <= elem(&1, 1)))
      |> Enum.map(fn {nickname, kills} ->
        %{"nickname" => nickname, "kills" => kills}
      end)

    %{"ranking" => ranking}
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end
end
