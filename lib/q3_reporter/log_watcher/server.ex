defmodule Q3Reporter.LogWatcher.Server do
  @moduledoc false

  @timeout Application.compile_env(:q3_reporter, [Q3Reporter.LogWatcher, :timeout], 1_000)

  use GenServer

  alias Q3Reporter.Log
  alias Q3Reporter.LogWatcher.State

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

  @spec close(pid) :: :ok
  def close(pid) do
    GenServer.stop(pid)
  end

  # Server Callbacks

  @impl true
  @spec init(keyword) :: {:ok, state} | {:stop, atom()}
  def init(opts) do
    :timer.send_interval(@timeout, :tick)

    case initialize_state(opts) do
      {:error, reason} -> {:stop, reason}
      state -> {:ok, state}
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
    %{mtime: mtime, path: path, log_adapter: log_adapter} = state

    state = unsubscribe_dead_processes(state)

    case Log.mtime(path, log_adapter) do
      {:ok, ^mtime} ->
        {:noreply, state}

      {:ok, new_mtime} ->
        notify_subscribers(state, new_mtime)

        {:noreply, State.update_mtime(state, new_mtime)}
    end
  end

  defp notify_subscribers(state, mtime) do
    State.each_subscribers(state, &send(&1, {:file_updated, self(), mtime}))
  end

  defp unsubscribe_dead_processes(state) do
    State.unsubscribe_by(state, &(!Process.alive?(&1)))
  end

  defp initialize_state(opts) do
    with {:ok, mtime} <- Log.mtime(opts[:path], opts[:log_adapter]) do
      opts
      |> Keyword.put(:mtime, mtime)
      |> State.new()
    end
  end
end
