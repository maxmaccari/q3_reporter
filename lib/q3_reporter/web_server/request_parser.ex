defmodule Q3Reporter.WebServer.RequestParser do
  alias Q3Reporter.WebServer.Conv

  def parse(request) do
    [first_line | _rest] = String.split(request, "\r\n")
    [method, path, _http_version] = String.split(first_line)

    %Conv{method: method, path: path}
  end
end
