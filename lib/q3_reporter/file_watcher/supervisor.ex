defmodule Q3Reporter.FileWatcher.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  alias Q3Reporter.FileWatcher.Server

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    DynamicSupervisor.start_link(__MODULE__, [], opts)
  end

  @spec start_child(atom | pid | {atom, any} | {:via, atom, any}, String.t()) ::
          :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_child(sup \\ __MODULE__, path) do
    DynamicSupervisor.start_child(sup, {Server, path})
  end

  @impl true
  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
