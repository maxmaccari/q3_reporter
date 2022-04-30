defmodule Q3Reporter.GameServer do
  use Supervisor

  @moduledoc false

  alias Q3Reporter.GameServer.Supervisor, as: GameSupervisor
  alias Q3Reporter.GameServer.Server

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
