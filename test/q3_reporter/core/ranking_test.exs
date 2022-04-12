defmodule Q3Reporter.Core.RankingTest do
  use ExUnit.Case

  alias Q3Reporter.Core.{Game, Ranking, Player}

  describe "Ranking.by_game/1" do
    test "with empty games list" do
      assert Ranking.by_game([]) == %Ranking{type: :by_game}
    end

    test "with games list without players" do
      games = [Game.new(), Game.new()]

      assert Ranking.by_game(games).entries == [
               %{
                 game: "Game 1",
                 ranking: [],
                 total_kills: 0
               },
               %{
                 game: "Game 2",
                 ranking: [],
                 total_kills: 0
               }
             ]
    end

    test "with games list with players sorting by kills" do
      player1 = Player.new(1, "player1") |> with_stats(10, 5)
      player2 = Player.new(2, "player2") |> with_stats(5, 5)

      game =
        Game.new()
        |> Game.add_player(player1)
        |> Game.add_player(player2)

      assert Ranking.by_game([game]).entries == [
               %{
                 game: "Game 1",
                 ranking: [
                   %{nickname: "player1", kills: 10, deaths: 5},
                   %{nickname: "player2", kills: 5, deaths: 5}
                 ],
                 total_kills: 15
               }
             ]

      assert Ranking.by_game([game, game]).entries == [
               %{
                 game: "Game 1",
                 ranking: [
                   %{nickname: "player1", kills: 10, deaths: 5},
                   %{nickname: "player2", kills: 5, deaths: 5}
                 ],
                 total_kills: 15
               },
               %{
                 game: "Game 2",
                 ranking: [
                   %{nickname: "player1", kills: 10, deaths: 5},
                   %{nickname: "player2", kills: 5, deaths: 5}
                 ],
                 total_kills: 15
               }
             ]
    end

    test "with games list with players sorting by less deaths" do
      player1 = Player.new(1, "player1") |> with_stats(0, 5)
      player2 = Player.new(2, "player2") |> with_stats(0, 0)

      game =
        Game.new()
        |> Game.add_player(player1)
        |> Game.add_player(player2)

      assert Ranking.by_game([game]).entries == [
               %{
                 game: "Game 1",
                 ranking: [
                   %{nickname: "player2", kills: 0, deaths: 0},
                   %{nickname: "player1", kills: 0, deaths: 5}
                 ],
                 total_kills: 0
               }
             ]
    end
  end

  describe "Ranking.general/1" do
    test "with empty games list" do
      assert Ranking.general([]) == %Ranking{type: :general}
    end

    test "with games list without players" do
      games = [Game.new(), Game.new()]

      assert Ranking.general(games).entries == []
    end

    test "with games list with players sorting by kills" do
      player1 = Player.new(1, "player1") |> with_stats(10, 5)
      player2 = Player.new(2, "player2") |> with_stats(5, 5)

      game =
        Game.new()
        |> Game.add_player(player1)
        |> Game.add_player(player2)

      assert Ranking.general([game]).entries == [
               %{nickname: "player1", kills: 10, deaths: 5},
               %{nickname: "player2", kills: 5, deaths: 5}
             ]

      assert Ranking.general([game, game, game]).entries == [
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

      assert Ranking.general([game]).entries == [
               %{nickname: "player2", kills: 0, deaths: 0},
               %{nickname: "player1", kills: 0, deaths: 5}
             ]
    end
  end

  describe "Ranking.to_string/1" do
    test "when type is :general with no players" do
      ranking = Ranking.general([])

      assert to_string(ranking) == "# General Ranking #\n--- Empty ---"
    end

    test "when type is :general with players" do
      player1 = Player.new(1, "player1") |> with_stats(5, 0)
      player2 = Player.new(2, "player2") |> with_stats(10, 5)

      game = Game.new() |> Game.add_player(player1) |> Game.add_player(player2)
      ranking = Ranking.general([game])

      assert to_string(ranking) ==
               "# General Ranking #\n" <>
                 "player2: 10 kills / 5 deaths\n" <>
                 "player1: 5 kills / 0 deaths"
    end

    test "when type is :by_game with no game" do
      ranking = Ranking.by_game([])

      assert to_string(ranking) == "# No Games :( #"
    end

    test "when type is :by_game with one game and no players" do
      ranking = Ranking.by_game([Game.new()])

      assert to_string(ranking) == "# Game 1 #\n--- Empty ---\nTotal Kills: 0"
    end

    test "when type is :by_game with one game" do
      player1 = Player.new(1, "player1") |> with_stats(5, 0)
      player2 = Player.new(2, "player2") |> with_stats(10, 5)

      game = Game.new() |> Game.add_player(player1) |> Game.add_player(player2)
      ranking = Ranking.by_game([game])

      assert to_string(ranking) ==
               "# Game 1 #\n" <>
                 "player2: 10 kills / 5 deaths\n" <>
                 "player1: 5 kills / 0 deaths\n" <>
                 "Total Kills: 15"
    end

    test "when type is :by_game with multiple games" do
      player1 = Player.new(1, "player1") |> with_stats(5, 0)
      player2 = Player.new(2, "player2") |> with_stats(10, 5)

      game = Game.new() |> Game.add_player(player1) |> Game.add_player(player2)
      ranking = Ranking.by_game([game, game])

      assert to_string(ranking) ==
               "# Game 1 #\n" <>
                 "player2: 10 kills / 5 deaths\n" <>
                 "player1: 5 kills / 0 deaths\n" <>
                 "Total Kills: 15" <>
                 "\n\n# Game 2 #\n" <>
                 "player2: 10 kills / 5 deaths\n" <>
                 "player1: 5 kills / 0 deaths\n" <>
                 "Total Kills: 15"
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
