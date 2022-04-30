defmodule Q3Reporter.GameServer.Server do
  use GenServer

  alias Q3Reporter.GameServer.State

  def start_link(opts \\ []) do
    case Keyword.fetch(opts, :path) do
      {:ok, path} -> GenServer.start_link(__MODULE__, opts, name: via_tuple(path))
      _ -> {:error, "path is required"}
    end
  end

  def via_tuple(path) do
    {:via, Registry, {Q3Reporter.GameServer.Registry, {__MODULE__, path}}}
  end

  def subscribe(path, mode \\ :by_game) do
    path
    |> via_tuple()
    |> GenServer.call({:subscribe, mode})
  end

  def unsubscribe(path, mode \\ :by_game) do
    path
    |> via_tuple()
    |> GenServer.call({:unsubscribe, mode})
  end

  def subscribed?(path, mode \\ :by_game, pid \\ self()) do
    path
    |> via_tuple()
    |> GenServer.call({:subscribed?, pid, mode})
  end

  def results(path, mode \\ :by_game) do
    path
    |> via_tuple()
    |> GenServer.call({:results, mode})
  end

  def stop(path) do
    path
    |> via_tuple()
    |> GenServer.stop(:normal)
  end

  def init(opts) do
    case initialize(opts) do
      {:ok, state} -> {:ok, state}
      {:error, reason} -> {:stop, reason}
    end
  end

  def handle_continue(:reload_games, state) do
    case State.load_games(state) do
      {:ok, state} ->
        {:noreply, state, {:continue, :notify_subscribers}}

      {:error, reason} ->
        {:stop, {:shutdown, reason}, state}
    end
  end

  def handle_continue(:notify_subscribers, state) do
    notify_subscribers(state)

    {:noreply, state}
  end

  def handle_info({:file_updated, _, _}, state) do
    {:noreply, state, {:continue, :reload_games}}
  end

  def handle_info({:DOWN, _ref, :process, _watcher, {:shutdown, reason}}, state) do
    {:stop, {:shutdown, reason}, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  def handle_call({:subscribe, mode}, {subscriber, _}, state) do
    {:reply, :ok, State.subscribe(state, subscriber, mode)}
  end

  def handle_call({:unsubscribe, mode}, {subscriber, _}, state) do
    {:reply, :ok, State.unsubscribe(state, subscriber, mode)}
  end

  def handle_call({:subscribed?, pid, mode}, _from, state) do
    {:reply, State.subscribed?(state, pid, mode), state}
  end

  def handle_call({:results, mode}, _from, state) do
    {:reply, State.results(state, mode), state}
  end

  @task_supervisor Q3Reporter.GameServer.TaskSupervisor

  defp notify_subscribers(state) do
    %{
      by_game: by_game,
      ranking: ranking,
      subscribers: subscribers,
      path: path
    } = state

    @task_supervisor
    |> Task.Supervisor.async_stream(subscribers, fn
      {pid, :by_game} -> send(pid, {:game_results, path, :by_game, by_game})
      {pid, :ranking} -> send(pid, {:game_results, path, :ranking, ranking})
    end)
    |> Stream.run()
  end

  defp initialize(opts) do
    opts
    |> State.new()
    |> State.initialize()
  end
end