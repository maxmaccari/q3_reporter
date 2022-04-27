defmodule Q3Reporter.LogWatcher.StateTest do
  use ExUnit.Case, async: true

  alias Q3Reporter.LogWatcher.State

  defp create_state do
    %State{
      path: "example.log",
      mtime: :calendar.local_time(),
      subscribers: [],
      log_adapter: nil
    }
  end

  defp create_pid do
    :c.pid(0, :rand.uniform(99), :rand.uniform(5000))
  end

  defp create_mtime do
    NaiveDateTime.new!(2000, 1, 1, 0, 0, 0)
    |> NaiveDateTime.to_erl()
  end

  describe "LogWatcher.State" do
    test "new/1 create a new state" do
      mtime = :calendar.local_time()
      path = "example.log"

      assert %State{
               path: ^path,
               mtime: ^mtime,
               subscribers: []
             } = State.new(path: path, mtime: mtime)
    end

    test "subscribe/2 add a new subscriber to the state" do
      state = create_state()
      pid = self()

      assert %{subscribers: [^pid]} = State.subscribe(state, pid)
    end

    test "subscribe/2 doesn't subscribe a pid twice" do
      state = create_state()
      pid = self()

      assert %{subscribers: [^pid]} =
               state
               |> State.subscribe(pid)
               |> State.subscribe(pid)
    end

    test "subscribed?/2 return if pid is a subscriber" do
      pid = self()
      non_subscribed = create_state()
      subscribed = create_state() |> State.subscribe(pid)

      assert State.subscribed?(subscribed, pid)
      refute State.subscribed?(non_subscribed, pid)
    end
  end

  test "unsubscribe/2 remove the subscriber from the state" do
    pid = self()
    state = create_state() |> State.subscribe(pid)

    assert %{subscribers: []} = State.unsubscribe(state, pid)
  end

  test "unsubscribe_by/2 remove the subscriber from the state by the given function" do
    pid = self()
    state = create_state() |> State.subscribe(pid)

    assert %{subscribers: []} = State.unsubscribe_by(state, &(&1 === pid))
  end

  test "each_subscribers/2 iterate the subscribers executing the given function" do
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

  test "update_mtime/2 update the current mtime" do
    state = create_state()
    new_mtime = create_mtime()

    assert %State{mtime: ^new_mtime} = State.update_mtime(state, new_mtime)
  end
end
