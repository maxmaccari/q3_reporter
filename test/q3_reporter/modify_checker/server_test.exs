defmodule Q3Reporter.ModifyChecker.ServerTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.ModifyChecker.Server

  import Support.LogHelpers

  def updating(context) do
    checker = fn _path -> {:ok, NaiveDateTime.utc_now()} end

    Map.put(context, :checker, checker)
  end

  def non_updating(context) do
    mtime = NaiveDateTime.utc_now()
    checker = fn _path -> {:ok, mtime} end

    context
    |> Map.put(:checker, checker)
    |> Map.put(:mtime, mtime)
  end

  def started(%{checker: checker} = context) do
    path = random_log_path()
    {:ok, pid} = start_supervised({Server, path: path, mtime: context[:mtime], checker: checker})

    Map.put(context, :pid, pid)
  end

  def started(context), do: context |> updating() |> started()

  test "should start a new server with valid path" do
    path = random_log_path()
    assert {:ok, pid} = Server.start_link(path: path)
    assert Process.alive?(pid)
  end

  test "should not start with missing path" do
    assert {:error, "path is required"} = Server.start_link()
  end

  test "should not start with if checker return an error" do
    invalid_checker = fn _ -> {:error, :enoent} end
    assert {:error, :enoent} = Server.start_link(path: "invalid", checker: invalid_checker)
  end

  test "should exit after sucesfull startup if checker return an error" do
    path = random_log_path()
    {:ok, agent} = Agent.start(fn -> [NaiveDateTime.utc_now()] end)

    checker = fn _path ->
      Agent.get_and_update(agent, fn
        [] -> {{:error, :enoent}, []}
        [current | rest] -> {{:ok, current}, rest}
      end)
    end

    Process.flag(:trap_exit, true)
    assert {:ok, pid} = Server.start_link(path: path, checker: checker)

    assert_receive {:EXIT, ^pid, {:shutdown, {:error, :enoent}}}

    Process.flag(:trap_exit, false)
  end

  describe "with server started and updating" do
    setup :started

    test "should receive a updated message when something is updated and it is subscribed", %{
      pid: pid
    } do
      refute_receive {:updated, ^pid, _mtime}

      assert :ok = Server.subscribe(pid)

      assert_receive {:updated, ^pid, _mtime}
    end

    test "should allow unsubscribe", %{pid: pid} do
      Server.subscribe(pid)

      assert :ok = Server.unsubscribe(pid)

      refute_receive {:updated, ^pid, _mtime}
    end

    test "should allow to check if the current process is subscribed", %{pid: pid} do
      refute Server.subscribed?(pid)

      Server.subscribe(pid)

      assert Server.subscribed?(pid)
    end

    test "should unsubscribe dead processes automatically", %{pid: pid} do
      task = Task.async(fn -> Server.subscribe(pid) end)
      Task.await(task)
      Server.subscribe(pid)

      assert_receive {:updated, _, _}

      assert Server.subscribed?(pid, self())
      refute Server.subscribed?(pid, task.pid)
    end

    test "should allow to stop the given server", %{pid: pid} do
      Server.stop(pid)
      refute Process.alive?(pid)
    end
  end

  describe "with server started and non updating" do
    setup [:non_updating, :started]

    test "should not receive a update message", %{pid: pid} do
      assert :ok = Server.subscribe(pid)

      refute_receive {:updated, ^pid, _mtime}, 200
      assert Process.alive?(pid)
    end
  end
end
