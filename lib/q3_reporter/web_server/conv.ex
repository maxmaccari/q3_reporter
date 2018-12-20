defmodule Q3Reporter.WebServer.Conv do
  defstruct method: nil,
            path: nil,
            body: "",
            status: 200,
            resp_headers: %{}
end
