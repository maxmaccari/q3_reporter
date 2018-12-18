defmodule Q3Reporter.WebServer.Handler do
  alias Q3Reporter.Ranking
  def handle(request, result) do
    request
    |> parse_params
    |> route(result)
    |> make_response
  end

  defp route(%{method: "GET", path: "/ranking"} = conv, result) do
    ranking =
      result
      |> Ranking.build()
      |> Enum.map(fn {nickname, kills} -> "  <li>#{nickname} => #{kills}</li>" end)
      |> Enum.join("\n")

    body = "<ul>\n#{ranking}\n</ul>"

    %{conv | body: body}
  end

  defp route(%{method: "GET", path: "/summary"} = conv, result) do
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

  defp route(conv, _result) do
    conv
  end

  defp parse_params(request) do
    [first_line | _rest] = String.split(request, "\r\n")
    [method, path, _http_version] = String.split(first_line)

    %{method: method, path: path, body: ""}
  end

  defp make_response(conv) do
    """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: #{String.length(conv.body)}\r
    \r
    #{conv.body}
    """
  end
end
