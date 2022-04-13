defmodule Q3Reporter.Core.PlayerTest do
  use ExUnit.Case
  alias Q3Reporter.Core.Player

  describe "Player" do
    setup context do
      {:ok, Map.put(context, :player, Player.new(1))}
    end

    test "new/1 create a Player with the given id and default values" do
      assert %Player{id: 1, nickname: "", connected?: false, kills: 0} = Player.new(1)
    end

    test "set_nickname/2 updates the Player nickname", %{player: player} do
      new_nickname = "abc123"
      player = Player.set_nickname(player, new_nickname)

      assert player.nickname == new_nickname
    end

    test "connect/1 set player as connected status to true", %{player: player} do
      player = Player.connect(player)

      assert player.connected?
    end

    test "disconnect/1 set player as connected status to false", %{player: player} do
      player = player |> Player.connect() |> Player.disconnect()

      refute player.connected?
    end

    test "increment_kills/1 increment player kills by 1", %{player: player} do
      player = player |> Player.increment_kills()

      assert player.kills == 1
    end

    test "increment_deaths/1 increment player deaths by 1", %{player: player} do
      player = player |> Player.increment_kills()

      assert player.kills == 1
    end
  end
end
