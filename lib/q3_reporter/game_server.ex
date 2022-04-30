defmodule Q3Reporter.GameServer do
  use Supervisor

  @moduledoc """
  It is a service to store and receive game updates automatically.

  You start Q3Reporter.GameServer directly in your supervision tree:

      {Q3Reporter.GameServer, []}

  You can now use the functions in this module to open and subscribe for game updates:

      iex> path = "path_to_log"
      iex> Q3Reporter.GameServer
      iex> {:ok, pid} = GameServer.start(
        path,
        watcher: Q3Reporter.start_watch_log_updates/1,
        loader: Q3Reporter.parse/1
      )
      {:ok, #PID<0, 100, 0>}
      iex> GameServer.subscribe(path, :by_game)
      :ok
      iex> flush()
      {:game_results, "path_to_log", :by_game,
                    %Q3Reporter.Core.Results{entries: [], mode: :by_game}}
      :ok
      iex> UpdateChecker.unsubscribe(path)
      iex> flush()
      :ok
      iex> UpdateChecker.stop(path)
      :ok
  """

  alias Q3Reporter.GameServer.Server
  alias Q3Reporter.GameServer.Supervisor, as: GameSupervisor

  def start(path, opts \\ []) do
    opts = Keyword.put(opts, :path, path)
    GameSupervisor.start_child(opts)
  end

  defdelegate stop(path), to: Server
  defdelegate subscribe(path, mode \\ :by_game), to: Server
  defdelegate unsubscribe(path, mode \\ :by_game), to: Server
  defdelegate subscribed?(path, mode \\ :by_game, pid \\ self()), to: Server
  defdelegate results(path, mode \\ :by_game), to: Server

  @doc false
  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      {Registry, keys: :unique, name: Q3Reporter.GameServer.Registry},
      {Task.Supervisor, name: Q3Reporter.GameServer.TaskSupervisor},
      {Q3Reporter.GameServer.Supervisor, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
