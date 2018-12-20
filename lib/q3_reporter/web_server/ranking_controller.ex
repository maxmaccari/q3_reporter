defmodule Q3Reporter.WebServer.RankingController do
  alias Q3Reporter.Ranking

  import Q3Reporter.WebServer.Controller

  def index(conv, result) do
    ranking =
      result
      |> Ranking.build()
      |> Enum.map(fn {nickname, kills} -> "  <li>#{nickname} => #{kills}</li>" end)
      |> Enum.join("\n")

    body = "<ul>\n#{ranking}\n</ul>"

    send_resp(conv, body)
  end
end
