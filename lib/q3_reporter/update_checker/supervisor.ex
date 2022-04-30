defmodule Q3Reporter.UpdateChecker.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  alias Q3Reporter.UpdateChecker.Server

  @spec start_link(keyword) :: Supervisor.on_start()
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @spec start_child(GenServer.name(), keyword()) :: DynamicSupervisor.on_start_child()
  def start_child(sup \\ __MODULE__, opts) do
    DynamicSupervisor.start_child(sup, {Server, opts})
  end

  @impl true
  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
