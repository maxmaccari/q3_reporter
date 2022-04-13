defmodule Q3Reporter.Supervisor do
  use Supervisor

  alias Q3Reporter.{ResultServer, WebServerMonitor, UpdaterServer}

  def start_link([result, path]) do
    Supervisor.start_link(__MODULE__, [result, path], name: __MODULE__)
  end

  def init([result, path]) do
    children = [
      {ResultServer, result},
      WebServerMonitor,
      {UpdaterServer, path}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
