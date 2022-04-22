defmodule Q3Reporter.FileWatcher.Server do
  @moduledoc false

  @timeout 100

  use GenServer

  alias Q3Reporter.FileWatcher.State

  @type state :: State.t()

  # Client

  @spec start_link(String.t(), keyword()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(path, opts \\ []) do
    GenServer.start_link(__MODULE__, path, opts)
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
  @spec init(String.t()) :: {:ok, state} | {:stop, atom()}
  def init(path) do
    case File.stat(path) do
      {:ok, %{mtime: mtime}} ->
        :timer.send_interval(@timeout, :tick)

        {:ok, State.new(path: path, mtime: mtime)}

      {:error, reason} ->
        {:stop, reason}
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
    %{mtime: mtime, path: path} = state

    state = unsubscribe_dead_processes(state)

    case File.stat!(path) do
      %{mtime: ^mtime} ->
        {:noreply, state}

      %{mtime: new_mtime} ->
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
end
