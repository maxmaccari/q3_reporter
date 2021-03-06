defmodule Q3Reporter.WebServer.Controller do
  alias Q3Reporter.WebServer.Conv

  @host "http://localhost:8080/"

  def send_redirect(%Conv{resp_headers: resp_headers} = conv, path) do
    new_path = Path.join(@host, path)
    resp_headers = Map.put(resp_headers, "Location", new_path)

    %{conv | status: 307, resp_headers: resp_headers}
  end

  def send_resp(conv, status, body) do
    %Conv{conv | status: status, body: body}
  end

  def send_resp(conv, body) do
    send_resp(conv, 200, body)
  end

  def render(conv, template, bindings) do
    template = Path.join(templates_path(), "#{template}.html.eex")
    body = EEx.eval_file(template, bindings)

    send_resp(conv, body)
  end

  defp templates_path do
    Path.expand("../../../templates", __DIR__)
  end
end
