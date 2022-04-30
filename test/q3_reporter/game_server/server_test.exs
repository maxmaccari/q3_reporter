defmodule Q3Reporter.GameServer.ServerTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.Core.Results
  alias Q3Reporter.GameServer.Server

  import Support.LogHelpers

  test "should start a server with the correct path" do
    path = random_log_path()
    assert {:ok, pid} = start_supervised({Server, path: path})
    assert Process.alive?(pid)
  end

  test "should not start a server with missing path" do
    assert {:error, "path is required"} = Server.start_link()
  end

  test "should call the watcher and loader functions with the given path when started" do
    path = random_log_path()
    me = self()

    watcher = fn path ->
      send(me, {:watcher_called, path})

      {:ok, nil}
    end

    loader = fn path ->
      send(me, {:loader_called, path})

      {:ok, []}
    end

    {:ok, _pid} = Server.start_link(path: path, watcher: watcher, loader: loader)

    assert_receive {:watcher_called, ^path}
    assert_receive {:loader_called, ^path}
  end

  test "should stop if the watcher or loader return error" do
    fun = fn _ -> {:error, :enoent} end
    assert {:error, :enoent} = Server.start_link(path: "invalid", watcher: fun)
    assert {:error, :enoent} = Server.start_link(path: "invalid", loader: fun)
  end

  test "should call loader function with the path if receive :updated message" do
    path = random_log_path()
    me = self()

    loader = fn path ->
      send(me, {:loader_called, path})

      {:ok, []}
    end

    assert {:ok, pid} = Server.start_link(path: path, loader: loader)

    send(pid, {:updated, :ignored, :ignored})

    assert_receive {:loader_called, ^path}
  end

  test "should stop the server if loader function return an error" do
    path = random_log_path()
    {:ok, agent} = Agent.start(fn -> [[]] end)

    loader = fn _path ->
      Agent.get_and_update(agent, fn
        [] -> {{:error, :enoent}, []}
        [current | rest] -> {{:ok, current}, rest}
      end)
    end

    Process.flag(:trap_exit, true)
    assert {:ok, pid} = Server.start_link(path: path, loader: loader)

    send(pid, {:updated, :ignored, :ignored})

    assert_receive {:EXIT, ^pid, {:shutdown, :enoent}}

    Process.flag(:trap_exit, false)
  end

  test "should monitor the watcher if it it process is alive, and stop if receive the DOWN message from it" do
    path = random_log_path()
    me = self()
    {:ok, agent} = Agent.start(fn -> :ok end)

    watcher = fn _path ->
      send(me, {:initialized_watcher, agent})

      {:ok, agent}
    end

    Process.flag(:trap_exit, true)
    {:ok, pid} = Server.start_link(path: path, watcher: watcher)

    assert_receive {:initialized_watcher, ^agent}

    Agent.stop(agent, {:shutdown, {:error, :enoent}})

    assert_receive {:EXIT, ^pid, {:shutdown, {:error, :enoent}}}

    Process.flag(:trap_exit, false)
  end

  test "should notify subscribed pids with new games after game update" do
    path = random_log_path()

    assert {:ok, pid} = Server.start_link(path: path)

    Server.subscribe(path, :by_game)
    Server.subscribe(path, :ranking)

    send(pid, {:updated, :ignored, :ignored})

    assert_receive {:game_results, ^path, :by_game,
                    %Q3Reporter.Core.Results{entries: [], mode: :by_game}}

    assert_receive {:game_results, ^path, :ranking,
                    %Q3Reporter.Core.Results{entries: [], mode: :ranking}}
  end

  test "should allow to unsubscribed pids with new games after game update" do
    path = random_log_path()

    assert {:ok, pid} = Server.start_link(path: path)

    Server.subscribe(path, :by_game)
    Server.subscribe(path, :ranking)

    Server.unsubscribe(path, :ranking)

    send(pid, {:updated, :ignored, :ignored})

    assert_receive {:game_results, ^path, :by_game,
                    %Q3Reporter.Core.Results{entries: [], mode: :by_game}}

    refute_receive {:game_results, ^path, :ranking,
                    %Q3Reporter.Core.Results{entries: [], mode: :ranking}}
  end

  test "should allow to check if the pid is subscribed" do
    path = random_log_path()

    assert {:ok, _pid} = Server.start_link(path: path)

    Server.subscribe(path, :by_game)
    Server.subscribe(path, :ranking)

    assert Server.subscribed?(path, :by_game)
    assert Server.subscribed?(path, :ranking)

    Server.unsubscribe(path, :by_game)
    Server.unsubscribe(path, :ranking)

    refute Server.subscribed?(path, :by_game)
    refute Server.subscribed?(path, :ranking)
  end

  test "should allow to get the results from path" do
    path = random_log_path()

    assert {:ok, _pid} = Server.start_link(path: path)

    assert %Results{
             entries: [],
             mode: :by_game
           } = Server.results(path)

    assert %Results{
             entries: [],
             mode: :ranking
           } = Server.results(path, :ranking)
  end

  test "should allow to stop the server" do
    path = random_log_path()

    assert {:ok, pid} = Server.start_link(path: path)
    assert :ok = Server.stop(path)

    refute Process.alive?(pid)
  end

  test "should ignore unknown messages without stop the server" do
    path = random_log_path()

    assert {:ok, pid} = Server.start_link(path: path)
    send(pid, {:some_unknown_message, :hello})

    assert Process.alive?(pid)
  end
end
