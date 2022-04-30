defmodule Q3Reporter.GameServer.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  alias Q3Reporter.GameServer.Server

  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  def start_child(sup \\ __MODULE__, opts) do
    DynamicSupervisor.start_child(sup, {Server, opts})
  end

  @impl true
  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
