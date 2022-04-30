defmodule Q3Reporter.UpdateChecker.Server do
  @moduledoc false

  @timeout Application.compile_env(:q3_reporter, [Q3Reporter.UpdateChecker, :timeout], 1_000)

  use GenServer

  alias Q3Reporter.UpdateChecker.State

  @type state :: State.t()

  # Client

  @spec start_link(keyword()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    case Keyword.fetch(opts, :path) do
      {:ok, _path} -> GenServer.start_link(__MODULE__, opts, opts)
      _ -> {:error, "path is required"}
    end
  end

  @spec subscribe(pid) :: :ok
  def subscribe(file) do
    GenServer.call(file, :subscribe)
  end

  @spec subscribed?(pid) :: boolean()
  def subscribed?(file, pid \\ self()) do
    GenServer.call(file, {:subscribed?, pid})
  end

  @spec unsubscribe(pid) :: :ok
  def unsubscribe(file) do
    GenServer.call(file, :unsubscribe)
  end

  @spec stop(pid) :: :ok
  def stop(pid) do
    GenServer.stop(pid)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    :timer.send_interval(@timeout, :tick)

    state = State.new(opts)

    case State.check(state) do
      :not_modified -> {:ok, state}
      {:modified, new_state} -> {:ok, new_state}
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_call(:subscribe, {subscriber, _}, state) do
    {:reply, :ok, State.subscribe(state, subscriber)}
  end

  @impl true
  def handle_call(:unsubscribe, {subscriber, _}, state) do
    {:reply, :ok, State.unsubscribe(state, subscriber)}
  end

  @impl true
  def handle_call({:subscribed?, subscriber}, _, state) do
    {:reply, State.subscribed?(state, subscriber), state}
  end

  @impl true
  def handle_info(:tick, state) do
    state = unsubscribe_dead_processes(state)

    case State.check(state) do
      {:modified, state} ->
        notify_subscribers(state)

        {:noreply, state}

      :not_modified ->
        {:noreply, state}

      {:error, _reason} = error ->
        {:stop, {:shutdown, error}, state}
    end
  end

  defp notify_subscribers(%{mtime: mtime} = state) do
    State.each_subscribers(state, &send(&1, {:updated, self(), mtime}))
  end

  defp unsubscribe_dead_processes(state) do
    State.unsubscribe_by(state, &(!Process.alive?(&1)))
  end
end
