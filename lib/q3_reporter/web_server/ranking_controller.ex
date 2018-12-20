defmodule Q3Reporter.WebServer.RankingController do
  alias Q3Reporter.Ranking

  import Q3Reporter.WebServer.Controller

  def index(conv, result) do
    render(conv, "ranking_index", ranking: Ranking.build(result))
  end
end
