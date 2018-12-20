defmodule Q3Reporter.WebServer.SummaryController do
  import Q3Reporter.WebServer.Controller

  def index(conv, result) do
    games =
      result
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {game, id} -> Map.put(game, :id, id) end)
      |> Enum.reverse()

    body = EEx.eval_file("templates/summary_index.html.eex", games: games)

    send_resp(conv, body)
  end
end
