defmodule Q3Reporter.GameServer.StateTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.GameServer.State
  alias Q3Reporter.Core.{Game, Results}

  defp create_state do
    State.new(path: "example.log")
  end

  defp create_pid do
    :c.pid(0, :rand.uniform(99), :rand.uniform(5000))
  end

  test "should create a new state" do
    path = "example.log"

    assert %State{
             path: ^path,
             games: [],
             subscribers: []
           } = State.new(path: path)
  end

  test "should allow update the list of games, ranking and by_game results to the state" do
    state = create_state()
    games = [Game.new()]

    assert %{
             games: ^games,
             by_game: %Results{mode: :by_game},
             ranking: %Results{mode: :ranking}
           } = State.update_games(state, games)
  end

  test "should allow subscribe a pid by the given mode only one time per mode" do
    state = create_state()
    pid = create_pid()
    anoter_pid = create_pid()

    assert %{subscribers: [{^pid, :by_game}]} = State.subscribe(state, pid)
    assert %{subscribers: [{^pid, :by_game}]} = State.subscribe(state, pid, :by_game)
    assert %{subscribers: [{^pid, :ranking}]} = State.subscribe(state, pid, :ranking)

    assert %{subscribers: [{^anoter_pid, :by_game}, {^pid, :by_game}]} =
             state
             |> State.subscribe(pid)
             |> State.subscribe(anoter_pid)

    assert %{subscribers: [{^pid, :ranking}, {^pid, :by_game}]} =
             state
             |> State.subscribe(pid, :by_game)
             |> State.subscribe(pid, :ranking)

    assert %{subscribers: [{^anoter_pid, :ranking}, {^pid, :ranking}, {^pid, :by_game}]} =
             state
             |> State.subscribe(pid, :by_game)
             |> State.subscribe(pid, :ranking)
             |> State.subscribe(anoter_pid, :ranking)

    assert %{subscribers: [{^pid, :ranking}, {^pid, :by_game}]} =
             state
             |> State.subscribe(pid)
             |> State.subscribe(pid, :by_game)
             |> State.subscribe(pid, :ranking)
             |> State.subscribe(pid, :ranking)
  end

  test "should unsubscribe a pid by the given mode" do
    state = create_state()
    pid = create_pid()

    assert %{subscribers: []} = state |> State.subscribe(pid) |> State.unsubscribe(pid)

    assert %{subscribers: [{^pid, :ranking}]} =
             state
             |> State.subscribe(pid)
             |> State.subscribe(pid, :ranking)
             |> State.unsubscribe(pid)

    assert %{subscribers: [{^pid, :by_game}]} =
             state
             |> State.subscribe(pid)
             |> State.subscribe(pid, :ranking)
             |> State.unsubscribe(pid, :ranking)
  end

  test "should allow to check if pid is subscribed by the given mode" do
    state = create_state()
    pid = create_pid()
    another_pid = create_pid()

    assert state |> State.subscribe(pid) |> State.subscribed?(pid, :by_game)
    assert state |> State.subscribe(pid, :ranking) |> State.subscribed?(pid, :ranking)

    refute state |> State.subscribe(another_pid) |> State.subscribed?(pid, :by_game)
    refute state |> State.subscribe(pid) |> State.subscribed?(pid, :ranking)
  end

  test "should allow to return the result by the given mode" do
    state = State.update_games(create_state(), [Game.new()])

    assert %Results{mode: :by_game} = State.results(state, :by_game)
    assert %Results{mode: :ranking} = State.results(state, :ranking)
  end

  test "should allow to initialize games by the given initialize function" do
    initializer = fn path ->
      send(self(), {:initialized_with, path})

      {:ok, [%Game{}]}
    end

    bad_initializer = fn _ ->
      {:error, :enoent}
    end

    assert {:ok,
            %State{
              by_game: %Results{},
              ranking: %Results{},
              games: []
            }} = State.new() |> State.initialize()

    assert {:ok,
            %State{
              by_game: %Results{},
              ranking: %Results{},
              games: [%Game{}]
            }} =
             State.new(path: "expected_path", initializer: initializer)
             |> State.initialize()

    assert_received {:initialized_with, "expected_path"}

    assert {:error, :enoent} = State.new(initializer: bad_initializer) |> State.initialize()
  end

  test "should allow to load games by the given loader function" do
    loader = fn path ->
      send(self(), {:loaded_with, path})

      {:ok, [%Game{}]}
    end

    bad_loader = fn _ ->
      {:error, :enoent}
    end

    assert {:ok,
            %State{
              by_game: %Results{},
              ranking: %Results{},
              games: []
            }} = State.new() |> State.load_games()

    assert {:ok,
            %State{
              by_game: %Results{},
              ranking: %Results{},
              games: [%Game{}]
            }} =
             State.new(path: "expected_path", loader: loader)
             |> State.load_games()

    assert_received {:loaded_with, "expected_path"}

    assert {:error, :enoent} = State.new(loader: bad_loader) |> State.load_games()
  end
end
