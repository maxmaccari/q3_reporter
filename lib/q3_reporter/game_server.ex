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
        watcher: Q3Reporter.watch_log_updates/1,
        loader: Q3Reporter.log_to_games/1
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

  @doc """
  Start a GameServer for the given path and options.


  ## Options
  - `watcher`: function that is going to be used to subscribe for updates. It
  must send messages to GameServer in `{:update, watcher_pid, mtime}` format. It
  takes the `path` and returns `{:ok, pid}` or `{:error, reason}`.
  - `loader`: function used to load game data. It is called on the startup and
  every time that GameServer receives an update. It takes the `path` and should
  return `{:ok, games_list}` or `{:error, reason}`.
  """
  @spec start(String.t(), keyword) :: DynamicSupervisor.on_start_child()
  def start(path, opts \\ []) do
    opts = Keyword.put(opts, :path, path)
    GameSupervisor.start_child(opts)
  end

  @doc """
  Stop the GameServer.
  """
  @spec stop(String.t()) :: :ok
  defdelegate stop(path), to: Server

  @doc """
  Subscribe for GameServer updates.

  When subscribed, the process will start receiving messages for every update on
  the following format:

      {:game_results, log_path, mode, %Q3Reporter.Core.Results{}}
  """
  @spec subscribe(String.t(), :by_game | :ranking) :: :ok
  defdelegate subscribe(path, mode \\ :by_game), to: Server

  @doc """
  Unsubscribe from GameServer updates.
  """
  @spec unsubscribe(String.t(), :by_game | :ranking) :: :ok
  defdelegate unsubscribe(path, mode \\ :by_game), to: Server

  @doc """
  Check if the current pid is subscribed for the GameServer updates for the given
  mode.
  """
  @spec subscribed?(String.t(), :by_game | :ranking, pid) :: boolean
  defdelegate subscribed?(path, mode \\ :by_game, pid \\ self()), to: Server

  @doc """
  Return a list of games from the given GameServer
  """
  @spec results(String.t(), :by_game | :ranking) :: list
  defdelegate results(path, mode \\ :by_game), to: Server

  @doc false
  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc false
  @impl true
  def init([]) do
    children = [
      {Registry, keys: :unique, name: Q3Reporter.GameServer.Registry},
      {Task.Supervisor, name: Q3Reporter.GameServer.TaskSupervisor},
      {Q3Reporter.GameServer.Supervisor, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
