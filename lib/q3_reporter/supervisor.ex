defmodule Q3Reporter.Supervisor do
  use Supervisor

  alias Q3Reporter.WebServerMonitor

  def start_link(results) do
    Supervisor.start_link(__MODULE__, results, name: __MODULE__)
  end

  def init(results) do
    children = [
      {WebServerMonitor, results},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
