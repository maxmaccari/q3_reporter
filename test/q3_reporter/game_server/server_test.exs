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

  test "should call the initializer function with the given path when initialize" do
    path = random_log_path()
    parent = self()

    initializer = fn path ->
      send(parent, {:initializer_called, path})

      {:ok, []}
    end

    {:ok, _pid} = Server.start_link(path: path, initializer: initializer)

    assert_receive {:initializer_called, ^path}
  end

  test "should stop if the initializer return error" do
    initializer = fn _ -> {:error, :enoent} end
    assert {:error, :enoent} = Server.start_link(path: "invalid", initializer: initializer)
  end

  test "should call loader function with the path if receive :file_updated message" do
    path = random_log_path()
    parent = self()

    loader = fn path ->
      send(parent, {:loader_called, path})

      {:ok, []}
    end

    assert {:ok, pid} = Server.start_link(path: path, loader: loader)

    refute_receive {:loader_called, ^path}

    send(pid, {:file_updated, :ignored, :ignored})

    assert_receive {:loader_called, ^path}
  end

  test "should stop the server if loader function return an error" do
    Process.flag(:trap_exit, true)

    path = random_log_path()

    loader = fn _path -> {:error, :enoent} end

    assert {:ok, pid} = Server.start_link(path: path, loader: loader)

    send(pid, {:file_updated, :ignored, :ignored})

    assert_receive {:EXIT, ^pid, {:shutdown, :enoent}}

    Process.flag(:trap_exit, false)
  end

  test "should stop if receive the DOWN message from a monitored process" do
    Process.flag(:trap_exit, true)

    path = random_log_path()
    assert {:ok, pid} = Server.start_link(path: path)

    send(pid, {:DOWN, make_ref(), :process, self(), {:shutdown, {:error, :enoent}}})

    assert_receive {:EXIT, ^pid, {:shutdown, {:error, :enoent}}}

    Process.flag(:trap_exit, false)
  end

  test "should notify subscribed pids with new games after game update" do
    path = random_log_path()

    assert {:ok, pid} = Server.start_link(path: path)

    Server.subscribe(path, :by_game)
    Server.subscribe(path, :ranking)

    send(pid, {:file_updated, :ignored, :ignored})

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

    send(pid, {:file_updated, :ignored, :ignored})

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
