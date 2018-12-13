defmodule Q3Reporter.WebServer.HandlerTest do
  use ExUnit.Case

  alias Q3Reporter.WebServer.Handler
  alias Q3Reporter.Parser.Game

  @result [
    %Game{
      total_kills: 12,
      players: [
        %{
          id: "2",
          nickname: "Isgalamido",
          kills: 0,
          deaths: 4
        },
        %{
          id: "4",
          nickname: "Dono da Bola",
          kills: 4,
          deaths: 4
        },
        %{
          id: "6",
          nickname: "Mocinha",
          kills: 9,
          deaths: 0
        }
      ]
    },

    %Game{
      total_kills: 4,
      players: [
        %{
          id: "2",
          nickname: "Isgalamido",
          kills: 2,
          deaths: 4
        },
        %{
          id: "4",
          nickname: "Dono da Bola",
          kills: 3,
          deaths: 4
        },
        %{
          id: "6",
          nickname: "Mocinha",
          kills: -1,
          deaths: 5
        }
      ]
    }
  ]

  test "GET /root" do
    request = """
    GET / HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request, @result)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 79\r
    \r
    <ul>
      <li>Mocinha => 8</li>
      <li>Dono da Bola => 7</li>
      <li>Isgalamido => 2</li>
    </ul>
    """
  end
end
