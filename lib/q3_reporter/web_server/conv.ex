defmodule Q3Reporter.WebServer.Conv do
  defstruct method: nil,
            path: nil,
            body: "",
            status: nil,
            resp_headers: %{}
end
