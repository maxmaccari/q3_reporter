defmodule Q3Reporter.WebServer.RankingController do
  alias Q3Reporter.Ranking

  def index(conv, result) do
    ranking =
      result
      |> Ranking.build()
      |> Enum.map(fn {nickname, kills} -> "  <li>#{nickname} => #{kills}</li>" end)
      |> Enum.join("\n")

    body = "<ul>\n#{ranking}\n</ul>"

    %{conv | status: 200, body: body}
  end
end
