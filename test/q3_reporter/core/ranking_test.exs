defmodule Q3Reporter.Core.RankingTest do
  use ExUnit.Case

  alias Q3Reporter.Core.{Game, Ranking, Player}

  describe "Ranking.from_games/1" do
    test "with empty games list" do
      assert Ranking.from_games([]) == []
    end

    test "with games list without players" do
      games = [Game.new(), Game.new()]

      assert Ranking.from_games(games) == []
    end

    test "with games list with players sorting by kills" do
      player1 = Player.new(1, "player1") |> with_stats(10, 5)
      player2 = Player.new(2, "player2") |> with_stats(5, 5)

      game =
        Game.new()
        |> Game.add_player(player1)
        |> Game.add_player(player2)

      assert Ranking.from_games([game]) == [
               %{nickname: "player1", kills: 10, deaths: 5},
               %{nickname: "player2", kills: 5, deaths: 5}
             ]

      assert Ranking.from_games([game, game, game]) == [
               %{nickname: "player1", kills: 30, deaths: 15},
               %{nickname: "player2", kills: 15, deaths: 15}
             ]
    end

    test "with games list with players sorting by less deaths" do
      player1 = Player.new(1, "player1") |> with_stats(0, 5)
      player2 = Player.new(2, "player2") |> with_stats(0, 0)

      game =
        Game.new()
        |> Game.add_player(player1)
        |> Game.add_player(player2)

      assert Ranking.from_games([game]) == [
               %{nickname: "player2", kills: 0, deaths: 0},
               %{nickname: "player1", kills: 0, deaths: 5}
             ]
    end
  end

  def with_stats(player, kills \\ 0, deaths \\ 0) do
    player
    |> increment_kills(kills)
    |> increment_deaths(deaths)
  end

  def increment_kills(player, 0), do: player

  def increment_kills(player, rem_kills) do
    increment_kills(Player.increment_kills(player), rem_kills - 1)
  end

  def increment_deaths(player, 0), do: player

  def increment_deaths(player, rem_deaths) do
    increment_deaths(Player.increment_deaths(player), rem_deaths - 1)
  end
end
