defmodule Q3Reporter.WebServer.Router do
  alias Q3Reporter.WebServer.{Conv, RankingController, SummaryController}

  def route(%Conv{method: "GET", path: "/ranking"} = conv, result) do
    RankingController.index(conv, result)
  end

  def route(%Conv{method: "GET", path: "/summary"} = conv, result) do
    SummaryController.index(conv, result)
  end

  def route(%Conv{method: "GET", path: "/", resp_headers: resp_headers} = conv, _result) do
    resp_headers = Map.put(resp_headers, "Location", "http://localhost:8080/ranking")

    %{conv | status: 301, resp_headers: resp_headers}
  end

  def route(conv, _result) do
    %{conv | status: 404, body: "Not Found"}
  end
end
