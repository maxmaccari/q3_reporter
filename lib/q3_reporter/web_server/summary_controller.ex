defmodule Q3Reporter.WebServer.SummaryController do
  import Q3Reporter.WebServer.Controller

  def index(conv, result) do
    games =
      result
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {game, id} -> Map.put(game, :id, id) end)
      |> Enum.reverse()

    render(conv, "summary_index", games: games)
  end
end
