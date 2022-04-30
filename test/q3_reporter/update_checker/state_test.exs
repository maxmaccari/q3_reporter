defmodule Q3Reporter.UpdateChecker.StateTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.UpdateChecker.State

  defp create_state(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:path, "example.log")
      |> Keyword.put_new(:mtime, NaiveDateTime.utc_now())

    State.new(opts)
  end

  defp create_pid do
    :c.pid(0, :rand.uniform(99), :rand.uniform(5000))
  end

  defp create_mtime do
    NaiveDateTime.new!(2000, 1, 1, 0, 0, 0)
  end

  test "should create a new state" do
    mtime = NaiveDateTime.utc_now()
    path = "example.log"

    assert %State{
             path: ^path,
             mtime: ^mtime,
             subscribers: []
           } = State.new(path: path, mtime: mtime)
  end

  test "should allow to add a new subscriber to the state" do
    state = create_state()
    pid = self()

    assert %{subscribers: [^pid]} = State.subscribe(state, pid)
  end

  test "should not allow to subscribe a pid twice" do
    state = create_state()
    pid = self()

    assert %{subscribers: [^pid]} =
             state
             |> State.subscribe(pid)
             |> State.subscribe(pid)
  end

  test "should allot to check if pid is subscribed" do
    pid = self()
    non_subscribed = create_state()
    subscribed = create_state() |> State.subscribe(pid)

    assert State.subscribed?(subscribed, pid)
    refute State.subscribed?(non_subscribed, pid)
  end

  test "should allow to unsubscribe a pid" do
    pid = self()
    state = create_state() |> State.subscribe(pid)

    assert %{subscribers: []} = State.unsubscribe(state, pid)
  end

  test "should allow to unsubscribe by the given function" do
    pid = self()
    state = create_state() |> State.subscribe(pid)

    assert %{subscribers: []} = State.unsubscribe_by(state, &(&1 === pid))
  end

  test "should allow to iterate the subscribers executing the given function" do
    pid1 = create_pid()
    pid2 = create_pid()

    pids = [pid1, pid2]

    state =
      create_state()
      |> State.subscribe(pid1)
      |> State.subscribe(pid2)

    State.each_subscribers(state, fn subscriber ->
      send(self(), {:executed, subscriber})
      assert subscriber in pids
    end)

    assert_received {:executed, ^pid1}
    assert_received {:executed, ^pid2}

    assert %State{} = State.each_subscribers(state, & &1)
  end

  test "should allow to update the current mtime" do
    state = create_state()
    new_mtime = create_mtime()

    assert %State{mtime: ^new_mtime} = State.update_mtime(state, new_mtime)
  end

  test "should allow to check if the mtime is updated by the given function" do
    state = create_state()

    checker = fn path ->
      send(self(), {:checker_called, path})

      {:ok, create_mtime()}
    end

    not_modified_checker = fn _path -> {:ok, state.mtime} end
    bad_checker = fn _path -> {:error, :enoent} end
    current_path = state.path

    create_state(checker: checker) |> State.check()
    assert_receive {:checker_called, ^current_path}

    assert {:modified, _new_state} = State.check(state)

    assert :not_modified =
             create_state(mtime: state.mtime, checker: not_modified_checker) |> State.check()

    assert {:error, :enoent} = create_state(checker: bad_checker) |> State.check()
  end
end
