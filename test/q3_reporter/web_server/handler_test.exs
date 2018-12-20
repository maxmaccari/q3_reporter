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

    assert status(response) == 200

    ["Mocinha => 8", "Dono da Bola => 7", "Isgalamido => 2"]
    |> Enum.each(&assert_contains(response, &1))
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

    assert status(response) == 200

    ["Game 1", "Game 2"]
    |> Enum.each(&assert_contains(response, &1))

    ["Isgalamido: 0 kills / 4 deaths",
    "Dono da Bola: 4 kills / 4 deaths",
    "Mocinha: 9 kills / 0 deaths"]
    |> Enum.each(&assert_contains(response, &1))

    ["Isgalamido: 2 kills / 4 deaths",
    "Dono da Bola: 3 kills / 4 deaths",
    "Mocinha: -1 kills / 5 deaths"]
    |> Enum.each(&assert_contains(response, &1))
  end

  test "GET /" do
    request = """
    GET / HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request, @result)

    assert response == """
           HTTP/1.1 307 Temporary Redirect\r
           Location: http://localhost:8080/ranking\r
           Content-Type: text/html\r
           Content-Length: 0\r
           \r

           """
  end

  test "GET /foo" do
    request = """
    GET /foo HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request, @result)

    assert response == """
           HTTP/1.1 404 Not Found\r
           Content-Type: text/html\r
           Content-Length: 9\r
           \r
           Not Found
           """
  end

  defp status(response) do
    [first_line | _rest] = String.split(response, "\r\n")
    [_version, status, _] = String.split(first_line, " ", parts: 3)

    String.to_integer(status)
  end

  defp assert_contains(string, content) do
    assert String.contains?(string, content), "#{string} does not contais #{content}"
  end
end
