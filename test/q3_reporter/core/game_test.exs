defmodule Q3Reporter.Core.GameTest do
  use ExUnit.Case
  alias Q3Reporter.Core.{Game, Player}

  describe "Game" do
    setup context do
      {:ok, Map.put(context, :game, Game.new())}
    end

    test "new/1 create a Game with and default values" do
      assert %Game{players: [], initialized_at: nil, shutdown_at: nil} = Game.new()
    end

    test "initialize/1 set game initialize at the given time", %{game: game} do
      {:ok, time} = random_time()
      game = Game.initialize(game, time)

      assert game.initialized_at == time
    end

    test "shutdown/1 set game initialize at the given time", %{game: game} do
      {:ok, time} = random_time()
      game = Game.shutdown(game, time)

      assert game.shutdown_at == time
    end

    test "add_player/2 add a new player", %{game: game} do
      player = build_player()
      game = Game.add_player(game, player)

      assert game.players == [player]
    end

    test "add_player/2 doesn't add a new player if it is already added", %{game: game} do
      player = build_player()
      game = game |> Game.add_player(player) |> Game.add_player(player)

      assert game.players == [player]
    end

    test "add_player/2 add players with different ids", %{game: game} do
      player1 = build_player(1)
      player2 = build_player(2)
      game = game |> Game.add_player(player1) |> Game.add_player(player2)

      assert length(game.players) == 2

      Enum.each([player2, player1], fn player ->
        assert player in game.players
      end)
    end

    test "change_player_nickname/2 change the player nickname", %{game: game} do
      player = build_player(1)
      new_nickname = "abc123"

      game =
        game
        |> Game.add_player(player)
        |> Game.change_player_nickname(player.id, new_nickname)

      assert [%Player{nickname: ^new_nickname}] = game.players
    end

    test "connect_player/1 change the player connected status to true", %{game: game} do
      player = build_player(1)

      game =
        game
        |> Game.add_player(player)
        |> Game.connect_player(player.id)

      assert [%Player{connected?: true}] = game.players
    end

    test "disconnect_player/1 change the player connected status to false", %{game: game} do
      player1 = build_player(1)

      game =
        game
        |> Game.add_player(player1)
        |> Game.connect_player(player1.id)
        |> Game.disconnect_player(player1.id)

      assert [%Player{connected?: false}] = game.players
    end

    test "kill_player/2 increment the killer kills and increment the killed deaths", %{game: game} do
      killer = build_player(1)
      killed = build_player(2)

      game =
        game
        |> Game.add_player(killer)
        |> Game.add_player(killed)
        |> Game.kill_player(killer.id, killed.id)

      assert player_from(game, killer.id).kills == 1
      assert player_from(game, killer.id).deaths == 0

      assert player_from(game, killed.id).kills == 0
      assert player_from(game, killed.id).deaths == 1
    end

    test "kill_player/2 increment the deaths from player killed by :world", %{game: game} do
      killed = build_player(1)

      game =
        game
        |> Game.add_player(killed)
        |> Game.kill_player(:world, killed.id)

      assert player_from(game, killed.id).kills == 0
      assert player_from(game, killed.id).deaths == 1
    end

    test "kill_player/2 increment the deaths from self kiled player without increment it kills",
         %{game: game} do
      player = build_player(1)

      game =
        game
        |> Game.add_player(player)
        |> Game.kill_player(player.id, player.id)

      assert player_from(game, player.id).kills == 0
      assert player_from(game, player.id).deaths == 1
    end

    test "total_kills/2 get the total of kills from the game",
         %{game: game} do
      player1 = build_player(1)
      player2 = build_player(2)

      game
      |> Game.add_player(player1)
      |> Game.add_player(player2)
      |> assert_total_kills_by(0)
      |> Game.kill_player(player1.id, player2.id)
      |> assert_total_kills_by(1)
      |> Game.kill_player(player2.id, player1.id)
      |> assert_total_kills_by(2)
      |> Game.kill_player(:world, player1.id)
      |> assert_total_kills_by(2)
      |> Game.kill_player(player2.id, player2.id)
      |> assert_total_kills_by(2)
      |> Game.kill_player(player1.id, player2.id)
      |> assert_total_kills_by(3)
    end
  end

  defp assert_total_kills_by(game, number) do
    assert Game.total_kills(game) == number
    game
  end

  defp random_time() do
    hour = Enum.random(0..23)
    minutes = Enum.random(0..59)

    Time.new(hour, minutes, 0)
  end

  defp build_player(id \\ 1) do
    Player.new(id)
  end

  defp player_from(game, id) do
    Enum.find(game.players, &(&1.id == id))
  end
end
