defmodule Q3Reporter.WebServer.SummaryController do
  import Q3Reporter.WebServer.Controller

  def index(conv, result) do
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

    send_resp(conv, body)
  end
end
