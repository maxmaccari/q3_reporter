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

  test "GET /ranking" do
    request = """
    GET /ranking HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request, @result)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 90\r
    \r
    <ul>
      <li>Mocinha => 8</li>
      <li>Dono da Bola => 7</li>
      <li>Isgalamido => 2</li>
    </ul>
    """
  end

  test "GET /summary" do
    request = """
    GET /summary HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request, @result)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 446\r
    \r
    <ul>
      <li>
        <h3>Game 2</h3>
        <p>Total Kills: 12</p>
        <ul>
          <li>Isgalamido: 0 kills / 4 deaths</li>
          <li>Dono da Bola: 4 kills / 4 deaths</li>
          <li>Mocinha: 9 kills / 0 deaths</li>
        </ul>
      </li>
      <li>
        <h3>Game 1</h3>
        <p>Total Kills: 4</p>
        <ul>
          <li>Isgalamido: 2 kills / 4 deaths</li>
          <li>Dono da Bola: 3 kills / 4 deaths</li>
          <li>Mocinha: -1 kills / 5 deaths</li>
        </ul>
      </li>
    </ul>
    """
  end
end
