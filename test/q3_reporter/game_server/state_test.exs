defmodule Q3Reporter.GameServer.StateTest do
  use ExUnit.Case

  alias Q3Reporter.GameServer.State
  alias Q3Reporter.Core.{Game, Results}

  defp create_state do
    State.new(path: "example.log")
  end

  defp create_pid do
    :c.pid(0, :rand.uniform(99), :rand.uniform(5000))
  end

  describe "GameServer.State" do
    test "new/1 create a new state" do
      path = "example.log"

      assert %State{
               path: ^path,
               games: [],
               subscribers: []
             } = State.new(path: path)
    end

    test "set_watch_pid/2 set a watch_pid to the state" do
      state = create_state()
      watch_pid = create_pid()

      assert %{watch_pid: ^watch_pid} = State.set_watch_pid(state, watch_pid)
    end

    test "set_games/2 set a list of games, ranking and by_game results to the state" do
      state = create_state()
      games = [Game.new()]

      assert %{
               games: ^games,
               by_game: %Results{mode: :by_game},
               ranking: %Results{mode: :ranking}
             } = State.set_games(state, games)
    end

    test "subscribe/2 subscribe a pid by :by_game mode" do
      state = create_state()
      pid = create_pid()
      anoter_pid = create_pid()

      assert state =
               %{
                 subscribers: [{^pid, :by_game}]
               } = State.subscribe(state, pid)

      assert state =
               %{
                 subscribers: [{^pid, :by_game}]
               } = State.subscribe(state, pid)

      assert %{
               subscribers: [{^anoter_pid, :by_game}, {^pid, :by_game}]
             } = State.subscribe(state, anoter_pid)
    end

    test "subscribe/3 subscribe a pid by the given mode" do
      state = create_state()
      pid = create_pid()
      anoter_pid = create_pid()

      assert state =
               %{
                 subscribers: [{^pid, :by_game}]
               } = State.subscribe(state, pid, :by_game)

      assert state =
               %{
                 subscribers: [{^pid, :ranking}, {^pid, :by_game}]
               } = State.subscribe(state, pid, :ranking)

      assert state =
               %{
                 subscribers: [{^pid, :ranking}, {^pid, :by_game}]
               } = State.subscribe(state, pid, :ranking)

      assert %{
               subscribers: [{^anoter_pid, :ranking}, {^pid, :ranking}, {^pid, :by_game}]
             } = State.subscribe(state, anoter_pid, :ranking)
    end

    test "unsubscribe/2 unsubscribe a pid by :by_game mode" do
      state = create_state()
      pid = create_pid()

      state = State.subscribe(state, pid)
      state = State.subscribe(state, pid, :ranking)

      assert %{
               subscribers: [{^pid, :ranking}]
             } = State.unsubscribe(state, pid)
    end

    test "unsubscribe/3 unsubscribe a pid by the given mode" do
      state = create_state()
      pid = create_pid()

      state = State.subscribe(state, pid)
      state = State.subscribe(state, pid, :ranking)

      assert %{
               subscribers: [{^pid, :by_game}]
             } = State.unsubscribe(state, pid, :ranking)
    end

    test "subscribed?/3 return if pid is subscribed by the given mode" do
      state = create_state()
      pid = create_pid()
      another_pid = create_pid()

      state = State.subscribe(state, pid)
      state = State.subscribe(state, another_pid, :ranking)

      assert State.subscribed?(state, pid, :by_game)
      refute State.subscribed?(state, pid, :ranking)

      assert State.subscribed?(state, another_pid, :ranking)
      refute State.subscribed?(state, another_pid, :by_game)
    end

    test "results/2 return the result by the given mode" do
      state = State.set_games(create_state(), [Game.new()])

      assert %Results{mode: :by_game} = State.results(state, :by_game)
      assert %Results{mode: :ranking} = State.results(state, :ranking)
    end
  end
end
