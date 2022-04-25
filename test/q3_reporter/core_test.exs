defmodule Q3Reporter.CoreTest do
  use ExUnit.Case
  alias Q3Reporter.Core
  alias Q3Reporter.Core.{Game, Results}

  doctest Q3Reporter.Core

  describe "Core.log_to_results/2" do
    @content " 12:00 InitGame:\n 12:00 ClientConnect: 2\n 12:00 ShutdownGame:"

    test "with default mode" do
      assert %Results{entries: [%{}], mode: :by_game} = Core.log_to_results(@content, :by_game)
    end

    test "with ranking mode" do
      assert %Results{entries: [%{}], mode: :ranking} = Core.log_to_results(@content, :ranking)
    end
  end

  describe "Core.log_to_games/1" do
    @content " 12:00 InitGame:\n 12:00 ClientConnect: 2\n 12:00 ShutdownGame:"

    test "convert log into a list of games" do
      assert [%Game{}] = Core.log_to_games(@content)
    end
  end

  describe "Core.games_to_results/2" do
    test "convert log into a list of games with default mode" do
      assert %Results{entries: [%{}], mode: :by_game} =
               Core.games_to_results([%Q3Reporter.Core.Game{}])
    end

    test "convert log into a list of games with ranking mode" do
      assert %Results{entries: [], mode: :ranking} =
               Core.games_to_results([%Q3Reporter.Core.Game{}], :ranking)
    end
  end
end
