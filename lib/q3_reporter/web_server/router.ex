defmodule Q3Reporter.WebServer.Router do
  alias Q3Reporter.Ranking
  alias Q3Reporter.WebServer.Conv

  def route(%Conv{method: "GET", path: "/ranking"} = conv, result) do
    ranking =
      result
      |> Ranking.build()
      |> Enum.map(fn {nickname, kills} -> "  <li>#{nickname} => #{kills}</li>" end)
      |> Enum.join("\n")

    body = "<ul>\n#{ranking}\n</ul>"

    %{conv | body: body}
  end

  def route(%Conv{method: "GET", path: "/summary"} = conv, result) do
    games =
      result
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {game, id} ->
        players =
          game.players
          |> Enum.map(fn player ->
            "  <li>#{player.nickname}: #{player.kills} kills / #{player.deaths} deaths</li>"
          end)
          |> Enum.join("\n    ")

        """
          <li>
            <h3>Game #{id}</h3>
            <p>Total Kills: #{game.total_kills}</p>
            <ul>
            #{players}
            </ul>
          </li>
        """
      end)
      |> Enum.reverse()
      |> Enum.join("")

    body = "<ul>\n#{games}</ul>"

    %{conv | body: body}
  end

  def route(%Conv{method: "GET", path: "/", resp_headers: resp_headers} = conv, _result) do
    resp_headers = Map.put(resp_headers, "Location", "http://localhost:8080/ranking")

    %{conv | status: 301, resp_headers: resp_headers}
  end

  def route(conv, _result) do
    %{conv | status: 404, body: "Not Found"}
  end
end
