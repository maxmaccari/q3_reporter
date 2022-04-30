defmodule Q3Reporter.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Q3Reporter.ModifyChecker,
      Q3Reporter.GameServer
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end
end
