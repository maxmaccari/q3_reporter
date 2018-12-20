defmodule Q3Reporter.WebServer.Handler do
  alias Q3Reporter.WebServer.{Conv, Router, RequestParser}

  def handle(request, result) do
    request
    |> RequestParser.parse()
    |> Router.route(result)
    |> make_response()
  end

  defp make_response(%Conv{resp_headers: resp_headers} = conv) do
    headers =
      resp_headers
      |> Enum.map(fn {key, value} -> "#{key}: #{value}\r\n" end)
      |> Enum.join()

    headers =
      headers <> "Content-Type: text/html\r\n" <> "Content-Length: #{String.length(conv.body)}\r"

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
