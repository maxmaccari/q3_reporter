defmodule Q3Reporter.Supervisor do
  use Supervisor

  alias Q3Reporter.{ResultServer, WebServerMonitor}

  def start_link(result) do
    Supervisor.start_link(__MODULE__, result, name: __MODULE__)
  end

  def init(result) do
    children = [
      {ResultServer, result},
      WebServerMonitor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
