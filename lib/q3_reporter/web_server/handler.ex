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

  defp route(%{method: "GET", path: "/", resp_headers: resp_headers} = conv, _result) do
    resp_headers = Map.put(resp_headers, "Location", "http://localhost:8080/ranking")

    %{conv | status: 301, resp_headers: resp_headers}
  end

  defp route(conv, _result) do
    %{conv | status: 404, body: "Not Found"}
  end

  defp parse_params(request) do
    [first_line | _rest] = String.split(request, "\r\n")
    [method, path, _http_version] = String.split(first_line)

    %{method: method, path: path, body: "", status: 200, resp_headers: %{}}
  end

  defp make_response(%{resp_headers: resp_headers} = conv) do
    headers =
      resp_headers
      |> Enum.map(fn {key, value} -> "#{key}: #{value}\r\n" end)
      |> Enum.join()

    headers = headers <>
      "Content-Type: text/html\r\n" <>
      "Content-Length: #{String.length(conv.body)}\r"

    """
    HTTP/1.1 #{conv.status} #{status_desc(conv.status)}\r
    #{headers}
    \r
    #{conv.body}
    """
  end

  defp status_desc(status) do
    %{
      200 => "OK",
      301 => "Moved Permanently",
      404 => "Not Found"
    }[status]
  end
end
