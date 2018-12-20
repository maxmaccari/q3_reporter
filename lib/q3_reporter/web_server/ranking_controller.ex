defmodule Q3Reporter.WebServer.RankingController do
  alias Q3Reporter.Ranking

  import Q3Reporter.WebServer.Controller

  def index(conv, result) do
    ranking = Ranking.build(result)

    body = EEx.eval_file("templates/ranking_index.html.eex", ranking: ranking)

    send_resp(conv, body)
  end
end
