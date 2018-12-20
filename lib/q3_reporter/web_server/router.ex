defmodule Q3Reporter.WebServer.Router do
  alias Q3Reporter.WebServer.{Conv, Controller, RankingController, SummaryController}

  def route(%Conv{method: "GET", path: "/ranking"} = conv, result) do
    RankingController.index(conv, result)
  end

  def route(%Conv{method: "GET", path: "/summary"} = conv, result) do
    SummaryController.index(conv, result)
  end

  def route(%Conv{method: "GET", path: "/"} = conv, _result) do
    Controller.send_redirect(conv, "/ranking")
  end

  def route(conv, _result) do
    Controller.send_resp(conv, 404, "Not Found")
  end
end
