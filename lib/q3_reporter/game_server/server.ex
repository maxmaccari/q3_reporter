defmodule Q3Reporter.GameServer.Server do
  use GenServer

  alias Q3Reporter.{Core, Log, LogWatcher}
  alias Q3Reporter.GameServer.State

  def start_link(opts \\ []) do
    case Keyword.fetch(opts, :path) do
      {:ok, path} -> GenServer.start_link(__MODULE__, opts, name: via_tuple(path))
      _ -> {:error, "path is required"}
    end
  end

  def via_tuple(path) do
    {:via, Registry, {Q3Reporter.Registry, {__MODULE__, path}}}
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

  def init(opts) do
    with {:ok, games} <- load_games(opts[:path], opts[:log_adapter]),
         {:ok, watch_pid} <- watch_and_subscribe_to_log(opts[:path], opts[:log_adapter]) do
      state =
        opts
        |> State.new()
        |> State.set_games(games)
        |> State.set_watch_pid(watch_pid)

      {:ok, state}
    end
  end

  def handle_continue(:reload_games, %{path: path, log_adapter: adapter} = state) do
    case load_games(path, adapter) do
      {:ok, games} ->
        {:noreply, State.set_games(state, games), {:continue, :notify_subscribers}}

      {:stop, reason} ->
        {:stop, reason, state}
    end
  end

  def handle_continue(:notify_subscribers, state) do
    notify_subscribers(state)

    {:noreply, state}
  end

  def handle_info({:file_updated, watch_pid, _}, %{watch_pid: watch_pid} = state) do
    {:noreply, state, {:continue, :reload_games}}
  end

  def handle_info(
        {:DOWN, _ref, :process, watch_pid, {:shutdown, reason}},
        %{watch_pid: watch_pid} = state
      ) do
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

  def terminate({:shutdown, {:error, :enoent}}, _state), do: :ok

  def terminate(_reason, %{watch_pid: watch_pid}) do
    LogWatcher.close(watch_pid)
  rescue
    _ -> :ok
  catch
    :exit, _ -> :ok
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

  defp watch_and_subscribe_to_log(path, adapter) do
    case LogWatcher.open(path, log_adapter: adapter) do
      {:ok, watch_pid} ->
        Process.monitor(watch_pid)
        :ok = LogWatcher.subscribe(watch_pid)

        {:ok, watch_pid}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  defp load_games(path, adapter) do
    case Log.read(path, adapter) do
      {:ok, content} -> {:ok, Core.log_to_games(content)}
      {:error, reason} -> {:stop, reason}
    end
  end
end
